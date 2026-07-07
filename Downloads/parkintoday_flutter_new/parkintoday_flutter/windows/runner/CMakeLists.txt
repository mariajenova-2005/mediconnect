cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

set(BINARY_NAME "parkintoday")
set(APP_IDENTIFIER "com.parkintoday.app")

cmake_policy(SET CMP0063 NEW)

find_package(FlutterWindows REQUIRED)

set(RUNNER_SRCS
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
)

add_executable(${BINARY_NAME} WIN32
  ${RUNNER_SRCS}
)

target_compile_definitions(${BINARY_NAME} PRIVATE
  "NOMINMAX"
  "UNICODE"
  "_UNICODE"
)

target_include_directories(${BINARY_NAME} PRIVATE
  "${CMAKE_SOURCE_DIR}"
)

target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")

set_target_properties(${BINARY_NAME} PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY "${BUILD_BUNDLE_DIR}"
)

set(WINDOWS_PACKAGE_GUID "4d3d9e7c-fa1f-4b41-b31f-9b5e5e0c4f1c")
