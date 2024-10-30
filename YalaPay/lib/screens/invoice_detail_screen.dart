import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/Invoice.dart';
import '../models/payment.dart';
import 'package:YalaPay/screens/PaymentDetailScreen.dart';
import '../providers/payment_provider.dart';
import '../utils/data_loader.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final Invoice invoice;

  InvoiceDetailScreen({required this.invoice});

  @override
  _InvoiceDetailScreenState createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  List<String> paymentModes = [];
  List<String> banks = [];
  List<Payment> filteredPayments = [];
  List<Payment> allPayments = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPaymentModesAndBanks();
    _searchController.addListener(_filterPayments);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadPaymentModesAndBanks() async {
    try {
      final loadedPaymentModes = await loadPaymentModes();
      final loadedBanks = await loadBanks();
      setState(() {
        paymentModes = loadedPaymentModes;
        banks = loadedBanks;
      });
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  void _filterPayments() {
    final searchQuery = _searchController.text.toLowerCase();

    // Filter based on payment mode or cheque number
    setState(() {
      if (searchQuery.isEmpty) {
        filteredPayments = allPayments;
      } else {
        filteredPayments = allPayments.where((payment) {
          return payment.paymentMode.toLowerCase().contains(searchQuery) ||
              (payment.chequeNo?.toLowerCase().contains(searchQuery) ?? false);
        }).toList();
      }
    });
  }

  String formatDate(DateTime date) {
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    String year = date.year.toString();
    return "$month/$day/$year";
  }

  @override
  Widget build(BuildContext context) {
    allPayments = ref
        .watch(paymentProvider)
        .where((p) => p.invoiceNo == widget.invoice.id)
        .toList();

    if (filteredPayments.isEmpty) {
      filteredPayments = allPayments;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Invoice #${widget.invoice.id}')),
      body: paymentModes.isEmpty || banks.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                ListTile(
                  title: Text('Customer: ${widget.invoice.customerName}'),
                  subtitle: Text(
                      'Amount: ${widget.invoice.amount}, Balance: ${widget.invoice.balance}'),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Payments',
                      hintText: 'Search by payment mode or cheque no',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                Divider(),
                Text('Payments:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredPayments.length,
                    itemBuilder: (context, index) {
                      final payment = filteredPayments[index];
                      return ListTile(
                        title: Text('Payment: ${payment.amount}'),
                        subtitle: Text(
                            'Date: ${formatDate(payment.paymentDate)}, Mode: ${payment.paymentMode}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PaymentDetailScreen(payment: payment),
                            ),
                          );
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _showAddPaymentDialog(
                                  context, ref,
                                  payment: payment),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deletePayment(ref, payment),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showAddPaymentDialog(context, ref),
                  child: Text('Add Payment'),
                ),
              ],
            ),
    );
  }

  void _deletePayment(WidgetRef ref, Payment payment) {
    ref.read(paymentProvider.notifier).deletePayment(payment.id);
    _filterPayments(); // Update search results after deletion
  }

  void _showAddPaymentDialog(BuildContext context, WidgetRef ref,
      {Payment? payment}) {
    final _chequeNoController = TextEditingController(text: payment?.chequeNo);
    final _amountController =
        TextEditingController(text: payment?.amount.toString() ?? '');
    final _drawerController = TextEditingController(text: payment?.drawer);
    final _dueDateController = TextEditingController(
        text: payment?.dueDate?.toIso8601String().split('T').first);
    String? _selectedBank = payment?.drawerBank;
    String _selectedPaymentMode = payment?.paymentMode ??
        (paymentModes.isNotEmpty ? paymentModes[0] : 'Cheque');
    File? _chequeImage =
        payment?.chequeImageUri != null ? File(payment!.chequeImageUri!) : null;
    final ImagePicker _picker = ImagePicker();

    Future<void> _pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _chequeImage = File(pickedFile.path);
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(payment == null ? 'Add New Payment' : 'Edit Payment'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedPaymentMode,
                      decoration: InputDecoration(labelText: 'Payment Mode'),
                      items: paymentModes.map((String mode) {
                        return DropdownMenuItem<String>(
                          value: mode,
                          child: Text(mode),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setDialogState(() {
                          _selectedPaymentMode = newValue!;
                        });
                      },
                    ),
                    if (_selectedPaymentMode == 'Cheque') ...[
                      TextField(
                        controller: _chequeNoController,
                        decoration: InputDecoration(labelText: 'Cheque No'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: _amountController,
                        decoration: InputDecoration(labelText: 'Amount'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: _drawerController,
                        decoration: InputDecoration(labelText: 'Drawer'),
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedBank,
                        decoration: InputDecoration(labelText: 'Drawer Bank'),
                        items: banks.map((String bank) {
                          return DropdownMenuItem<String>(
                            value: bank,
                            child: Text(bank),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setDialogState(() {
                            _selectedBank = newValue!;
                          });
                        },
                      ),
                      Text('Status: Awaiting',
                          style: TextStyle(color: Colors.grey)),
                      Text('Received Date: ${formatDate(DateTime.now())}'),
                      TextField(
                        controller: _dueDateController,
                        decoration:
                            InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
                      ),
                      TextButton.icon(
                        icon: Icon(Icons.image),
                        label: Text('Upload Cheque Image'),
                        onPressed: _pickImage,
                      ),
                      if (_chequeImage != null)
                        Image.file(_chequeImage!, height: 100),
                    ],
                    if (_selectedPaymentMode == 'Bank transfer' ||
                        _selectedPaymentMode == 'Credit card') ...[
                      TextField(
                        controller: _amountController,
                        decoration: InputDecoration(labelText: 'Amount'),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child:
                      Text(payment == null ? 'Add Payment' : 'Update Payment'),
                  onPressed: () {
                    try {
                      final newPayment = Payment(
                        id: payment?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        invoiceNo: widget.invoice.id,
                        amount: double.tryParse(_amountController.text) ?? 0.0,
                        paymentDate: DateTime.now(),
                        paymentMode: _selectedPaymentMode,
                        chequeNo: _selectedPaymentMode == 'Cheque'
                            ? _chequeNoController.text
                            : null,
                        drawer: _selectedPaymentMode == 'Cheque'
                            ? _drawerController.text
                            : null,
                        drawerBank: _selectedPaymentMode == 'Cheque'
                            ? _selectedBank
                            : null,
                        status: _selectedPaymentMode == 'Cheque'
                            ? 'Awaiting'
                            : null,
                        receivedDate: DateTime.now(),
                        dueDate: _selectedPaymentMode == 'Cheque' &&
                                _dueDateController.text.isNotEmpty
                            ? DateTime.parse(_dueDateController.text)
                            : null,
                        chequeImageUri: _selectedPaymentMode == 'Cheque'
                            ? _chequeImage?.path
                            : null,
                      );

                      if (payment == null) {
                        ref
                            .read(paymentProvider.notifier)
                            .addPayment(newPayment);
                      } else {
                        ref
                            .read(paymentProvider.notifier)
                            .updatePayment(newPayment);
                      }
                      Navigator.of(context).pop();
                    } catch (e) {
                      print('Error adding payment: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Error adding payment. Please try again.')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
