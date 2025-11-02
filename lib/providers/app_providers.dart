import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/medication.dart';
export 'user_provider.dart';

// Rewards points provider
final rewardsPointsProvider = StateProvider<int>((ref) => 120);

// Notifications toggle provider
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

// Recognized OCR text
final recognizedTextProvider = StateProvider<String>((ref) => '');

// Medications list provider with persistence
final medicationsProvider =
    StateNotifierProvider<MedicationsController, List<Medication>>(
  (ref) => MedicationsController()..loadFromStorage(),
);

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false);

  void login() {
    state = true;
  }

  void logout() {
    state = false;
  }
}

class MedicationsController extends StateNotifier<List<Medication>> {
  MedicationsController() : super(const []);

  static const _prefsKey = 'meds_v1';

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final data = List<Map<String, dynamic>>.from(jsonDecode(raw) as List);
      state = data
          .map((m) => Medication(
                id: m['id'] as String,
                name: m['name'] as String,
                dosage: m['dosage'] as String,
                timing: m['timing'] as String,
                taken: m['taken'] as bool? ?? false,
              ))
          .toList();
    } catch (_) {
      // ignore corrupt data; could log/report
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = state
        .map((m) => {
              'id': m.id,
              'name': m.name,
              'dosage': m.dosage,
              'timing': m.timing,
              'taken': m.taken,
            })
        .toList();
    await prefs.setString(_prefsKey, jsonEncode(data));
  }

  void setFromParsed(List<Map<String, String>> parsed) {
    state = [
      for (final m in parsed)
        Medication(
          id: _id(),
          name: m['name'] ?? 'Medicine',
          dosage: m['dosage'] ?? '—',
          timing: m['timing'] ?? 'As prescribed',
        )
    ];
    _saveToStorage();
  }

  void loadFromPrescriptionMock() {
    final examples = <Medication>[
      Medication(
          id: _id(), name: 'Atorvastatin', dosage: '20mg', timing: 'Night'),
      Medication(
          id: _id(),
          name: 'Metformin',
          dosage: '500mg',
          timing: 'Morning & Night'),
      Medication(
          id: _id(), name: 'Amlodipine', dosage: '5mg', timing: 'Morning'),
    ];
    state = examples;
    _saveToStorage();
  }

  void toggleTaken(String id, bool value) {
    state = [
      for (final m in state)
        if (m.id == id) m.copyWith(taken: value) else m,
    ];
    _saveToStorage();
  }

  double adherenceProgress() {
    if (state.isEmpty) return 0;
    final taken = state.where((m) => m.taken).length.toDouble();
    return taken / state.length;
  }

  String _id() => Random().nextInt(1 << 32).toString();
}
