function(validate_build_dir)
  if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
    message(FATAL_ERROR
      "In-source builds are not supported\n"
      "Create a build directory (inside or outside of the source directory) and run CMake from there.\n"
      "Please remove the cache files: rm -r CMakeFiles CMakeCache.txt"
    )
  endif()
endfunction()
