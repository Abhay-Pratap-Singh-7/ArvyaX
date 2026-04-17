import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/ambience.dart';
import '../../../data/repositories/ambience_repository.dart';

final ambiencesFutureProvider = FutureProvider<List<Ambience>>((ref) async {
  final repo = ref.watch(ambienceRepositoryProvider);
  return repo.loadAmbiences();
});

final selectedTagProvider = StateProvider<String?>((ref) => 'All');
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredAmbiencesProvider = Provider<AsyncValue<List<Ambience>>>((ref) {
  final ambiencesAsync = ref.watch(ambiencesFutureProvider);
  final selectedTag = ref.watch(selectedTagProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  return ambiencesAsync.whenData((ambiences) {
    return ambiences.where((ambience) {
      final matchesTag = selectedTag == null || selectedTag == 'All' || ambience.tag == selectedTag;
      final matchesQuery = ambience.title.toLowerCase().contains(searchQuery);
      return matchesTag && matchesQuery;
    }).toList();
  });
});
