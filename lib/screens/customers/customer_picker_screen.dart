import 'package:flutter/material.dart';
import '../../models/customer_model.dart';
import '../../db/db_helper.dart';
import 'add_customer_screen.dart';

class CustomerPickerScreen extends StatefulWidget {
  const CustomerPickerScreen({super.key});

  @override
  State<CustomerPickerScreen> createState() => _CustomerPickerScreenState();
}

class _CustomerPickerScreenState extends State<CustomerPickerScreen> {
  List<Customer> allCustomers = [];
  List<Customer> filtered = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCustomers();
  }

  void loadCustomers() async {
    List<Customer> data = await DBHelper.getAllCustomers();
    setState(() {
      allCustomers = data;
      filtered = data;
    });
  }

  void filterList(String query) {
    setState(() {
      filtered = allCustomers.where((c) {
        return c.name.toLowerCase().contains(query.toLowerCase()) || c.phone.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void addNewCustomer() async {
    bool? result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCustomerScreen()));
    if (result == true) loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Customer'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              onChanged: filterList,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: addNewCustomer,
                icon: const Icon(Icons.person_add),
                label: const Text('Add New Customer'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.storefront)),
                  title: const Text('Walk-in Customer'),
                  onTap: () {
                    Customer walkIn = Customer(name: 'Walk-in Customer', phone: '', address: '');
                    walkIn.id = -1;
                    Navigator.pop(context, walkIn);
                  },
                ),
                const Divider(height: 1),
                ...filtered.map((c) {
                  return ListTile(
                    leading: CircleAvatar(child: Text(c.name.isNotEmpty ? c.name[0].toUpperCase() : '?')),
                    title: Text(c.name),
                    subtitle: Text(c.phone),
                    trailing: Text('SAR ${c.balance.toStringAsFixed(0)}'),
                    onTap: () {
                      Navigator.pop(context, c);
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}