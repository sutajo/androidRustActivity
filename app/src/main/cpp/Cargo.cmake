include(ExternalProject)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CARGO_PROFILE "")
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(CARGO_PROFILE "--release")
else ()
    set(CARGO_PROFILE "--profile ${CMAKE_BUILD_TYPE}")
endif()

if(ANDROID_ABI STREQUAL "armeabi-v7a")
    set(RUST_TARGET "armv7-linux-androideabi")
    set(AND_TARGET "armv7a-linux-androideabi")
elseif(ANDROID_ABI STREQUAL "arm64-v8a")
    set(RUST_TARGET "aarch64-linux-android")
    set(AND_TARGET "aarch64-linux-android")
elseif(ANDROID_ABI STREQUAL "x86")
    set(RUST_TARGET "i686-linux-android")
    set(AND_TARGET "i686-linux-android")
elseif(ANDROID_ABI STREQUAL "x86_64")
    set(RUST_TARGET "x86_64-linux-android")
    set(AND_TARGET "x86_64-linux-android")
else()
    message(FATAL_ERROR "Unsupported ANDROID_ABI: ${ANDROID_ABI}")
endif()

if(NOT DEFINED ANDROID_LINKER)
    set(ANDROID_LINKER clang++)
endif()

# Detect host OS and architecture
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
    set(HOST_OS "darwin")
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
    set(HOST_OS "linux")
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    set(HOST_OS "windows")
else()
    message(FATAL_ERROR "Unsupported host OS: ${CMAKE_HOST_SYSTEM_NAME}")
endif()

# Combine to form the NDK host tag
set(NDK_HOST_TAG "${HOST_OS}-x86_64")

string(REGEX REPLACE "android-([0-9]+)" "\\1" ANDROID_API_LEVEL ${ANDROID_PLATFORM})
set(NDK_BIN ${ANDROID_NDK}/toolchains/llvm/prebuilt/${NDK_HOST_TAG}/bin)
set(AR_TOOL ${NDK_BIN}/llvm-ar)
set(LINKER_TOOL ${NDK_BIN}/${AND_TARGET}${ANDROID_API_LEVEL}-${ANDROID_LINKER})

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    set(AR_TOOL ${AR_TOOL}.cmd)
    set(LINKER_TOOL ${LINKER_TOOL}.cmd)
endif()

file(TO_CMAKE_PATH "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}" CMAKE_RUNTIME_OUTPUT_DIRECTORY)

function(add_external_library_crate TARGET MANIFEST_DIR JNI_DIR)
    ExternalProject_Add(${TARGET}
            URL               ${MANIFEST_DIR}
            BUILD_ALWAYS      ON
            CONFIGURE_COMMAND ""
            BUILD_COMMAND
            ${CMAKE_COMMAND}
                -E chdir ${MANIFEST_DIR}
                cargo build
                    --config "target.${RUST_TARGET}.ar = '${AR_TOOL}'"
                    --config "target.${RUST_TARGET}.linker = '${LINKER_TOOL}'"
                    -Z unstable-options
                    --artifact-dir ${JNI_DIR}/${ANDROID_ABI}
                    --target-dir ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
                    --target ${RUST_TARGET}
                    ${CARGO_PROFILE}
            INSTALL_COMMAND   ""
            LOG_BUILD         ON
            LOG_OUTPUT_ON_FAILURE ON
    )
endfunction()