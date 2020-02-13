import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:audio_push/audio_push.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _nativeRate = -1;
  Timer _timer;

  Float64List _sinWave;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    var nativeRate = -1;
    try {
      nativeRate = await AudioPush.nativeRate;
    } on PlatformException {
      nativeRate = -2;
    }

    if (nativeRate > 0) {
      _sinWave = Float64List(nativeRate ~/ 100);
      var twentyPi = 20.0 * pi;
      for (var i = 0; i < _sinWave.length; i++) {
        _sinWave[i] = sin(twentyPi * i / _sinWave.length);
      }
    }

    if (!mounted) return;

    setState(() {
      _nativeRate = nativeRate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Native rate is: $_nativeRate'),
              RaisedButton(
                child: Text('START'),
                onPressed: () {
                  AudioPush.start(_nativeRate).then(print);
                  _timer = Timer.periodic(Duration(milliseconds: 10), (_) {
                    pumpBuffer();
                  });
                  pumpBuffer();
                  pumpBuffer();
                },
              ),
              RaisedButton(
                child: Text('STOP'),
                onPressed: () {
                  _timer?.cancel();
                  _timer = null;
                  AudioPush.stop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void pumpBuffer() {
    AudioPush.process(_sinWave);
  }
}
