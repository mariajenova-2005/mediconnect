#include "win32_window.h"

#include <dwmapi.h>
#include <flutter/flutter_view_controller.h>
#include <map>
#include <memory>

namespace {
constexpr const wchar_t kWindowClassName[] = L"FLUTTER_RUNNER_WIN32_WINDOW";
HINSTANCE g_hinstance = nullptr;
std::map<HWND, Win32Window*> g_window_map;

static int g_active_window_count = 0;

std::wstring Utf8ToWideString(const std::string& str) {
  if (str.empty()) return std::wstring();
  int size_needed =
      MultiByteToWideChar(CP_UTF8, 0, &str[0], (int)str.size(), nullptr, 0);
  std::wstring result(size_needed, 0);
  MultiByteToWideChar(CP_UTF8, 0, &str[0], (int)str.size(), &result[0],
                      size_needed);
  return result;
}

void EnableFullDpiSupportIfAvailable() {
  HMODULE user32_module = LoadLibraryA("User32.dll");
  if (!user32_module) return;
  auto set_process_dpi_aware_func =
      reinterpret_cast<decltype(SetProcessDpiAwarenessContext)*>(
          GetProcAddress(user32_module, "SetProcessDpiAwarenessContext"));
  if (set_process_dpi_aware_func) {
    set_process_dpi_aware_func(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);
  }
  FreeLibrary(user32_module);
}
}  // namespace

Win32Window::Win32Window() {
  ++g_active_window_count;
}
Win32Window::~Win32Window() {
  --g_active_window_count;
  Destroy();
}

bool Win32Window::Create(const std::wstring& title, const Point& origin,
                         const Size& size) {
  Destroy();
  EnableFullDpiSupportIfAvailable();
  WNDCLASS window_class = RegisterWindowClass();
  auto* result = CreateWindow(
      window_class.lpszClassName, title.c_str(),
      WS_OVERLAPPEDWINDOW | WS_VISIBLE,
      Scale(origin.x, 1.0), Scale(origin.y, 1.0),
      Scale(size.width, 1.0), Scale(size.height, 1.0),
      nullptr, nullptr, g_hinstance, this);
  if (!result) return false;
  return OnCreate();
}

bool Win32Window::Show() {
  return ShowWindow(window_handle_, SW_SHOWNORMAL);
}

void Win32Window::Destroy() {
  OnDestroy();
  if (window_handle_) {
    g_window_map.erase(window_handle_);
    DestroyWindow(window_handle_);
    window_handle_ = nullptr;
  }
  if (g_active_window_count == 0) {
    UnregisterClass(kWindowClassName, nullptr);
  }
}

Win32Window* Win32Window::GetThisFromHandle(HWND const window) noexcept {
  return reinterpret_cast<Win32Window*>(
      GetWindowLongPtr(window, GWLP_USERDATA));
}

LRESULT Win32Window::MessageHandler(HWND hwnd, UINT const message,
                                    WPARAM const wparam,
                                    LPARAM const lparam) noexcept {
  switch (message) {
    case WM_DESTROY:
      window_handle_ = nullptr;
      Destroy();
      if (quit_on_close_) PostQuitMessage(0);
      return 0;
    case WM_DPICHANGED: {
      auto newRectSize = reinterpret_cast<RECT*>(lparam);
      LONG newWidth = newRectSize->right - newRectSize->left;
      LONG newHeight = newRectSize->bottom - newRectSize->top;
      SetWindowPos(hwnd, nullptr, newRectSize->left, newRectSize->top, newWidth,
                   newHeight, SWP_NOZORDER | SWP_NOACTIVATE);
      return 0;
    }
    case WM_SIZE: {
      RECT rect = GetClientArea();
      if (child_content_ != nullptr) {
        MoveWindow(child_content_, rect.left, rect.top, rect.right - rect.left,
                   rect.bottom - rect.top, TRUE);
      }
      return 0;
    }
    case WM_ACTIVATE:
      if (child_content_ != nullptr) SetFocus(child_content_);
      return 0;
  }
  return DefWindowProc(window_handle_, message, wparam, lparam);
}

WNDCLASS Win32Window::RegisterWindowClass() {
  g_hinstance = GetModuleHandle(nullptr);
  WNDCLASS wc{};
  wc.hCursor = LoadCursor(nullptr, IDC_ARROW);
  wc.lpszClassName = kWindowClassName;
  wc.style = CS_HREDRAW | CS_VREDRAW;
  wc.cbClsExtra = 0;
  wc.cbWndExtra = 0;
  wc.hInstance = g_hinstance;
  wc.hIcon = LoadIcon(g_hinstance, IDI_APPLICATION);
  wc.hbrBackground = 0;
  wc.lpszMenuName = nullptr;
  wc.lpfnWndProc = WndProc;
  RegisterClass(&wc);
  return wc;
}

LRESULT CALLBACK Win32Window::WndProc(HWND const window, UINT const message,
                                      WPARAM const wparam,
                                      LPARAM const lparam) noexcept {
  if (message == WM_NCCREATE) {
    auto window_struct = reinterpret_cast<CREATESTRUCT*>(lparam);
    SetWindowLongPtr(window, GWLP_USERDATA,
                     reinterpret_cast<LONG_PTR>(window_struct->lpCreateParams));
    auto that = static_cast<Win32Window*>(window_struct->lpCreateParams);
    that->window_handle_ = window;
    g_window_map[window] = that;
  } else if (Win32Window* that = GetThisFromHandle(window)) {
    return that->MessageHandler(window, message, wparam, lparam);
  }
  return DefWindowProc(window, message, wparam, lparam);
}

void Win32Window::SetChildContent(HWND content) {
  child_content_ = content;
  SetParent(content, window_handle_);
  RECT frame = GetClientArea();
  MoveWindow(content, frame.left, frame.top, frame.right - frame.left,
             frame.bottom - frame.top, true);
  SetFocus(child_content_);
}

RECT Win32Window::GetClientArea() {
  RECT frame;
  GetClientRect(window_handle_, &frame);
  return frame;
}

HWND Win32Window::GetHandle() {
  return window_handle_;
}

void Win32Window::SetQuitOnClose(bool quit_on_close) {
  quit_on_close_ = quit_on_close;
}

bool Win32Window::OnCreate() { return true; }
void Win32Window::OnDestroy() {}

int Win32Window::Scale(int source, double scale_factor) {
  return static_cast<int>(source * scale_factor);
}

void Win32Window::UpdateTheme(HWND const window) {}
