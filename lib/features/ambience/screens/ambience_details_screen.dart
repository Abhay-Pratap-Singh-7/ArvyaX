import 'package:flutter/material.dart';
import '../../../data/models/ambience.dart';
import '../../player/screens/session_player_screen.dart';

class AmbienceDetailsScreen extends StatelessWidget {
  final Ambience ambience;

  const AmbienceDetailsScreen({super.key, required this.ambience});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120), // Leave space for mini player later
        child: Column(
          children: [
            // Hero section with fade
            SizedBox(
              height: 400,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      ambience.heroUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: const Color(0xFF2C4A30)),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.0),
                            Theme.of(context).scaffoldBackgroundColor,
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 20,
                    child: SafeArea(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.5),
                          child: const Icon(Icons.arrow_back, color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        ambience.title,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    ambience.description,
                    style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _DetailChip(label: ambience.tag),
                      const _DetailChip(label: "Spatial Audio"),
                      _DetailChip(label: ambience.formattedDuration),
                    ],
                  ),
                  const SizedBox(height: 48),
                  
                  // Start Session Button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SessionPlayerScreen(ambience: ambience)),
                      );
                    },
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 36,
                          backgroundColor: Color(0xFF8BB18A),
                          child: Icon(Icons.play_arrow, color: Colors.white, size: 36),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "START SESSION",
                          style: TextStyle(
                            color: Color(0xFF3F6345),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Sensory Mix
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.tune, size: 20),
                            SizedBox(width: 8),
                            Text("Sensory Mix", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ...ambience.sensoryMix.map((mix) => _SensorySlider(label: mix)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Curator Notes
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.eco_outlined, size: 20, color: Color(0xFF3F6345)),
                            SizedBox(width: 8),
                            Text("Curator Notes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          ambience.curatorNotes,
                          style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  const _DetailChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _SensorySlider extends StatelessWidget {
  final String label;
  const _SensorySlider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 14))),
          Expanded(
            flex: 3,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                overlayShape: SliderComponentShape.noOverlay,
                activeTrackColor: Theme.of(context).primaryColor,
                inactiveTrackColor: Colors.grey.withOpacity(0.2),
              ),
              child: Slider(
                value: 0.7, // Dummy value purely for UI visually matching Figma
                onChanged: (val) {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
