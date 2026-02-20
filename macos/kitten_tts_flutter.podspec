Pod::Spec.new do |s|
  s.name             = 'kitten_tts_flutter'
  s.version          = '0.1.1'
  s.summary          = 'KittenTTS v0.8 - Offline text-to-speech for Flutter.'
  s.description      = <<-DESC
High-quality offline text-to-speech using the KittenML v0.8 ONNX model with espeak-ng phonemization.
                       DESC
  s.homepage         = 'https://github.com/ikeoffiah/kitten_tts_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'KittenTTS' => 'dev@example.com' }
  s.source           = { :path => '.' }

  espeak_root = '../third_party/espeak-ng'

  s.source_files = [
    'kitten_tts_flutter/Sources/kitten_tts_flutter/**/*.swift',
    "#{espeak_root}/src/libespeak-ng/*.c",
    "#{espeak_root}/src/libespeak-ng/*.h",
    "#{espeak_root}/src/ucd-tools/src/*.c",
    "#{espeak_root}/src/ucd-tools/src/include/**/*.h",
    "#{espeak_root}/src/include/**/*.h",
    'espeak_config.h',
  ]

  s.exclude_files = [
    "#{espeak_root}/src/libespeak-ng/compiledata.c",
    "#{espeak_root}/src/libespeak-ng/sPlayer.c",
    "#{espeak_root}/src/libespeak-ng/spect.c",
  ]

  s.preserve_paths = "#{espeak_root}/**/*"
  s.public_header_files = "#{espeak_root}/src/include/**/*.h"

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'HEADER_SEARCH_PATHS' => [
      "$(PODS_TARGET_SRCROOT)/#{espeak_root}/src/include",
      "$(PODS_TARGET_SRCROOT)/#{espeak_root}/src/include/espeak-ng",
      "$(PODS_TARGET_SRCROOT)/#{espeak_root}/src/libespeak-ng",
      "$(PODS_TARGET_SRCROOT)/#{espeak_root}/src/ucd-tools/src/include",
      "$(PODS_TARGET_SRCROOT)",
    ].join(' '),
    'GCC_PREPROCESSOR_DEFINITIONS' => [
      'HAVE_STDINT_H=1',
      'HAVE_MKSTEMP=1',
      'USE_ASYNC=0',
      'USE_KLATT=1',
      'USE_LIBPCAUDIO=0',
      'USE_LIBSONIC=0',
      'USE_MBROLA=0',
      'USE_SPEECHPLAYER=0',
      'PACKAGE_VERSION=\"1.52.0\"',
    ].join(' '),
    'OTHER_CFLAGS' => '-w -include $(PODS_TARGET_SRCROOT)/espeak_config.h',
  }

  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.14'
  s.swift_version = '5.0'
end
