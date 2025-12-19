import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadSampleLogs();
  }

  void _loadSampleLogs() {
    // Sample log data - in real app, this would come from a database or state management
    _logs = [
      {
        'product': 'बास्मती चामल',
        'action': 'बेचियो',
        'quantity': 5,
        'amount': 900.0,
        'date': DateTime.now().subtract(Duration(hours: 2)),
      },
      {
        'product': 'दाल',
        'action': 'किनियो',
        'quantity': 10,
        'amount': 1500.0,
        'date': DateTime.now().subtract(Duration(hours: 5)),
      },
      {
        'product': 'तोरीको तेल',
        'action': 'बेचियो',
        'quantity': 2,
        'amount': 640.0,
        'date': DateTime.now().subtract(Duration(days: 1)),
      },
      {
        'product': 'चिनी',
        'action': 'किनियो',
        'quantity': 20,
        'amount': 2000.0,
        'date': DateTime.now().subtract(Duration(days: 2)),
      },
    ];
  }

  Future<void> _exportLogsToCSV() async {
    if (_logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No logs to export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('Product,Action,Quantity,Amount,Date');
    
    for (var log in _logs) {
      buffer.writeln(
        '${log['product']},${log['action']},${log['quantity']},${log['amount']},${(log['date'] as DateTime).toIso8601String()}'
      );
    }
    
    final csv = buffer.toString();

    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/pasale_logs.csv';
      final file = File(path);
      await file.writeAsString(csv);

      await Share.shareXFiles([XFile(file.path)], text: 'Pasale Activity Logs CSV');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ CSV exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to export CSV: $e'),
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
        title: Text('Activity Logs', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF1E88E5),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            tooltip: 'Export CSV',
            onPressed: _exportLogsToCSV,
          ),
        ],
      ),
      body: _logs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No activity logs yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Summary card
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E88E5), Color(0xFF1976D2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF1E88E5).withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(
                        'Total Logs',
                        _logs.length.toString(),
                        Icons.list_alt,
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _buildSummaryItem(
                        'Total Amount',
                        'रू ${_logs.fold<double>(0.0, (sum, log) => sum + (log['amount'] as double)).toStringAsFixed(0)}',
                        Icons.currency_rupee,
                      ),
                    ],
                  ),
                ),

                // Export button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.file_download),
                    label: Text('Export to CSV'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _exportLogsToCSV,
                  ),
                ),

                SizedBox(height: 16),

                // Logs list
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      final isSale = log['action'] == 'बेचियो';
                      
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSale 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            child: Icon(
                              isSale ? Icons.sell : Icons.shopping_cart,
                              color: isSale ? Colors.green : Colors.orange,
                            ),
                          ),
                          title: Text(
                            log['product'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${log['action']} • Qty: ${log['quantity']} • ${_formatDate(log['date'] as DateTime)}',
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            'रू ${(log['amount'] as double).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSale ? Colors.green : Colors.orange,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}