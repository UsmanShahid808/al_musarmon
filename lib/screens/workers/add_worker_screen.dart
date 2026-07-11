import 'package:flutter/material.dart';
import '../../models/worker_model.dart';
import '../../db/db_helper.dart';

class AddWorkerScreen extends StatefulWidget {
  final Worker? worker;

  const AddWorkerScreen({super.key, this.worker});

  @override
  State<AddWorkerScreen> createState() => _AddWorkerScreenState();
}

class _AddWorkerScreenState extends State<AddWorkerScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool get isEditMode => widget.worker != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      nameController.text = widget.worker!.name;
      phoneController.text = widget.worker!.phone;
    }
  }

  void saveWorker() async {
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Worker name is required')),
      );
      return;
    }

    if (isEditMode) {
      Worker updatedWorker = widget.worker!;
      updatedWorker.name = name;
      updatedWorker.phone = phone;
      await DBHelper.updateWorker(updatedWorker);
    } else {
      Worker newWorker = Worker(name: name, phone: phone);
      await DBHelper.addWorker(newWorker);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Worker' : 'Add New Worker'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 130,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF9C27B0), Color(0xFF6C63FF)],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.engineering_rounded, color: Colors.white, size: 34),
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
                        hintText: 'Worker Name (e.g. Shahzad)',
                        prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Phone Number (optional)',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: saveWorker,
                        icon: Icon(isEditMode ? Icons.check_rounded : Icons.save_rounded),
                        label: Text(isEditMode ? 'Update Worker' : 'Save Worker'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9C27B0),
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