import 'package:YalaPay/models/cheque.dart';
import 'package:flutter/material.dart';

class ChequeDepositsScreen extends StatefulWidget {
  @override
  _ChequeDepositsScreenState createState() => _ChequeDepositsScreenState();
}

class _ChequeDepositsScreenState extends State<ChequeDepositsScreen> {
  List<Cheque> depositedCheques = [];
  List<String> returnReasons = [];

  @override
  void initState() {
    super.initState();
    loadCheques();
    loadReturnReasons();
  }

  Future<void> loadCheques() async {
    List<Cheque> cheques = await Cheque.fetchCheques();
    setState(() {
      depositedCheques =
          cheques.where((cheque) => cheque.status == 'Deposited').toList();
    });
  }

  Future<void> loadReturnReasons() async {
    List<String> reasons = await Cheque.fetchReturnReasons();
    setState(() {
      returnReasons = reasons;
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
    return Scaffold(
      appBar: AppBar(title: Text('Deposited Cheques')),
      body: ListView.builder(
        itemCount: depositedCheques.length,
        itemBuilder: (context, index) {
          Cheque cheque = depositedCheques[index];

          return Expanded(
            child: ListTile(
              leading: Image.asset('assets/images/${cheque.chequeImageUri}'),
              title: Text(
                  'Cheque No: ${cheque.chequeNo} - Amount: ${cheque.amount}'),
              subtitle: Text(
                  'Deposit Date: ${cheque.depositDate?.toLocal().toString().split(" ")[0] ?? ""}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
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
            ),
          );
        },
      ),
    );
  }
}
