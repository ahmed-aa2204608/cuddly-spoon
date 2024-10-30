import 'package:flutter/material.dart';
import 'package:YalaPay/models/payment.dart';
import 'dart:io';

class PaymentDetailScreen extends StatelessWidget {
  final Payment payment;

  PaymentDetailScreen({required this.payment});

  // Custom function to format date
  String formatDate(DateTime date) {
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    String year = date.year.toString();
    return "$month/$day/$year";
  }

  void _showEnlargedImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBankOrCreditCard = payment.paymentMode == 'Bank transfer' ||
        payment.paymentMode == 'Credit card';

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Always show Amount and Received Date
            DetailRow(
                label: 'Amount',
                value: '\$${payment.amount.toStringAsFixed(2)}'),
            DetailRow(
                label: 'Received Date',
                value: formatDate(payment.receivedDate ?? DateTime.now())),

            // Conditionally show other details if payment mode is not Bank transfer or Credit card
            if (!isBankOrCreditCard) ...[
              DetailRow(label: 'Cheque No', value: payment.chequeNo ?? 'N/A'),
              DetailRow(label: 'Drawer', value: payment.drawer ?? 'N/A'),
              DetailRow(
                  label: 'Drawer Bank', value: payment.drawerBank ?? 'N/A'),
              DetailRow(label: 'Status', value: payment.status ?? 'N/A'),
              DetailRow(
                  label: 'Due Date',
                  value: formatDate(payment.dueDate ?? DateTime.now())),
              if (payment.chequeImageUri != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Cheque Image',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () =>
                      _showEnlargedImage(context, payment.chequeImageUri!),
                  child: Image.file(
                    File(payment.chequeImageUri!),
                    height: 100,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
