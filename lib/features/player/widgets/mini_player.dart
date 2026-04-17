import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/player_provider.dart';
import '../../ambience/providers/ambience_provider.dart';
import '../screens/session_player_screen.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = ref.watch(sessionMetaProvider);
    if (meta == null) return const SizedBox.shrink();

    final player = ref.watch(audioPlayerProvider);
    final actions = ref.watch(playerActionsProvider);

    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, posSnap) {
        return StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, stateSnap) {
            final position = posSnap.data ?? Duration.zero;
            final total = player.duration ?? Duration(seconds: meta.durationSeconds);
            final isPlaying = stateSnap.data?.playing ?? false;
            final progress = total.inMilliseconds > 0
                ? (position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0)
                : 0.0;

            return GestureDetector(
              onTap: () {
                final ambiencesAsync = ref.read(filteredAmbiencesProvider);
                ambiencesAsync.whenData((ambiences) {
                  final ambience = ambiences.firstWhere(
                    (a) => a.id == meta.ambienceId,
                    orElse: () => ambiences.first,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SessionPlayerScreen(ambience: ambience),
                    ),
                  );
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2D22),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.graphic_eq,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  meta.ambienceTitle,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  isPlaying ? 'Playing' : 'Paused',
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                            ),
                            onPressed: actions.togglePlayPause,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.white54),
                            onPressed: actions.endSession,
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      child: LinearProgressIndicator(
                        value: progress,
                        color: const Color(0xFFA2C5A0),
                        backgroundColor: Colors.white12,
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
