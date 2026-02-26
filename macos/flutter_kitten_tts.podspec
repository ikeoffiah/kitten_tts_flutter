Pod::Spec.new do |s|
  s.name             = 'flutter_kitten_tts'
  s.version          = '0.0.2'
  s.summary          = 'KittenTTS v0.8 - Offline text-to-speech for Flutter.'
  s.description      = <<-DESC
High-quality offline text-to-speech using the KittenML v0.8 ONNX model with espeak-ng phonemization.
                       DESC
  s.homepage         = 'https://github.com/ikeoffiah/kitten_tts_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'KittenTTS' => 'dev@example.com' }
  s.source           = { :path => '.' }

  s.source_files = [
    'kitten_tts_flutter/Sources/kitten_tts_flutter/**/*.swift',
    'Classes/espeak-ng/**/*.c',
    'Classes/espeak-ng/**/*.h',
    'espeak_config.h',
  ]

  s.public_header_files = 'Classes/espeak-ng/include/**/*.h'
  s.preserve_paths = 'Classes/espeak-ng/**/*'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'HEADER_SEARCH_PATHS' => [
      '$(PODS_TARGET_SRCROOT)/Classes/espeak-ng/include',
      '$(PODS_TARGET_SRCROOT)/Classes/espeak-ng/include/espeak-ng',
      '$(PODS_TARGET_SRCROOT)/Classes/espeak-ng',
      '$(PODS_TARGET_SRCROOT)/Classes/espeak-ng/ucd-include',
      '$(PODS_TARGET_SRCROOT)',
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
