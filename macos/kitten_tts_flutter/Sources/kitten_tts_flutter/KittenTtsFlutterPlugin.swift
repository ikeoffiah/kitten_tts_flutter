import Cocoa
import FlutterMacOS

@_silgen_name("kitten_tts_force_link_espeak")
func kittenTtsForceLink()

public class KittenTtsFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    kittenTtsForceLink()

    let channel = FlutterMethodChannel(name: "kitten_tts_flutter", binaryMessenger: registrar.messenger)
    let instance = KittenTtsFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
