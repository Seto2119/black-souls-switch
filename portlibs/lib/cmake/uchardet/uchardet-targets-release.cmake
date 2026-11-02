#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "uchardet::libuchardet" for configuration "Release"
set_property(TARGET uchardet::libuchardet APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(uchardet::libuchardet PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libuchardet.a"
  )

list(APPEND _cmake_import_check_targets uchardet::libuchardet )
list(APPEND _cmake_import_check_files_for_uchardet::libuchardet "${_IMPORT_PREFIX}/lib/libuchardet.a" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
