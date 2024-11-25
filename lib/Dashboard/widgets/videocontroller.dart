import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayerWidgetscreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidgetscreen({Key? key, required this.videoUrl})
      : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidgetscreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              VisibilityDetector(
                key: Key(widget.videoUrl),
                onVisibilityChanged: (visibilityInfo) {
                  if (visibilityInfo.visibleFraction == 0) {
                    _pauseVideo();
                  } else if (visibilityInfo.visibleFraction == 1) {
                    _playVideo();
                  }
                },
                child: VideoPlayer(_controller),
              ),
              _buildControls(),
            ],
          ),
        ),
        _buildDuration(),
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isPlaying ? _controller.pause() : _controller.play();
                  _isPlaying = !_isPlaying;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDuration() {
    return _controller.value.isInitialized
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: _controller.value.position.inSeconds.toDouble() /
                      _controller.value.duration.inSeconds.toDouble(),
                  minHeight: 4.0,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.red), // Change color to red
                ),
              ],
            ),
          )
        : Container();
  }

  void _playVideo() {
    if (!_isPlaying) {
      _controller.play();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  void _pauseVideo() {
    if (_isPlaying) {
      _controller.pause();
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
