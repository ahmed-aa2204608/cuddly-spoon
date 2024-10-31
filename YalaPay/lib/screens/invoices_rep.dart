import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:YalaPay/providers/invoices_provider.dart';
import 'package:intl/intl.dart';

class InvoicesRep extends ConsumerStatefulWidget {
  const InvoicesRep({Key? key}) : super(key: key);

  @override
  ConsumerState<InvoicesRep> createState() => _InvoicesRepState();
}

class _InvoicesRepState extends ConsumerState<InvoicesRep> {
  String selectedStatus = 'Pending Invoices';
  DateTime? startDate;
  DateTime? endDate;

  void _selectDateRange(BuildContext context) async {
    final DateTimeRange? dateTimeRange = await showDateRangePicker(
      context: context,
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 30)),
              end: DateTime.now(),
            ),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (dateTimeRange != null) {
      setState(() {
        startDate = dateTimeRange.start;
        endDate = dateTimeRange.end;
      });
      ref
          .read(invoicesNotifierProvider.notifier)
          .setDateRange(startDate, endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoicesByStatus = ref.watch(invoicesNotifierProvider);
    List<InvoiceWithComputedFields> invoices = [];

    if (selectedStatus == 'Pending Invoices') {
      invoices = invoicesByStatus.pending;
    } else if (selectedStatus == 'Partially Paid Invoices') {
      invoices = invoicesByStatus.partiallyPaid;
    } else if (selectedStatus == 'Paid Invoices') {
      invoices = invoicesByStatus.paid;
    }

    final invoiceCount = invoices.length;
    final totalAmount = invoices.fold<double>(
      0.0,
      (sum, invoice) => sum + invoice.invoice.amount,
    );

    if (invoicesByStatus.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Invoices Report'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (invoicesByStatus.hasError) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Invoices Report'),
        ),
        body:
            const Center(child: Text('An error occurred while loading data.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices Report'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => _selectDateRange(context),
            child: Text(
              startDate != null && endDate != null
                  ? 'From: ${DateFormat('yyyy-MM-dd').format(startDate!)} - To: ${DateFormat('yyyy-MM-dd').format(endDate!)}'
                  : 'Select Date Range',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: selectedStatus,
              onChanged: (String? newValue) {
                setState(() {
                  selectedStatus = newValue!;
                });
              },
              items: <String>[
                'Pending Invoices',
                'Partially Paid Invoices',
                'Paid Invoices',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Invoices: $invoiceCount'),
                Text('Total Amount: \$${totalAmount.toStringAsFixed(2)}'),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (selectedStatus == 'Pending Invoices')
                    _buildInvoiceSection(
                      title: 'Pending Invoices',
                      invoices: invoicesByStatus.pending,
                    ),
                  if (selectedStatus == 'Partially Paid Invoices')
                    _buildInvoiceSection(
                      title: 'Partially Paid Invoices',
                      invoices: invoicesByStatus.partiallyPaid,
                    ),
                  if (selectedStatus == 'Paid Invoices')
                    _buildInvoiceSection(
                      title: 'Paid Invoices',
                      invoices: invoicesByStatus.paid,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceSection({
    required String title,
    required List<InvoiceWithComputedFields> invoices,
  }) {
    return invoices.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                itemCount: invoices.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final invoiceWithComputed = invoices[index];
                  final invoice = invoiceWithComputed.invoice;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      child: ListTile(
                        title: Text('Invoice No: ${invoice.id}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Customer: ${invoice.customerName}'),
                            Text(
                                'Amount: \$${invoice.amount.toStringAsFixed(2)}'),
                            Text(
                                'Total Payments: \$${invoiceWithComputed.totalPayments.toStringAsFixed(2)}'),
                            Text(
                                'Balance: \$${invoiceWithComputed.balance.toStringAsFixed(2)}'),
                            Text('Status: ${invoiceWithComputed.status}'),
                            Text(
                                'Invoice Date: ${DateFormat('yyyy-MM-dd').format(invoice.invoiceDate)}'),
                            Text(
                                'Due Date: ${DateFormat('yyyy-MM-dd').format(invoice.dueDate)}'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          )
        : Container(
            padding: const EdgeInsets.all(16.0),
            child: const Text('No invoices available for this status.'),
          );
  }
}
