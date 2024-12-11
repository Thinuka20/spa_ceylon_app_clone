import 'package:ZAM_GEMS/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

// Model for invoice data
class InvoiceData {
  final String invoiceNumber;
  final String saleby;
  final String branch;
  final String date;
  final String customerName;
  final String email;
  final String mobile;
  final List<InvoiceItem> items;
  final List<Payments> payments;
  final double total;
  final double rsequalant;

  InvoiceData({
    required this.saleby,
    required this.branch,
    required this.invoiceNumber,
    required this.date,
    required this.customerName,
    required this.email,
    required this.mobile,
    required this.items,
    required this.payments,
    required this.total,
    required this.rsequalant,
  });
}

class InvoiceItem {
  final String code;
  final double quantity;
  final String description;
  final double weight;
  final double amount;

  InvoiceItem({
    required this.code,
    required this.quantity,
    required this.description,
    required this.weight,
    required this.amount,
  });
}

class Payments {
  final String currency;
  final String type;
  final double amount;

  Payments({
    required this.currency,
    required this.type,
    required this.amount,
  });
}

class InvoicePdfViewer extends StatelessWidget {
  InvoicePdfViewer({Key? key}) : super(key: key);

  String get invoiceId => Get.arguments.toString();
  // Sample data - you can replace this with actual data
  InvoiceData get sampleData => InvoiceData(
        invoiceNumber: '$invoiceId',
        saleby:
            'The Honorable Justice William Harrison Benjamin Franklin Washington Ambassador Patricia Elizabeth Knightsbridge',
        branch: 'Zam Gems (Pvt) Ltd-L1, Odel Department',
        date: '10/12/2024',
        customerName: 'John Doe',
        email: 'abc@gmail.com',
        mobile: '0723344451',
        items: [
          InvoiceItem(
            code: '0010000339',
            quantity: 1.00,
            description: 'Ruby Gemstone',
            weight: 3.41,
            amount: 1000.00,
          ),
          InvoiceItem(
            code: '0010000339',
            quantity: 1,
            description: 'Ruby Gemstone',
            weight: 3.41,
            amount: 1500.00,
          ),
          InvoiceItem(
            code: '0010000339',
            quantity: 1,
            description: 'Ruby Gemstone',
            weight: 3.41,
            amount: 800.00,
          ),
        ],
        payments: [
          Payments(
            currency: "USD",
            type: "Card Visa",
            amount: 2000.0,
          ),
          Payments(
            currency: "USD",
            type: "Card Master",
            amount: 1000.0,
          ),
          Payments(
            currency: "USD",
            type: "Cash",
            amount: 100.0,
          ),
        ],
        total: 3100.00,
        rsequalant: 956241.00,
      );

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document(
      theme: pw.ThemeData.base().copyWith(
        defaultTextStyle: pw.TextStyle(fontSize: 10),
      ),
    );

    // Load the template image
    final image = await imageFromAssetBundle('assets/bill_template.png');

    final pageFormat = PdfPageFormat.a4.copyWith(
      marginTop: 0,
      marginBottom: 0,
      marginLeft: 0,
      marginRight: 0,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.Stack(
            children: [
              // Background template
              pw.SizedBox(
                width: pageFormat.width,
                height: pageFormat.height,
                child: pw.Image(image, fit: pw.BoxFit.cover),
              ),

              // Invoice data - adjust positions as needed
              pw.Positioned(
                right: 40,
                top: 150,
                child: pw.Text(
                  sampleData.branch,
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),

              pw.Positioned(
                left: 375,
                top: 197,
                child: pw.Text(
                  sampleData.invoiceNumber,
                  style: pw.TextStyle(
                      fontSize: 12,),
                ),
              ),

              pw.Positioned(
                left: 470,
                top: 197,
                child: pw.Text(
                  sampleData.date,
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),

              pw.Positioned(
                right: 25,
                top: 222,
                child: pw.SizedBox(
                  width: 230,
                  child: pw.Text(
                    "Sale By - ${sampleData.saleby}",
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ),
              ),

              // Customer details
              pw.Positioned(
                left: 116,
                top: 162,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      sampleData.customerName,
                      style: pw.TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    pw.SizedBox(height: 15),
                    pw.Text(
                      sampleData.mobile,
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    pw.SizedBox(height: 15),
                    pw.Text(
                      sampleData.email,
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Invoice items
              pw.Positioned(
                left: 50,
                top: 290,
                child: pw.Column(
                  children: [
                    ...sampleData.items
                        .map((item) => pw.Container(
                              margin: const pw.EdgeInsets.only(bottom: 10),
                              child: pw.Row(
                                children: [
                                  pw.SizedBox(
                                    width: 72,
                                    child: pw.Text(item.code),
                                  ),
                                  pw.SizedBox(
                                    width: 35,
                                    child: pw.Text(item.quantity.toString()),
                                  ),
                                  pw.SizedBox(
                                    width: 240,
                                    child: pw.Text(item.description),
                                  ),
                                  pw.SizedBox(width: 27),
                                  pw.SizedBox(
                                    width: 40,
                                    child: pw.Text(item.weight.toString()),
                                  ),
                                  pw.SizedBox(width: 20),
                                  pw.SizedBox(
                                    width: 70,
                                    child: pw.Text(
                                      item.amount.toString(),
                                      textAlign: pw.TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ],
                ),
              ),
              pw.Positioned(
                right: 40,
                top: 627,
                child: pw.Text(
                  '${sampleData.total.toStringAsFixed(2)}',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Positioned(
                right: 40,
                top: 665,
                child: pw.Text(
                  '${sampleData.rsequalant.toStringAsFixed(2)}',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Positioned(
                left: 350,
                top: 700,
                child: pw.Column(
                  children: [
                    ...sampleData.payments
                        .map(
                          (item) => pw.Container(
                            margin: const pw.EdgeInsets.only(bottom: 2),
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment
                                  .start, // Added to align row contents to the left
                              children: [
                                pw.SizedBox(
                                  width: 300,
                                  child: pw.Text(
                                    '(${item.currency} - ${item.type}) ${item.amount}',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: const Text(
            "Invoice Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: Theme(
          data: ThemeData(
            colorScheme: const ColorScheme.dark(
              // This should affect the controls and footer
              surface: Colors.transparent,
              onSurface: Colors.transparent,
            ),
          ),
          child: PdfPreview(
            build: (format) => _generatePdf(format),
            allowPrinting: true,
            allowSharing: true,
            initialPageFormat: PdfPageFormat.a4,
            pdfFileName: "zam_gems_invoice.pdf",
            canChangeOrientation: false,
            canChangePageFormat: false,
            previewPageMargin: const EdgeInsets.all(10),
          
            actions: const [],  // Remove default actions
            loadingWidget: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
