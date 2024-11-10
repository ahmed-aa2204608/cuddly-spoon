import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cheque.dart';
import 'cheque_deposits_screen.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class ChequeScreen extends StatefulWidget {
  @override
  _ChequeScreenState createState() => _ChequeScreenState();
}

class _ChequeScreenState extends State<ChequeScreen> {
  List<Cheque> cheques = [];
  List<int> selectedChequeNos = [];
  List<String> bankAccounts = [];
  String? selectedBankAccount;

  @override
  void initState() {
    super.initState();
    loadCheques();
    loadBankAccounts();
  }

  Future<void> loadCheques() async {
    final String response =
        await rootBundle.loadString('assets/data/cheques.json');
    final List<dynamic> data = json.decode(response);

    setState(() {
      cheques = data.map((item) => Cheque.fromJson(item)).toList();
    });
  }

  Future<void> loadBankAccounts() async {
    final String response =
        await rootBundle.loadString('assets/data/bank-accounts.json');
    final List<dynamic> data = json.decode(response);

    setState(() {
      bankAccounts = data.map<String>((item) => item['bank']).toList();
    });
  }

  void depositSelectedCheques() {
    setState(() {
      for (var cheque in cheques) {
        if (selectedChequeNos.contains(cheque.chequeNo) &&
            cheque.status == 'Awaiting') {
          cheque.updateStatus('Deposited', DateTime.now());
        }
      }
      selectedChequeNos.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    List<Cheque> awaitingCheques =
        cheques.where((cheque) => cheque.status == 'Awaiting').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Awaiting Cheques'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: awaitingCheques.length,
                  itemBuilder: (context, index) {
                    Cheque cheque = awaitingCheques[index];
                    int remainingDays = cheque.dueDate.difference(today).inDays;
                    Color daysColor =
                        remainingDays >= 0 ? Colors.green : Colors.red;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      child: Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: selectedChequeNos.contains(cheque.chequeNo),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedChequeNos.add(cheque.chequeNo);
                                } else {
                                  selectedChequeNos.remove(cheque.chequeNo);
                                }
                              });
                            },
                          ),
                          title: Text('Drawer: ${cheque.drawer}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bank: ${cheque.bankName}'),
                              Text('Cheque No: ${cheque.chequeNo}'),
                              Text(
                                  'Amount: ${cheque.amount.toStringAsFixed(2)}'),
                              Text(
                                'Due Date: ${DateFormat('dd/MM/yyyy').format(cheque.dueDate)} (${remainingDays >= 0 ? '+' : ''}$remainingDays)',
                                style: TextStyle(color: daysColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButton<String>(
                      value: selectedBankAccount,
                      hint: Text('Select Bank Account'),
                      isExpanded: true,
                      items: bankAccounts.map((String account) {
                        return DropdownMenuItem<String>(
                          value: account,
                          child: Text(account),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedBankAccount = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 10), // Space between dropdown and buttons
                    ElevatedButton(
                      onPressed: depositSelectedCheques,
                      child: Text('Deposit Selected Cheques'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: 10), // Space between the buttons
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChequeDepositsScreen(
                              cheques: cheques,
                            ),
                          ),
                        );
                      },
                      child: Text('Go to Deposited Cheques'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
