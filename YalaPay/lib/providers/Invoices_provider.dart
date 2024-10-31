import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/invoices.dart';
import '../models/payments.dart';

class InvoicesNotifier extends StateNotifier<InvoicesByStatus> {
  InvoicesNotifier() : super(InvoicesByStatus.initial()) {
    _loadData();
  }

  List<Invoices> _allInvoices = [];
  List<Payments> _allPayments = [];
  DateTime? startDate;
  DateTime? endDate;

  Future<void> _loadData() async {
    try {
      String invoicesData =
          await rootBundle.loadString('assets/data/invoices.json');
      var invoicesJson = jsonDecode(invoicesData);
      _allInvoices = invoicesJson
          .map<Invoices>((json) => Invoices.fromJson(json))
          .toList();

      String paymentsData =
          await rootBundle.loadString('assets/data/payments.json');
      var paymentsJson = jsonDecode(paymentsData);
      _allPayments = paymentsJson
          .map<Payments>((json) => Payments.fromJson(json))
          .toList();

      _groupInvoicesByStatus();
    } catch (e) {
      print('Error during data loading: $e');
      state = InvoicesByStatus.error();
    }
  }

  void setDateRange(DateTime? start, DateTime? end) {
    startDate = start;
    endDate = end;
    filterInvoices();
  }

  void filterInvoices() {
    List<Invoices> filteredInvoices = _allInvoices;

    if (startDate != null && endDate != null) {
      filteredInvoices = filteredInvoices.where((invoice) {
        return invoice.invoiceDate
                .isAfter(startDate!.subtract(const Duration(days: 1))) &&
            invoice.invoiceDate.isBefore(endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    state = filteredInvoices as InvoicesByStatus;
  }

  void _groupInvoicesByStatus() {
    List<InvoiceWithComputedFields> pendingInvoices = [];
    List<InvoiceWithComputedFields> partiallyPaidInvoices = [];
    List<InvoiceWithComputedFields> paidInvoices = [];

    for (var invoice in _allInvoices) {
      List<Payments> invoicePayments = _allPayments
          .where((payment) => payment.invoiceNo == invoice.id)
          .toList();

      double totalPayments = invoicePayments
          .where((payment) => !(payment.paymentMode == 'Cheque' &&
              payment.status == 'Returned'))
          .fold(0.0, (sum, payment) => sum + payment.amount);

      double balance = invoice.amount - totalPayments;

      String status;
      if (totalPayments == 0) {
        status = 'Pending';
      } else if (balance > 0) {
        status = 'Partially Paid';
      } else {
        status = 'Paid';
      }

      var invoiceWithComputed = InvoiceWithComputedFields(
        invoice: invoice,
        totalPayments: totalPayments,
        balance: balance,
        status: status,
      );

      if (status == 'Pending') {
        pendingInvoices.add(invoiceWithComputed);
      } else if (status == 'Partially Paid') {
        partiallyPaidInvoices.add(invoiceWithComputed);
      } else if (status == 'Paid') {
        paidInvoices.add(invoiceWithComputed);
      }
    }

    state = InvoicesByStatus(
      pending: pendingInvoices,
      partiallyPaid: partiallyPaidInvoices,
      paid: paidInvoices,
      isLoading: false,
      hasError: false,
    );
  }
}

class InvoicesByStatus {
  final List<InvoiceWithComputedFields> pending;
  final List<InvoiceWithComputedFields> partiallyPaid;
  final List<InvoiceWithComputedFields> paid;
  final bool isLoading;
  final bool hasError;

  InvoicesByStatus({
    required this.pending,
    required this.partiallyPaid,
    required this.paid,
    required this.isLoading,
    required this.hasError,
  });

  factory InvoicesByStatus.initial() {
    return InvoicesByStatus(
      pending: [],
      partiallyPaid: [],
      paid: [],
      isLoading: true,
      hasError: false,
    );
  }

  factory InvoicesByStatus.error() {
    return InvoicesByStatus(
      pending: [],
      partiallyPaid: [],
      paid: [],
      isLoading: false,
      hasError: true,
    );
  }
}

class InvoiceWithComputedFields {
  final Invoices invoice;
  final double totalPayments;
  final double balance;
  final String status;

  InvoiceWithComputedFields({
    required this.invoice,
    required this.totalPayments,
    required this.balance,
    required this.status,
  });
}

final invoicesNotifierProvider =
    StateNotifierProvider<InvoicesNotifier, InvoicesByStatus>(
        (ref) => InvoicesNotifier());
