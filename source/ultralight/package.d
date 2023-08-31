/// License: MIT
module ultralight;

import std.conv: to;
import std.functional: toDelegate;
import std.string: fromStringz, toStringz;
import std.typecons: Flag, No, Yes;

import ultralight.bindings;
public import ultralight.callbacks;
public import ultralight.enums;

/// Global configuration singleton, manages user-defined configuration.
static Config config;

/// Create the `Renderer` singleton.
static this() {
  config = Config(ulCreateConfig());
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

  ~this() {
    assert(ptr);
    ulDestroyConfig(ptr);
    ptr = null;
  }

  /// A writable OS file path to store persistent Session data in.
  static void setCachePath(string cachePath) {
    ulConfigSetCachePath(config.ptr, cachePath.toUlString.ptr);
  }

  /// The relative path to the resources folder (loaded via the FileSystem API).
  static void setResourcePathPrefix(string resourcePathPrefix) {
    ulConfigSetResourcePathPrefix(config.ptr, resourcePathPrefix.toUlString.ptr);
  }

  /// The winding order for front-facing triangles.
  static void setFaceWinding(FaceWinding winding) {
    ulConfigSetFaceWinding(config.ptr, winding);
  }

  /// The hinting algorithm to use when rendering fonts.
  static void setFontHinting(FontHinting fontHinting) {
    ulConfigSetFontHinting(config.ptr, fontHinting);
  }

  /// The gamma to use when compositing font glyphs, change this value to adjust contrast (Adobe and Apple prefer 1.8, others may prefer 2.2).
  static void setFontGamma(double fontGamma) {
    ulConfigSetFontGamma(config.ptr, fontGamma);
  }

  /// Global user-defined CSS string (included before any CSS on the page).
  static void setUserStylesheet(string cssString) {
    ulConfigSetUserStylesheet(config.ptr, cssString.toUlString.ptr);
  }

  /// Whether or not to continuously repaint any Views, regardless if they are dirty.
  static void setForceRepaint(bool enabled) {
    ulConfigSetForceRepaint(config.ptr, enabled);
  }

  /// The delay (in seconds) between every tick of a CSS animation.
  static void setAnimationTimerDelay(double delay) {
    ulConfigSetAnimationTimerDelay(config.ptr, delay);
  }

  /// The delay (in seconds) between every tick of a smooth scroll animation.
  static void setScrollTimerDelay(double delay) {
    ulConfigSetScrollTimerDelay(config.ptr, delay);
  }

  /// The delay (in seconds) between every call to the recycler.
  static void setRecycleDelay(double delay) {
    ulConfigSetRecycleDelay(config.ptr, delay);
  }

  /// The size of WebCore's memory cache in bytes.
  static void setMemoryCacheSize(uint size) {
    ulConfigSetMemoryCacheSize(config.ptr, size);
  }

  /// The number of pages to keep in the cache.
  static void setPageCacheSize(uint size) {
    ulConfigSetPageCacheSize(config.ptr, size);
  }

  /// The system's physical RAM size in bytes.
  static void setOverrideRAMSize(uint size) {
    ulConfigSetOverrideRAMSize(config.ptr, size);
  }

  /// The minimum size of large VM heaps in JavaScriptCore.
  static void setMinLargeHeapSize(uint size) {
    ulConfigSetMinLargeHeapSize(config.ptr, size);
  }

  /// The minimum size of small VM heaps in JavaScriptCore.
  static void setMinSmallHeapSize(uint size) {
    ulConfigSetMinSmallHeapSize(config.ptr, size);
  }

  /// The number of threads to use in the Renderer (for parallel painting on the CPU, etc.).
  static void setNumRendererThreads(uint numRendererThreads) {
    ulConfigSetNumRendererThreads(config.ptr, numRendererThreads);
  }

  /// The max amount of time (in seconds) to allow repeating timers to run during each call to `Renderer.update`.
  static void setMaxUpdateTime(double maxUpdateTime) {
    ulConfigSetMaxUpdateTime(config.ptr, maxUpdateTime);
  }

  /// The alignment (in bytes) of the BitmapSurface when using the CPU renderer.
  static void setBitmapAlignment(uint bitmapAlignment) {
    ulConfigSetBitmapAlignment(config.ptr, bitmapAlignment);
  }
}

/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___renderer_8h.html
class Renderer {
  ///
  ULRenderer ptr;

  /// Create a new renderer given Ultralight's default configuration.
  this() {
    this(config);
  }
  /// Create a new renderer.
  this(Config config) {
    assert(config.ptr);
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
  Session defaultSession() {
    return new Session(ulDefaultSession(ptr));
  }

  ///
  View createView(uint width, uint height, ViewConfig viewConfig, Session session = null) {
    return new View(ulCreateView(ptr, width, height, viewConfig.ptr, session.ptr));
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

/// Global platform singleton, manages user-defined platform handlers.
/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___platform_8h.html
class Platform {
  ///
  static void enablePlatformFontLoader() {
    ulEnablePlatformFontLoader();
  }

  ///
  static void enablePlatformFileSystem(string baseDir) {
    ulEnablePlatformFileSystem(baseDir.toUlString.ptr);
  }

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
  ///
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

/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___view_8h.html
class ViewConfig {
  ///
  ULViewConfig ptr;

  /// Create view configuration with default values.
  /// See_Also: Ultralight/platform/View.h
  this() {
    ptr = ulCreateViewConfig();
  }
  ~this() {
    assert(ptr);
    ulDestroyViewConfig(ptr);
    ptr = null;
  }

  /// Whether to render using the GPU renderer (accelerated) or the CPU renderer (unaccelerated).
  void isAccelerated(bool value) {
    ulViewConfigSetIsAccelerated(ptr, value);
  }

  /// Set whether images should be enabled (Default = True).
  void isTransparent(bool isTransparent) {
    ulViewConfigSetIsTransparent(ptr, isTransparent);
  }

  /// The initial device scale.
  ///
  /// The amount to scale page units to screen pixels. This should be set to the scaling factor of the device that the View is displayed on. (Default = 1.0)
  void initialDeviceScale(double value) {
    ulViewConfigSetInitialDeviceScale(ptr, value);
  }

  /// Whether or not the View should initially have input focus.
  void initialFocus(bool isFocused) {
    ulViewConfigSetInitialFocus(ptr, isFocused);
  }

  /// Set whether images should be enabled (Default = True).
  void enableImages(bool enabled) {
    ulViewConfigSetEnableImages(ptr, enabled);
  }

  /// Set whether JavaScript should be enabled (Default = True).
  void enableJavaScript(bool enabled) {
    ulViewConfigSetEnableJavaScript(ptr, enabled);
  }

  /// Set default font-family to use (Default = Times New Roman).
  void fontFamilyStandard(string fontName) {
    this.fontFamilyStandard(fontName.toUlString);
  }
  /// ditto
  void fontFamilyStandard(String fontName) {
    ulViewConfigSetFontFamilyStandard(ptr, fontName.ptr);
  }

  /// Set default font-family to use for fixed fonts, eg.
  void fontFamilyFixed(string fontName) {
    this.fontFamilyFixed(fontName.toUlString);
  }
  /// ditto
  void fontFamilyFixed(String fontName) {
    ulViewConfigSetFontFamilyFixed(ptr, fontName.ptr);
  }

  /// Set default font-family to use for serif fonts (Default = Times New Roman).
  void fontFamilySerif(string fontName) {
    this.fontFamilySerif(fontName.toUlString);
  }
  /// ditto
  void fontFamilySerif(String fontName) {
    ulViewConfigSetFontFamilySerif(ptr, fontName.ptr);
  }

  /// Set default font-family to use for sans-serif fonts (Default = Arial).
  void fontFamilySansSerif(string fontName) {
    this.fontFamilySansSerif(fontName.toUlString);
  }
  /// ditto
  void fontFamilySansSerif(String fontName) {
    ulViewConfigSetFontFamilySansSerif(ptr, fontName.ptr);
  }

  /// Set user agent string (See <Ultralight/platform/Config.h> for the default).
  void userAgent(string agentString) {
    this.userAgent(agentString.toUlString);
  }
  /// ditto
  void userAgent(String agentString) {
    ulViewConfigSetUserAgent(ptr, agentString.ptr);
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
  ///
  ULView ptr;
  /// Whether this view is managed.
  bool owned;

  package this(ULView view, Flag!"owned" owned = Yes.owned) {
    this.ptr = view;
    this.owned = owned;
  }
  ~this() {
    assert(ptr);
    if (owned) ulDestroyView(ptr);
    ptr = null;
  }

  /// Get current URL.
  string url() {
    return ulViewGetURL(ptr).toString;
  }

  /// Get current title.
  string title() {
    return ulViewGetTitle(ptr).toString;
  }

  /// Get the width, in pixels.
  uint width() {
    return ulViewGetWidth(ptr);
  }

  /// Get the height, in pixels.
  uint height() {
    return ulViewGetHeight(ptr);
  }

  /// Get the device scale.
  double deviceScale() {
    return ulViewGetDeviceScale(ptr);
  }

  /// Set the device scale.
  void deviceScale(double scale) {
    ulViewSetDeviceScale(ptr, scale);
  }

  /// Whether or not the View is GPU-accelerated.
  bool isAccelerated() {
    return ulViewIsAccelerated(ptr);
  }

  /// Whether or not the View supports transparent backgrounds.
  bool isTransparent() {
    return ulViewIsTransparent(ptr);
  }

  /// Check if the main frame of the page is currently loading.
  bool isLoading() {
    return ulViewIsLoading(ptr);
  }

  /// Get the RenderTarget for the View.
  ULRenderTarget renderTarget() {
    // TODO: Wrap `RenderTarget` for D.
    return ulViewGetRenderTarget(ptr);
  }

  /// Get the Surface for the View (native pixel buffer that the CPU renderer draws into).
  Surface surface() {
    import std.typecons: No;

    return new Surface(ulViewGetSurface(ptr), No.owned);
  }

  /// Load a raw string of HTML.
  void loadHtml(string htmlString) {
    this.loadHtml(htmlString.toUlString);
  }
  /// ditto
  void loadHtml(String htmlString) {
    ulViewLoadHTML(ptr, htmlString.ptr);
  }

  /// Load a URL into main frame.
  void loadUrl(string urlString) {
    this.loadUrl(urlString.toUlString);
  }
  /// ditto
  void loadUrl(String urlString) {
    ulViewLoadURL(ptr, urlString.ptr);
  }

  /// Resize view to a certain width and height (in pixels).
  void resize(uint width, uint height) {
    ulViewResize(ptr, width, height);
  }

  /// Acquire the page's `JSContext` for use with JavaScriptCore API.
  JSContextRef lockJsContext() {
    // TODO: Wrap `RenderTarget` for D.
    return ulViewLockJSContext(ptr);
  }

  /// Unlock the page's `JSContext` after a previous call to `View.lockJsContext`.
  void unlockJsContext() {
    ulViewUnlockJSContext(ptr);
  }

  /// Evaluate a string of JavaScript and return result.
  string evaluateScript(string jsString, ref string exception) {
    auto exceptionStr = exception is null ? null : new String(null.to!ULString);
    auto result = this.evaluateScript(jsString.toUlString, exceptionStr);
    if (exceptionStr !is null)
      exception = exceptionStr.toString;
    return result;
  }
  /// ditto
  string evaluateScript(String jsString, out String exception) {
    return ulViewEvaluateScript(
      ptr, jsString.ptr, exception is null ? null : &exception.ptr
    ).toString;
  }

  /// Check if can navigate backwards in history.
  bool canGoBack() {
    return ulViewCanGoBack(ptr);
  }

  /// Check if can navigate forwards in history.
  bool canGoForward() {
    return ulViewCanGoForward(ptr);
  }

  /// Navigate backwards in history.
  void goBack() {
    ulViewGoBack(ptr);
  }

  /// Navigate forwards in history.
  void goForward() {
    ulViewGoForward(ptr);
  }

  /// Navigate to arbitrary offset in history.
  void goToHistoryOffset(int offset) {
    ulViewGoToHistoryOffset(ptr, offset);
  }

  /// Reload current page.
  void reload() {
    ulViewReload(ptr);
  }

  /// Stop all page loads.
  void stop() {
    ulViewStop(ptr);
  }

  /// Give focus to the View.
  void focus() {
    ulViewFocus(ptr);
  }

  /// Remove focus from the View and unfocus any focused input elements.
  void unfocus() {
    ulViewUnfocus(ptr);
  }

  /// Whether or not the View has focus.
  bool hasFocus() {
    return ulViewHasFocus(ptr);
  }

  /// Whether or not the View has an input element with visible keyboard focus (indicated by a blinking caret).
  bool hasInputFocus() {
    return ulViewHasInputFocus(ptr);
  }

  /// Fire a keyboard event.
  void fireKeyEvent(KeyEvent keyEvent) {
    ulViewFireKeyEvent(ptr, keyEvent.ptr);
  }

  /// Fire a mouse event.
  void fireMouseEvent(MouseEvent mouseEvent) {
    ulViewFireMouseEvent(ptr, mouseEvent.ptr);
  }

  /// Fire a scroll event.
  void fireScrollEvent(ScrollEvent scrollEvent) {
    ulViewFireScrollEvent(ptr, scrollEvent.ptr);
  }

  /// Set callback for when the page title changes.
  void setChangeTitleCallback(ChangeTitleCallback callback, void* userData) {
    ulViewSetChangeTitleCallback(ptr, ((void* user_data, ULView caller, ULString title) {
      callback(user_data, new View(caller, No.owned), title.toString);
    }).toDelegate.bindDelegate, userData);
  }

  /// Set callback for when the page URL changes.
  void setChangeUrlCallback(ChangeURLCallback callback, void* userData) {
    ulViewSetChangeURLCallback(ptr, ((void* user_data, ULView caller, ULString url) {
      callback(user_data, new View(caller, No.owned), url.toString);
    }).toDelegate.bindDelegate, userData);
  }

  /// Set callback for when the tooltip changes (usually result of a mouse hover).
  void setChangeTooltipCallback(ChangeTooltipCallback callback, void* userData) {
    ulViewSetChangeTooltipCallback(ptr, ((void* user_data, ULView caller, ULString tooltip) {
      callback(user_data, new View(caller, No.owned), tooltip.toString);
    }).toDelegate.bindDelegate, userData);
  }

  /// Set callback for when the mouse cursor changes.
  void setChangeCursorCallback(ChangeCursorCallback callback, void* userData) {
    ulViewSetChangeCursorCallback(ptr, cast(ULChangeCursorCallback) ((void* user_data, ULView caller, Cursor cursor) {
      callback(user_data, new View(caller, No.owned), cursor);
    }).toDelegate.bindDelegate, userData);
  }

  /// Set callback for when a message is added to the console (useful for JavaScript / network errors and debugging).
  void setAddConsoleMessageCallback(AddConsoleMessageCallback callback, void* userData) {
    ulViewSetAddConsoleMessageCallback(ptr, cast(ULAddConsoleMessageCallback) ((void* user_data, ULView caller, MessageSource source, MessageLevel level, ULString message, uint line_number, uint column_number, ULString source_id) {
      callback(user_data, new View(caller, No.owned), source, level, message.toString, line_number, column_number, source_id.toString);
    }).toDelegate.bindDelegate, userData);
  }

  /// Set callback for when the page wants to create a new View.
  void setCreateChildViewCallback(CreateChildViewCallback callback, void* userData) {
    ulViewSetCreateChildViewCallback(ptr, (delegate(void* user_data, ULView caller, ULString opener_url, ULString target_url, bool is_popup, ULIntRect popup_rect) {
      return callback(user_data, new View(caller, No.owned), opener_url.toString, target_url.toString, is_popup, popup_rect).ptr;
    }).bindDelegate, userData);
  }

  /// Set callback for when the page wants to create a new View to display the local inspector in.
  void setCreateInspectorViewCallback(CreateInspectorViewCallback callback, void* userData) {
    ulViewSetCreateInspectorViewCallback(ptr, (delegate(void* user_data, ULView caller, bool is_local, ULString inspected_url) {
      return callback(user_data, new View(caller, No.owned), is_local, inspected_url.toString).ptr;
    }).bindDelegate, userData);
  }

  /// Set callback for when the page begins loading a new URL into a frame.
  void setBeginLoadingCallback(BeginLoadingCallback callback, void* userData) {
    ulViewSetBeginLoadingCallback(ptr, ((void* user_data, ULView caller, ulong frame_id, bool is_main_frame, ULString url) {
      callback(user_data, new View(caller, No.owned), frame_id, is_main_frame, url.toString);
    }).toDelegate.bindDelegate, userData);
  }

  /// Set callback for when the page finishes loading a URL into a frame.
  void setFinishLoadingCallback(FinishLoadingCallback callback, void* userData) {
    ulViewSetFinishLoadingCallback(ptr, ((void* user_data, ULView caller, ulong frame_id, bool is_main_frame, ULString url) {
      callback(user_data, new View(caller, No.owned), frame_id, is_main_frame, url.toString);
    }).toDelegate.bindDelegate, userData);
  }

  /// Set callback for when an error occurs while loading a URL into a frame.
  void setFailLoadingCallback(FailLoadingCallback callback, void* userData) {
    ulViewSetFailLoadingCallback(ptr, ((void* user_data, ULView caller, ulong frame_id, bool is_main_frame, ULString url, ULString description, ULString error_domain, int error_code) {
      callback(user_data, new View(caller, No.owned), frame_id, is_main_frame, url.toString, description.toString, error_domain.toString, error_code);
    }).toDelegate.bindDelegate, userData);
  }

  /// Set callback for when the JavaScript window object is reset for a new page load.
  void setWindowObjectReadyCallback(WindowObjectReadyCallback callback, void* userData) {
    ulViewSetWindowObjectReadyCallback(ptr, ((void* user_data, ULView caller, ulong frame_id, bool is_main_frame, ULString url) {
      callback(user_data, new View(caller, No.owned), frame_id, is_main_frame, url.toString);
    }).toDelegate.bindDelegate, userData);
  }

  /// Set callback for when all JavaScript has been parsed and the document is ready.
  void setDOMReadyCallback(DOMReadyCallback callback, void* userData) {
    ulViewSetDOMReadyCallback(ptr, ((void* user_data, ULView caller, ulong frame_id, bool is_main_frame, ULString url) {
      callback(user_data, new View(caller, No.owned), frame_id, is_main_frame, url.toString);
    }).toDelegate.bindDelegate, userData);
  }

  /// Set callback for when the history (back/forward state) is modified.
  void setUpdateHistoryCallback(UpdateHistoryCallback callback, void* userData) {
    ulViewSetUpdateHistoryCallback(ptr, ((void* user_data, ULView caller) {
      callback(user_data, new View(caller, No.owned));
    }).toDelegate.bindDelegate, userData);
  }

  /// Set whether or not a view should be repainted during the next call to `Renderer.render`.
  void needsPaint(bool needs_paint) {
    ulViewSetNeedsPaint(ptr, needs_paint);
  }

  /// Whether or not a view should be painted during the next call to `Renderer.render`.
  bool needsPaint() {
    return ulViewGetNeedsPaint(ptr);
  }

  /// Create an Inspector View to inspect/debug this View locally.
  void createLocalInspectorView() {
    ulViewCreateLocalInspectorView(ptr);
  }
}

/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___surface_8h.html
class Surface {
  ///
  ULSurface ptr;
  /// Whether this surface is managed.
  bool owned;

  package this(ULSurface surface, Flag!"owned" owned = Yes.owned) {
    this.ptr = surface;
    this.owned = owned;
  }

  /// Width (in pixels).
  uint width() {
    return ulSurfaceGetWidth(ptr);
  }

  /// Height (in pixels).
  uint height() {
    return ulSurfaceGetHeight(ptr);
  }

  /// Number of bytes between rows (usually width * 4)
  uint rowBytes() {
    return ulSurfaceGetRowBytes(ptr);
  }

  /// Size in bytes.
  size_t size() {
    return ulSurfaceGetSize(ptr);
  }

  /// Lock the pixel buffer and get a pointer to the beginning of the data for reading/writing.
  /// ditto
  void* lockPixels() {
    return ulSurfaceLockPixels(ptr);
  }

  /// Unlock the pixel buffer.
  void unlockPixels() {
    ulSurfaceUnlockPixels(ptr);
  }

  /// Resize the pixel buffer to a certain width and height (both in pixels).
  void resize(uint width, uint height) {
    ulSurfaceResize(ptr, width, height);
  }

  /// Get the dirty bounds.
  ULIntRect dirtyBounds() {
    return ulSurfaceGetDirtyBounds(ptr);
  }
  /// Set the dirty bounds to a certain value.
  void dirtyBounds(ULIntRect bounds) {
    ulSurfaceSetDirtyBounds(ptr, bounds);
  }

  /// Clear the dirty bounds.
  void clearDirtyBounds() {
    ulSurfaceClearDirtyBounds(ptr);
  }

  /// Get the underlying user data pointer (this is only valid if you have set a custom surface implementation via `Platform.setSurfaceDefinition`).
  void* userData() {
    return ulSurfaceGetUserData(ptr);
  }

  /// Get the underlying Bitmap from the default Surface.
  Bitmap bitmap() {
    return new Bitmap(ulBitmapSurfaceGetBitmap(ptr));
  }
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
    if (owned) ulDestroyBitmap(ptr);
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
