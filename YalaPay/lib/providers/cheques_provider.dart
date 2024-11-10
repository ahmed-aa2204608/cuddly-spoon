import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:YalaPay/models/cheque.dart';

class ChequesNotifier extends Notifier<List<Cheque>> {
  List<Cheque> _allCheques = [];
  List<Cheque> depositedCheques = [];
  String selectedStatus = 'All';
  DateTime? startDate;
  DateTime? endDate;

  @override
  List<Cheque> build() {
    readAllCheques();
    return [];
  }

  Map<String, dynamic> getTotals() {
    final totalCount = state.length;
    final totalAmount =
        state.fold<double>(0, (sum, cheque) => sum + cheque.amount);
    return {
      'totalCount': totalCount,
      'totalAmount': totalAmount,
    };
  }

  Future<void> readAllCheques() async {
    String data = await rootBundle.loadString('assets/data/cheques.json');
    var chequesMap = jsonDecode(data);
    _allCheques = chequesMap
        .map<Cheque>((chequeMap) => Cheque.fromJson(chequeMap))
        .toList();
    depositedCheques =
        _allCheques.where((cheque) => cheque.status == 'Deposited').toList();
    state = _allCheques;
  }

  void setFilter(String status) {
    selectedStatus = status;
    filterCheques();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    startDate = start;
    endDate = end;
    filterCheques();
  }

  void filterCheques() {
    List<Cheque> filteredCheques = _allCheques;

    if (selectedStatus != 'All') {
      filteredCheques = filteredCheques
          .where((cheque) => cheque.status == selectedStatus)
          .toList();
    }

    if (startDate != null && endDate != null) {
      filteredCheques = filteredCheques.where((cheque) {
        final chequeDate = cheque.dueDate;
        return chequeDate
                .isAfter(startDate!.subtract(const Duration(days: 1))) &&
            chequeDate.isBefore(endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    state = filteredCheques;
  }

  void markAsDeposited(Cheque cheque) {
    cheque.status = 'Deposited';
  }

  void markAsCashed(Cheque cheque) {
    cheque.status = 'Cashed';
  }

  void markAsReturned(Cheque cheque, DateTime returnDate) {
    cheque.status = 'Returned';
    cheque.dueDate = returnDate;
  }
}

final chequeNotifierProvider =
    NotifierProvider<ChequesNotifier, List<Cheque>>(() => ChequesNotifier());
