// payment.dart
class Payment {
  String id;
  String invoiceNo;
  double amount;
  DateTime paymentDate;
  String paymentMode;

  // Optional cheque-specific fields
  String? chequeNo;
  String? drawer;
  String? drawerBank;
  String? status;
  DateTime? receivedDate;
  DateTime? dueDate;
  String? chequeImageUri;

  Payment({
    required this.id,
    required this.invoiceNo,
    required this.amount,
    required this.paymentDate,
    required this.paymentMode,
    this.chequeNo,
    this.drawer,
    this.drawerBank,
    this.status,
    this.receivedDate,
    this.dueDate,
    this.chequeImageUri,
  });

  // Factory method to create a Payment from JSON
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      invoiceNo: json['invoiceNo'],
      amount: json['amount'],
      paymentDate: DateTime.parse(json['paymentDate']),
      paymentMode: json['paymentMode'],
      chequeNo: json['chequeNo'],
      drawer: json['drawer'],
      drawerBank: json['drawerBank'],
      status: json['status'],
      receivedDate: json['receivedDate'] != null
          ? DateTime.parse(json['receivedDate'])
          : null,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      chequeImageUri: json['chequeImageUri'],
    );
  }

  // Method to convert a Payment to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceNo': invoiceNo,
        'amount': amount,
        'paymentDate': paymentDate.toIso8601String(),
        'paymentMode': paymentMode,
        if (chequeNo != null) 'chequeNo': chequeNo,
        if (drawer != null) 'drawer': drawer,
        if (drawerBank != null) 'drawerBank': drawerBank,
        if (status != null) 'status': status,
        if (receivedDate != null)
          'receivedDate': receivedDate!.toIso8601String(),
        if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
        if (chequeImageUri != null) 'chequeImageUri': chequeImageUri,
      };
}
