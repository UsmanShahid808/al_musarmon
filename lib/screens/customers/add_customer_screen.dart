import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../models/customer_model.dart';
import '../../db/db_helper.dart';

class AddCustomerScreen extends StatefulWidget {
  final Customer? customer;

  const AddCustomerScreen({super.key, this.customer});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool get isEditMode => widget.customer != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      nameController.text = widget.customer!.name;
      phoneController.text = widget.customer!.phone;
    }
  }

  Future<void> pickFromContacts() async {
    try {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null) {
        final fullContact = await FlutterContacts.getContact(contact.id, withProperties: true);
        setState(() {
          nameController.text = fullContact?.displayName ?? contact.displayName;
          if (fullContact != null && fullContact.phones.isNotEmpty) {
            phoneController.text = fullContact.phones.first.number.replaceAll(RegExp(r'[^0-9]'), '');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open contacts: $e')),
        );
      }
    }
  }

  void saveCustomer() async {
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer name is required')),
      );
      return;
    }

    if (isEditMode) {
      Customer updatedCustomer = widget.customer!;
      updatedCustomer.name = name;
      updatedCustomer.phone = phone;
      await DBHelper.updateCustomer(updatedCustomer);
    } else {
      Customer newCustomer = Customer(name: name, phone: phone, address: '');
      await DBHelper.addCustomer(newCustomer);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Customer' : 'Add New Customer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 140,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 36),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF14141F) : const Color(0xFFF6F7FB),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!isEditMode)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: pickFromContacts,
                          icon: const Icon(Icons.contacts_rounded),
                          label: const Text('Pick from Contacts'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFF4facfe)),
                            foregroundColor: const Color(0xFF4facfe),
                          ),
                        ),
                      ),
                    if (!isEditMode) const SizedBox(height: 20),

                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Customer Name (e.g. Ahmed Khan)',
                        prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Phone Number (e.g. 0501234567)',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: saveCustomer,
                        icon: Icon(isEditMode ? Icons.check_rounded : Icons.save_rounded),
                        label: Text(isEditMode ? 'Update Customer' : 'Save Customer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4facfe),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}