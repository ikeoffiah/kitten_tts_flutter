cmake_minimum_required(VERSION 3.18)
project(espeak_ng_for_kitten C)

set(ESPEAK_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../../../third_party/espeak-ng")

if(NOT EXISTS "${ESPEAK_ROOT}/src/libespeak-ng/speak_lib.c")
  message(FATAL_ERROR
    "espeak-ng source not found at ${ESPEAK_ROOT}. "
    "Run scripts/setup_espeak.sh first.")
endif()

set(ESPEAK_SRC_DIR "${ESPEAK_ROOT}/src/libespeak-ng")

file(GLOB ESPEAK_SOURCES
  "${ESPEAK_SRC_DIR}/speak_lib.c"
  "${ESPEAK_SRC_DIR}/compiledict.c"
  "${ESPEAK_SRC_DIR}/compilembrola.c"
  "${ESPEAK_SRC_DIR}/dictionary.c"
  "${ESPEAK_SRC_DIR}/encoding.c"
  "${ESPEAK_SRC_DIR}/error.c"
  "${ESPEAK_SRC_DIR}/espeak_api.c"
  "${ESPEAK_SRC_DIR}/ieee80.c"
  "${ESPEAK_SRC_DIR}/intonation.c"
  "${ESPEAK_SRC_DIR}/klatt.c"
  "${ESPEAK_SRC_DIR}/mnemonics.c"
  "${ESPEAK_SRC_DIR}/numbers.c"
  "${ESPEAK_SRC_DIR}/phoneme.c"
  "${ESPEAK_SRC_DIR}/phonemelist.c"
  "${ESPEAK_SRC_DIR}/readclause.c"
  "${ESPEAK_SRC_DIR}/setlengths.c"
  "${ESPEAK_SRC_DIR}/soundicon.c"
  "${ESPEAK_SRC_DIR}/speech.c"
  "${ESPEAK_SRC_DIR}/ssml.c"
  "${ESPEAK_SRC_DIR}/synthdata.c"
  "${ESPEAK_SRC_DIR}/synthesize.c"
  "${ESPEAK_SRC_DIR}/translate.c"
  "${ESPEAK_SRC_DIR}/translateword.c"
  "${ESPEAK_SRC_DIR}/tr_languages.c"
  "${ESPEAK_SRC_DIR}/voices.c"
  "${ESPEAK_SRC_DIR}/wavegen.c"
)

# UCD tools for Unicode character classification
file(GLOB UCD_SOURCES
  "${ESPEAK_ROOT}/src/ucd-tools/src/*.c"
)

add_library(espeak-ng SHARED ${ESPEAK_SOURCES} ${UCD_SOURCES})

target_include_directories(espeak-ng PUBLIC
  "${ESPEAK_ROOT}/src/include"
  "${ESPEAK_ROOT}/src/include/espeak-ng"
  "${ESPEAK_ROOT}/src/libespeak-ng"
  "${ESPEAK_ROOT}/src/ucd-tools/src/include"
)

target_compile_definitions(espeak-ng PRIVATE
  HAVE_STDINT_H=1
  PACKAGE_VERSION="1.52.0"
  DATA_FROM_FILE=1
)

target_compile_options(espeak-ng PRIVATE -w)
