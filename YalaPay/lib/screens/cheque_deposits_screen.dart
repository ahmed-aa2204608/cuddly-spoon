import 'package:YalaPay/models/cheque.dart';
import 'package:flutter/material.dart';

class ChequeDepositsScreen extends StatefulWidget {
  @override
  _ChequeDepositsScreenState createState() => _ChequeDepositsScreenState();
}

class _ChequeDepositsScreenState extends State<ChequeDepositsScreen> {
  List<Cheque> depositedCheques = [];

  // Hardcoded list of return reasons
  final List<String> returnReasons = [
    "No funds/insufficient funds",
    "Cheque post-dated, please represent on due date",
    "Drawer's signature differs",
    "Alteration in date/words/figures requires drawer's full signature",
    "Order cheque requires payee's endorsement",
    "Not drawn on us",
    "Drawer deceased/bankrupt",
    "Account closed",
    "Stopped by drawer due to cheque lost, bearer's bankruptcy or a judicial order",
    "Date/beneficiary name is required",
    "Presentment cycle expired",
    "Already paid",
    "Requires drawer's signature",
    "Cheque information and electronic data mismatch"
  ];

  @override
  void initState() {
    super.initState();
    loadCheques();
  }

  Future<void> loadCheques() async {
    List<Cheque> cheques = await Cheque.fetchCheques();
    setState(() {
      depositedCheques =
          cheques.where((cheque) => cheque.status == 'Deposited').toList();
    });
  }

  void markAsCashed(Cheque cheque) {
    setState(() {
      cheque.status = 'Cashed';
      cheque.cashedDate = DateTime.now();
      depositedCheques.remove(cheque);
    });
  }

  void markAsReturned(Cheque cheque) async {
    String? selectedReason;
    DateTime returnDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Return Cheque'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Select Return Date:'),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2025),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          returnDate = pickedDate;
                        });
                      }
                    },
                    child: Text(returnDate.toLocal().toString().split(" ")[0]),
                  ),
                  DropdownButton<String>(
                    hint: Text("Select Return Reason"),
                    value: selectedReason,
                    items: returnReasons.map((reason) {
                      return DropdownMenuItem(
                          value: reason, child: Text(reason));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (selectedReason != null) {
                      setState(() {
                        cheque.status = 'Returned';
                        cheque.returnDate = returnDate;
                        cheque.returnReason = selectedReason;
                        depositedCheques.remove(cheque);
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Return'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text('Deposited Cheques')),
      body: ListView.builder(
        itemCount: depositedCheques.length,
        itemBuilder: (context, index) {
          Cheque cheque = depositedCheques[index];

          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05, vertical: 8.0),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: screenWidth * 0.2,
                          height: screenWidth * 0.2,
                          child: Image.asset(
                            'assets/images/${cheque.chequeImageUri}',
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.05),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cheque No: ${cheque.chequeNo}',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Amount: ${cheque.amount}',
                                style: TextStyle(fontSize: screenWidth * 0.035),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Deposit Date: ${cheque.depositDate?.toLocal().toString().split(" ")[0] ?? ""}',
                                style: TextStyle(fontSize: screenWidth * 0.035),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () => markAsCashed(cheque),
                          child: Text('Cashed'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => markAsReturned(cheque),
                          child: Text('Returned'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
