import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:YalaPay/models/customer.dart';

class CustomerNotifier extends StateNotifier<List<Customer>> {
  CustomerNotifier() : super([]);

  Future<void> loadCustomers() async {
    final String response =
        await rootBundle.loadString('assets/data/customers.json');
    final List<dynamic> data = json.decode(response);
    state = data.map((json) => Customer.fromJson(json)).toList();
  }

  void addCustomer(Customer customer) {
    state = [...state, customer];
  }

  void deleteCustomer(String id) {
    state = state.where((customer) => customer.id != id).toList();
  }
}

final customerProvider =
    StateNotifierProvider<CustomerNotifier, List<Customer>>((ref) {
  final notifier = CustomerNotifier();
  notifier.loadCustomers();
  return notifier;
});
