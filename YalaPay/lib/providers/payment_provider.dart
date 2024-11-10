import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment.dart';
import '../models/Invoice.dart';

class PaymentNotifier extends StateNotifier<List<Payment>> {
  PaymentNotifier() : super([]);

  Future<void> loadPayments() async {
    final String response = await rootBundle.loadString('assets/payments.json');
    final List<dynamic> data = json.decode(response);
    state = data.map((payment) => Payment.fromJson(payment)).toList();
  }

  void addPayment(Payment payment) {
    state = [...state, payment];
  }

  void updatePayment(Payment payment) {
    state = [
      for (final pmt in state)
        if (pmt.id == payment.id) payment else pmt,
    ];
  }

  void deletePayment(String paymentId) {
    state = state.where((pmt) => pmt.id != paymentId).toList();
  }

  List<Payment> getPaymentsByInvoice(String invoiceNo) {
    return state.where((payment) => payment.invoiceNo == invoiceNo).toList();
  }
}

final paymentProvider =
    StateNotifierProvider<PaymentNotifier, List<Payment>>((ref) {
  return PaymentNotifier();
});
