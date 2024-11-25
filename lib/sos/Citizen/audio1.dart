import 'dart:async';
import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:record/record.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class AudioScreen extends StatefulWidget {
  final Function(String) onAudioRecorded;

  AudioScreen({Key? key, required this.onAudioRecorded}) : super(key: key);

  _AudioScreenState createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  final RecorderController recorderController = RecorderController();
  final PlayerController playerController = PlayerController();

  late Record record;
  late audio.AudioPlayer audioPlayer;
  bool isRecording = false;
  String audioPath = '';
  bool isAudioPlaying = false;
  bool isCheckIconTapped = false;
  int recordingDurationInSeconds = 0;
  late Timer recordingTimer;

  @override
  void initState() {
    super.initState();
    audioPlayer = audio.AudioPlayer();
    record = Record();

    audioPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        isAudioPlaying = event == audio.PlayerState.playing;
      });
    });
  }

  @override
  void dispose() {
    record.dispose();
    audioPlayer.dispose();
    recordingTimer.cancel();

    super.dispose();
  }

  void startRecordingTimer() {
    recordingTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      setState(() {
        recordingDurationInSeconds++;
      });
    });
  }

  void stopRecordingTimer() {
    recordingTimer.cancel();
  }

  Future<void> startRecording() async {
    try {
      if (await record.hasPermission()) {
        await record.start();
        setState(() {
          isRecording = true;
          recordingDurationInSeconds = 0;
        });
        startRecordingTimer();
      }
    } catch (e) {
      print('Error starting record: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      String? path = await record.stop();
      setState(() {
        isRecording = false;
        audioPath = path!;
      });
      stopRecordingTimer();
    } catch (e) {
      print('Error stopping record: $e');
    }
  }

  Future<void> playRecording() async {
    try {
      audio.Source urlSource = audio.UrlSource(audioPath);
      await audioPlayer.play(urlSource);
    } catch (e) {
      print('Error playing recording: $e');
    }
  }

  Future<void> pauseRecording() async {
    try {
      await audioPlayer.pause();
    } catch (e) {
      print('Error pausing recording: $e');
    }
  }

  void _shareAudioFile() {
    if (audioPath.isNotEmpty) {
      Navigator.of(context).pop(audioPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isRecording)
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    height: 200,
                    width: double.infinity,
                    child: VerticalLinesWaveWidget()),
              if (isRecording)
                Text(
                  Duration(seconds: recordingDurationInSeconds).toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (isAudioPlaying)
                Container(
                    height: 200, width: double.infinity, child: WaveWidgetss()),
              const SizedBox(
                height: 30,
              ),
              if (isRecording)
                const Text(
                  'Click here to stop recording',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink),
                )
              else
                const Text(
                  'Click here to start recording',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink),
                ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: isRecording ? stopRecording : startRecording,
                child: Container(
                  child: isRecording
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.grey[350]),
                            child: const Center(
                              child: Icon(
                                Icons.replay,
                                size: 51,
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.grey[350],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.mic,
                                size: 51,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Visibility(
                visible:
                    !isRecording && audioPath != null && audioPath.isNotEmpty,
                child: Container(
                  padding: EdgeInsets.only(right: 20.0, left: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 55.w,
                        height: 55.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromRGBO(216, 6, 131, 1),
                              Color.fromRGBO(99, 7, 114, 1),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            if (isAudioPlaying) {
                              pauseRecording();
                            } else {
                              playRecording();
                            }
                          },
                          child: Center(
                            child: Icon(
                              isAudioPlaying ? Icons.pause : Icons.play_arrow,
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          width: 20.w), // Add spacing between the containers
                      Container(
                        width: 55.w,
                        height: 55.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromRGBO(216, 6, 131, 1),
                              Color.fromRGBO(99, 7, 114, 1),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            _shareAudioFile();
                          },
                          child: const Center(
                            child: Icon(
                              Icons.check,
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaveWidgetss extends StatelessWidget {
  const WaveWidgetss({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WaveWidget(
      config: CustomConfig(
        gradients: [
          [Colors.blue, Colors.blue],
          [Colors.blue.shade200, Colors.blue.shade400],
          [Colors.blue.shade100, Colors.blue.shade200],
          [Colors.blue.shade50, Colors.blue.shade100],
        ],
        durations: [3500, 3000, 2500, 2000],
        heightPercentages: [0.3, 0.4, 0.5, 0.6],
      ),
      waveAmplitude: 0,
      backgroundColor: Colors.white,
      size: Size(double.infinity, double.infinity),
    );
  }
}

class PulsatingWaveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WaveWidget(
      config: CustomConfig(
        gradients: [
          [Colors.pink, Colors.pink],
          [Colors.pink.shade200, Colors.pink.shade400],
          [Colors.pink.shade100, Colors.pink.shade200],
          [Colors.pink.shade50, Colors.pink.shade100],
        ],
        durations: [1200, 1000, 800, 600],
        heightPercentages: [0.3, 0.4, 0.5, 0.6],
      ),
      waveAmplitude: 0,
      backgroundColor: Colors.white,
      size: Size(double.infinity, double.infinity),
    );
  }
}

class VerticalLinesWaveWidget extends StatefulWidget {
  @override
  _VerticalLinesWaveWidgetState createState() =>
      _VerticalLinesWaveWidgetState();
}

class _VerticalLinesWaveWidgetState extends State<VerticalLinesWaveWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<double> _offsets;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _offsets = List.generate(50, (index) => 0.0); // Generating 20 lines
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _offsets.insert(0, _controller.value);
        _offsets.removeLast();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return CustomPaint(
          painter: VerticalLinesWavePainter(
            offsets: _offsets,
            height: constraints.maxHeight,
            borderRadius: 20,
          ),
          size: Size(double.infinity, constraints.maxHeight),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class VerticalLinesWavePainter extends CustomPainter {
  final List<double> offsets;
  final double height;
  final double borderRadius;

  VerticalLinesWavePainter({
    required this.offsets,
    required this.height,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..strokeWidth = 10.0; // Set the width of the lines

    final double lineHeight = height / 2; // Height of each line
    final double spacing = size.width / 30; // Space between lines

    for (int i = 0; i < offsets.length; i++) {
      final double x =
          i * spacing + spacing / 2; // Adjust x coordinate with spacing
      final double startY = (i % 2 == 0)
          ? (height - lineHeight) / 2
          : (height - lineHeight) / 2 - lineHeight / 10;
      final double endY = startY + lineHeight;

      final double oscillationOffset = sin(offsets[i] * pi) * (lineHeight / 2);
      final double modifiedStartY = startY + oscillationOffset;
      final double modifiedEndY = endY + oscillationOffset;

      // Create a rounded rectangle
      final Rect rect = Rect.fromLTRB(x - paint.strokeWidth / 2, modifiedStartY,
          x + paint.strokeWidth / 2, modifiedEndY);
      final RRect roundedRect =
          RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

      // Define gradient for line
      final Shader gradientShader = LinearGradient(
        colors: [
          Colors.blueAccent,
          Colors.purpleAccent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);

      paint.shader = gradientShader;

      // Draw rounded rectangle with gradient
      canvas.drawRRect(roundedRect, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
