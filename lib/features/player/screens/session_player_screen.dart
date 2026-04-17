import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/ambience.dart';
import '../providers/player_provider.dart';
import '../../journal/screens/journal_screen.dart';

class SessionPlayerScreen extends ConsumerStatefulWidget {
  final Ambience ambience;

  const SessionPlayerScreen({super.key, required this.ambience});

  @override
  ConsumerState<SessionPlayerScreen> createState() => _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends ConsumerState<SessionPlayerScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
       vsync: this,
       duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    // Start session when opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playerProvider.notifier).startSession(
        widget.ambience.id, 
        widget.ambience.title, 
        widget.ambience.durationMinutes,
      );
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _endSession(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("End Session?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              ref.read(playerProvider.notifier).endSession();
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => JournalScreen(ambienceTitle: widget.ambience.title)),
              );
            },
            child: const Text("End", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeSession = ref.watch(playerProvider);
    final isPlaying = activeSession?.isPlaying ?? false;
    final elapsed = activeSession?.elapsedSeconds ?? 0;
    final total = (activeSession?.durationMinutes ?? widget.ambience.durationMinutes) * 60;
    
    // Auto-Completion check
    if (activeSession != null && elapsed >= total && !isPlaying) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
         ref.read(playerProvider.notifier).endSession();
         Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => JournalScreen(ambienceTitle: widget.ambience.title)),
         );
       });
    }

    return Scaffold(
      backgroundColor: Colors.black, // Dark mode for player
      body: Stack(
        children: [
          // Background Image with breathing gradient
          Positioned.fill(
            child: Opacity(
              opacity: 0.6,
              child: Image.network(
                widget.ambience.heroUrl.contains('http') ? widget.ambience.heroUrl : "https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?auto=format&fit=crop&w=800",
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.network(
                  "https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?auto=format&fit=crop&w=800",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.8 + (_animController.value * 0.15)),
                      ],
                      radius: 1.2,
                    ),
                  ),
                );
              },
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 36),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Spacer(flex: 2),
                
                // Breathing Title
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                     return Transform.scale(
                        scale: 1.0 + (_animController.value * 0.05),
                        child: Text(
                          "Breathe\nOut",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 72,
                            height: 1.1,
                          ),
                        ),
                     );
                  },
                ),
                
                const Spacer(flex: 3),
                
                // Player Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      // Seek bar
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          activeTrackColor: const Color(0xFFA2C5A0),
                          inactiveTrackColor: Colors.white.withOpacity(0.2),
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 0,
                          onChanged: (val) {
                             ref.read(playerProvider.notifier).seekTo(val);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatTime(elapsed), style: const TextStyle(color: Colors.white70)),
                            Text(_formatTime(total), style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Play/Pause Button
                      GestureDetector(
                        onTap: () {
                          ref.read(playerProvider.notifier).togglePlayPause();
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFF6A7F70),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                
                // End Session Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: TextButton(
                    onPressed: () => _endSession(context),
                    child: const Text("END SESSION", style: TextStyle(color: Colors.white54, letterSpacing: 2)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
