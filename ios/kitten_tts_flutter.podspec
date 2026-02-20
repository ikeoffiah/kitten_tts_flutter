Pod::Spec.new do |s|
  s.name             = 'kitten_tts_flutter'
  s.version          = '0.1.0'
  s.summary          = 'KittenTTS v0.8 - Offline text-to-speech for Flutter.'
  s.description      = <<-DESC
High-quality offline text-to-speech using the KittenML v0.8 ONNX model with espeak-ng phonemization.
                       DESC
  s.homepage         = 'https://github.com/KittenML/KittenTTS'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'KittenTTS' => 'dev@example.com' }
  s.source           = { :path => '.' }

  # Swift plugin files
  s.source_files = 'kitten_tts_flutter/Sources/kitten_tts_flutter/**/*'

  # espeak-ng C sources (compiled by Xcode)
  espeak_root = '../third_party/espeak-ng'
  espeak_src = "#{espeak_root}/src/libespeak-ng"

  s.preserve_paths = "#{espeak_root}/**/*"

  s.vendored_libraries = []

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'HEADER_SEARCH_PATHS' => [
      "$(PODS_TARGET_SRCROOT)/#{espeak_root}/src/include",
      "$(PODS_TARGET_SRCROOT)/#{espeak_root}/src/libespeak-ng",
      "$(PODS_TARGET_SRCROOT)/#{espeak_root}/src/ucd-tools/src/include",
    ].join(' '),
    'GCC_PREPROCESSOR_DEFINITIONS' => 'HAVE_STDINT_H=1',
    'OTHER_CFLAGS' => '-w',
  }

  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.swift_version = '5.0'
end
