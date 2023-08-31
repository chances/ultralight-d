import std.stdio;
import ultralight;

// See https://github.com/ultralight-ux/Ultralight/blob/master/samples/Sample%201%20-%20Render%20to%20PNG/C-API/main.c

///
static bool done = false;

void main() {
  // We must provide our own Platform API handlers since we're not using ulCreateApp().
  //
  // `FileSystem` and `FontLoader` Platform API handlers are required.
  //
  // You can replace these with your own implementations.
  Platform.enablePlatformFontLoader();
  Platform.enablePlatformFileSystem("./");

  // TODO: Enable default logger
  // Platform.enableDefaultLogger("./ultralight.log");

  // Create a renderer using Ultralight's default configuration.
  //
  // The renderer instance should outlive any Views.
  auto renderer = new Renderer();

  // Create a view.
  // 
  // Views are sized containers for loading and displaying web content.
  //
  // Let's set a 2x DPI scale and disable GPU acceleration so we can render to a bitmap.
  auto viewConfig = ViewConfig();
  viewConfig.initialDeviceScale = 2.0;
  viewConfig.isAccelerated = false;
  auto view = renderer.createView(800, 600, viewConfig, null);
  delete viewConfig;

  // Register onFinishLoading() callback with the view.
  view.setFinishLoadingCallback(&onFinishLoading, null);

  // Load a local HTML file into the View (uses the file system defined above).
  view.loadUrl("file:///page.html");

  writeln("Waiting for page to load...");

  // Continuously update until onFinishLoading() is called below (which sets done = true).
  do {
    renderer.update();
  } while (!done);

  // Render the View.
  // Note: Calling render() will render any dirty Views to their respective Surfaces.
  renderer.render();

  // Get the View's rendering surface's underlying bitmap.
  auto bitmap = view.surface.bitmap;

  // Write our bitmap to a PNG in the current working directory.
  bitmap.writePng("result.png");

  writeln("Saved a render of page to result.png");
}

///
extern(C) void onFinishLoading(void* userData, ULView caller, ulong frameId, bool isMainFrame, ULString url) {
  assert(caller !is null);
  assert(frameId);
  assert(url);

  // Page is done when the main frame is finished loading.
  if (!isMainFrame) return;

  writeln("Page has loaded!");
  done = true;
}
