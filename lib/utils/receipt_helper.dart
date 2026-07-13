import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/sale_item_model.dart';

class ReceiptHelper {
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF6C63FF);
  static const PdfColor secondaryColor = PdfColor.fromInt(0xFF9C27B0);
  static const PdfColor greenColor = PdfColor.fromInt(0xFF38A169);
  static const PdfColor greyColor = PdfColor.fromInt(0xFF757575);
  static const PdfColor lightGrey = PdfColor.fromInt(0xFFF6F7FB);

  static const int receiptNumberOffset = 25100;

  static int displayNumber(int id) => id + receiptNumberOffset;

  static Future<pw.Font?> _loadArabicFontSafe() async {
    try {
      final fontData = await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf');
      return pw.Font.ttf(fontData);
    } catch (e) {
      return null;
    }
  }

  static Map<String, dynamic> _parseItem(SaleItem item) {
    RegExp regex = RegExp(r'^(.*)\s\((\d+)\s*suit\)$');
    Match? match = regex.firstMatch(item.productName);

    if (match != null) {
      String cleanName = match.group(1) ?? item.productName;
      int pieces = int.tryParse(match.group(2) ?? '1') ?? 1;
      double totalAmount = item.price * item.quantity;
      double pricePerPiece = pieces > 0 ? totalAmount / pieces : totalAmount;

      return {
        'name': cleanName,
        'qtyLabel': '$pieces suit',
        'pricePerUnit': pricePerPiece,
        'total': totalAmount,
      };
    }

    return {
      'name': item.productName,
      'qtyLabel': '${item.quantity.toStringAsFixed(1)}m',
      'pricePerUnit': item.price,
      'total': item.price * item.quantity,
    };
  }

  static Future<String?> generateAndShareReceipt({
    required int saleId,
    required List<SaleItem> items,
    required double totalAmount,
    String customerName = 'Walk-in Customer',
  }) async {
    try {
      final pdf = pw.Document();
      int shownNumber = displayNumber(saleId);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          margin: const pw.EdgeInsets.all(0),
          build: (context) {
            return pw.Column(
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  decoration: const pw.BoxDecoration(
                    gradient: pw.LinearGradient(colors: [primaryColor, secondaryColor]),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'AL MUSARMON',
                        style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.white, letterSpacing: 2),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('SALES RECEIPT', style: pw.TextStyle(fontSize: 10, color: PdfColors.white, letterSpacing: 3)),
                    ],
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Receipt No.', style: const pw.TextStyle(fontSize: 8, color: greyColor)),
                              pw.Text('#$shownNumber', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text('Date', style: const pw.TextStyle(fontSize: 8, color: greyColor)),
                              pw.Text(DateTime.now().toString().substring(0, 16), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text('Customer: $customerName', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 16),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        decoration: pw.BoxDecoration(color: lightGrey, borderRadius: pw.BorderRadius.circular(6)),
                        child: pw.Row(
                          children: [
                            pw.Expanded(flex: 4, child: pw.Text('ITEM', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: greyColor))),
                            pw.Expanded(flex: 2, child: pw.Text('QTY', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: greyColor))),
                            pw.Expanded(flex: 2, child: pw.Text('PRICE', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: greyColor))),
                            pw.Expanded(flex: 2, child: pw.Text('TOTAL', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: greyColor))),
                          ],
                        ),
                      ),
                      ...items.map((item) {
                        Map<String, dynamic> parsed = _parseItem(item);
                        return pw.Container(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide(color: lightGrey, width: 1)),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Expanded(flex: 4, child: pw.Text(parsed['name'], style: const pw.TextStyle(fontSize: 10))),
                              pw.Expanded(flex: 2, child: pw.Text(parsed['qtyLabel'], style: const pw.TextStyle(fontSize: 10))),
                              pw.Expanded(flex: 2, child: pw.Text('SAR ${(parsed['pricePerUnit'] as double).toStringAsFixed(0)}', style: const pw.TextStyle(fontSize: 10))),
                              pw.Expanded(
                                flex: 2,
                                child: pw.Text('SAR ${(parsed['total'] as double).toStringAsFixed(0)}',
                                    textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      }),
                      pw.SizedBox(height: 16),
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.all(14),
                        decoration: pw.BoxDecoration(
                          gradient: const pw.LinearGradient(colors: [primaryColor, secondaryColor]),
                          borderRadius: pw.BorderRadius.circular(10),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('TOTAL AMOUNT', style: pw.TextStyle(fontSize: 11, color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                            pw.Text('SAR ${totalAmount.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 18, color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 24),
                      pw.Center(
                        child: pw.Text('Thank you for your business!', style: pw.TextStyle(fontSize: 11, color: greyColor, fontStyle: pw.FontStyle.italic)),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();

      await Printing.sharePdf(
        bytes: bytes,
        filename: 'receipt_$shownNumber.pdf',
      );

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String?> generateOrderAdvanceReceipt({
    required int orderId,
    required String customerName,
    required String itemDescription,
    required double totalAmount,
    required double advancePaid,
  }) async {
    try {
      final pdf = pw.Document();
      double remaining = totalAmount - advancePaid;
      bool isFullyPaid = remaining <= 0;
      int shownNumber = displayNumber(orderId);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          margin: const pw.EdgeInsets.all(0),
          build: (context) {
            return pw.Column(
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  decoration: pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      colors: isFullyPaid
                          ? [greenColor, const PdfColor.fromInt(0xFF38ef7d)]
                          : [const PdfColor.fromInt(0xFFFF9A56), const PdfColor.fromInt(0xFFFF6B6B)],
                    ),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text('AL MUSARMON', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.white, letterSpacing: 2)),
                      pw.SizedBox(height: 4),
                      pw.Text(isFullyPaid ? 'PAYMENT RECEIPT' : 'ADVANCE PAYMENT RECEIPT', style: pw.TextStyle(fontSize: 10, color: PdfColors.white, letterSpacing: 2)),
                    ],
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Order No.', style: const pw.TextStyle(fontSize: 8, color: greyColor)),
                              pw.Text('#$shownNumber', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text('Date', style: const pw.TextStyle(fontSize: 8, color: greyColor)),
                              pw.Text(DateTime.now().toString().substring(0, 16), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(color: lightGrey, borderRadius: pw.BorderRadius.circular(8)),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('CUSTOMER', style: pw.TextStyle(fontSize: 8, color: greyColor, fontWeight: pw.FontWeight.bold)),
                            pw.Text(customerName, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 8),
                            pw.Text('ORDER DETAILS', style: pw.TextStyle(fontSize: 8, color: greyColor, fontWeight: pw.FontWeight.bold)),
                            pw.Text(itemDescription, style: const pw.TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      _buildPaymentRow('Total Amount', totalAmount, PdfColors.black),
                      pw.SizedBox(height: 8),
                      _buildPaymentRow('Amount Paid', advancePaid, greenColor),
                      pw.SizedBox(height: 12),
                      pw.Divider(color: PdfColors.grey300),
                      pw.SizedBox(height: 12),
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.all(14),
                        decoration: pw.BoxDecoration(
                          gradient: pw.LinearGradient(
                            colors: isFullyPaid
                                ? [greenColor, const PdfColor.fromInt(0xFF38ef7d)]
                                : [const PdfColor.fromInt(0xFFFF9A56), const PdfColor.fromInt(0xFFFF6B6B)],
                          ),
                          borderRadius: pw.BorderRadius.circular(10),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(isFullyPaid ? 'FULLY PAID' : 'REMAINING AMOUNT', style: pw.TextStyle(fontSize: 11, color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                            pw.Text(isFullyPaid ? 'SAR 0' : 'SAR ${remaining.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 18, color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 24),
                      pw.Center(
                        child: pw.Text('Thank you for your business!', style: pw.TextStyle(fontSize: 11, color: greyColor, fontStyle: pw.FontStyle.italic)),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();

      await Printing.sharePdf(
        bytes: bytes,
        filename: 'order_receipt_$shownNumber.pdf',
      );

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  static pw.Widget _buildPaymentRow(String label, double amount, PdfColor color) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 11, color: greyColor)),
        pw.Text('SAR ${amount.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }
}