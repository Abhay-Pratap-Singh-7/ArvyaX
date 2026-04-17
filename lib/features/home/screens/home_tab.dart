import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ambience/providers/ambience_provider.dart';
import '../../../data/models/ambience.dart';
import '../../ambience/screens/ambience_details_screen.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ambiencesAsync = ref.watch(filteredAmbiencesProvider);
    final selectedTag = ref.watch(selectedTagProvider);

    return SafeArea(
      bottom: false,
      child: ambiencesAsync.when(
        data: (ambiences) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 24, bottom: 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "Good Morning.\nFind your center today.",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 32,
                          height: 1.2,
                        ),
                  ),
                ),
                const SizedBox(height: 24),
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) =>
                          ref.read(searchQueryProvider.notifier).state = val,
                      decoration: InputDecoration(
                        hintText: "Search meditations, sounds...",
                        hintStyle: const TextStyle(color: Colors.black38),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(
                              right: 8.0, top: 4, bottom: 4),
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: const Icon(Icons.mic_none,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Tags
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: ['All', 'Focus', 'Sleep', 'Calm', 'Reset']
                        .map((tag) {
                      final isSelected = selectedTag == tag ||
                          (selectedTag == null && tag == 'All');
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: ChoiceChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (_) =>
                              ref.read(selectedTagProvider.notifier).state =
                                  tag,
                          showCheckmark: false,
                          selectedColor: Theme.of(context).primaryColor,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color:
                                isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                                color: Colors.grey.withOpacity(0.2)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                if (ambiences.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 48),
                        const Text("No ambiences found",
                            style: TextStyle(
                                fontSize: 18, color: Colors.black54)),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            ref.read(searchQueryProvider.notifier).state = '';
                            ref.read(selectedTagProvider.notifier).state =
                                'All';
                          },
                          child: const Text("Clear Filters",
                              style:
                                  TextStyle(color: Color(0xFF3F6345))),
                        ),
                      ],
                    ),
                  )
                else ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text("Featured",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 380,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      itemCount:
                          ambiences.length > 5 ? 5 : ambiences.length,
                      clipBehavior: Clip.none,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child:
                              _AmbienceCard(ambience: ambiences[index]),
                        );
                      },
                    ),
                  ),
                  if (ambiences.length > 5) ...[
                    const SizedBox(height: 32),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text("Discover More",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 380,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24),
                        itemCount: ambiences.length - 5,
                        clipBehavior: Clip.none,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(right: 16),
                            child: _AmbienceCard(
                                ambience: ambiences[index + 5]),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text("Error: $error")),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _AmbienceCard extends StatelessWidget {
  final Ambience ambience;
  const _AmbienceCard({required this.ambience});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AmbienceDetailsScreen(ambience: ambience)),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.70,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Hero image ────────────────────────────────────────
              Image.network(
                ambience.heroUrl,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: const Color(0xFF2C4A30),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Color(0xFFA2C5A0),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF2C4A30)),
              ),

              // ── Dark gradient overlay ─────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black54,
                    ],
                    stops: [0.3, 1.0],
                  ),
                ),
              ),

              // ── Card content ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tag badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white30, width: 0.5),
                      ),
                      child: Text(
                        ambience.tag.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Title
                    Text(
                      ambience.title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                    ),
                    const SizedBox(height: 14),
                    // Bottom row
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            color: Colors.white70, size: 15),
                        const SizedBox(width: 4),
                        Text(
                          ambience.formattedDuration,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(width: 10),
                        const Text("·",
                            style: TextStyle(
                                color: Colors.white38, fontSize: 16)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ambience.sensoryMix.firstOrNull ??
                                "Nature",
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Play button
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(
                                color: Colors.white38, width: 0.5),
                          ),
                          child: const Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
