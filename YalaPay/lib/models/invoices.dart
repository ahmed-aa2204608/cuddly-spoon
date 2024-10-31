class Invoices {
  String id;
  String customerId;
  String customerName;
  double amount;
  DateTime invoiceDate;
  DateTime dueDate;

  Invoices({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.invoiceDate,
    required this.dueDate,
  });

  factory Invoices.fromJson(Map<String, dynamic> json) {
    return Invoices(
      id: json['id'].toString(),
      customerId: json['customerId'].toString(),
      customerName: json['customerName'],
      amount: json['amount'],
      invoiceDate: DateTime.parse(json['invoiceDate']),
      dueDate: DateTime.parse(json['dueDate']),
    );
  }
}
