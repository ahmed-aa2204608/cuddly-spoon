import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:YalaPay/models/customer.dart';

class Page1 extends StatefulWidget {
  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _filteredCustomers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_filterCustomers);
  }

  Future<void> _loadCustomers() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/customers.json');
      final List<dynamic> data = json.decode(response);
      print(
          "Customer data loaded successfully: $data"); // Debug print to check data
      setState(() {
        _customers = List<Map<String, dynamic>>.from(data);
        _filteredCustomers = _customers; // Show all customers initially
      });
    } catch (e) {
      print("Error loading customer data: $e"); // Print any error that occurs
    }
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredCustomers =
            _customers; // Show all customers if the query is empty
      });
    } else {
      setState(() {
        _filteredCustomers = _customers.where((customer) {
          return customer['contactDetails']['lastName']
              .toLowerCase()
              .contains(query);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customer Management"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by last name...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredCustomers.isNotEmpty
                ? ListView.builder(
                    itemCount: _filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = _filteredCustomers[index];
                      if (_searchController.text.isEmpty) {
                        // Display brief info for all customers
                        return ListTile(
                          title: Text(customer['companyName']),
                          subtitle: Text(
                              "${customer['contactDetails']['firstName']} ${customer['contactDetails']['lastName']}"),
                        );
                      } else {
                        // Display full details for the searched customer
                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Customer ID: ${customer['id']}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 5),
                                Text(
                                    "Company Name: ${customer['companyName']}"),
                                Text(
                                    "Address: ${customer['address']['street']}, ${customer['address']['city']}, ${customer['address']['country']}"),
                                SizedBox(height: 5),
                                Text("Contact Details:"),
                                Text(
                                    "  - Name: ${customer['contactDetails']['firstName']} ${customer['contactDetails']['lastName']}"),
                                Text(
                                    "  - Mobile: ${customer['contactDetails']['mobile']}"),
                                Text(
                                    "  - Email: ${customer['contactDetails']['email']}"),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  )
                : Center(
                    child: Text(
                      "No customers found",
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
