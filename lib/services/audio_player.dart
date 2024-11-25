import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  late AudioPlayer _audioPlayer;

  void initializeAudioPlayer(String audioUrl) async {
    _audioPlayer = AudioPlayer();
    try {
      await _audioPlayer.setUrl(audioUrl);
      _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void playAudio(String audioUrl) async {
    initializeAudioPlayer(audioUrl);
  }
}