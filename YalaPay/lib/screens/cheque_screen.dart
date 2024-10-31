import 'package:YalaPay/models/cheque.dart';
import 'package:YalaPay/screens/cheque_deposits_screen.dart';
import 'package:flutter/material.dart';

class ChequeScreen extends StatefulWidget {
  @override
  _ChequeScreenState createState() => _ChequeScreenState();
}

class _ChequeScreenState extends State<ChequeScreen> {
  List<Cheque> awaitingCheques = [];

  @override
  void initState() {
    super.initState();
    loadCheques();
  }

  Future<void> loadCheques() async {
    List<Cheque> cheques = await Cheque.fetchCheques();
    setState(() {
      awaitingCheques =
          cheques.where((cheque) => cheque.status == 'Awaiting').toList();
    });
  }

  void markAsDeposited(Cheque cheque) {
    setState(() {
      cheque.status = 'Deposited';
      cheque.depositDate = DateTime.now();
      awaitingCheques.remove(cheque);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Awaiting Cheques')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: awaitingCheques.length,
              itemBuilder: (context, index) {
                Cheque cheque = awaitingCheques[index];
                int remainingDays =
                    cheque.dueDate.difference(DateTime.now()).inDays;
                Color dateColor =
                    remainingDays >= 0 ? Colors.green : Colors.red;
                String dateDisplay = remainingDays >= 0
                    ? '(+$remainingDays)'
                    : '($remainingDays)';

                return ListTile(
                  title: Text(
                      'Cheque No: ${cheque.chequeNo} - Amount: ${cheque.amount}'),
                  subtitle: Text(
                    'Due Date: ${cheque.dueDate.toLocal().toString().split(" ")[0]} $dateDisplay',
                    style: TextStyle(color: dateColor),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => markAsDeposited(cheque),
                    child: Text('Mark as Deposited'),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChequeDepositsScreen()),
              );
            },
            child: Text('Go to Deposited Cheques'),
          ),
        ],
      ),
    );
  }
}
