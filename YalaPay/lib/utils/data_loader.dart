import 'dart:convert';
import 'package:flutter/services.dart';

Future<List<String>> loadPaymentModes() async {
  final String response =
      await rootBundle.loadString('assets/data/payment-modes.json');
  final List<dynamic> data = json.decode(response);
  return List<String>.from(data);
}

Future<List<String>> loadBanks() async {
  final String response = await rootBundle.loadString('assets/data/banks.json');
  final List<dynamic> data = json.decode(response);
  return List<String>.from(data);
}
