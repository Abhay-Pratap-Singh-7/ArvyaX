import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/player_provider.dart';
import '../../ambience/providers/ambience_provider.dart';
import '../screens/session_player_screen.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(playerProvider);

    if (activeSession == null) {
      return const SizedBox.shrink();
    }

    final total = activeSession.durationMinutes * 60;
    final progress = total > 0 ? (activeSession.elapsedSeconds / total).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: () async {
        final ambiencesAsync = ref.read(filteredAmbiencesProvider);
        ambiencesAsync.whenData((ambiences) {
          final ambience = ambiences.firstWhere((a) => a.id == activeSession.ambienceId, orElse: () => ambiences.first);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SessionPlayerScreen(ambience: ambience)),
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
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.graphic_eq, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeSession.ambienceTitle,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          activeSession.isPlaying ? "Playing" : "Paused",
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      activeSession.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      ref.read(playerProvider.notifier).togglePlayPause();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () {
                      ref.read(playerProvider.notifier).endSession();
                    },
                  ),
                ],
              ),
            ),
            // Progress Bar
            ClipRRect(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
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
  }
}
