import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../shop.dart'; // Import SaleRecord from shop.dart

class ProfilePage extends StatefulWidget {
  final List<SaleRecord> sales;

  const ProfilePage({Key? key, required this.sales}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int totalPoints = 0;
  int saleTransactions = 0;
  int purchaseTransactions = 0;
  int dailyBonuses = 0;
  int streakBonuses = 0;

  @override
  void initState() {
    super.initState();
    _calculateRewards();
  }

  void _calculateRewards() {
    // Reset counters
    saleTransactions = 0;
    purchaseTransactions = 0;
    dailyBonuses = 0;
    streakBonuses = 0;

    // Calculate sale and purchase transactions
    for (var sale in widget.sales) {
      if (sale.type == 'sell') {
        saleTransactions++;
      } else if (sale.type == 'buy') {
        purchaseTransactions++;
      }
    }

    // Calculate daily bonuses (10+ transactions in a day)
    Map<String, int> transactionsByDay = {};
    for (var sale in widget.sales) {
      String dateKey = '${sale.time.year}-${sale.time.month}-${sale.time.day}';
      transactionsByDay[dateKey] = (transactionsByDay[dateKey] ?? 0) + 1;
    }

    for (var count in transactionsByDay.values) {
      if (count >= 10) {
        dailyBonuses++;
      }
    }

    // Calculate streak bonuses (7-day streak with 5+ transactions daily)
    streakBonuses = _calculateStreakBonus(transactionsByDay);

    // Calculate total points
    totalPoints = (saleTransactions * 2) +
        (purchaseTransactions * 1) +
        (dailyBonuses * 10) +
        (streakBonuses * 50);

    setState(() {});
  }

  int _calculateStreakBonus(Map<String, int> transactionsByDay) {
    if (transactionsByDay.isEmpty) return 0;

    // Sort dates
    List<DateTime> dates = transactionsByDay.keys.map((key) {
      List<String> parts = key.split('-');
      return DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    }).toList();
    dates.sort();

    int streakCount = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (var date in dates) {
      String dateKey = '${date.year}-${date.month}-${date.day}';
      int txnCount = transactionsByDay[dateKey] ?? 0;

      if (txnCount >= 5) {
        if (lastDate == null || date.difference(lastDate).inDays == 1) {
          currentStreak++;
          if (currentStreak >= 7) {
            streakCount++;
            currentStreak = 0; // Reset for next potential streak
          }
        } else {
          currentStreak = 1; // Start new streak
        }
        lastDate = date;
      } else {
        currentStreak = 0;
        lastDate = null;
      }
    }

    return streakCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            SizedBox(height: 20),
            _buildPointsCard(),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'पुरस्कार विवरण',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildRewardTile(
                    icon: Icons.sell_rounded,
                    title: 'बिक्री कारोबार',
                    subtitle: '$saleTransactions कारोबार',
                    points: saleTransactions * 2,
                    color: Colors.green,
                  ),
                  _buildRewardTile(
                    icon: Icons.shopping_cart_rounded,
                    title: 'खरिद कारोबार',
                    subtitle: '$purchaseTransactions कारोबार',
                    points: purchaseTransactions * 1,
                    color: Colors.blue,
                  ),
                  _buildRewardTile(
                    icon: Icons.task_alt_rounded,
                    title: 'दैनिक बोनस',
                    subtitle: '$dailyBonuses दिन पूरा',
                    points: dailyBonuses * 10,
                    color: Colors.orange,
                  ),
                  _buildRewardTile(
                    icon: Icons.local_fire_department_rounded,
                    title: 'स्ट्रीक बोनस',
                    subtitle: '$streakBonuses सप्ताह',
                    points: streakBonuses * 50,
                    color: Colors.red,
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        color: Color(0xFF1B5E20),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                'प्रोफाइल',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.settings, color: Colors.white, size: 24),
                onPressed: () {}, // Placeholder for settings
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10)
                  ],
                ),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Color(0xFF1B5E20)),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ram Bahadur',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '९८४५६७८९०१',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'सबित्रा किराना तथा चिया पसल',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on,
                              color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'काठमाडौं, नेपाल',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'कुल पुरस्कार अंक',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '$totalPoints',
                    style: TextStyle(
                      color: Color(0xFFFFB300), // Gold/Orange color for text
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF8E1), // Light yellow bg
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 40,
                  color: Color(0xFFFFB300),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.0, // Initial state as requested
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
              minHeight: 10,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'अर्को इनामको लागि ७०% पूरा भयो',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required int points,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+$points',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
