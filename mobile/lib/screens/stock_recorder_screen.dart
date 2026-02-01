import 'package:flutter/material.dart';
import '../services/api_service.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class StockRecorderScreen extends StatefulWidget {
  const StockRecorderScreen({super.key});

  @override
  State<StockRecorderScreen> createState() => _StockRecorderScreenState();
}

class _StockRecorderScreenState extends State<StockRecorderScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _ledgerData = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    try {
      final data = await _apiService.getGlobalStockLedger();
      setState(() {
        _ledgerData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return '${date.day}-${date.month}-${date.year}';
  }

  Future<void> _printPdf() async {
    try {
      final pdf = pw.Document();

      final headers = [
        'Dates',
        'Incoming item',
        'Quantity',
        'Outgoing items',
        'Quantity',
        'Remainder',
      ];

      final data = _ledgerData.map((item) {
        final name = item['name'] ?? '';
        final unit = item['unit'] ?? '';
        final qtyIn = item['incomingQuantity'] > 0
            ? '${item['incomingQuantity']} $unit'
            : '';
        final qtyOut = item['outgoingQuantity'] > 0
            ? '${item['outgoingQuantity']} $unit'
            : '';
        final incomingName = item['incomingQuantity'] > 0 ? name : '';
        final outgoingName = item['outgoingQuantity'] > 0 ? name : '';
        final remainder = '${item['remainder']} $unit';

        return [
          _formatDate(item['date']),
          incomingName,
          qtyIn,
          outgoingName,
          qtyOut,
          remainder,
        ];
      }).toList();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'STOCK RECORDER (2025)',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: headers,
                data: data,
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.centerLeft,
                  4: pw.Alignment.centerLeft,
                  5: pw.Alignment.centerLeft,
                },
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e. Please Restart App fully.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STOCK RECORDER(2025)'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _ledgerData.isEmpty ? null : _printPdf,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _ledgerData.length,
              itemBuilder: (context, index) {
                final item = _ledgerData[index];
                final name = item['name'] ?? '';
                final unit = item['unit'] ?? '';
                final date = _formatDate(item['date']);

                final isIncoming = (item['incomingQuantity'] ?? 0) > 0;
                final qty = isIncoming
                    ? item['incomingQuantity']
                    : item['outgoingQuantity'];
                final typeLabel = isIncoming ? 'IN' : 'OUT';
                final color = isIncoming ? Colors.green : Colors.red;
                final icon = isIncoming
                    ? Icons.arrow_downward
                    : Icons.arrow_upward;

                final remainder = '${item['remainder']} $unit';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        // Header: Name and Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              date,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const Divider(),
                        // Body: Transaction Details
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Transaction Chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: color.withOpacity(0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(icon, size: 16, color: color),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$typeLabel: $qty $unit',
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Balance
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Remainder',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  remainder,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
