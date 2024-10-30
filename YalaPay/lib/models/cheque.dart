class Cheque {
  final int chequeNo;
  final double amount;
  final String drawer;
  final String bankName;
  final String status;
  final DateTime receivedDate;
  final DateTime dueDate;
  final String chequeImageUri;

  Cheque({
    required this.chequeNo,
    required this.amount,
    required this.drawer,
    required this.bankName,
    required this.status,
    required this.receivedDate,
    required this.dueDate,
    required this.chequeImageUri,
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
}
