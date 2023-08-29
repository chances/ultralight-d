/// License: MIT
module ultralight;

import std.conv: to;
import std.string: fromStringz, toStringz;

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

/// Convert a `string` to an Ultralight `String`.
String toUlString(string str) {
  return new String(str);
}

/// Convert an unmanaged Ultralight string directly to a managed `string`.
/// Remarks: This makes a copy of the unmanaged string.
string toString(ULString str) {
  return ulStringGetData(str)[0 .. ulStringGetLength(str)].to!string.idup;
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

  /// Create a Session to store local data in (such as cookies, local storage, application cache, indexed db, etc).
  Session createSession(bool isPersistent, string name) {
    return this.createSession(isPersistent, name.toUlString);
  }
  /// ditto
  Session createSession(bool isPersistent, String name) {
    return new Session(ulCreateSession(ptr, isPersistent, name.ptr));
  }

  /// Get the default session (persistent session named "default").
  static Session defaultSession() {
    assert(renderer && renderer.ptr);
    return new Session(ulDefaultSession(renderer.ptr));
  }

  /// Update timers and dispatch internal callbacks (JavaScript and network).
  void update() {
    ulUpdate(ptr);
  }

  /// Render all active Views.
  void render() {
    ulRender(ptr);
  }

  /// Attempt to release as much memory as possible.
  void purgeMemory() {
    ulPurgeMemory(ptr);
  }

  /// Print detailed memory usage statistics to the log.
  void logMemoryUsage() {
    ulLogMemoryUsage(ptr);
  }

  /// Start the remote inspector server.
  bool startRemoteInspectorServer(string address, ushort port) {
    return ulStartRemoteInspectorServer(ptr, address.toStringz, port);
  }

  /// Describe the details of a gamepad, to be used with `ulFireGamepadEvent` and related events below.
  void setGamepadDetails(uint index, string id, uint axis_count, uint button_count) {
    ulSetGamepadDetails(ptr, index, cast(C_String*) id.toStringz, axis_count, button_count);
  }

  /// Fire a gamepad event (connection / disconnection).
  void fireGamepadEvent(ULGamepadEvent evt) {
    ulFireGamepadEvent(ptr, evt);
  }

  /// Fire a gamepad axis event (to be called when an axis value is changed).
  void fireGamepadAxisEvent(ULGamepadAxisEvent evt) {
    ulFireGamepadAxisEvent(ptr, evt);
  }

  /// Fire a gamepad button event (to be called when a button value is changed).
  void fireGamepadButtonEvent(ULGamepadButtonEvent evt) {
    ulFireGamepadButtonEvent(ptr, evt);
  }
}

/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___platform_8h.html
class Platform {
  /// Set a custom Logger implementation.
  static void setLogger(ULLogger logger) {
    ulPlatformSetLogger(logger);
  }

  /// Set a custom FileSystem implementation.
  static void setFileSystem(ULFileSystem file_system) {
    ulPlatformSetFileSystem(file_system);
  }

  /// Set a custom Surface implementation.
  static void setSurfaceDefinition(ULSurfaceDefinition surface_definition) {
    ulPlatformSetSurfaceDefinition(surface_definition);
  }

  /// Set a custom GPUDriver implementation.
  static void setGPUDriver(ULGPUDriver gpu_driver) {
    ulPlatformSetGPUDriver(gpu_driver);
  }

  /// Set a custom Clipboard implementation.
  static void setClipboard(ULClipboard clipboard) {
    ulPlatformSetClipboard(clipboard);
  }
}

/// See_Also: `Renderer.createSession`
/// See_Also: `Renderer.defaultSession`
/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___session_8h.html
class Session {
  ULSession ptr;

  package this(ULSession ptr) {
    assert(ptr);
    this.ptr = ptr;
  }
  /// Destroy a Session.
  ~this() {
    ulDestroySession(ptr);
  }

  /// Whether or not is persistent (backed to disk).
  bool isPersistent() {
    return ulSessionIsPersistent(ptr);
  }

  /// Unique name identifying the session (used for unique disk path).
  string name() {
    return ulSessionGetName(ptr).toString;
  }

  /// Unique numeric ID for the session.
  ulong getId() {
    return ulSessionGetId(ptr);
  }

  /// The disk path to write to (used by persistent sessions only).
  string getDiskPath() {
    return ulSessionGetDiskPath(ptr).toString;
  }
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

  /// Lock pixels for reading/writing.
  /// Returns: Slice of pixel buffer.
  ubyte[] lockPixels() {
    return cast(ubyte[]) ulBitmapLockPixels(ptr)[0 .. this.size];
  }

  /// Unlock pixels after locking.
  void unlockPixels() {
    ulBitmapUnlockPixels(ptr);
  }

  /// Get raw pixel buffer.
  ///
  /// You should only call this if Bitmap is already locked.
  ubyte[] rawPixels() {
    return cast(ubyte[]) ulBitmapRawPixels(ptr)[0 .. this.size];
  }

  /// Whether or not this bitmap is empty.
  bool isEmpty() {
    return ulBitmapIsEmpty(ptr);
  }

  /// Reset bitmap pixels to 0.
  void erase() {
    ulBitmapErase(ptr);
  }

  /// Write bitmap to a PNG on disk.
  bool writePng(string path) {
    return ulBitmapWritePNG(ptr, path.toStringz);
  }

  /// Converts a BGRA bitmap to RGBA bitmap and vice-versa by swapping the red and blue channels.
  void swapRedBlueChannels() {
    ulBitmapSwapRedBlueChannels(ptr);
  }
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
