import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:YalaPay/providers/cheques_provider.dart';
import 'package:YalaPay/models/cheques.dart';

class ChequesRep extends ConsumerStatefulWidget {
  const ChequesRep({super.key});

  @override
  ConsumerState<ChequesRep> createState() => _ChequesRepState();
}

class _ChequesRepState extends ConsumerState<ChequesRep> {
  final List<String> statuses = [
    'All',
    'Awaiting',
    'Deposited',
    'Cashed',
    'Returned'
  ];
  String selectedStatus = 'All';
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
          .read(chequeNotifierProvider.notifier)
          .setDateRange(startDate, endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cheques = ref.watch(chequeNotifierProvider);
    final chequeNotifier = ref.read(chequeNotifierProvider.notifier);

    final totals = chequeNotifier.getTotals();
    final totalCount = totals['totalCount'];
    final totalAmount = totals['totalAmount'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cheques Report'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedStatus,
              onChanged: (newStatus) {
                setState(() {
                  selectedStatus = newStatus!;
                });
                chequeNotifier.setFilter(selectedStatus);
              },
              items: statuses.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              isExpanded: true,
              hint: const Text('Select Status'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectDateRange(context),
                    child: Text(
                      startDate != null && endDate != null
                          ? 'From: ${startDate!.toLocal()} - To: ${endDate!.toLocal()}'
                          : 'Select Date Range',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Cheques: $totalCount'),
                Text('Total Amount: \$${totalAmount.toStringAsFixed(2)}'),
              ],
            ),
          ),
          mainWidget(cheques),
        ],
      ),
    );
  }

  Expanded mainWidget(List<Cheques> cheques) {
    return Expanded(
      child: cheques.isEmpty
          ? const Center(child: Text('No cheques available'))
          : ListView.builder(
              itemCount: cheques.length,
              itemBuilder: (context, index) {
                final cheque = cheques[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Image.asset(
                      'assets/images/${cheque.chequeImageUri}',
                      fit: BoxFit.cover,
                    ),
                    title: Text('Cheque No: ${cheque.chequeNo}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Amount: \$${cheque.amount.toStringAsFixed(2)}'),
                        Text('Drawer: ${cheque.drawer}'),
                        Text('Bank: ${cheque.bankName}'),
                        Text('Status: ${cheque.status}'),
                        Text('Received Date: ${cheque.receivedDate}'),
                        Text('Due Date: ${cheque.dueDate}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
