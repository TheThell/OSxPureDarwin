function(add_darwin_executable name)
    cmake_parse_arguments(SL "NO_STANDARD_LIBRARIES;USE_HOST_SDK" "MACOSX_VERSION_MIN" "" ${ARGN})

    add_executable(${name})
    add_dependencies(${name} darwin_ld)
    target_compile_definitions(${name} PRIVATE __PUREDARWIN__)
    target_link_options(${name} PRIVATE -fuse-ld=$<TARGET_FILE:darwin_ld>)

    if(NOT SL_USE_HOST_SDK)
        target_compile_options(${name} PRIVATE -nostdlib -nostdinc)
        target_link_options(${name} PRIVATE -nostdlib)
        set_property(TARGET ${name} PROPERTY OSX_ARCHITECTURES x86_64)
    endif()

    # TODO: Handle SL_NO_STANDARD_LIBRARIES here, once the libraries have been added to the build.

    if(SL_MACOSX_VERSION_MIN)
        target_compile_options(${name} PRIVATE -mmacosx-version-min=${SL_MACOSX_VERSION_MIN})
        target_link_options(${name} PRIVATE -mmacosx-version-min=${SL_MACOSX_VERSION_MIN})
        set_property(TARGET ${name} PROPERTY CMAKE_OSX_DEPLOYMENT_TARGET ${SL_MACOSX_VERSION_MIN})
    elseif(CMAKE_MACOSX_MIN_VERSION)
        target_compile_options(${name} PRIVATE -mmacosx-version-min=${CMAKE_MACOSX_MIN_VERSION})
        target_link_options(${name} PRIVATE -mmacosx-version-min=${CMAKE_MACOSX_MIN_VERSION})
        set_property(TARGET ${name} PROPERTY CMAKE_OSX_DEPLOYMENT_TARGET ${CMAKE_MACOSX_MIN_VERSION})
    else()
        message(AUTHOR_WARNING "Could not determine -mmacosx-version-min flag for target ${name}")
    endif()
endfunction()

function(add_darwin_static_library name)
    cmake_parse_arguments(SL "USE_HOST_SDK" "MACOSX_VERSION_MIN" "" ${ARGN})

    add_library(${name} STATIC)
    add_dependencies(${name} darwin_libtool)
    target_compile_definitions(${name} PRIVATE __PUREDARWIN__)

    string(SUBSTRING ${name} 0 3 name_prefix)
    if(name_prefix STREQUAL "lib")
        set_property(TARGET ${name} PROPERTY PREFIX "")
    endif()

    if(SL_MACOSX_VERSION_MIN)
        target_compile_options(${name} PRIVATE -mmacosx-version-min=${SL_MACOSX_VERSION_MIN})
        target_link_options(${name} PRIVATE -mmacosx-version-min=${SL_MACOSX_VERSION_MIN})
        set_property(TARGET ${name} PROPERTY CMAKE_OSX_DEPLOYMENT_TARGET ${SL_MACOSX_VERSION_MIN})
    elseif(CMAKE_MACOSX_MIN_VERSION)
        target_compile_options(${name} PRIVATE -mmacosx-version-min=${CMAKE_MACOSX_MIN_VERSION})
        target_link_options(${name} PRIVATE -mmacosx-version-min=${CMAKE_MACOSX_MIN_VERSION})
        set_property(TARGET ${name} PROPERTY CMAKE_OSX_DEPLOYMENT_TARGET ${CMAKE_MACOSX_MIN_VERSION})
     else()
        message(AUTHOR_WARNING "Could not determine -mmacosx-version-min flag for target ${name}")
    endif()

    if(NOT SL_USE_HOST_SDK)
        target_compile_options(${name} PRIVATE -nostdlib -nostdinc)
        set_property(TARGET ${name} PROPERTY OSX_ARCHITECTURES x86_64)
    endif()
endfunction()

function(add_darwin_shared_library name)
    cmake_parse_arguments(SL "MODULE;USE_HOST_SDK" "MACOSX_VERSION_MIN;INSTALL_NAME_DIR" "RPATHS" ${ARGN})

    if(SL_MODULE)
        add_library(${name} MODULE)
    else()
        add_library(${name} SHARED)
    endif()

    add_dependencies(${name} darwin_ld)
    target_link_options(${name} PRIVATE -fuse-ld=$<TARGET_FILE:darwin_ld>)
    target_compile_definitions(${name} PRIVATE __PUREDARWIN__)

    string(SUBSTRING ${name} 0 3 name_prefix)
    if(name_prefix STREQUAL "lib")
        set_property(TARGET ${name} PROPERTY PREFIX "")
    endif()

    if(NOT SL_USE_HOST_SDK)
        target_compile_options(${name} PRIVATE -nostdlib -nostdinc)
        target_link_options(${name} PRIVATE -nostdlib)

        set_property(TARGET ${name} PROPERTY OSX_ARCHITECTURES x86_64)
    endif()

    if(SL_MACOSX_VERSION_MIN)
        target_compile_options(${name} PRIVATE -mmacosx-version-min=${SL_MACOSX_VERSION_MIN})
        target_link_options(${name} PRIVATE -mmacosx-version-min=${SL_MACOSX_VERSION_MIN})
        set_property(TARGET ${name} PROPERTY CMAKE_OSX_DEPLOYMENT_TARGET ${SL_MACOSX_VERSION_MIN})
    elseif(CMAKE_MACOSX_MIN_VERSION)
        target_compile_options(${name} PRIVATE -mmacosx-version-min=${CMAKE_MACOSX_MIN_VERSION})
        target_link_options(${name} PRIVATE -mmacosx-version-min=${CMAKE_MACOSX_MIN_VERSION})
        set_property(TARGET ${name} PROPERTY CMAKE_OSX_DEPLOYMENT_TARGET ${CMAKE_MACOSX_MIN_VERSION})
    else()
        message(AUTHOR_WARNING "Could not determine -mmacosx-version-min flag for target ${name}")
    endif()

    if(SL_INSTALL_NAME_DIR)
        target_link_options(${name} PRIVATE -install_name "${SL_INSTALL_NAME_DIR}/$<TARGET_FILE_NAME:${name}>")
        set_property(TARGET ${name} PROPERTY BUILD_WITH_INSTALL_NAME_DIR FALSE)
        set_property(TARGET ${name} PROPERTY NO_SONAME TRUE)
    elseif(NOT SL_MODULE)
        message(WARNING "Shared library target ${name} should have INSTALL_NAME_DIR defined")
    endif()

    foreach(rpath IN LISTS SL_RPATHS)
        target_link_options(${name} PRIVATE "SHELL:-rpath ${rpath}")
    endforeach()
endfunction()

function(add_darwin_object_library name)
    cmake_parse_arguments(SL "USE_HOST_SDK" "MACOSX_VERSION_MIN" "" ${ARGN})

    add_library(${name} OBJECT)
    set_property(TARGET ${name} PROPERTY LINKER_LANGUAGE C)
    target_compile_definitions(${name} PRIVATE __PUREDARWIN__)

    if(SL_MACOSX_VERSION_MIN)
        target_compile_options(${name} PRIVATE -mmacosx-version-min=${SL_MACOSX_VERSION_MIN})
        target_link_options(${name} PRIVATE -mmacosx-version-min=${SL_MACOSX_VERSION_MIN})
        set_property(TARGET ${name} PROPERTY CMAKE_OSX_DEPLOYMENT_TARGET ${SL_MACOSX_VERSION_MIN})
    elseif(CMAKE_MACOSX_MIN_VERSION)
        target_compile_options(${name} PRIVATE -mmacosx-version-min=${CMAKE_MACOSX_MIN_VERSION})
        target_link_options(${name} PRIVATE -mmacosx-version-min=${CMAKE_MACOSX_MIN_VERSION})
        set_property(TARGET ${name} PROPERTY CMAKE_OSX_DEPLOYMENT_TARGET ${CMAKE_MACOSX_MIN_VERSION})
    else()
        message(AUTHOR_WARNING "Could not determine -mmacosx-version-min flag for target ${name}")
    endif()

    if(NOT SL_USE_HOST_SDK)
        target_compile_options(${name} PRIVATE -nostdlib -nostdinc)
        set_property(TARGET ${name} PROPERTY OSX_ARCHITECTURES x86_64)
    endif()
endfunction()

set(CMAKE_SKIP_RPATH TRUE)
set(CMAKE_SKIP_BUILD_RPATH TRUE)
set(CMAKE_SKIP_INSTALL_RPATH TRUE)
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
set(CMAKE_MACOSX_RPATH FALSE)
