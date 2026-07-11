import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive_io.dart';
import '../../db/db_helper.dart';
import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool isLoading = false;

  Future<String> getDbPath() async {
    return p.join(await getDatabasesPath(), 'khata_app.db');
  }

  void exportBackup() async {
    setState(() => isLoading = true);
    try {
      String dbPath = await getDbPath();
      File dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database file not found')),
        );
        setState(() => isLoading = false);
        return;
      }

      Directory tempDir = await getTemporaryDirectory();
      String backupName = 'al_musarmon_backup_${DateTime.now().millisecondsSinceEpoch}.zip';
      String zipPath = p.join(tempDir.path, backupName);

      var encoder = ZipFileEncoder();
      encoder.create(zipPath);
      encoder.addFile(dbFile, 'khata_app.db');
      encoder.close();

      await Share.shareXFiles(
        [XFile(zipPath)],
        text: 'Al Musarmon - Database Backup',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    setState(() => isLoading = false);
  }

  void importBackup() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Restore Data?'),
        content: const Text(
          'This will delete your current data and replace it with the backup data. This action cannot be undone. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Restore'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);
    try {
      // withData: true taake bytes seedha milein, path pe depend na karna pade
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result == null || result.files.single.bytes == null) {
        setState(() => isLoading = false);
        return;
      }

      Uint8List fileBytes = result.files.single.bytes!;
      String fileName = result.files.single.name.toLowerCase();
      String dbPath = await getDbPath();

      List<int> dbBytes;

      if (fileName.endsWith('.zip')) {
        final archive = ZipDecoder().decodeBytes(fileBytes);

        ArchiveFile? dbFileInZip;
        for (final file in archive) {
          if (file.isFile && file.name.toLowerCase().endsWith('.db')) {
            dbFileInZip = file;
            break;
          }
        }

        if (dbFileInZip == null) {
          throw Exception('No database file found inside the zip');
        }

        dbBytes = dbFileInZip.content as List<int>;
      } else if (fileName.endsWith('.db')) {
        dbBytes = fileBytes;
      } else {
        throw Exception('Please select a .zip or .db backup file');
      }

      // Database connection band karo taake file lock na ho
      await DBHelper.closeAndReset();

      File targetFile = File(dbPath);
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await targetFile.writeAsBytes(dbBytes, flush: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data restored successfully! Please close and reopen the app.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF636FA4), Color(0xFFE8CBC0)],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF14141F) : const Color(0xFFF6F7FB),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline_rounded, color: Colors.white),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Back up your data regularly to keep it safe.',
                                    style: TextStyle(color: Colors.white, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: exportBackup,
                            icon: const Icon(Icons.upload_file_rounded),
                            label: const Text('Create Backup (Export)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF38A169),
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: importBackup,
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Restore From Backup'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE53E3E),
                              foregroundColor: Colors.white,
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