import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/cheque.dart';
import 'package:intl/intl.dart';

class ChequeDepositsScreen extends StatefulWidget {
  final List<Cheque> cheques;

  ChequeDepositsScreen({required this.cheques});

  @override
  _ChequeDepositsScreenState createState() => _ChequeDepositsScreenState();
}

class _ChequeDepositsScreenState extends State<ChequeDepositsScreen> {
  List<String> returnReasons = [];

  @override
  void initState() {
    super.initState();
    loadReturnReasons();
  }

  Future<void> loadReturnReasons() async {
    final String response =
        await rootBundle.loadString('assets/data/return-reasons.json');
    final List<dynamic> data = json.decode(response);

    setState(() {
      returnReasons = data.cast<String>();
    });
  }

  void updateChequeStatus(Cheque cheque, String status) async {
    DateTime today = DateTime.now();
    if (status == 'Returned') {
      TextEditingController dateController = TextEditingController();
      String? selectedReason;

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Return Cheque'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: dateController,
                    decoration:
                        const InputDecoration(labelText: 'Date: (YYYY-MM-DD)'),
                  ),
                  SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    decoration:
                        InputDecoration(labelText: 'Select Return Reason'),
                    isExpanded: true,
                    items: returnReasons.map((reason) {
                      return DropdownMenuItem<String>(
                        value: reason,
                        child: Text(reason),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedReason = value;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (dateController.text.isNotEmpty &&
                      selectedReason != null) {
                    setState(() {
                      cheque.updateStatus(
                          status, DateTime.parse(dateController.text));
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text('Submit'),
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        cheque.updateStatus(status, today);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Cheque> depositedCheques =
        widget.cheques.where((cheque) => cheque.status == 'Deposited').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Deposited Cheques'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return depositedCheques.isNotEmpty
              ? ListView.builder(
                  itemCount: depositedCheques.length,
                  itemBuilder: (context, index) {
                    Cheque cheque = depositedCheques[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      child: Card(
                        child: ListTile(
                          contentPadding: EdgeInsets.all(8.0),
                          leading: Image.asset(
                            'assets/images/${cheque.chequeImageUri}',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            'Drawer: ${cheque.drawer}',
                            style: TextStyle(
                                fontSize: constraints.maxWidth > 600 ? 18 : 14),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cheque No: ${cheque.chequeNo}',
                                style: TextStyle(
                                    fontSize:
                                        constraints.maxWidth > 600 ? 16 : 12),
                              ),
                              Text(
                                'Amount: ${cheque.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize:
                                        constraints.maxWidth > 600 ? 16 : 12),
                              ),
                              Text(
                                'Received Date: ${DateFormat('dd/MM/yyyy').format(cheque.receivedDate)}',
                                style: TextStyle(
                                    fontSize:
                                        constraints.maxWidth > 600 ? 16 : 12),
                              ),
                            ],
                          ),
                          trailing: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      updateChequeStatus(cheque, 'Cashed'),
                                  child: Text('Cashed',
                                      style: TextStyle(fontSize: 14)),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      updateChequeStatus(cheque, 'Returned'),
                                  child: Text('Returned',
                                      style: TextStyle(fontSize: 14)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: Text(
                    'No Deposited Cheques Available',
                    style: TextStyle(fontSize: 16),
                  ),
                );
        },
      ),
    );
  }
}
