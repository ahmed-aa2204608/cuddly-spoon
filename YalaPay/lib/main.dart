import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/invoice_list_screen.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YalaPay',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InvoiceListScreen(), // Directly opens the Invoice List screen
    );
  }
}
