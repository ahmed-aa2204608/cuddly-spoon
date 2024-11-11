import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/invoice_provider.dart';
import 'invoice_detail_screen.dart';
import '../models/Invoice.dart';

class InvoiceListScreen extends ConsumerStatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final invoices = ref.watch(invoiceProvider);
    final filteredInvoices = invoices.where((invoice) {
      return invoice.customerName
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoices'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredInvoices.length,
        itemBuilder: (ctx, index) {
          final invoice = filteredInvoices[index];
          return ListTile(
            title: Text('Invoice #${invoice.id} - ${invoice.customerName}'),
            subtitle:
                Text('Amount: ${invoice.amount}, Balance: ${invoice.balance}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InvoiceDetailScreen(invoice: invoice),
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () =>
                      _showUpdateInvoiceDialog(context, ref, invoice),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteInvoice(context, invoice),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddInvoiceDialog(context, ref),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search Invoices by Customer Name'),
          content: TextField(
            decoration: InputDecoration(labelText: 'Enter customer name'),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateInvoiceDialog(
      BuildContext context, WidgetRef ref, Invoice invoice) {
    final customerIdController =
        TextEditingController(text: invoice.customerId);
    final customerNameController =
        TextEditingController(text: invoice.customerName);
    final amountController =
        TextEditingController(text: invoice.amount.toString());
    final invoiceDateController = TextEditingController(
        text: invoice.invoiceDate.toIso8601String().split('T').first);
    final dueDateController = TextEditingController(
        text: invoice.dueDate.toIso8601String().split('T').first);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Invoice'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: customerIdController,
                  decoration: InputDecoration(labelText: 'Customer ID'),
                ),
                TextField(
                  controller: customerNameController,
                  decoration: InputDecoration(labelText: 'Customer Name'),
                ),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: invoiceDateController,
                  decoration:
                      InputDecoration(labelText: 'Invoice Date (YYYY-MM-DD)'),
                ),
                TextField(
                  controller: dueDateController,
                  decoration:
                      InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Update'),
              onPressed: () {
                final updatedInvoice = Invoice(
                  id: invoice.id,
                  customerId: customerIdController.text,
                  customerName: customerNameController.text,
                  amount: double.tryParse(amountController.text) ?? 0.0,
                  invoiceDate: DateTime.parse(invoiceDateController.text),
                  dueDate: DateTime.parse(dueDateController.text),
                );

                ref
                    .read(invoiceProvider.notifier)
                    .updateInvoice(updatedInvoice);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteInvoice(BuildContext context, Invoice invoice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Invoice'),
          content: Text('Are you sure you want to delete this invoice?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                ref.read(invoiceProvider.notifier).deleteInvoice(invoice.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddInvoiceDialog(BuildContext context, WidgetRef ref) {
    final customerIdController = TextEditingController();
    final customerNameController = TextEditingController();
    final amountController = TextEditingController();
    final invoiceDateController = TextEditingController();
    final dueDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Invoice'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: customerIdController,
                  decoration: InputDecoration(labelText: 'Customer ID'),
                ),
                TextField(
                  controller: customerNameController,
                  decoration: InputDecoration(labelText: 'Customer Name'),
                ),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: invoiceDateController,
                  decoration:
                      InputDecoration(labelText: 'Invoice Date (YYYY-MM-DD)'),
                ),
                TextField(
                  controller: dueDateController,
                  decoration:
                      InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Add Invoice'),
              onPressed: () {
                final newInvoice = Invoice(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  customerId: customerIdController.text,
                  customerName: customerNameController.text,
                  amount: double.tryParse(amountController.text) ?? 0.0,
                  invoiceDate: DateTime.parse(invoiceDateController.text),
                  dueDate: DateTime.parse(dueDateController.text),
                );

                ref.read(invoiceProvider.notifier).addInvoice(newInvoice);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
