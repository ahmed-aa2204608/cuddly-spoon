class Cheque {
  int chequeNo;
  double amount;
  String drawer;
  String bankName;
  String status;
  DateTime receivedDate;
  DateTime dueDate;
  String chequeImageUri;

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

  Map<String, dynamic> toJson() {
    return {
      'chequeNo': chequeNo,
      'amount': amount,
      'drawer': drawer,
      'bankName': bankName,
      'status': status,
      'receivedDate': receivedDate,
      'dueDate': dueDate,
      'chequeImageUri': chequeImageUri,
    };
  }

  void updateStatus(String newStatus, DateTime newReceivedDate) {
    status = newStatus;
    receivedDate = newReceivedDate;
  }
}
