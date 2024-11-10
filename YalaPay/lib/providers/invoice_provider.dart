import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/Invoice.dart';
import '../models/payment.dart';
import 'payment_provider.dart';

class InvoiceNotifier extends StateNotifier<List<Invoice>> {
  InvoiceNotifier(this.ref) : super([]);

  final Ref ref;

  Future<void> loadInvoices() async {
    final String response =
        await rootBundle.loadString('assets/data/invoices.json');
    final List<dynamic> data = json.decode(response);
    final invoices = data.map((invoice) => Invoice.fromJson(invoice)).toList();

    // Load payments and associate them with invoices
    await ref.read(paymentProvider.notifier).loadPayments();
    final payments = ref.read(paymentProvider);
    for (var invoice in invoices) {
      invoice.payments =
          payments.where((p) => p.invoiceNo == invoice.id).toList();
    }
    state = invoices;
  }

  void addInvoice(Invoice invoice) {
    state = [...state, invoice];
  }

  void updateInvoice(Invoice invoice) {
    state = [
      for (final inv in state)
        if (inv.id == invoice.id) invoice else inv,
    ];
  }

  void deleteInvoice(String invoiceId) {
    state = state.where((inv) => inv.id != invoiceId).toList();
  }
}

final invoiceProvider =
    StateNotifierProvider<InvoiceNotifier, List<Invoice>>((ref) {
  return InvoiceNotifier(ref);
});
