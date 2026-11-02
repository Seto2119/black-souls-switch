# sdl2_sound cmake project-config input


####### Expanded from @PACKAGE_INIT@ by configure_package_config_file() #######
####### Any changes to this file will be overwritten by the next CMake run ####
####### The input file was SDL2_soundConfig.cmake.in                            ########

get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)

macro(set_and_check _var _file)
  set(${_var} "${_file}")
  if(NOT EXISTS "${_file}")
    message(FATAL_ERROR "File or directory ${_file} referenced by variable ${_var} does not exist !")
  endif()
endmacro()

macro(check_required_components _NAME)
  foreach(comp ${${_NAME}_FIND_COMPONENTS})
    if(NOT ${_NAME}_${comp}_FOUND)
      if(${_NAME}_FIND_REQUIRED_${comp})
        set(${_NAME}_FOUND FALSE)
      endif()
    endif()
  endforeach()
endmacro()

####################################################################################

include(FeatureSummary)
set_package_properties(SDL2_sound PROPERTIES
    URL "https://github.com/icculus/SDL_sound/"
    DESCRIPTION " An abstract soundfile decoder"
)

set(SDL2_sound_FOUND ON)

if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/SDL2_sound-shared-targets.cmake")
    include("${CMAKE_CURRENT_LIST_DIR}/SDL2_sound-shared-targets.cmake")
    set(SDL2_sound_SDL2_sound_FOUND TRUE)
endif()

if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/SDL2_sound-static-targets.cmake")
    include("${CMAKE_CURRENT_LIST_DIR}/SDL2_sound-static-targets.cmake")
    set(SDL2_sound_SDL2_sound-static_FOUND TRUE)
endif()

check_required_components(SDL2_sound)

# Create SDL2_sound::SDL2_sound alias for static-only builds
if(TARGET SDL2_sound::SDL2_sound-static AND NOT TARGET SDL2_sound::SDL2_sound)
  if(CMAKE_VERSION VERSION_LESS "3.18")
    # FIXME: Aliasing local targets is not supported on CMake < 3.18, so make it global.
    add_library(SDL2_sound::SDL2_sound INTERFACE IMPORTED)
    set_target_properties(SDL2_sound::SDL2_sound PROPERTIES INTERFACE_LINK_LIBRARIES "SDL2_sound::SDL2_sound-static")
  else()
    add_library(SDL2_sound::SDL2_sound ALIAS SDL2_sound::SDL2_sound-static)
  endif()
endif()
