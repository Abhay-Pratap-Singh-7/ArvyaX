import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math' as math;
import '../../../data/models/ambience.dart';
import '../providers/player_provider.dart';
import '../../journal/screens/journal_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────

class SessionPlayerScreen extends ConsumerStatefulWidget {
  final Ambience ambience;
  const SessionPlayerScreen({super.key, required this.ambience});

  @override
  ConsumerState<SessionPlayerScreen> createState() =>
      _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends ConsumerState<SessionPlayerScreen>
    with TickerProviderStateMixin {
  // Blob drift controllers — very slow, organic loops
  late final AnimationController _blob1;
  late final AnimationController _blob2;

  // Breathing core glow
  late final AnimationController _breathe;

  // Pulse ring controllers (staggered)
  late final AnimationController _ring1;
  late final AnimationController _ring2;
  late final AnimationController _ring3;


  @override
  void initState() {
    super.initState();

    // Blobs drift on different periods for organic feel
    _blob1 = AnimationController(
        vsync: this, duration: const Duration(seconds: 22))
      ..repeat();
    _blob2 = AnimationController(
        vsync: this, duration: const Duration(seconds: 17))
      ..repeat();

    // Core glow pulse
    _breathe = AnimationController(
        vsync: this, duration: const Duration(seconds: 5))
      ..repeat(reverse: true);

    // Staggered rings
    _ring1 = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _ring2 = AnimationController(
        vsync: this, duration: const Duration(seconds: 3));
    _ring3 = AnimationController(
        vsync: this, duration: const Duration(seconds: 3));

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _ring2.repeat();
    });
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) _ring3.repeat();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only start a NEW session if there is no active one.
      // If the user comes back from mini-player, sessionMetaProvider
      // is already set — we just reconnect without restarting audio.
      final existingMeta = ref.read(sessionMetaProvider);
      if (existingMeta == null || existingMeta.ambienceId != widget.ambience.id) {
        ref.read(playerActionsProvider).startSession(
              widget.ambience.id,
              widget.ambience.title,
              widget.ambience.audioUrl,
              widget.ambience.durationSeconds,
            );
      }
    });
  }

  @override
  void dispose() {
    _blob1.dispose();
    _blob2.dispose();
    _breathe.dispose();
    _ring1.dispose();
    _ring2.dispose();
    _ring3.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _endSession(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('End Session?'),
        content: const Text('Your progress will be saved.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep Going')),
          TextButton(
            onPressed: () async {
              await ref.read(playerActionsProvider).endSession();
              if (!context.mounted) return;
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      JournalScreen(ambienceTitle: widget.ambience.title),
                ),
              );
            },
            child:
                const Text('End', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(audioPlayerProvider);
    final actions = ref.watch(playerActionsProvider);
    final meta = ref.watch(sessionMetaProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF060E07),
      body: Stack(
        children: [
          // ── Drifting blob background ───────────────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge([_blob1, _blob2]),
              builder: (_, __) => CustomPaint(
                painter: _DriftingBlobPainter(
                  t1: _blob1.value,
                  t2: _blob2.value,
                ),
              ),
            ),
          ),

          // ── UI content ─────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Colors.white, size: 36),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      if (meta != null)
                        Text(
                          meta.ambienceTitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // ── Staggered pulse ring animation ────────────────────────
                SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ring
                      AnimatedBuilder(
                        animation: _ring3,
                        builder: (_, __) => _PulseRing(
                          progress: _ring3.value,
                          maxRadius: 110,
                          color: const Color(0xFFA2C5A0),
                        ),
                      ),
                      // Middle ring
                      AnimatedBuilder(
                        animation: _ring2,
                        builder: (_, __) => _PulseRing(
                          progress: _ring2.value,
                          maxRadius: 88,
                          color: const Color(0xFFA2C5A0),
                        ),
                      ),
                      // Inner ring
                      AnimatedBuilder(
                        animation: _ring1,
                        builder: (_, __) => _PulseRing(
                          progress: _ring1.value,
                          maxRadius: 66,
                          color: const Color(0xFFCDE4CC),
                        ),
                      ),
                      // Glowing core orb
                      AnimatedBuilder(
                        animation: _breathe,
                        builder: (_, __) {
                          final v = _breathe.value;
                          return Container(
                            width: 52 + v * 10,
                            height: 52 + v * 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF8BB18A)
                                  .withOpacity(0.92),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFA2C5A0)
                                      .withOpacity(0.55),
                                  blurRadius: 28 + v * 16,
                                  spreadRadius: 4 + v * 4,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // ── Stream-driven controls ────────────────────────────────
                StreamBuilder<Duration>(
                  stream: player.positionStream,
                  builder: (context, posSnap) => StreamBuilder<PlayerState>(
                    stream: player.playerStateStream,
                    builder: (context, stateSnap) {
                      final position = posSnap.data ?? Duration.zero;
                      final duration = player.duration ??
                          Duration(
                              seconds: widget.ambience.durationSeconds);
                      final isPlaying =
                          stateSnap.data?.playing ?? false;
                      final progress = duration.inMilliseconds > 0
                          ? (position.inMilliseconds /
                                  duration.inMilliseconds)
                              .clamp(0.0, 1.0)
                          : 0.0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32),
                        child: Column(
                          children: [
                            // ── Semi-circle arc ─────────────────────
                            SizedBox(
                              width: 280,
                              height: 140,
                              child: CustomPaint(
                                painter: SemiCircleProgressPainter(
                                  progress: progress,
                                  trackColor:
                                      Colors.white.withOpacity(0.15),
                                  fillColor: const Color(0xFFA2C5A0),
                                  strokeWidth: 7,
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            // ── Time labels ─────────────────────────
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_fmt(position),
                                    style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 13)),
                                Text(_fmt(duration),
                                    style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 13)),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // ── Transport controls ──────────────────
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                _SkipButton(
                                  label: '5',
                                  direction: SkipDir.backward,
                                  onTap: actions.skipBackward,
                                ),
                                const SizedBox(width: 36),
                                GestureDetector(
                                  onTap: actions.togglePlayPause,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF6A7F70),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF6A7F70)
                                              .withOpacity(0.5),
                                          blurRadius: 24,
                                          spreadRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 44,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 36),
                                _SkipButton(
                                  label: '5',
                                  direction: SkipDir.forward,
                                  onTap: actions.skipForward,
                                ),
                              ],
                            ),

                            const SizedBox(height: 28),

                            // ── Volume slider ───────────────────────
                            StreamBuilder<double>(
                              stream: player.volumeStream,
                              builder: (_, volSnap) {
                                final volume = volSnap.data ?? 1.0;
                                return Row(
                                  children: [
                                    const Icon(Icons.volume_down,
                                        color: Colors.white38,
                                        size: 18),
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderThemeData(
                                          trackHeight: 2,
                                          thumbShape:
                                              const RoundSliderThumbShape(
                                                  enabledThumbRadius: 6),
                                          activeTrackColor:
                                              const Color(0xFFA2C5A0),
                                          inactiveTrackColor:
                                              Colors.white24,
                                          thumbColor: Colors.white,
                                          overlayColor: Colors.white10,
                                        ),
                                        child: Slider(
                                          value:
                                              volume.clamp(0.0, 1.0),
                                          onChanged: (v) =>
                                              player.setVolume(v),
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.volume_up,
                                        color: Colors.white38,
                                        size: 18),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const Spacer(),

                // ── End session button ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: TextButton(
                    onPressed: () => _endSession(context),
                    child: const Text(
                      'END SESSION',
                      style: TextStyle(
                        color: Colors.white30,
                        letterSpacing: 2.5,
                        fontSize: 12,
                      ),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Drifting blob painter
//
// Two large green circles move along independent Lissajous-like sine paths.
// MaskFilter.blur (Skia) applies a heavy gaussian blur per-circle on the GPU.
// A top dark vignette is painted over them for depth.
// ─────────────────────────────────────────────────────────────────────────────

class _DriftingBlobPainter extends CustomPainter {
  final double t1; // 0 → 1 over 22 s
  final double t2; // 0 → 1 over 17 s

  const _DriftingBlobPainter({required this.t1, required this.t2});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Dark background ──────────────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFF060E07),
    );

    // ── Blob positions — Lissajous paths ────────────────────────────
    // Blob 1: moves in a wide ellipse offset to upper-left
    final x1 = w * 0.55 + w * 0.38 * math.sin(t1 * 2 * math.pi);
    final y1 = h * 0.35 + h * 0.22 * math.cos(t1 * 2 * math.pi * 1.3);

    // Blob 2: slightly slower, moves lower-right
    final x2 = w * 0.45 + w * 0.32 * math.cos(t2 * 2 * math.pi + math.pi / 2.5);
    final y2 = h * 0.65 + h * 0.20 * math.sin(t2 * 2 * math.pi * 0.9 + 1.0);

    // ── Paint blobs with heavy blur (GPU-accelerated via Skia) ───────
    final blobPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 72)
      ..style = PaintingStyle.fill;

    // Blob 1 — vivid forest green
    blobPaint.color = const Color(0xFF3F7045).withOpacity(0.85);
    canvas.drawCircle(Offset(x1, y1), w * 0.55, blobPaint);

    // Blob 2 — deeper emerald, small size contrast
    blobPaint.color = const Color(0xFF2A5C35).withOpacity(0.80);
    canvas.drawCircle(Offset(x2, y2), w * 0.48, blobPaint);

    // ── Top + bottom dark vignette for depth ─────────────────────────
    final vignetteTop = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF060E07).withOpacity(0.70),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), vignetteTop);

    final vignetteBottom = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFF060E07).withOpacity(0.75),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), vignetteBottom);
  }

  @override
  bool shouldRepaint(covariant _DriftingBlobPainter old) =>
      old.t1 != t1 || old.t2 != t2;
}

// ─────────────────────────────────────────────────────────────────────────────
// Pulse ring — expands from center and fades out
// ─────────────────────────────────────────────────────────────────────────────

class _PulseRing extends StatelessWidget {
  final double progress;
  final double maxRadius;
  final Color color;

  const _PulseRing(
      {required this.progress,
      required this.maxRadius,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final radius = maxRadius * progress;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withOpacity(opacity * 0.55),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skip button
// ─────────────────────────────────────────────────────────────────────────────

enum SkipDir { forward, backward }

class _SkipButton extends StatelessWidget {
  final String label;
  final SkipDir direction;
  final VoidCallback onTap;

  const _SkipButton(
      {required this.label,
      required this.direction,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isForward = direction == SkipDir.forward;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.10),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isForward
                  ? Icons.fast_forward_rounded
                  : Icons.fast_rewind_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 1),
            Text(
              '${label}s',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Semi-circle progress painter
// ─────────────────────────────────────────────────────────────────────────────

class SemiCircleProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;

  const SemiCircleProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    this.strokeWidth = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    if (progress > 0) {
      canvas.drawArc(
        rect,
        math.pi,
        math.pi * progress,
        false,
        Paint()
          ..color = fillColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SemiCircleProgressPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.fillColor != fillColor;
}
