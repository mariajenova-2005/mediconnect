cmake_minimum_required(VERSION 3.14)
project(parkintoday LANGUAGES CXX)

set(BINARY_NAME "parkintoday")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install")

if(DEFINED ENV{FLUTTER_TOOL_ENVIRONMENT})
  set(FLUTTER_TOOL_ENVIRONMENT $ENV{FLUTTER_TOOL_ENVIRONMENT})
endif()

set(BUILD_BUNDLE_DIR "$<TARGET_FILE_DIR:${BINARY_NAME}>")

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")

add_subdirectory(${FLUTTER_MANAGED_DIR})
add_subdirectory("runner")

set_target_properties(${BINARY_NAME} PROPERTIES
  OUTPUT_NAME "${BINARY_NAME}"
)

target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")
