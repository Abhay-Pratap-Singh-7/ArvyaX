import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/journal_provider.dart';

class JournalScreen extends ConsumerStatefulWidget {
  final String ambienceTitle;

  const JournalScreen({super.key, required this.ambienceTitle});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  String _selectedMood = 'Calm';
  final TextEditingController _textController = TextEditingController();

  final List<Map<String, String>> _moods = [
    {'label': 'Calm', 'emoji': '😌'},
    {'label': 'Grounded', 'emoji': '😐'},
    {'label': 'Energized', 'emoji': '😃'},
    {'label': 'Sleepy', 'emoji': '😴'},
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _saveReflection() {
    // Bonus Feature: Haptic feedback
    HapticFeedback.mediumImpact();
    
    ref.read(journalProvider.notifier).addEntry(
      ambienceTitle: widget.ambienceTitle,
      mood: _selectedMood,
      content: _textController.text,
    );
    
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Evening Reflection", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                children: [
                  const Text("How are you feeling today?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _moods.map((mood) {
                      final isSelected = _selectedMood == mood['label'];
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedMood = mood['label']!);
                        },
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: isSelected ? const Color(0xFF6A7F70) : const Color(0xFFF0F2F0),
                          child: Text(mood['emoji']!, style: const TextStyle(fontSize: 28)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text("What's on your mind?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "Write your thoughts here...",
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _saveReflection,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F6345),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Save Reflection", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
