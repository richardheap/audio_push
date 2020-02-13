import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class AudioPush {
  static const _channel = const MethodChannel('audio_push');

  static Future<int> get nativeRate async {
    return await _channel.invokeMethod('nativeRate');
  }

  static Future<int> start(int sampleRate) async {
    return await _channel.invokeMethod('start', {
      'rate': sampleRate,
    });
  }

  static void stop() {
    _channel.invokeMethod('stop');
  }

  static void process(Float64List doubles) {
    _channel.invokeMethod('process', {
      'data': doubles,
    });
  }
}
