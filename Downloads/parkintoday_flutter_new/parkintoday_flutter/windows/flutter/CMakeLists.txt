cmake_minimum_required(VERSION 3.14)

set(EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")

include(${EPHEMERAL_DIR}/generated_config.cmake OPTIONAL RESULT_VARIABLE HAS_FLUTTER)

if(NOT HAS_FLUTTER)
  message(FATAL_ERROR "Missing Flutter SDK. Run: flutter pub get")
endif()

set(FLUTTER_LIBRARY "${EPHEMERAL_DIR}/flutter_windows.dll")

add_library(flutter INTERFACE)
target_include_directories(flutter INTERFACE
  "${EPHEMERAL_DIR}/"
)
target_link_libraries(flutter INTERFACE "${FLUTTER_LIBRARY}.lib")
add_custom_command(OUTPUT "${FLUTTER_LIBRARY}"
  COMMAND ${CMAKE_COMMAND} -E copy_if_different "${FLUTTER_LIBRARY}" $<TARGET_FILE_DIR:${BINARY_NAME}>
)
set(FLUTTER_LIBRARY ${FLUTTER_LIBRARY} PARENT_SCOPE)

add_library(flutter_wrapper_app STATIC
  "${EPHEMERAL_DIR}/cpp_client_wrapper/core_implementations.cc"
  "${EPHEMERAL_DIR}/cpp_client_wrapper/standard_codec.cc"
)
target_link_libraries(flutter_wrapper_app PUBLIC flutter)
target_include_directories(flutter_wrapper_app PUBLIC
  "${EPHEMERAL_DIR}/cpp_client_wrapper/include"
  "${EPHEMERAL_DIR}/include"
)
