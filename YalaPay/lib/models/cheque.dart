import 'dart:convert';
import 'package:flutter/services.dart';

class Cheque {
  final int chequeNo;
  final double amount;
  final String drawer;
  final String bankName;
  String status;
  final DateTime receivedDate;
  final DateTime dueDate;
  final String chequeImageUri;
  String? returnReason;
  DateTime? depositDate;
  DateTime? cashedDate;
  DateTime? returnDate;

  Cheque({
    required this.chequeNo,
    required this.amount,
    required this.drawer,
    required this.bankName,
    required this.status,
    required this.receivedDate,
    required this.dueDate,
    required this.chequeImageUri,
    this.returnReason,
    this.depositDate,
    this.cashedDate,
    this.returnDate,
  });

  factory Cheque.fromJson(Map<String, dynamic> json) {
    return Cheque(
      chequeNo: json['chequeNo'],
      amount: json['amount'],
      drawer: json['drawer'],
      bankName: json['bankName'],
      status: json['status'],
      receivedDate: DateTime.parse(json['receivedDate']),
      dueDate: DateTime.parse(json['dueDate']),
      chequeImageUri: json['chequeImageUri'],
    );
  }

  static Future<List<Cheque>> fetchCheques() async {
    final String response =
        await rootBundle.loadString('assets/data/cheques.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Cheque.fromJson(json)).toList();
  }

  static Future<List<String>> fetchReturnReasons() async {
    final String response =
        await rootBundle.loadString('assets/data/return-reasons.json');
    return List<String>.from(json.decode(response));
  }
}
