import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

// Expose the AudioPlayer singleton directly so the UI can listen to its streams
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() => player.dispose());
  return player;
});

// Holds the metadata about the current session (title, url, etc.)
class SessionMeta {
  final String ambienceId;
  final String ambienceTitle;
  final String audioUrl;
  final int durationSeconds;

  const SessionMeta({
    required this.ambienceId,
    required this.ambienceTitle,
    required this.audioUrl,
    required this.durationSeconds,
  });
}

final sessionMetaProvider = StateProvider<SessionMeta?>((ref) => null);

// A helper notifier that manages player actions
final playerActionsProvider = Provider<PlayerActions>((ref) {
  final player = ref.watch(audioPlayerProvider);
  return PlayerActions(ref, player);
});

class PlayerActions {
  final Ref _ref;
  final AudioPlayer _player;

  PlayerActions(this._ref, this._player);

  Future<void> startSession(
    String ambienceId,
    String title,
    String audioUrl,
    int durationSeconds,
  ) async {
    _ref.read(sessionMetaProvider.notifier).state = SessionMeta(
      ambienceId: ambienceId,
      ambienceTitle: title,
      audioUrl: audioUrl,
      durationSeconds: durationSeconds,
    );

    try {
      await _player.setAsset(audioUrl);
      await _player.setVolume(1.0);
      await _player.setLoopMode(LoopMode.all);
      await _player.play();
    } catch (e) {
      // ignore setup errors - audio may fail on simulator
    }
  }

  void togglePlayPause() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void skipForward() {
    final current = _player.position;
    final duration = _player.duration ?? Duration.zero;
    final target = current + const Duration(seconds: 5);
    _player.seek(target > duration ? duration : target);
  }

  void skipBackward() {
    final current = _player.position;
    final target = current - const Duration(seconds: 5);
    _player.seek(target < Duration.zero ? Duration.zero : target);
  }

  void seekToRatio(double ratio) {
    final duration = _player.duration ?? Duration.zero;
    final target = Duration(milliseconds: (duration.inMilliseconds * ratio).toInt());
    _player.seek(target);
  }

  Future<void> endSession() async {
    await _player.stop();
    _ref.read(sessionMetaProvider.notifier).state = null;
  }
}

// Keep backward-compat: the old playerProvider is replaced — expose a thin wrapper
// so session_player_screen.dart can still call .notifier methods easily.
// We now use audioPlayerProvider + playerActionsProvider directly in the UI.
