import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../data/models/active_session.dart';

final playerProvider = StateNotifierProvider<PlayerNotifier, ActiveSession?>((ref) {
  return PlayerNotifier();
});

class PlayerNotifier extends StateNotifier<ActiveSession?> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;

  PlayerNotifier() : super(null) {
    _init();
  }

  void _init() {
    final box = Hive.box<ActiveSession>('sessionBox');
    if (box.isNotEmpty) {
      state = box.getAt(0);
      if (state!.isPlaying) {
        _setupAudio();
        _startTimer();
      }
    }
  }

  Future<void> startSession(String ambienceId, String title, int durationMinutes) async {
    state = ActiveSession(
      ambienceId: ambienceId,
      ambienceTitle: title,
      startTimeMs: DateTime.now().millisecondsSinceEpoch,
      durationMinutes: durationMinutes,
      elapsedSeconds: 0,
      isPlaying: true,
    );
    _saveState();
    await _setupAudio();
    _startTimer();
  }

  Future<void> _setupAudio() async {
    try {
      // Using a public URL to guarantee audio playback works out-of-the-box
      await _audioPlayer.setUrl('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
      _audioPlayer.setLoopMode(LoopMode.one);
      if (state?.isPlaying == true) {
        _audioPlayer.play();
      }
    } catch (e) {
      print("Audio setup error: $e");
    }
  }

  void togglePlayPause() {
    if (state == null) return;
    
    final isPlaying = !state!.isPlaying;
    state = ActiveSession(
      ambienceId: state!.ambienceId,
      ambienceTitle: state!.ambienceTitle,
      startTimeMs: state!.startTimeMs,
      durationMinutes: state!.durationMinutes,
      elapsedSeconds: state!.elapsedSeconds,
      isPlaying: isPlaying,
    );
    _saveState();
    
    if (isPlaying) {
      _audioPlayer.play();
      _startTimer();
    } else {
      _audioPlayer.pause();
      _timer?.cancel();
    }
  }

  void seekTo(double progressRatio) {
    if (state == null) return;
    final totalSeconds = state!.durationMinutes * 60;
    final newSeconds = (totalSeconds * progressRatio).toInt();
    
    state = ActiveSession(
      ambienceId: state!.ambienceId,
      ambienceTitle: state!.ambienceTitle,
      startTimeMs: state!.startTimeMs,
      durationMinutes: state!.durationMinutes,
      elapsedSeconds: newSeconds,
      isPlaying: state!.isPlaying,
    );
    _saveState();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state == null || !state!.isPlaying) {
        timer.cancel();
        return;
      }
      
      final totalSeconds = state!.durationMinutes * 60;
      if (state!.elapsedSeconds >= totalSeconds) {
        // Session Ended properly
        timer.cancel();
        _audioPlayer.pause();
        state = ActiveSession(
            ambienceId: state!.ambienceId,
            ambienceTitle: state!.ambienceTitle,
            startTimeMs: state!.startTimeMs,
            durationMinutes: state!.durationMinutes,
            elapsedSeconds: totalSeconds,
            isPlaying: false,
        );
        _saveState();
        return;
      }

      state = ActiveSession(
        ambienceId: state!.ambienceId,
        ambienceTitle: state!.ambienceTitle,
        startTimeMs: state!.startTimeMs,
        durationMinutes: state!.durationMinutes,
        elapsedSeconds: state!.elapsedSeconds + 1,
        isPlaying: state!.isPlaying,
      );
    });
  }

  void endSession() {
    _timer?.cancel();
    _audioPlayer.stop();
    state = null;
    final box = Hive.box<ActiveSession>('sessionBox');
    box.clear();
  }

  void _saveState() {
    if (state != null) {
      final box = Hive.box<ActiveSession>('sessionBox');
      box.put(0, state!);
    }
  }
}
