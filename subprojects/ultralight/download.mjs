import ora from 'ora'
import seven from 'node-7z'

import https from 'https'
import os from 'os'
import fs from 'fs'
import path from 'path'
import url from 'url'

const __filename = url.fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const SDK_ROOT = path.join(__dirname, 'SDK')
const ULTRALIGHT_INCLUDE_DIR = path.join(SDK_ROOT, 'include')
const ULTRALIGHT_BINARY_DIR = path.join(SDK_ROOT, 'bin')
const ULTRALIGHT_INSPECTOR_DIR = path.join(SDK_ROOT, 'inspector')

let port
let platform
let ULTRALIGHT_LIBRARY_DIR = path.join(SDK_ROOT, 'bin')

const osPlatform = os.type()
if (osPlatform === 'Linux') {
  port = 'UltralightLinux'
  platform = 'linux'
} else if (osPlatform === 'Darwin') {
  port = 'UltralightMac'
  platform = 'mac'
} else if (osPlatform === 'Windows_NT') {
  port = 'UltralightWin'
  platform = 'win'
  ULTRALIGHT_LIBRARY_DIR = `${SDK_ROOT}/lib`
} else {
  console.error(`Unknown OS ${osPlatform}`)
  process.exit(1)
}

const architecture = process.arch === 'x64' ? 'x64' : 'x86'

const S3_DOMAIN = '.sfo2.cdn.digitaloceanspaces.com'

// Ultralight SDK

const sdkArchiveUrl = `https://ultralight-sdk${S3_DOMAIN}/ultralight-sdk-latest-${platform}-${architecture}.7z`
const destination = SDK_ROOT

let spinner = ora('Downloading Ultralight SDK...').start()

const archivePath = path.join(__dirname, `ultralight-sdk-latest-${platform}-${architecture}.7z`)
console.log(archivePath)
if (fs.existsSync(archivePath)) {
  fs.unlinkSync(archivePath)
}
const file = fs.createWriteStream(archivePath)
const request = https.get(sdkArchiveUrl, (response) => {
  if (response.statusCode === 200) {
    const len = parseInt(response.headers['content-length'], 10)
    let downloaded = 0
    const total = len / 1048576

    response.pipe(file)

    response.on('data', (chunk) => {
      downloaded += chunk.length
      spinner.text = `Downloading Ultralight SDK... ${(100.0 * downloaded / len).toFixed(0)}% (${(downloaded / 1048576).toFixed(2)} MB of ${total.toFixed(2)} MB)`
    })

    response.on('end', () => {
      spinner.succeed('Downloaded Ultralight SDK')
      spinner = ora('Deflating...').start()

      const stream = seven.extractFull(archivePath, destination, {
        $progress: true
      })
      stream.on('progress', function (progress) {
        spinner.text = `Deflating... ${progress.percent}%`
      })

      stream.on('end', function () {
        spinner.succeed(`Deflated Ultralight SDK to ${destination}`)
        process.exit(0)
      })
      stream.on('error', (err) => {
        spinner.fail(`Could not deflate Ultralight SDK archive! (${err.message})`)
        process.exit(1)
      })
    })
  } else {
    request.destroy()
    spinner.fail(`Could not download Ultralight SDK! (${response.statusCode})`)
    process.exit(1)
  }
})
