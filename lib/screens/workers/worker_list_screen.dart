import 'package:flutter/material.dart';
import '../../models/worker_model.dart';
import '../../db/db_helper.dart';
import 'add_worker_screen.dart';
import 'worker_detail_screen.dart';

class WorkerListScreen extends StatefulWidget {
  const WorkerListScreen({super.key});

  @override
  State<WorkerListScreen> createState() => _WorkerListScreenState();
}

class _WorkerListScreenState extends State<WorkerListScreen> {
  List<Worker> allWorkers = [];
  List<Worker> filteredWorkers = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadWorkers();
  }

  void loadWorkers() async {
    List<Worker> data = await DBHelper.getAllWorkers();
    setState(() {
      allWorkers = data;
      filteredWorkers = data;
    });
  }

  void filterWorkers(String query) {
    setState(() {
      filteredWorkers = allWorkers.where((w) => w.name.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Workers'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF9C27B0), Color(0xFF6C63FF)]),
            ),
            child: TextField(
              controller: searchController,
              onChanged: filterWorkers,
              decoration: InputDecoration(
                hintText: 'Search worker name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                        searchController.clear();
                        filterWorkers('');
                      })
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF14141F) : const Color(0xFFF6F7FB),
              child: filteredWorkers.isEmpty
                  ? const Center(child: Text('No workers found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: filteredWorkers.length,
                      itemBuilder: (context, index) {
                        Worker w = filteredWorkers[index];
                        bool pending = w.balance > 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFF9C27B0).withOpacity(0.12),
                              child: Text(w.name.isNotEmpty ? w.name[0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFF9C27B0), fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                            title: Text(w.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: (pending ? const Color(0xFFE53E3E) : const Color(0xFF38A169)).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('SAR ${w.balance.abs().toStringAsFixed(0)}', style: TextStyle(color: pending ? const Color(0xFFE53E3E) : const Color(0xFF38A169), fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text(pending ? 'Payment Due' : 'Cleared', style: TextStyle(fontSize: 9, color: pending ? const Color(0xFFE53E3E) : const Color(0xFF38A169))),
                                ],
                              ),
                            ),
                            onTap: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (context) => WorkerDetailScreen(worker: w)));
                              loadWorkers();
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddWorkerScreen()));
          if (result == true) loadWorkers();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}