#include "utils.h"

#include <flutter/flutter_view_controller.h>
#include <io.h>
#include <stdio.h>
#include <windows.h>

#include <iostream>
#include <string>
#include <vector>

void CreateAndAttachConsole() {
  if (::AllocConsole()) {
    FILE* unused;
    if (freopen_s(&unused, "CONOUT$", "w", stdout)) {
      _dup2(_fileno(stdout), 1);
    }
    if (freopen_s(&unused, "CONOUT$", "w", stderr)) {
      _dup2(_fileno(stdout), 2);
    }
    std::ios::sync_with_stdio();
    FlutterDesktopResyncOutputStreams();
  }
}

std::vector<std::string> GetCommandLineArguments() {
  int argc;
  wchar_t** argv = ::CommandLineToArgvW(::GetCommandLineW(), &argc);
  if (argv == nullptr) return {};
  std::vector<std::string> command_line_arguments;
  for (int i = 1; i < argc; i++) {
    command_line_arguments.push_back(flutter::WideStringToUtf8(argv[i]));
  }
  ::LocalFree(argv);
  return command_line_arguments;
}
