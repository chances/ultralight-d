/// License: MIT
module ultralight.callbacks;

import std.traits : isDelegate;

import ultralight : View;
import ultralight.bindings;
import ultralight.enums;

/// `extern (C) void function(void* user_data, C_View* caller, C_String* title)`
alias ChangeTitleCallback = void delegate(void* userData, View caller, string title);
/// `extern (C) void function(void* user_data, C_View* caller, C_String* url)`
alias ChangeURLCallback = void delegate(void* userData, View caller, string url);
/// `extern (C) void function(void* user_data, C_View* caller, C_String* tooltip)`
alias ChangeTooltipCallback = void delegate(void* userData, View caller, string tooltip);
/// `extern (C) void function(void* user_data, C_View* caller, ULCursor cursor)`
alias ChangeCursorCallback = void delegate(void* userData, View caller, Cursor cursor);
/// `extern (C) void function(void* user_data, C_View* caller, ULMessageSource source, ULMessageLevel level, C_String* message, uint line_number, uint column_number, C_String* source_id)`
alias AddConsoleMessageCallback = void delegate(
  void* userData, View caller, MessageSource source, MessageLevel level,
  string message, uint lineNumber, uint columnNumber, string sourceId
);
/// `extern (C) C_View* function(void* user_data, C_View* caller, C_String* opener_url, C_String* target_url, bool is_popup, ULRect popup_rect)`
alias CreateChildViewCallback = View delegate(
  void* userData, View caller, string opener_url, string target_url, bool isPopup, ULIntRect popup_rect
);
/// `extern (C) C_View* function(void* user_data, C_View* caller, bool is_local, C_String* inspected_url)`
alias CreateInspectorViewCallback = View delegate(void* userData, View caller, bool is_local, string inspectedUrl);
/// `extern (C) void function(void* user_data, C_View* caller, ulong frame_id, bool is_main_frame, C_String* url)`
alias BeginLoadingCallback = void delegate(void* userData, View caller, ulong frameId, bool isMainFrame, string url);
/// `extern (C) void function(void* user_data, C_View* caller, ulong frame_id, bool is_main_frame, C_String* url)`
alias FinishLoadingCallback = void delegate(void* userData, View caller, ulong frameId, bool isMainFrame, string url);
/// `extern (C) void function(void* user_data, C_View* caller, ulong frame_id, bool is_main_frame, C_String* url, C_String* description, C_String* error_domain, int error_code)`
alias FailLoadingCallback = void delegate(
  void* userData, View caller, ulong frameId, bool isMainFrame, string url,
  string description, string errorDomain, int errorCode
);
/// `extern (C) void function(void* user_data, C_View* caller, ulong frame_id, bool is_main_frame, C_String* url)`
alias WindowObjectReadyCallback = void delegate(
  void* userData, View caller, ulong frameId, bool isMainFrame, string url
);
/// `extern (C) void function(void* user_data, C_View* caller, ulong frame_id, bool is_main_frame, C_String* url)`
alias DOMReadyCallback = void delegate(void* userData, View caller, ulong frameId, bool isMainFrame, string url);
/// `extern (C) void function(void* user_data, C_View* caller)`
alias UpdateHistoryCallback = void delegate(void* userData, View caller);

package(ultralight):

/// Transform the given delegate into a static function pointer with C linkage.
/// See_Also: <a href="https://stackoverflow.com/a/22845722/1363247">stackoverflow.com/a/22845722/1363247</a>
auto bindDelegate(Func, string file = __FILE__, size_t line = __LINE__)(Func f) if(isDelegate!Func) {
  import std.traits : ParameterTypeTuple, ReturnType;

  static Func delegate_;
  delegate_ = f;
  extern(C) static ReturnType!Func func(ParameterTypeTuple!Func args) {
    return delegate_(args);
  }

  return &func;
}
