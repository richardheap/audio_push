package io.swhh.audio_push;

import android.media.AudioFormat;
import android.media.AudioTrack;

import androidx.annotation.NonNull;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static android.media.AudioManager.STREAM_MUSIC;

/**
 * AudioPushPlugin
 */
public class AudioPushPlugin implements FlutterPlugin, MethodCallHandler {

  private static final String TAG = "audio_push";

  private MethodChannel channel;

  private AudioTrack audioTrack;

  private boolean running;

  private float[] floats = new float[2048];

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "audio_push");
    channel.setMethodCallHandler(this);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "audio_push");
    channel.setMethodCallHandler(new AudioPushPlugin());
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "nativeRate":
        result.success(AudioTrack.getNativeOutputSampleRate(STREAM_MUSIC));
        return;

      case "start":
        start(call, result);
        return;

      case "stop":
        stop(call, result);
        return;

      case "process":
        process(call, result);
        return;

      default:
        result.notImplemented();
        break;
    }
  }

  private void start(MethodCall call, Result result) {
    Log.d(TAG, call.method);
    if (running) {
      result.error("invalidState", "already started", null);
      return;
    }

    Integer rate = call.argument("rate");
    if (rate == null) {
      result.error("missingParam", "rate is missing", null);
      return;
    }

    int outMinSize = AudioTrack.getMinBufferSize(rate,
            AudioFormat.CHANNEL_OUT_MONO, AudioFormat.ENCODING_PCM_FLOAT);

    int bufferSize = outMinSize * 4; // 4 times the minimum for luck

    audioTrack = new AudioTrack.Builder()
            .setAudioFormat(new AudioFormat.Builder()
                    .setSampleRate(rate)
                    .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                    .setEncoding(AudioFormat.ENCODING_PCM_FLOAT)
                    .build())
            .setBufferSizeInBytes(bufferSize)
            //.setPerformanceMode(AudioTrack.PERFORMANCE_MODE_LOW_LATENCY) // only allowed at 48k
            .build();
    audioTrack.play();
    running = true;
    //audioTrack.write(new float[outMinSize / 2],
    //        0, outMinSize / 2, AudioTrack.WRITE_BLOCKING);

    result.success(bufferSize / 4); // the number of floats in the buffer (float = 4 bytes)
  }

  private void stop(MethodCall call, Result result) {
    Log.d(TAG, call.method);
    running = false;
    if (audioTrack != null) {
      audioTrack.stop();
      audioTrack.release();
      audioTrack = null;
    }
    result.success(null);
  }

  private void process(MethodCall call, Result result) {
    double[] data = call.argument("data");
    if (data == null || data.length == 0) {
      result.error("missingParam", "data is missing", null);
      return;
    }
    if (floats.length < data.length) {
      floats = new float[data.length];
    }
    for (int i = 0; i < data.length; i++) {
      floats[i] = (float) data[i];
    }
    audioTrack.write(floats, 0, data.length, AudioTrack.WRITE_NON_BLOCKING);
    result.success(null);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
