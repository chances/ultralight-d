/// License: MIT
module ultralight.enums;

import ultralight.bindings;

///
enum MessageSource {
  xml = kMessageSource_XML,
  js = kMessageSource_JS,
  network = kMessageSource_Network,
  consoleApi = kMessageSource_ConsoleAPI,
  storage = kMessageSource_Storage,
  appCache = kMessageSource_AppCache,
  rendering = kMessageSource_Rendering,
  css = kMessageSource_CSS,
  security = kMessageSource_Security,
  contentBlocker = kMessageSource_ContentBlocker,
  other = kMessageSource_Other
}

///
enum MessageLevel {
  ///
  log = kMessageLevel_Log,
  ///
  warning = kMessageLevel_Warning,
  ///
  error = kMessageLevel_Error,
  ///
  debug_ = kMessageLevel_Debug,
  ///
  info = kMessageLevel_Info
}

/// See_Also: https://ultralig.ht/api/c/1_3_0/_c_a_p_i___defines_8h.html#af81b997faeeb522a0cb41000e0c3f89d
enum BitmapFormat {
  ///
  a8_unorm = kBitmapFormat_A8_UNORM,
  ///
  bgra8_unorm_srgb = kBitmapFormat_BGRA8_UNORM_SRGB
}

///
enum FaceWinding {
  ///
  clockwise = kFaceWinding_Clockwise,
  ///
  counterClockwise = kFaceWinding_CounterClockwise
}

///
enum FontHinting {
  /// Lighter hinting algorithm– glyphs are slightly fuzzier but better resemble their original shape.
  ///
  /// This is achieved by snapping glyphs to the pixel grid only vertically which better preserves inter-glyph spacing.
  smooth = kFontHinting_Smooth,
  /// Default hinting algorithm– offers a good balance between sharpness and shape at smaller font sizes.
  normal = kFontHinting_Normal,
  /// Strongest hinting algorithm– outputs only black/white glyphs.
  ///
  /// The result is usually unpleasant if the underlying TTF does not contain hints for this type of rendering.
  monochrome = kFontHinting_Monochrome
}

///
enum Cursor {
  ///
  pointer = kCursor_Pointer,
  ///
  cross = kCursor_Cross,
  ///
  hand = kCursor_Hand,
  ///
  iBeam = kCursor_IBeam,
  ///
  wait = kCursor_Wait,
  ///
  help = kCursor_Help,
  ///
  eastResize = kCursor_EastResize,
  ///
  northResize = kCursor_NorthResize,
  ///
  northEastResize = kCursor_NorthEastResize,
  ///
  northWestResize = kCursor_NorthWestResize,
  ///
  southResize = kCursor_SouthResize,
  ///
  southEastResize = kCursor_SouthEastResize,
  ///
  southWestResize = kCursor_SouthWestResize,
  ///
  westResize = kCursor_WestResize,
  ///
  northSouthResize = kCursor_NorthSouthResize,
  ///
  eastWestResize = kCursor_EastWestResize,
  ///
  northEastSouthWestResize = kCursor_NorthEastSouthWestResize,
  ///
  northWestSouthEastResize = kCursor_NorthWestSouthEastResize,
  ///
  columnResize = kCursor_ColumnResize,
  ///
  rowResize = kCursor_RowResize,
  ///
  middlePanning = kCursor_MiddlePanning,
  ///
  eastPanning = kCursor_EastPanning,
  ///
  northPanning = kCursor_NorthPanning,
  ///
  northEastPanning = kCursor_NorthEastPanning,
  ///
  northWestPanning = kCursor_NorthWestPanning,
  ///
  southPanning = kCursor_SouthPanning,
  ///
  southEastPanning = kCursor_SouthEastPanning,
  ///
  southWestPanning = kCursor_SouthWestPanning,
  ///
  westPanning = kCursor_WestPanning,
  ///
  move = kCursor_Move,
  ///
  verticalText = kCursor_VerticalText,
  ///
  cell = kCursor_Cell,
  ///
  contextMenu = kCursor_ContextMenu,
  ///
  alias_ = kCursor_Alias,
  ///
  progress = kCursor_Progress,
  ///
  noDrop = kCursor_NoDrop,
  ///
  copy = kCursor_Copy,
  ///
  none = kCursor_None,
  ///
  notAllowed = kCursor_NotAllowed,
  ///
  zoomIn = kCursor_ZoomIn,
  ///
  zoomOut = kCursor_ZoomOut,
  ///
  grab = kCursor_Grab,
  ///
  grabbing = kCursor_Grabbing,
  ///
  custom = kCursor_Custom
}
