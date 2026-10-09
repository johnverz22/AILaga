import Flutter
import UIKit
import Speech
import Vision
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Platform channels for iOS AI capabilities.
///
/// - `com.ailaga.ailaga/device`    → hardware probe (RAM, OS, ABI, free storage)
/// - `com.ailaga.ailaga/apple_ai`  → FoundationModels (iOS 26+, on-device LLM)
/// - `com.ailaga.ailaga/apple_speech` → on-device speech recognition (ASR)
/// - `com.ailaga.ailaga/apple_vision` → on-device OCR
/// - `com.ailaga.ailaga/traffic`   → nil (iOS has no per-app byte counters)
final class AilagaChannels {

  static func register(messenger: FlutterBinaryMessenger) {
    deviceChannel(messenger)
    appleAiChannel(messenger)
    appleSpeechChannel(messenger)
    appleVisionChannel(messenger)
    // iOS exposes no per-app network counters — tell Dart "not measurable"
    // rather than fabricate a number (privacy invariant 7).
    FlutterMethodChannel(name: "com.ailaga.ailaga/traffic",
                         binaryMessenger: messenger)
      .setMethodCallHandler { _, result in result(nil) }
  }

  // MARK: - Device probe

  private static func deviceChannel(_ messenger: FlutterBinaryMessenger) {
    FlutterMethodChannel(name: "com.ailaga.ailaga/device",
                         binaryMessenger: messenger)
      .setMethodCallHandler { call, result in
        guard call.method == "getDeviceInfo" else {
          return result(FlutterMethodNotImplemented)
        }
        let ramMb = Int(ProcessInfo.processInfo.physicalMemory / 1_048_576)
        let v = ProcessInfo.processInfo.operatingSystemVersion
        var freeBytes: Int64 = 0
        if let attrs = try? FileManager.default.attributesOfFileSystem(
            forPath: NSHomeDirectory()),
           let free = attrs[.systemFreeSize] as? NSNumber {
          freeBytes = free.int64Value
        }
        result([
          "ramMb": ramMb,
          "sdkInt": v.majorVersion,          // iOS major version
          "abis": ["arm64"],                 // all modern iPhones
          "freeStorageBytes": freeBytes,
          "platform": "ios",
        ])
      }
  }

  // MARK: - FoundationModels (Apple Intelligence, iOS 26+)

  private static func appleAiChannel(_ messenger: FlutterBinaryMessenger) {
    FlutterMethodChannel(name: "com.ailaga.ailaga/apple_ai",
                         binaryMessenger: messenger)
      .setMethodCallHandler { call, result in
        switch call.method {
        case "isAvailable":
          result(availabilityMap())
        case "respond":
          guard let args = call.arguments as? [String: Any],
                let prompt = args["prompt"] as? String else {
            return result(FlutterError(code: "bad_args",
                                       message: "prompt required",
                                       details: nil))
          }
          respond(prompt: prompt,
                  temperature: args["temperature"] as? Double,
                  result: result)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
  }

  private static func availabilityMap() -> [String: Any] {
#if canImport(FoundationModels)
    if #available(iOS 26.0, *) {
      switch SystemLanguageModel.default.availability {
      case .available:
        return ["available": true, "reason": "ok"]
      case .unavailable(let reason):
        return ["available": false, "reason": "\(reason)"]
      }
    }
    return ["available": false, "reason": "requires_ios_26"]
#else
    return ["available": false, "reason": "framework_missing"]
#endif
  }

  private static func respond(prompt: String, temperature: Double?,
                              result: @escaping FlutterResult) {
#if canImport(FoundationModels)
    if #available(iOS 26.0, *) {
      Task {
        do {
          let session = LanguageModelSession()
          var options = GenerationOptions()
          if let t = temperature { options.temperature = t }
          let response = try await session.respond(to: prompt,
                                                   options: options)
          result(response.content)
        } catch {
          result(FlutterError(code: "inference_failed",
                              message: "\(error)", details: nil))
        }
      }
      return
    }
#endif
    result(FlutterError(code: "unavailable",
                        message: "Apple Intelligence not available",
                        details: nil))
  }

  // MARK: - Speech recognition (on-device ASR)

  private static func appleSpeechChannel(_ messenger: FlutterBinaryMessenger) {
    FlutterMethodChannel(name: "com.ailaga.ailaga/apple_speech",
                         binaryMessenger: messenger)
      .setMethodCallHandler { call, result in
        guard call.method == "transcribe",
              let args = call.arguments as? [String: Any],
              let path = args["path"] as? String else {
          return result(FlutterMethodNotImplemented)
        }
        transcribe(filePath: path, result: result)
      }
  }

  private static func transcribe(filePath: String,
                                 result: @escaping FlutterResult) {
    SFSpeechRecognizer.requestAuthorization { status in
      guard status == .authorized else {
        return result(FlutterError(code: "speech_denied",
                                   message: "Speech recognition denied: \(status.rawValue)",
                                   details: nil))
      }
      // Prefer Filipino (PH), fall back to English — pick from supported
      // locales so we never construct an unsupported recognizer.
      let supported = SFSpeechRecognizer.supportedLocales()
      let preferred = ["fil_PH", "fil-PH", "en_PH", "en-PH", "en_US", "en-US"]
      let locale = preferred
        .compactMap { id in
          supported.first { $0.identifier == id }
        }
        .first
      let recognizer = locale.flatMap { SFSpeechRecognizer(locale: $0) }
        ?? SFSpeechRecognizer()

      guard let recognizer, recognizer.isAvailable else {
        return result(FlutterError(code: "asr_unavailable",
                                   message: "Speech recognizer unavailable",
                                   details: nil))
      }
      // Privacy invariant: on-device only. If the device lacks on-device
      // ASR assets, fail → caller degrades to typed text (Basic).
      guard recognizer.supportsOnDeviceRecognition else {
        return result(FlutterError(code: "on_device_unavailable",
                                   message: "On-device ASR not supported",
                                   details: nil))
      }

      let url = URL(fileURLWithPath: filePath)
      let request = SFSpeechURLRecognitionRequest(url: url)
      request.requiresOnDeviceRecognition = true
      request.shouldReportPartialResults = false

      var finished = false
      recognizer.recognitionTask(with: request) { res, error in
        if finished { return }
        if let error {
          finished = true
          result(FlutterError(code: "asr_failed",
                              message: "\(error)", details: nil))
          return
        }
        if res?.isFinal == true {
          finished = true
          result([
            "transcript": res?.bestTranscription.formattedString ?? "",
            "onDevice": true,
          ])
        }
      }
    }
  }

  // MARK: - Vision OCR (on-device)

  private static func appleVisionChannel(_ messenger: FlutterBinaryMessenger) {
    FlutterMethodChannel(name: "com.ailaga.ailaga/apple_vision",
                         binaryMessenger: messenger)
      .setMethodCallHandler { call, result in
        guard call.method == "recognizeText",
              let args = call.arguments as? [String: Any],
              let path = args["path"] as? String else {
          return result(FlutterMethodNotImplemented)
        }
        recognizeText(filePath: path, result: result)
      }
  }

  private static func recognizeText(filePath: String,
                                    result: @escaping FlutterResult) {
    let url = URL(fileURLWithPath: filePath)
    guard let image = UIImage(contentsOfFile: url.path),
          let cg = image.cgImage else {
      return result(FlutterError(code: "bad_image",
                                 message: "Cannot load image", details: nil))
    }
    DispatchQueue.global(qos: .userInitiated).async {
      let request = VNRecognizeTextRequest { req, error in
        if let error {
          result(FlutterError(code: "ocr_failed",
                              message: "\(error)", details: nil))
          return
        }
        let lines = (req.results as? [VNRecognizedTextObservation] ?? [])
          .compactMap { $0.topCandidates(1).first?.string }
        result(["text": lines.joined(separator: "\n"), "onDevice": true])
      }
      request.recognitionLevel = .accurate
      request.recognitionLanguages = ["en-US", "fil-PH"]
      request.usesLanguageCorrection = true
      let handler = VNImageRequestHandler(cgImage: cg, options: [:])
      do {
        try handler.perform([request])
      } catch {
        result(FlutterError(code: "ocr_failed",
                            message: "\(error)", details: nil))
      }
    }
  }
}
