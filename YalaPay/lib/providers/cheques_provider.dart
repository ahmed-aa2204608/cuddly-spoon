import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:YalaPay/models/cheques.dart';

class ChequesNotifier extends Notifier<List<Cheques>> {
  List<Cheques> _allCheques = [];
  String selectedStatus = 'All';
  DateTime? startDate;
  DateTime? endDate;

  @override
  List<Cheques> build() {
    initializeCheques();
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

  Future<void> initializeCheques() async {
    String data = await rootBundle.loadString('assets/data/cheques.json');
    var chequesMap = jsonDecode(data);
    List<Cheques> cheques = [];
    for (var chequeMap in chequesMap) {
      cheques.add(Cheques.fromJson(chequeMap));
    }
    _allCheques = cheques;
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
    List<Cheques> filteredCheques = _allCheques;

    if (selectedStatus != 'All') {
      filteredCheques = filteredCheques
          .where((cheque) => cheque.status == selectedStatus)
          .toList();
    }

    if (startDate != null && endDate != null) {
      filteredCheques = filteredCheques.where((cheque) {
        final chequeDate = DateTime.parse(cheque.receivedDate);
        return chequeDate
                .isAfter(startDate!.subtract(const Duration(days: 1))) &&
            chequeDate.isBefore(endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    state = filteredCheques;
  }
}

final chequeNotifierProvider =
    NotifierProvider<ChequesNotifier, List<Cheques>>(() => ChequesNotifier());
