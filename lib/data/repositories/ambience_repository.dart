import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ambience.dart';

final ambienceRepositoryProvider = Provider<AmbienceRepository>((ref) {
  return AmbienceRepository();
});

class AmbienceRepository {
  Future<List<Ambience>> loadAmbiences() async {
    final String response = await rootBundle.loadString('assets/data/ambiences.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Ambience.fromJson(json)).toList();
  }
}
