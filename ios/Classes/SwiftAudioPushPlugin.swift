import Flutter
import AVFoundation

public class SwiftAudioPushPlugin: NSObject, FlutterPlugin {
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "audio_push", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(SwiftAudioPushPlugin(), channel: channel)
  }
  
  let playerNode = AVAudioPlayerNode()
  let engine = AVAudioEngine()
  
  var sampleRate: Double = 0.0
  var inputFormat: AVAudioFormat
  
  override init() {
    let mainMixer = engine.mainMixerNode
    let output = engine.outputNode
    sampleRate = output.inputFormat(forBus: 0).sampleRate
    
    inputFormat = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32,
                                sampleRate: sampleRate,
                                channels: 1,
                                interleaved: false)!
    
    engine.attach(playerNode)
    engine.connect(playerNode, to: mainMixer, format: inputFormat)
    
    engine.connect(mainMixer, to: output, format: nil)
    mainMixer.outputVolume = 1.0
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "nativeRate":
      result(Int(floor(sampleRate)))
      return
      
    case "start":
      do {
        try engine.start()
      } catch {
        
        result(FlutterError.init(code: "errorStart",
                                 message: "could not start engine",
                                 details: error.localizedDescription))
        return
      }
      playerNode.play()
      result(Int(-1))
      return
      
    case "stop":
      playerNode.stop()
      engine.stop()
      result(nil)
      return
      
    case "process":
      if let args = call.arguments as? Dictionary<String, Any>,
        let au = args["data"] as? FlutterStandardTypedData,
        let buffer = AVAudioPCMBuffer(pcmFormat: inputFormat, frameCapacity: au.elementCount),
        let floats = buffer.floatChannelData {
        
        let channelData = floats.pointee
        buffer.frameLength = au.elementCount
        au.data.withUnsafeBytes{(pointer: UnsafeRawBufferPointer) in
          let doubles = pointer.bindMemory(to: Double.self)
          for index in 0..<Int(au.elementCount) {
            channelData[index] = Float(doubles[index])
          }
        }
        playerNode.scheduleBuffer(buffer, completionHandler: nil)
        result(nil)
      } else {
        result(FlutterError.init(code: "errorProcess", message: "data or format error", details: nil))
      }
      return
      
    default:
      result(FlutterMethodNotImplemented)
      return
    }
  }
}
