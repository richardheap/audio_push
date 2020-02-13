# audio_push

An simple, example plugin to push blocks of audio to the sound card.

This simple plugin was created for a talk to the Flutter NYC Meetup.
It demonstrates some simple Dart->Native calls to find the default
sample rate of the sound system, to start and stop an audio stream
and to top up the output buffer.

> Since the timing of push audio relies too heavily
on the Dart timer, this shouldn't be used in a real system. Instead, use
the companion plugin [audio_worklet](https://github.com/richardheap/audio_worklet) which instead
pulls audio blocks from the native side.

## Usage

A typical first use is to query the default sample rate of the sound system.

```dart
import 'package:audio_push/audio_push.dart';

var nativeRate = await AudioPush.nativeRate;
```

See the example app for examples of `start`, `stop` and `process`.