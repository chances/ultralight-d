/// License: MIT
module ultralight;

import std.conv: to;
import std.string: fromStringz;

import ultralight.bindings;

/// Get the version string of the library in MAJOR.MINOR.PATCH format.
/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___defines_8h.html
string version_() {
  return ulVersionString().fromStringz.to!string;
}

/// Get the numeric major version of the library.
/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___defines_8h.html
uint versionMajor() {
  return ulVersionMajor();
}

/// Get the numeric minor version of the library.
/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___defines_8h.html
uint versionMinor() {
  return ulVersionMinor();
}

/// Get the numeric patch version of the library.
/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___defines_8h.html
uint versionPatch() {
  return ulVersionPatch();
}

/// Get the full WebKit version string.
/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___defines_8h.html
string webKitVersion() {
  return ulWebKitVersionString().fromStringz.to!string;
}

///
Config config;
///
Renderer renderer;
/// Global platform singleton, manages user-defined platform handlers.
Platform platform;

/// Create the `Renderer` singleton.
static this() {
  renderer = new Renderer();
  platform = new Platform();
}

/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___string_8h.html
class String {
  import std.string: toStringz;

  ///
  ULString ptr;

  package this(ULString str) {
    assert(str);
    ptr = str;
  }
  /// Create string from a D string.
  this(string source) {
    ptr = ulCreateString(source.toStringz);
  }
  /// Destroy string (you should destroy any strings you explicitly Create).
  ~this() {
    assert(ptr);
    ulDestroyString(ptr);
    ptr = null;
  }

  /// Create string from a UTF-8 buffer.
  String utf8(string str) {
    return new String(ulCreateStringUTF8(str.ptr, str.length));
  }

  /// Create string from a UTF-16 buffer.
  String utf16(wstring str) {
    return new String(ulCreateStringUTF16(cast(ushort*) str.ptr, str.length));
  }

  /// Create string from copy of this string.
  String idup() {
    return new String(ulCreateStringFromCopy(ptr));
  }

  /// Whether this string is empty or not.
  bool empty() const {
    return ulStringIsEmpty(cast(C_String*) ptr);
  }

  /// Replaces the contents of this string with the contents of a string.
  auto opAssign(T)(string str) {
    ulStringAssignCString(ptr, str.toStringz);
    return this;
  }

  /// Replaces the contents of this string with the contents of `str`.
  auto opAssign(T)(String str) {
    ulStringAssignString(ptr, str.ptr);
    return this;
  }

  /// Replaces the contents of this string with the contents of `str`.
  auto opAssign(T)(ULString str) {
    ulStringAssignString(ptr, str);
    return this;
  }

  ///
  override string toString() const @trusted nothrow {
    import std.exception : assumeWontThrow;

    return assumeWontThrow(
      ulStringGetData(cast(C_String*) ptr)[0 .. ulStringGetLength(cast(C_String*) ptr)].to!string
    );
  }
}

/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___config_8h.html
struct Config {
  ///
  ULConfig ptr;

  package this(ULConfig ptr) {
    this.ptr = ptr is null ? ulCreateConfig() : ptr;
  }

  ~this() {
    assert(ptr);
    ulDestroyConfig(ptr);
    ptr = null;
  }
}

/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___renderer_8h.html
class Renderer {
  ///
  ULRenderer ptr;

  package this() {
    ptr = ulCreateRenderer(config.ptr);
  }

  ~this() {
    ulDestroyRenderer(ptr);
  }

  // TODO: Bind to the following methods.

  /// Update timers and dispatch internal callbacks (JavaScript and network).
  void ulUpdate(ULRenderer renderer);

  /// Render all active Views.
  void ulRender(ULRenderer renderer);

  /// Attempt to release as much memory as possible.
  void ulPurgeMemory(ULRenderer renderer);

  /// Print detailed memory usage statistics to the log.
  void ulLogMemoryUsage(ULRenderer renderer);

  /// Start the remote inspector server.
  bool ulStartRemoteInspectorServer(ULRenderer renderer, const char* address, ushort port);

  /// Describe the details of a gamepad, to be used with `ulFireGamepadEvent` and related events below.
  void ulSetGamepadDetails(ULRenderer renderer, uint index, ULString id, uint axis_count, uint button_count);

  /// Fire a gamepad event (connection / disconnection).
  void ulFireGamepadEvent(ULRenderer renderer, ULGamepadEvent evt);

  /// Fire a gamepad axis event (to be called when an axis value is changed).
  void ulFireGamepadAxisEvent(ULRenderer renderer, ULGamepadAxisEvent evt);

  /// Fire a gamepad button event (to be called when a button value is changed).
  void ulFireGamepadButtonEvent(ULRenderer renderer, ULGamepadButtonEvent evt);
}

/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___platform_8h.html
class Platform {
  // TODO: Bind to the following methods.

  /// Set a custom Logger implementation.
  void ulPlatformSetLogger(ULLogger logger);

  /// Set a custom FileSystem implementation.
  void ulPlatformSetFileSystem(ULFileSystem file_system);

  /// Set a custom FontLoader implementation.
  void ulPlatformSetFontLoader(ULFontLoader font_loader);

  /// Set a custom Surface implementation.
  void ulPlatformSetSurfaceDefinition(ULSurfaceDefinition surface_definition);

  /// Set a custom GPUDriver implementation.
  void ulPlatformSetGPUDriver(ULGPUDriver gpu_driver);

  /// Set a custom Clipboard implementation.
  void ulPlatformSetClipboard(ULClipboard clipboard);
}

/// View is a web-page container rendered to an offscreen surface that you display yourself.
///
/// The View object is responsible for loading and rendering web-pages to an offscreen surface.
/// It is completely isolated from the OS windowing system, you must forward all input events to it from your application.
///
/// Remarks: The API is not thread-safe, all calls must be made on the same thread that the Renderer/App was created on.
/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___view_8h.html
class View {
}

/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___surface_8h.html
class Surface {
}

/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___defines_8h.html#af81b997faeeb522a0cb41000e0c3f89d
enum BitmapFormat {
  a8_unorm = kBitmapFormat_A8_UNORM,
  bgra8_unorm_srgb = kBitmapFormat_BGRA8_UNORM_SRGB
}

/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___bitmap_8h.html
class Bitmap {
  ///
  ULBitmap ptr;
  private bool owned = true;

  /// Create empty bitmap.
  this() {
    this(ulCreateEmptyBitmap());
  }
  /// Create bitmap with certain dimensions and pixel format.
  this(uint width, uint height, BitmapFormat format) {
    this(ulCreateBitmap(width, height, format));
  }
  ///
  package this(ULBitmap ptr) {
    assert(ptr);
    this.ptr = ptr;
    this.owned = this.ownsPixels;
  }
  /// Destroy a bitmap.
  /// Remarks: You should only destroy Bitmaps you have explicitly created via one of the creation functions above.
  ~this() {
    if (owned)
      ulDestroyBitmap(ptr);
  }

  /// Create bitmap from existing pixel buffer.
  static Bitmap fromPixels(
    uint width, uint height, BitmapFormat format, uint row_bytes, ubyte[] pixels, bool should_copy = true
  ) {
    return new Bitmap(
      ulCreateBitmapFromPixels(width, height, format, row_bytes, pixels.ptr, pixels.length, should_copy)
    );
  }

  /// Create bitmap from copy.
  static Bitmap fromCopy(Bitmap existingBitmap) {
    return new Bitmap(ulCreateBitmapFromCopy(existingBitmap.ptr));
  }

  /// Get the width in pixels.
  uint width() const {
    return ulBitmapGetWidth(cast(C_Bitmap*) ptr);
  }

  /// Get the height in pixels.
  uint height() const {
    return ulBitmapGetHeight(cast(C_Bitmap*) ptr);
  }

  /// Get the pixel format.
  BitmapFormat format() const {
    return ulBitmapGetFormat(cast(C_Bitmap*) ptr).to!uint.to!BitmapFormat;
  }

  /// Get the bytes per pixel.
  uint bpp() const {
    return ulBitmapGetBpp(cast(C_Bitmap*) ptr);
  }

  /// Get the number of bytes per row.
  uint rowBytes() const {
    return ulBitmapGetRowBytes(cast(C_Bitmap*) ptr);
  }

  /// Get the size in bytes of the underlying pixel buffer.
  size_t size() const {
    return ulBitmapGetSize(cast(C_Bitmap*) ptr);
  }

  /// Whether or not this bitmap owns its own pixel buffer.
  bool ownsPixels() const {
    return ulBitmapOwnsPixels(cast(C_Bitmap*) ptr);
  }

  // TODO: Bind to the following methods.

  /// Lock pixels for reading/writing, returns pointer to pixel buffer.
  void* ulBitmapLockPixels(ULBitmap bitmap);

  /// Unlock pixels after locking.
  void ulBitmapUnlockPixels(ULBitmap bitmap);

  /// Get raw pixel buffer– you should only call this if Bitmap is already locked.
  void* ulBitmapRawPixels(ULBitmap bitmap);

  /// Whether or not this bitmap is empty.
  bool ulBitmapIsEmpty(ULBitmap bitmap);

  /// Reset bitmap pixels to 0.
  void ulBitmapErase(ULBitmap bitmap);

  /// Write bitmap to a PNG on disk.
  bool ulBitmapWritePNG(ULBitmap bitmap, const char* path);

  /// This converts a BGRA bitmap to RGBA bitmap and vice-versa by swapping the red and blue channels.
  void ulBitmapSwapRedBlueChannels(ULBitmap bitmap);
}

/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___session_8h.html
class Session {
  // TODO: Bind to the following methods.

  /// Create a Session to store local data in (such as cookies, local storage, application cache, indexed db, etc).
  ULSession ulCreateSession(ULRenderer renderer, bool is_persistent, ULString name);

  /// Destroy a Session.
  void ulDestroySession(ULSession session);

  /// Get the default session (persistent session named "default").
  ULSession ulDefaultSession(ULRenderer renderer);

  /// Whether or not is persistent (backed to disk).
  bool ulSessionIsPersistent(ULSession session);

  /// Unique name identifying the session (used for unique disk path).
  ULString ulSessionGetName(ULSession session);

  /// Unique numeric Id for the session.
  ulong ulSessionGetId(ULSession session);

  /// The disk path to write to (used by persistent sessions only).
  ULString ulSessionGetDiskPath(ULSession session);
}

/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___mouse_event_8h.html
class MouseEvent {
  ///
  ULMouseEvent ptr;

  /// Create a mouse event.
  this() {
  }

  ~this() {
    assert(ptr);
    ulDestroyMouseEvent(ptr);
    ptr = null;
  }
}

/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___key_event_8h.html
class KeyEvent {
  ///
  ULKeyEvent ptr;

  /// Create a key event.
  this() {
  }

  ~this() {
    assert(ptr);
    ulDestroyKeyEvent(ptr);
    ptr = null;
  }
}

/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___scroll_event_8h.html
class ScrollEvent {
  ///
  ULScrollEvent ptr;

  /// Create a scroll event.
  this() {
  }

  ~this() {
    assert(ptr);
    ulDestroyScrollEvent(ptr);
    ptr = null;
  }
}

/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___gamepad_event_8h.html
class GamepadEvent {
  ///
  ULGamepadEvent ptr;

  /// Create a gamepad event.
  this() {
  }

  ~this() {
    assert(ptr);
    ulDestroyGamepadEvent(ptr);
    ptr = null;
  }
}
