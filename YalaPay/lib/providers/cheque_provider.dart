// cheque_provider.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:YalaPay/models/cheque.dart';

// StateNotifier to manage loading and storing the cheques
class ChequeNotifier extends StateNotifier<List<Cheque>> {
  ChequeNotifier() : super([]);

  // Load cheques from JSON file
  Future<void> loadCheques() async {
    final String response =
        await rootBundle.loadString('assets/data/cheques.json');
    final List<dynamic> data = json.decode(response);
    final loadedCheques = data.map((json) => Cheque.fromJson(json)).toList();
    state = loadedCheques;
  }
}

// Provider to expose the ChequeNotifier
final chequeProvider =
    StateNotifierProvider<ChequeNotifier, List<Cheque>>((ref) {
  final notifier = ChequeNotifier();
  notifier.loadCheques(); // Load cheques when provider is first accessed
  return notifier;
});
