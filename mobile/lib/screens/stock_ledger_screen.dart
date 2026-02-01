import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import 'edit_item_screen.dart';

class StockLedgerScreen extends StatefulWidget {
  final Item item;

  const StockLedgerScreen({super.key, required this.item});

  @override
  State<StockLedgerScreen> createState() => _StockLedgerScreenState();
}

class _StockLedgerScreenState extends State<StockLedgerScreen> {
  final ApiService _apiService = ApiService();
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _error;
  int? _currentQuantity;

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.item.quantity;
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await _apiService.getItemTransactions(
        widget.item.id,
      );
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Calculate table rows with running balance (Chronological Stock Card Logic)
  List<DataRow> _buildRows() {
    // Logic:
    // 1. Sort transactions Oldest to Newest (ASC).
    // 2. Calculate 'Starting Balance' (before the first visible transaction).
    //    Current Stock = Start Bal + Total In - Total Out
    //    Start Bal = Current Stock - Total In + Total Out
    // 3. Iterate transactions and calculate running balance.

    // Copy and sort ASC
    // Copy and sort ASC (Secondary sort by ID for stability)
    List<Transaction> sortedTx = List.from(_transactions);
    sortedTx.sort((a, b) {
      int cmp = a.createdAt.compareTo(b.createdAt);
      if (cmp != 0) return cmp;
      return a.id.compareTo(b.id);
    });

    // Calculate Starting Balance
    int currentStock = _currentQuantity ?? widget.item.quantity;
    int totalIn = 0;
    int totalOut = 0;
    for (var tx in sortedTx) {
      if (tx.type == 'IN') totalIn += tx.quantity;
      if (tx.type == 'OUT') totalOut += tx.quantity;
    }

    // Reverse calculation to find where we started
    int runningBalance = currentStock - totalIn + totalOut;

    List<DataRow> rows = [];

    for (var tx in sortedTx) {
      // Calculate balance AFTER this transaction
      if (tx.type == 'IN') {
        runningBalance += tx.quantity;
      } else if (tx.type == 'OUT') {
        runningBalance -= tx.quantity;
      }

      String incomingItem = '';
      String quantityIn = '';
      String outgoingItem = '';
      String quantityOut = '';

      if (tx.type == 'IN') {
        incomingItem = widget.item.name;
        quantityIn = '${tx.quantity} ${widget.item.unit}';
      } else if (tx.type == 'OUT') {
        outgoingItem = widget.item.name;
        quantityOut = '${tx.quantity} ${widget.item.unit}';
      }

      rows.add(
        DataRow(
          cells: [
            DataCell(Text(_formatDate(tx.createdAt))),
            DataCell(Text(incomingItem)),
            DataCell(Text(quantityIn)),
            DataCell(Text(outgoingItem)),
            DataCell(Text(quantityOut)),
            DataCell(Text('$runningBalance ${widget.item.unit}')),
          ],
        ),
      );
    }

    return rows;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemScreen(item: widget.item),
      ),
    );
    if (result == true) {
      if (mounted) Navigator.pop(context, true);
    }
  }

  void _showTransactionDialog(String type) {
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();
    final isStockIn = type == 'IN';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isStockIn ? 'Stock In (Restock)' : 'Stock Out (Issue/Usage)',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason (Optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isStockIn ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (quantityController.text.isEmpty) return;

              Navigator.pop(ctx);
              setState(() => _isLoading = true);

              try {
                await _apiService.updateStock(
                  widget.item.id,
                  int.parse(quantityController.text),
                  type,
                  reasonController.text,
                );

                // Update local quantity immediately to keep ledger consistent
                final qty = int.parse(quantityController.text);
                _currentQuantity ??= widget.item.quantity;
                if (type == 'IN') {
                  _currentQuantity = _currentQuantity! + qty;
                } else {
                  _currentQuantity = _currentQuantity! - qty;
                }

                // Refresh transactions and also need to refresh item details (quantity)
                // Actually _loadTransactions only refreshes the list, not the running balance base (widget.item.quantity).
                // We should ideally reload the Item too, but widget.item is final.
                // We should signal the InventoryScreen to reload.

                await _loadTransactions();

                // Showing success
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction recorded successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _navigateToEdit),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Dates',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Incoming item',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Quantity',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Outgoing items',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Quantity',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Remainder',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: _buildRows(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showTransactionDialog('IN'),
                        icon: const Icon(Icons.add),
                        label: const Text('Stock In'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showTransactionDialog('OUT'),
                        icon: const Icon(Icons.remove),
                        label: const Text('Stock Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
