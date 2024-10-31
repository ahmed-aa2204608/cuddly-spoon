import 'package:YalaPay/screens/invoice_list_screen.dart';
import 'package:YalaPay/screens/invoices_rep.dart';
import 'package:YalaPay/screens/cheques_rep.dart';
import 'package:YalaPay/screens/cheque_deposits_screen.dart';
import 'package:flutter/material.dart';
import 'page1.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
      ),
      body: Column(
        children: [
          Divider(),
          Text('Invoices', style: TextStyle(fontWeight: FontWeight.bold)),
          Divider(),
          Row(
            children: [
              Text('All: '),
              Text(
                '99.99 QR',
                style: TextStyle(color: Colors.green),
              )
            ],
          ),
          Row(
            children: [
              Text('Due Date in 30 days: '),
              Text(
                '33.33 QR',
                style: TextStyle(color: Colors.blue),
              )
            ],
          ),
          Row(
            children: [
              Text('Due Date in 60 days:'),
              Text(
                '66.66 QR',
                style: TextStyle(color: Colors.red),
              )
            ],
          ),
          Divider(),
          Text('Cheques', style: TextStyle(fontWeight: FontWeight.bold)),
          Divider(),
          Row(
            children: [
              Text('Awaiting: '),
              Text(
                '99.99 QR',
                style: TextStyle(color: Colors.yellow.shade300),
              )
            ],
          ),
          Row(
            children: [
              Text('Deposited: '),
              Text(
                '22.22 QR',
                style: TextStyle(color: Colors.blue),
              )
            ],
          ),
          Row(
            children: [
              Text('Cashed'),
              Text(
                '44.44 QR',
                style: TextStyle(color: Colors.green),
              )
            ],
          ),
          Row(children: [
            Text('Returned: '),
            Text(
              '11.11 QR',
              style: TextStyle(color: Colors.red),
            )
          ]),
          Divider(),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Page1()),
              );
            },
            child: Text("Go to Customer Management"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InvoiceListScreen()),
              );
            },
            child: Text("Go to Invoice List Screen"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChequeDepositsScreen()),
              );
            },
            child: Text("Cheque Deposits"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InvoicesRep()),
              );
            },
            child: Text("Invoices Report"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChequesRep()),
              );
            },
            child: Text("Cheques Report"),
          ),
        ],
      ),
    );
  }
}
