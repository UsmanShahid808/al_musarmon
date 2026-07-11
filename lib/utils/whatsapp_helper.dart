import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  static String formatPhone(String rawPhone) {
    String digits = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.startsWith('00')) {
      digits = digits.substring(2);
    }

    // Agar number already 10 se zyada digits ka hai, maan lo country code already hai
    if (digits.length > 10) {
      return digits;
    }

    // Agar 0 se start ho raha hai (local number), Saudi code lagao
    if (digits.startsWith('0')) {
      return '966${digits.substring(1)}';
    }

    return digits;
  }

  static Future<void> sendMessage(BuildContext context, String rawPhone, String message) async {
    String phone = formatPhone(rawPhone);
    String encodedMessage = Uri.encodeComponent(message);
    final Uri url = Uri.parse('https://wa.me/$phone?text=$encodedMessage');

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open WhatsApp: $e')),
        );
      }
    }
  }
}