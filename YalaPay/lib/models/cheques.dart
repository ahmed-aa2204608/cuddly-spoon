class Cheques {
  int chequeNo;
  double amount;
  String drawer;
  String bankName;
  String status;
  String receivedDate;
  String dueDate;
  String chequeImageUri;

  Cheques({
    required this.chequeNo,
    required this.amount,
    required this.drawer,
    required this.bankName,
    required this.status,
    required this.receivedDate,
    required this.dueDate,
    required this.chequeImageUri,
  });

  factory Cheques.fromJson(Map<String, dynamic> json) {
    return Cheques(
      chequeNo: json['chequeNo'],
      amount: json['amount'],
      drawer: json['drawer'],
      bankName: json['bankName'],
      status: json['status'],
      receivedDate: json['receivedDate'],
      dueDate: json['dueDate'],
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
}
