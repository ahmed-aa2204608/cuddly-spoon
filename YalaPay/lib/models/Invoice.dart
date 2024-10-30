import 'package:YalaPay/models/payment.dart';

class Invoice {
  String id;
  String customerId;
  String customerName;
  double amount;
  DateTime invoiceDate;
  DateTime dueDate;
  List<Payment> payments;

  Invoice({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.invoiceDate,
    required this.dueDate,
    List<Payment>? payments,
  }) : payments = payments ?? [];

  double get totalPayments =>
      payments.fold(0, (sum, payment) => sum + payment.amount);
  double get balance => amount - totalPayments;

  // Factory method to create an instance from JSON
  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      amount: json['amount'],
      invoiceDate: DateTime.parse(json['invoiceDate']),
      dueDate: DateTime.parse(json['dueDate']),
      payments: [],
    );
  }

  // Method to convert instance to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'customerName': customerName,
        'amount': amount,
        'invoiceDate': invoiceDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
      };
}
