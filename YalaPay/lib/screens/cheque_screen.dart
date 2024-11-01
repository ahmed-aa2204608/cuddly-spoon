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
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.04;
    double padding = screenWidth * 0.05;
    double margin = screenWidth * 0.04;
    double cardPadding = screenWidth * 0.03;
    double buttonFontSize = screenWidth * 0.035;

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

                return Card(
                  margin: EdgeInsets.symmetric(
                      vertical: margin / 2, horizontal: margin),
                  child: Padding(
                    padding: EdgeInsets.all(cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cheque No: ${cheque.chequeNo}',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: padding / 2),
                        Text('Amount: ${cheque.amount} QR',
                            style: TextStyle(fontSize: fontSize * 0.9)),
                        SizedBox(height: padding / 4),
                        Text('Bank Name: ${cheque.bankName}',
                            style: TextStyle(fontSize: fontSize * 0.9)),
                        SizedBox(height: padding / 4),
                        Text('Drawer: ${cheque.drawer}',
                            style: TextStyle(fontSize: fontSize * 0.9)),
                        SizedBox(height: padding / 4),
                        Text(
                          'Received Date: ${cheque.receivedDate.toLocal().toString().split(" ")[0]}',
                          style: TextStyle(fontSize: fontSize * 0.9),
                        ),
                        SizedBox(height: padding / 4),
                        Text(
                          'Due Date: ${cheque.dueDate.toLocal().toString().split(" ")[0]} $dateDisplay',
                          style: TextStyle(
                              color: dateColor, fontSize: fontSize * 0.9),
                        ),
                        SizedBox(height: padding),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () => markAsDeposited(cheque),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: padding * 0.8,
                                  vertical: padding * 0.4),
                            ),
                            child: Text(
                              'Mark as Deposited',
                              style: TextStyle(fontSize: buttonFontSize),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(padding),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChequeDepositsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    horizontal: padding * 1.5, vertical: padding * 0.6),
              ),
              child: Text(
                'Go to Deposited Cheques',
                style: TextStyle(fontSize: buttonFontSize),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
