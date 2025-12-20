import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../shop.dart';

// CSV EXPORT FUNCTION
// CSV EXPORT FUNCTION
Future<void> exportSalesToCsv(BuildContext context, List<SaleRecord> sales,
    List<Product> products) async {
  // 1. Aggregate Sales
  Map<String, Map<String, dynamic>> aggregated = {};

  // Helper to format date
  String formatDate(DateTime dt) =>
      "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";

  for (var sale in sales) {
    String dateKey = formatDate(sale.time);
    String key = "${dateKey}_${sale.productName}_${sale.type}";

    if (!aggregated.containsKey(key)) {
      aggregated[key] = {
        'date': dateKey,
        'productName': sale.productName,
        'type': sale.type,
        'quantity': 0.0,
        'amount': 0.0,
      };
    }
    aggregated[key]!['quantity'] += sale.quantity;
    aggregated[key]!['amount'] += sale.totalAmount;
  }

  final buffer = StringBuffer();
  // Add UTF-8 BOM for Excel compatibility
  buffer.write('\uFEFF');
  buffer.writeln('Product,Date,Type,Quantity,Unit,Amount');

  // Sort by date descending
  var sortedKeys = aggregated.keys.toList()..sort((a, b) => b.compareTo(a));

  for (var key in sortedKeys) {
    var item = aggregated[key]!;

    // Find unit
    String unit = '-';
    try {
      var prod = products.firstWhere((p) => p.name == item['productName'],
          orElse: () => Product(
              name: '',
              category: '',
              price: 0,
              unit: '-',
              quantity: 0)); // Fallback
      unit = prod.unit;
    } catch (e) {
      unit = '-';
    }

    buffer.writeln(
        '"${item['productName']}","\t${item['date']}","${item['type']}",${item['quantity']},"$unit",${item['amount']}');
  }

  final csv = buffer.toString();

  try {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/sales_log.csv';
    final file = File(path);
    await file.writeAsString(csv, encoding: const Utf8Codec());

    await Share.shareXFiles([XFile(file.path)], text: 'Sales Log CSV');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('CSV निर्यात गरियो!'), backgroundColor: Colors.green),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('CSV निर्यात गर्न असफल: $e'),
          backgroundColor: Colors.red),
    );
  }
}

class DashboardPage extends StatefulWidget {
  final List<Product> products;
  final List<SaleRecord> sales;

  const DashboardPage({Key? key, required this.products, required this.sales})
      : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _expandProductList = false;
  bool _expandSalesLog = false;

  @override
  Widget build(BuildContext context) {
    // 1. Calculate General Stats
    int totalProducts = widget.products.length;
    double totalStock = widget.products.fold(0.0, (sum, p) => sum + p.quantity);
    double totalValue =
        widget.products.fold(0.0, (sum, p) => sum + p.quantity * p.price);

    // 2. Filter Sell Transactions for Dashboard Top Cards
    double salesTodayCount = widget.sales
        .where((s) =>
            s.type == 'sell' &&
            s.time.year == DateTime.now().year &&
            s.time.month == DateTime.now().month &&
            s.time.day == DateTime.now().day)
        .fold(0.0, (sum, s) => sum + s.quantity);

    double salesTodayAmount = widget.sales
        .where((s) =>
            s.type == 'sell' &&
            s.time.year == DateTime.now().year &&
            s.time.month == DateTime.now().month &&
            s.time.day == DateTime.now().day)
        .fold(0.0, (sum, s) => sum + s.totalAmount);

    double totalSalesCount = widget.sales
        .where((s) => s.type == 'sell')
        .fold(0.0, (sum, s) => sum + s.quantity);

    double totalSalesAmount = widget.sales
        .where((s) => s.type == 'sell')
        .fold(0.0, (sum, s) => sum + s.totalAmount);

    // 3. Prepare Data for Product Table (Only Sold Items)
    Map<String, double> salesPerProduct = {
      for (var p in widget.products)
        p.name: widget.sales
            .where((s) => s.productName == p.name && s.type == 'sell')
            .fold(0, (sum, s) => sum + s.quantity)
    };

    Map<String, double> salesTodayPerProduct = {
      for (var p in widget.products)
        p.name: widget.sales
            .where((s) =>
                s.productName == p.name &&
                s.type == 'sell' &&
                s.time.year == DateTime.now().year &&
                s.time.month == DateTime.now().month &&
                s.time.day == DateTime.now().day)
            .fold(0, (sum, s) => sum + s.quantity)
    };

    // Filter to only products that have ever been sold
    final productsWithSales = widget.products
        .where((p) => (salesPerProduct[p.name] ?? 0) > 0)
        .toList();

    // Sort by most sold
    productsWithSales.sort((a, b) =>
        (salesPerProduct[b.name] ?? 0).compareTo(salesPerProduct[a.name] ?? 0));

    // 4. Prepare Data for Sales Log (Reverse Chronological)
    final sortedSales = widget.sales.reversed.toList();

    return Scaffold(
      backgroundColor: Color(0xFFF1F8E9), // Very light green background
      appBar: AppBar(
        title: Text('ड्यासबोर्ड',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 24)),
        backgroundColor: Color(0xFF1B5E20),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded),
            tooltip: "डाटा निर्यात गर्नुहोस्",
            onPressed: () =>
                exportSalesToCsv(context, widget.sales, widget.products),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header / Summary Section
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 30),
              decoration: BoxDecoration(
                  color: Color(0xFF1B5E20),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    )
                  ]),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  // Quick Actions
                  ElevatedButton.icon(
                    onPressed: () => exportSalesToCsv(
                        context, widget.sales, widget.products),
                    icon: Icon(Icons.file_download, size: 20),
                    label: Text("बिक्री विवरण (CSV)"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF1B5E20),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                  SizedBox(height: 25),
                  // Key Metrics Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _headerStatItem(
                        "आजको कमाई",
                        "रू ${salesTodayAmount.toStringAsFixed(0)}",
                        Text(
                          'रू',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(height: 40, width: 1, color: Colors.white30),
                      _headerStatItem(
                        "आजको बिक्री",
                        "${salesTodayCount % 1 == 0 ? salesTodayCount.toInt() : salesTodayCount.toStringAsFixed(1)}",
                        Icon(Icons.shopping_bag,
                            color: Colors.white70, size: 28),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("स्टक विवरण", style: _sectionTitleStyle),
                  SizedBox(height: 12),
                  // Stock Cards Grid
                  Row(
                    children: [
                      Expanded(
                          child: _modernCard("कुल सामान", "$totalProducts",
                              Icons.category, Colors.orangeAccent)),
                      SizedBox(width: 12),
                      Expanded(
                          child: _modernCard(
                              "कुल मौज्दात",
                              "${totalStock % 1 == 0 ? totalStock.toInt() : totalStock.toStringAsFixed(1)}",
                              Icons.inventory,
                              Colors.blueAccent)),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _modernCard(
                              "मौज्दात मूल्य",
                              "रू ${totalValue.toStringAsFixed(0)}",
                              Icons.monetization_on,
                              Colors.purpleAccent)),
                    ],
                  ),

                  SizedBox(height: 24),
                  Text("कुल कारोबार", style: _sectionTitleStyle),
                  SizedBox(height: 12),
                  // Total Sales Cards
                  Row(
                    children: [
                      Expanded(
                          child: _modernCard(
                              "कुल बिक्री",
                              "${totalSalesCount % 1 == 0 ? totalSalesCount.toInt() : totalSalesCount.toStringAsFixed(1)}",
                              Icons.trending_up,
                              Colors.teal)),
                      SizedBox(width: 12),
                      Expanded(
                          child: _modernCard(
                              "कुल कमाई",
                              "रू ${totalSalesAmount.toStringAsFixed(0)}",
                              Icons.account_balance_wallet,
                              Colors.green)),
                    ],
                  ),

                  SizedBox(height: 24),
                  // Product Sales Table
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.bar_chart, color: Color(0xFF1B5E20)),
                              SizedBox(width: 10),
                              Text('सामान अनुसार बिक्री (बिक्री भएको मात्र)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.grey[800])),
                            ],
                          ),
                          Divider(),
                          if (productsWithSales.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                  child: Text("कुनै सामान बिक्री भएको छैन",
                                      style: TextStyle(color: Colors.grey))),
                            )
                          else
                            Column(
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingTextStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B5E20)),
                                    columns: [
                                      DataColumn(label: Text('सामान')),
                                      DataColumn(label: Text('कुल बिक्री')),
                                      DataColumn(label: Text('आजको बिक्री')),
                                    ],
                                    rows: (_expandProductList
                                            ? productsWithSales
                                            : productsWithSales
                                                .take(5)
                                                .toList())
                                        .map((p) {
                                      return DataRow(cells: [
                                        DataCell(Text(p.name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500))),
                                        DataCell(Text(
                                            (salesPerProduct[p.name] ?? 0.0)
                                                .toStringAsFixed(1))),
                                        DataCell(Text(
                                            (salesTodayPerProduct[p.name] ??
                                                    0.0)
                                                .toStringAsFixed(1))),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                                if (productsWithSales.length > 5)
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _expandProductList =
                                            !_expandProductList;
                                      });
                                    },
                                    icon: Icon(_expandProductList
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down),
                                    label: Text(_expandProductList
                                        ? "कम हेर्नुहोस्"
                                        : "थप हेर्नुहोस्"),
                                    style: TextButton.styleFrom(
                                        foregroundColor: Color(0xFF1B5E20)),
                                  )
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24),
                  // Current Sales Log
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.history, color: Color(0xFF1B5E20)),
                              SizedBox(width: 10),
                              Text('हालैको कारोबार (खरिद र बिक्री)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.grey[800])),
                            ],
                          ),
                          Divider(),
                          _buildSalesLogList(sortedSales),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerStatItem(String label, String value, Widget iconWidget) {
    return Column(
      children: [
        iconWidget,
        SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _modernCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4))
          ],
          border: Border.all(color: color.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800])),
          SizedBox(height: 4),
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  final TextStyle _sectionTitleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF1B5E20),
      letterSpacing: 0.5);

  Widget _buildSalesLogList(List<SaleRecord> sortedSales) {
    if (sortedSales.isEmpty)
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text('कुनै कारोबार भएको छैन।',
            style: TextStyle(color: Colors.grey)),
      ));

    // Limit list if not expanded
    final displayList =
        _expandSalesLog ? sortedSales : sortedSales.take(5).toList();

    return Column(
      children: [
        ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: displayList.length,
          separatorBuilder: (ctx, i) => Divider(height: 1),
          itemBuilder: (context, index) {
            final sale = displayList[index];
            final isSell = sale.type == 'sell';
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: CircleAvatar(
                backgroundColor:
                    isSell ? Colors.green.shade50 : Colors.orange.shade50,
                child: Icon(
                  isSell ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isSell ? Colors.green : Colors.orange,
                  size: 20,
                ),
              ),
              title: Text(sale.productName,
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                  '${isSell ? "बिक्री" : "खरिद"}: ${sale.quantity % 1 == 0 ? sale.quantity.toInt() : sale.quantity.toStringAsFixed(2)} | ${sale.time.hour.toString().padLeft(2, '0')}:${sale.time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 12)),
              trailing: Text('रू ${sale.totalAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSell ? Colors.green[700] : Colors.orange[800])),
            );
          },
        ),
        if (sortedSales.length > 5)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _expandSalesLog = !_expandSalesLog;
              });
            },
            icon: Icon(_expandSalesLog
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down),
            label: Text(_expandSalesLog ? "कम हेर्नुहोस्" : "थप हेर्नुहोस्"),
            style: TextButton.styleFrom(foregroundColor: Color(0xFF1B5E20)),
          )
      ],
    );
  }
}
