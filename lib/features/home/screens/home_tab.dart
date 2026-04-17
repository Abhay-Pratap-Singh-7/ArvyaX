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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 0, 0), // Removed right padding for scroll bleed
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 24),
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
              padding: const EdgeInsets.only(right: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                  decoration: InputDecoration(
                    hintText: "Search meditations, sounds...",
                    hintStyle: const TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0, top: 4, bottom: 4),
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: const Icon(Icons.mic_none, color: Colors.white, size: 20),
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
              child: Row(
                children: ['All', 'Focus', 'Sleep', 'Calm', 'Reset'].map((tag) {
                  final isSelected = selectedTag == tag || (selectedTag == null && tag == 'All');
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (selected) {
                        ref.read(selectedTagProvider.notifier).state = tag;
                      },
                      selectedColor: Theme.of(context).primaryColor,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ambiencesAsync.when(
                data: (ambiences) {
                  if (ambiences.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("No ambiences found", style: TextStyle(fontSize: 18, color: Colors.black54)),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              ref.read(searchQueryProvider.notifier).state = '';
                              ref.read(selectedTagProvider.notifier).state = 'All';
                            },
                            child: const Text("Clear Filters", style: TextStyle(color: Color(0xFF3F6345))),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: ambiences.length,
                    padding: const EdgeInsets.only(bottom: 120, right: 24), // Padding for nav bar and right edge bleed
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _AmbienceCard(ambience: ambiences[index]),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text("Error: $error")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbienceCard extends StatelessWidget {
  final Ambience ambience;
  const _AmbienceCard({required this.ambience});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AmbienceDetailsScreen(ambience: ambience)),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(32),
          image: const DecorationImage(
             // Placeholder logic based on tag or random
             image: NetworkImage("https://images.unsplash.com/photo-1542273917363-3b1817f69a2d?auto=format&fit=crop&w=800&q=80"),
             fit: BoxFit.cover,
             colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "FEATURED",
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Text(
                ambience.title,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text("${ambience.durationMinutes} Min", style: const TextStyle(color: Colors.white)),
                  const SizedBox(width: 12),
                  const Text("•", style: TextStyle(color: Colors.white54)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ambience.sensoryMix.firstOrNull ?? "Nature", 
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: const Icon(Icons.play_arrow, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
