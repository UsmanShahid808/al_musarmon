import 'package:flutter/material.dart';
import '../../models/supplier_model.dart';
import '../../db/db_helper.dart';

class AddSupplierScreen extends StatefulWidget {
  final Supplier? supplier;

  const AddSupplierScreen({super.key, this.supplier});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool get isEditMode => widget.supplier != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      nameController.text = widget.supplier!.name;
      phoneController.text = widget.supplier!.phone;
    }
  }

  void saveSupplier() async {
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supplier name is required')),
      );
      return;
    }

    if (isEditMode) {
      Supplier updatedSupplier = widget.supplier!;
      updatedSupplier.name = name;
      updatedSupplier.phone = phone;
      await DBHelper.updateSupplier(updatedSupplier);
    } else {
      Supplier newSupplier = Supplier(name: name, phone: phone, address: '');
      await DBHelper.addSupplier(newSupplier);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Supplier' : 'Add New Supplier'),
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
                colors: [Color(0xFF636FA4), Color(0xFFE8CBC0)],
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
                  child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 36),
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
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Supplier/Shop Name',
                        prefixIcon: Icon(Icons.store_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: saveSupplier,
                        icon: Icon(isEditMode ? Icons.check_rounded : Icons.save_rounded),
                        label: Text(isEditMode ? 'Update Supplier' : 'Save Supplier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF636FA4),
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