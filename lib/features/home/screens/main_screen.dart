import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../journal/screens/history_tab.dart';
import '../../player/widgets/mini_player.dart';
import 'home_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  // Drifting blob controllers for the app-wide background
  late final AnimationController _blob1;
  late final AnimationController _blob2;

  final List<Widget> _tabs = [
    const HomeTab(),
    const HistoryTab(),
    const Center(child: Text("Profile (Placeholder)")),
  ];

  @override
  void initState() {
    super.initState();
    _blob1 = AnimationController(
        vsync: this, duration: const Duration(seconds: 25))
      ..repeat();
    _blob2 = AnimationController(
        vsync: this, duration: const Duration(seconds: 19))
      ..repeat();
  }

  @override
  void dispose() {
    _blob1.dispose();
    _blob2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      body: Stack(
        children: [
          // ── Drifting blurred blob background ──────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge([_blob1, _blob2]),
              builder: (_, __) => CustomPaint(
                painter: _AppBlobPainter(
                  t1: _blob1.value,
                  t2: _blob2.value,
                ),
              ),
            ),
          ),

          // ── Tab content (transparent scaffold so bg shows through) ─────
          _tabs[_currentIndex],

          // ── Mini player ────────────────────────────────────────────────
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: const MiniPlayer(),
          ),

          // ── Floating bottom nav bar ────────────────────────────────────
          Positioned(
            bottom: 32,
            left: 32,
            right: 32,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.80),
                borderRadius: BorderRadius.circular(36),
                border:
                    Border.all(color: Colors.white.withOpacity(0.6), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavBarIcon(
                    icon: Icons.eco_outlined,
                    isSelected: _currentIndex == 0,
                    onTap: () => setState(() => _currentIndex = 0),
                  ),
                  _NavBarIcon(
                    icon: Icons.article_outlined,
                    isSelected: _currentIndex == 1,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  _NavBarIcon(
                    icon: Icons.person_outline,
                    isSelected: _currentIndex == 2,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App-wide blob painter (light green on off-white background)
//
// Two large, heavily-blurred green circles drift slowly across the screen.
// Colours are desaturated so they stay subtle on light backgrounds.
// ─────────────────────────────────────────────────────────────────────────────

class _AppBlobPainter extends CustomPainter {
  final double t1; // 0 → 1 over 25 s
  final double t2; // 0 → 1 over 19 s

  const _AppBlobPainter({required this.t1, required this.t2});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Off-white base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFF0F5F0),
    );

    // Blob positions — independent Lissajous paths
    final x1 = w * 0.60 + w * 0.40 * math.sin(t1 * 2 * math.pi);
    final y1 = h * 0.30 + h * 0.25 * math.cos(t1 * 2 * math.pi * 1.2);

    final x2 = w * 0.40 + w * 0.35 * math.cos(t2 * 2 * math.pi + math.pi / 3);
    final y2 = h * 0.70 + h * 0.20 * math.sin(t2 * 2 * math.pi * 0.85 + 0.8);

    final blobPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80)
      ..style = PaintingStyle.fill;

    // Blob 1 — soft sage green
    blobPaint.color = const Color(0xFF8FBE8F).withOpacity(0.45);
    canvas.drawCircle(Offset(x1, y1), w * 0.60, blobPaint);

    // Blob 2 — cooler mint
    blobPaint.color = const Color(0xFF78C4A0).withOpacity(0.35);
    canvas.drawCircle(Offset(x2, y2), w * 0.50, blobPaint);
  }

  @override
  bool shouldRepaint(covariant _AppBlobPainter old) =>
      old.t1 != t1 || old.t2 != t2;
}

// ─────────────────────────────────────────────────────────────────────────────

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarIcon({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : const Color(0xFF6A7F70),
          size: 28,
        ),
      ),
    );
  }
}
