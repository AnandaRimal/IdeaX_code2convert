import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:math';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'screens/dashboard_page.dart';
import 'screens/profile_page.dart';

void main() {
  runApp(NepalShopApp());
}

class NepalShopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'पसले',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Color(0xFF1E88E5),
        fontFamily: 'Roboto',
      ),
      home: ShopHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Product {
  final String name;
  final String category; // This will match filter section
  final double price;
  final String unit;
  final String imageUrl;
  int quantity;

  Product({
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    this.imageUrl = '',
    this.quantity = 0,
  });

  // Convert Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  // Create Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      category: json['category'],
      price: json['price'],
      unit: json['unit'],
      quantity: json['quantity'],
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class SaleRecord {
  final String productName;
  final DateTime time;
  final int quantity;
  final double totalAmount;
  final String type; // 'buy' or 'sell'

  SaleRecord({
    required this.productName,
    required this.time,
    required this.quantity,
    required this.totalAmount,
    required this.type,
  });

  // Convert SaleRecord to JSON (for saving to cache)
  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'time': time.toIso8601String(),
      'quantity': quantity,
      'totalAmount': totalAmount,
      'type': type,
    };
  }

  // Create SaleRecord from JSON (for loading from cache)
  factory SaleRecord.fromJson(Map<String, dynamic> json) {
    return SaleRecord(
      productName: json['productName'],
      time: DateTime.parse(json['time']),
      quantity: json['quantity'],
      totalAmount: json['totalAmount'],
      type: json['type'],
    );
  }
}

class ShopHomePage extends StatefulWidget {
  @override
  _ShopHomePageState createState() => _ShopHomePageState();
}

class _ShopHomePageState extends State<ShopHomePage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'सबै';
  List<Product> _filteredProducts = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _categories = [
    'सबै',
    'खानेकुरा',
    'नास्ता / स्न्याक्स',
    'पेय पदार्थ',
    'मसला',
    'घरेलु सामान',
  ];

  // Generate random quantities for demo
  final Random _random = Random();

  late final List<Product> _products;

  final List<SaleRecord> _sales = [];

  // Map to track quantity counter for each product (for +/- buttons)
  final Map<String, int> _productQuantityCounters = {};

  // Voice recognition fields
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isDialogOpen = false; // <-- Added dialog open flag

  // Bottom Navbar index
  int _selectedNavbarIndex = 0;

  @override
  void initState() {
    super.initState();
    // List of all products with random quantity for demo
    _products = [
      // खानेकुरा
      Product(
          name: 'बास्मती चामल',
          category: 'खानेकुरा',
          price: 180,
          unit: 'केजी',
          imageUrl:
              'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=200',
          quantity: _rand()),
      Product(
          name: 'दाल',
          category: 'खानेकुरा',
          price: 150,
          unit: 'केजी',
          imageUrl:
              'https://images.unsplash.com/photo-1596040033229-a0b44cdfdb1c?w=200',
          quantity: _rand()),
      Product(
          name: 'तोरीको तेल',
          category: 'खानेकुरा',
          price: 320,
          unit: 'लिटर',
          imageUrl:
              'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=200',
          quantity: _rand()),
      Product(
          name: 'नुन',
          category: 'खानेकुरा',
          price: 20,
          unit: 'प्याकेट',
          imageUrl:
              'https://images.unsplash.com/photo-1598867299401-f88a3f7dfe78?w=200',
          quantity: _rand()),
      Product(
          name: 'चिनी',
          category: 'खानेकुरा',
          price: 100,
          unit: 'केजी',
          imageUrl:
              'https://images.unsplash.com/photo-1582654165286-8397973a7e3c?w=200',
          quantity: _rand()),
      Product(
          name: 'पीठो',
          category: 'खानेकुरा',
          price: 85,
          unit: 'केजी',
          imageUrl:
              'https://images.unsplash.com/photo-1628864269543-d950a1f08160?w=200',
          quantity: _rand()),
      Product(
          name: 'गुन्द्रुक',
          category: 'खानेकुरा',
          price: 95,
          unit: 'प्याकेट',
          imageUrl:
              'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=200',
          quantity: _rand()),
      Product(
          name: 'गहुँ',
          category: 'खानेकुरा',
          price: 90,
          unit: 'केजी',
          imageUrl:
              'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=200',
          quantity: _rand()),
      Product(
          name: 'मकै',
          category: 'खानेकुरा',
          price: 80,
          unit: 'केजी',
          imageUrl:
              'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=200',
          quantity: _rand()),
      Product(
          name: 'कोदो',
          category: 'खानेकुरा',
          price: 100,
          unit: 'केजी',
          imageUrl:
              'https://images.unsplash.com/photo-1560493676-04071c5f467b?w=200',
          quantity: _rand()),

      // मसला
      Product(
          name: 'जीरा',
          category: 'मसला',
          price: 200,
          unit: 'केजी',
          imageUrl:
              'https://images.unsplash.com/photo-1596040033229-a0b44cdfdb1c?w=200',
          quantity: _rand()),
      Product(
          name: 'गरम मसला',
          category: 'मसला',
          price: 120,
          unit: 'प्याकेट',
          imageUrl:
              'https://images.unsplash.com/photo-1599909595787-9fcd68dc4f7c?w=200',
          quantity: _rand()),
      Product(
          name: 'हल्दी पाउडर',
          category: 'मसला',
          price: 90,
          unit: 'प्याकेट',
          imageUrl:
              'https://images.unsplash.com/photo-1615485736743-e73a4c5f8e0c?w=200',
          quantity: _rand()),
      Product(
          name: 'धनियाँ पाउडर',
          category: 'मसला',
          price: 80,
          unit: 'प्याकेट',
          imageUrl:
              'https://images.unsplash.com/photo-1596040033229-a0b44cdfdb1c?w=200',
          quantity: _rand()),
      Product(
          name: 'अदुवा पाउडर',
          category: 'मसला',
          price: 100,
          unit: 'प्याकेट',
          imageUrl:
              'https://images.unsplash.com/photo-1577003833154-a7e3ea2c9f87?w=200',
          quantity: _rand()),
      Product(
          name: 'लसुन पाउडर',
          category: 'मसला',
          price: 110,
          unit: 'प्याकेट',
          imageUrl:
              'https://images.unsplash.com/photo-1588776814546-daab30f310ce?w=200',
          quantity: _rand()),

      // नास्ता / स्न्याक्स
      Product(
          name: 'चाउचाउ',
          category: 'नास्ता / स्न्याक्स',
          price: 25,
          unit: 'प्याकेट',
          imageUrl:
              'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=200',
          quantity: _rand()),
      Product(
          name: 'कुरकुरे',
          category: 'नास्ता / स्न्याक्स',
          price: 20,
          unit: 'प्याकेट',
          imageUrl:
              'https://images.unsplash.com/photo-1621447504864-d8686e12698c?w=200',
          quantity: _rand()),
      Product(
          name: 'बिस्कुट',
          category: 'नास्ता / स्न्याक्स',
          price: 30,
          unit: 'प्याकेट',
          imageUrl:
              'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=200',
          quantity: _rand()),
      Product(
          name: 'पापड',
          category: 'नास्ता / स्न्याक्स',
          price: 15,
          unit: 'पिस',
          imageUrl:
              'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=200',
          quantity: _rand()),
      Product(
          name: 'सेल रोटी मिक्स',
          category: 'नास्ता / स्न्याक्स',
          price: 125,
          unit: 'प्याकेट',
          imageUrl:
              'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200',
          quantity: _rand()),
      Product(
          name: 'भुजा',
          category: 'नास्ता / स्न्याक्स',
          price: 40,
          unit: 'प्याकेट',
          imageUrl:
              'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=200',
          quantity: _rand()),
      Product(
          name: 'मकै भुटेको',
          category: 'नास्ता / स्न्याक्स',
          price: 30,
          unit: 'प्याकेट',
          imageUrl:
              'https://images.unsplash.com/photo-1505686994434-e3cc5abf1330?w=200',
          quantity: _rand()),

      // पेय पदार्थ
      Product(
          name: 'कोकाकोला',
          category: 'पेय पदार्थ',
          price: 60,
          unit: 'बोतल',
          imageUrl:
              'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=200',
          quantity: _rand()),
      Product(
          name: 'फ्रूटी',
          category: 'पेय पदार्थ',
          price: 25,
          unit: 'प्याकेट',
          imageUrl:
              'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=200',
          quantity: _rand()),
      Product(
          name: 'रियल ज्यूस',
          category: 'पेय पदार्थ',
          price: 90,
          unit: 'प्याकेट',
          imageUrl:
              'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=200',
          quantity: _rand()),
      Product(
          name: 'मिनरल वाटर',
          category: 'पेय पदार्थ',
          price: 20,
          unit: 'बोतल',
          imageUrl:
              'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=200',
          quantity: _rand()),
      Product(
          name: 'नेपाली चिया',
          category: 'पेय पदार्थ',
          price: 45,
          unit: 'प्याकेट',
          imageUrl:
              'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=200',
          quantity: _rand()),
      Product(
          name: 'इन्स्टेन्ट कफी',
          category: 'पेय पदार्थ',
          price: 120,
          unit: 'प्याकेट',
          imageUrl:
              'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=200',
          quantity: _rand()),

      // घरेलु सामान
      Product(
          name: 'मह',
          category: 'घरेलु सामान',
          price: 850,
          unit: 'बोतल',
          imageUrl:
              'https://images.unsplash.com/photo-1587049352846-4a222e784587?w=200',
          quantity: _rand()),
      Product(
          name: 'अचार',
          category: 'घरेलु सामान',
          price: 280,
          unit: 'बोतल',
          imageUrl:
              'https://images.unsplash.com/photo-1589621316382-008455b857cd?w=200',
          quantity: _rand()),
      Product(
          name: 'घ्यु',
          category: 'घरेलु सामान',
          price: 1200,
          unit: 'लिटर',
          imageUrl:
              'https://images.unsplash.com/photo-1628863353691-0071c8c1874c?w=200',
          quantity: _rand()),
      Product(
          name: 'सावुन',
          category: 'घरेलु सामान',
          price: 25,
          unit: 'पिस',
          imageUrl:
              'https://images.unsplash.com/photo-1585128792103-e8c7468f723f?w=200',
          quantity: _rand()),
      Product(
          name: 'टुथपेस्ट',
          category: 'घरेलु सामान',
          price: 90,
          unit: 'वटा',
          imageUrl:
              'https://images.unsplash.com/photo-1622372738946-62e02505feb3?w=200',
          quantity: _rand()),
      Product(
          name: 'ब्रस',
          category: 'घरेलु सामान',
          price: 40,
          unit: 'वटा',
          imageUrl:
              'https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?w=200',
          quantity: _rand()),
      Product(
          name: 'डिटर्जेन्ट पाउडर',
          category: 'घरेलु सामान',
          price: 90,
          unit: 'प्याकेट',
          imageUrl:
              'https://images.unsplash.com/photo-1603899122634-f086ca5f5ddd?w=200',
          quantity: _rand()),
      Product(
          name: 'डिटर्जेन्ट बार',
          category: 'घरेलु सामान',
          price: 25,
          unit: 'पिस',
          imageUrl:
              'https://images.unsplash.com/photo-1585128792103-e8c7468f723f?w=200',
          quantity: _rand()),
      Product(
          name: 'फिनाइल',
          category: 'घरेलु सामान',
          price: 100,
          unit: 'बोतल',
          imageUrl:
              'https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=200',
          quantity: _rand()),
      Product(
          name: 'झाडु',
          category: 'घरेलु सामान',
          price: 80,
          unit: 'वटा',
          imageUrl:
              'https://images.unsplash.com/photo-1563453392212-326f5e854473?w=200',
          quantity: _rand()),

      // खाना पकाउने सामग्री
      Product(
          name: 'ग्यास सिलिन्डर',
          category: 'खाना पकाउने सामग्री',
          price: 1800,
          unit: 'वटा',
          imageUrl:
              'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=200',
          quantity: _rand()),
      Product(
          name: 'कुकर',
          category: 'खाना पकाउने सामग्री',
          price: 1200,
          unit: 'वटा',
          imageUrl:
              'https://images.unsplash.com/photo-1584990347449-39b4aa090603?w=200',
          quantity: _rand()),
      Product(
          name: 'भाँडा माझ्ने साबुन',
          category: 'खाना पकाउने सामग्री',
          price: 25,
          unit: 'पिस',
          imageUrl:
              'https://images.unsplash.com/photo-1585128792103-e8c7468f723f?w=200',
          quantity: _rand()),
      Product(
          name: 'भाँडा माझ्ने लिक्विड',
          category: 'खाना पकाउने सामग्री',
          price: 120,
          unit: 'बोतल',
          imageUrl:
              'https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=200',
          quantity: _rand()),

      // बच्चाको सामग्री
      Product(
          name: 'पाम्पर्स',
          category: 'बच्चाको सामग्री',
          price: 300,
          unit: 'प्याकेट',
          imageUrl:
              'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=200',
          quantity: _rand()),
      Product(
          name: 'बेबी लोसन',
          category: 'बच्चाको सामग्री',
          price: 250,
          unit: 'बोतल',
          imageUrl:
              'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=200',
          quantity: _rand()),
      Product(
          name: 'बेबी पाउडर',
          category: 'बच्चाको सामग्री',
          price: 180,
          unit: 'बोतल',
          imageUrl:
              'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=200',
          quantity: _rand()),
      Product(
          name: 'बेबी साबुन',
          category: 'बच्चाको सामग्री',
          price: 60,
          unit: 'पिस',
          imageUrl:
              'https://images.unsplash.com/photo-1585128792103-e8c7468f723f?w=200',
          quantity: _rand()),

      // अन्य
      Product(
          name: 'मोमबत्ती',
          category: 'अन्य',
          price: 20,
          unit: 'प्याकेट',
          imageUrl:
              'https://images.unsplash.com/photo-1602874801006-47c1c698b8e6?w=200',
          quantity: _rand()),
      Product(
          name: 'म्याचिस',
          category: 'अन्य',
          price: 5,
          unit: 'प्याकेट',
          imageUrl:
              'https://images.unsplash.com/photo-1523821741446-edb2b68bb7a0?w=200',
          quantity: _rand()),
      Product(
          name: 'प्लास्टिक झोला',
          category: 'अन्य',
          price: 10,
          unit: 'पिस',
          imageUrl:
              'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=200',
          quantity: _rand()),
      Product(
          name: 'अल्मुनियम फोइल',
          category: 'अन्य',
          price: 90,
          unit: 'रोल',
          imageUrl:
              'https://images.unsplash.com/photo-1610557892470-55d9e80c0bce?w=200',
          quantity: _rand()),
    ];

    _filteredProducts = _products;
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();

    _speech = stt.SpeechToText();
    _loadSalesFromCache(); // Load saved sales records
  }

  // Helper to generate random quantity (between 5 and 28)
  static int _rand() {
    return 5 + Random().nextInt(24); // 5 to 28
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Load sales from cache and restore product quantities
  Future<void> _loadSalesFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final String? salesJson = prefs.getString('sales_records');
    final String? productsJson = prefs.getString('products_quantities');

    setState(() {
      // Load sales records
      if (salesJson != null) {
        final List<dynamic> decoded = jsonDecode(salesJson);
        _sales.clear();
        _sales
            .addAll(decoded.map((json) => SaleRecord.fromJson(json)).toList());
      }

      // Load product quantities
      if (productsJson != null) {
        final Map<String, dynamic> quantities = jsonDecode(productsJson);
        for (var product in _products) {
          if (quantities.containsKey(product.name)) {
            product.quantity = quantities[product.name];
          }
        }
      }
    });
  }

  // Save sales and product quantities to cache
  Future<void> _saveSalesToCache() async {
    final prefs = await SharedPreferences.getInstance();

    // Save sales records
    final List<Map<String, dynamic>> salesJson =
        _sales.map((s) => s.toJson()).toList();
    await prefs.setString('sales_records', jsonEncode(salesJson));

    // Save product quantities
    final Map<String, int> quantities = {};
    for (var product in _products) {
      quantities[product.name] = product.quantity;
    }
    await prefs.setString('products_quantities', jsonEncode(quantities));
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch = product.name
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
        final matchesCategory =
            _selectedCategory == 'सबै' || product.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _buyProduct(Product product, [int quantity = 1]) {
    setState(() {
      if (product.quantity < 50) {
        product.quantity += quantity;
        _sales.add(
          SaleRecord(
            productName: product.name,
            time: DateTime.now(),
            quantity: quantity,
            totalAmount: product.price * quantity,
            type: 'buy',
          ),
        );
      }
    });
    _saveSalesToCache(); // Save to cache after buying
    _showSnackBar(
        '${product.name} किनियो! मात्रा: $quantity, जम्मा स्टक: ${product.quantity}',
        Colors.green);
  }

  void _sellProduct(Product product, [int quantity = 1]) {
    setState(() {
      if (product.quantity >= quantity) {
        product.quantity -= quantity;
        _sales.add(
          SaleRecord(
            productName: product.name,
            time: DateTime.now(),
            quantity: quantity,
            totalAmount: product.price * quantity,
            type: 'sell',
          ),
        );
      }
    });
    _saveSalesToCache(); // Save to cache after selling
    _showSnackBar(
        '${product.name} बेचियो! मात्रा: $quantity, जम्मा स्टक: ${product.quantity}',
        Colors.orange);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'खानेकुरा':
        return Colors.teal;
      case 'नास्ता / स्न्याक्स':
        return Colors.deepOrange;
      case 'पेय पदार्थ':
        return Colors.blue;
      case 'मसला':
        return Colors.green;
      case 'घरेलु सामान':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'खानेकुरा':
        return Icons.fastfood;
      case 'नास्ता / स्न्याक्स':
        return Icons.fastfood;
      case 'पेय पदार्थ':
        return Icons.local_drink;
      case 'मसला':
        return Icons.spa;
      case 'घरेलु सामान':
        return Icons.home;
      default:
        return Icons.inventory_2;
    }
  }

  // --- MIC FUNCTION WITH POPUP ---
  void _listenVoice() async {
    if (!_isListening) {
      // Request microphone permission first
      var status = await Permission.microphone.request();

      if (status.isDenied) {
        _showSnackBar(
            'माइक्रोफोन अनुमति आवश्यक छ! / Microphone permission required!',
            Colors.red);
        return;
      }

      if (status.isPermanentlyDenied) {
        _showSnackBar(
            'कृपया सेटिङमा जानुहोस् र माइक्रोफोन अनुमति दिनुहोस्! / Please enable microphone in Settings!',
            Colors.red);
        openAppSettings();
        return;
      }

      // Only initialize if not already initialized
      if (!_speech.isAvailable) {
        bool available = await _speech.initialize(
          onStatus: (val) {
            if (val == 'done' || val == 'notListening') {
              setState(() => _isListening = false);
              _closeListeningDialog();
            }
          },
          onError: (val) {
            setState(() => _isListening = false);
            _closeListeningDialog();
            _showSnackBar('Mic error: ${val.errorMsg}', Colors.red);
          },
        );
        if (!available) {
          _showSnackBar(
              'Speech recognition unavailable! Please check if Google app is installed.',
              Colors.red);
          return;
        }
      }

      setState(() => _isListening = true);
      _showListeningDialog();
      await _speech.listen(
        localeId: 'ne_NP', // Try removing if Nepali not supported
        onResult: (val) {
          setState(() {
            _searchController.text = val.recognizedWords;
            _filterProducts();
          });

          // Close dialog after 2 seconds of recognizing voice
          if (val.recognizedWords.isNotEmpty) {
            Future.delayed(Duration(seconds: 2), () async {
              if (_isListening) {
                setState(() => _isListening = false);
                await _speech.stop();
                _closeListeningDialog();
              }
            });
          }
        },
      );
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
      _closeListeningDialog();
    }
  }

  void _showListeningDialog() {
    if (!_isDialogOpen) {
      _isDialogOpen = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      onPressed: () async {
                        setState(() => _isListening = false);
                        await _speech.stop();
                        _closeListeningDialog();
                      },
                      tooltip: "बन्द गर्नुहोस्",
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.shade100,
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(22),
                  child: Icon(Icons.mic_rounded, color: Colors.red, size: 60),
                ),
                SizedBox(height: 14),
                Text(
                  "आवाज सुन्दैछ...\nकृपया बोल्नुहोस्!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  "Voice is listening...",
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ).then((_) {
        _isDialogOpen = false;
      });
    }
  }

  void _closeListeningDialog() {
    if (_isDialogOpen) {
      Navigator.of(context, rootNavigator: true).pop();
      _isDialogOpen = false;
    }
  }
  // --- END MIC FUNCTION WITH POPUP ---

  // --- Cool Bottom Navbar ---
  Widget _buildBottomNavbar() {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF1E88E5),
        unselectedItemColor: Colors.grey[500],
        currentIndex: _selectedNavbarIndex,
        elevation: 14,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, size: 28),
            label: "गृहपृष्ठ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded, size: 28),
            label: "प्रोफाइल",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_rounded, size: 28),
            label: "हाम्रो बारेमा",
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedNavbarIndex = index;
          });
          if (index == 1) {
            _showProfileDialog();
          } else if (index == 2) {
            _showAboutUsDialog();
          }
          // index==0 is home, do nothing (just stay here)
        },
      ),
    );
  }

  void _showProfileDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(sales: _sales),
      ),
    );
  }

  void _showAboutUsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(Icons.info_rounded, color: Color(0xFF1E88E5)),
            SizedBox(width: 10),
            Text('हाम्रो बारेमा',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'पसले एक सरल, स्मार्ट र नेपाली भाषामा आधारित पसल व्यवस्थापन एप हो। '
                'यस एपको उद्देश्य साना तथा मझौला व्यवसायीहरूको दैनिक व्यापार सजिलो बनाउनु हो।\n\n'
                'यो एप डेमो प्रयोजनका लागि बनाइएको हो।\n\n'
                'पसले एपले स्टक व्यवस्थापन, बिक्री/किनमेल र आवाज खोज जस्ता सुविधाहरू उपलब्ध गराउँछ। '
                'यसले तपाईंको पसलको सम्पूर्ण विवरण सजिलै ट्र्याक गर्न र विश्लेषण गर्न सहयोग गर्छ।\n\n'
                'हामी नेपाली व्यवसायीहरूको डिजिटल यात्रामा साथ दिन प्रतिबद्ध छौं। '
                'तपाईंको सुझाव र प्रतिक्रिया सधैं स्वागत छ!',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.copyright, size: 16, color: Colors.grey),
                  SizedBox(width: 3),
                  Text('2025 | Team Pasale',
                      style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ठिक छ'),
          ),
        ],
      ),
    );
  }
  // --- End Cool Bottom Navbar ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'lib/img/logo.jpeg',
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.store, color: Colors.white, size: 40);
                },
              ),
            ),
            SizedBox(width: 12),
            Text(
              'पसले',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Color(0xFF1E88E5),
        elevation: 8,
        actions: [
          IconButton(
            icon: Icon(Icons.dashboard, color: Colors.white),
            tooltip: "ड्यासबोर्ड",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DashboardPage(products: _products, sales: _sales),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.analytics, color: Colors.white),
            tooltip: "विश्लेषण",
            onPressed: () => _showAnalytics(),
          ),
        ],
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Search and Filter Section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'उत्पादन खोज्नुहोस्...',
                          prefixIcon:
                              Icon(Icons.search, color: Color(0xFF1E88E5)),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _filterProducts();
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Color(0xFFF0F0F0),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                        ),
                        onChanged: (value) => _filterProducts(),
                      ),
                      SizedBox(height: 12),
                      Container(
                        height: 45,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final isSelected = _selectedCategory == category;
                            return Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Color(0xFF1E88E5),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory = category;
                                    _filterProducts();
                                  });
                                },
                                backgroundColor: Colors.white,
                                selectedColor: Color(0xFF1E88E5),
                                elevation: isSelected ? 4 : 2,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Products List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [Colors.white, Color(0xFFFAFAFA)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor(
                                                  product.category)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: product.imageUrl.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  product.imageUrl,
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Icon(
                                                      _getCategoryIcon(
                                                          product.category),
                                                      color: _getCategoryColor(
                                                          product.category),
                                                      size: 32,
                                                    );
                                                  },
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return SizedBox(
                                                      width: 40,
                                                      height: 40,
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                  Color>(
                                                            _getCategoryColor(
                                                                product
                                                                    .category),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            : Icon(
                                                _getCategoryIcon(
                                                    product.category),
                                                color: _getCategoryColor(
                                                    product.category),
                                                size: 32,
                                              ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2C2C2C),
                                              ),
                                            ),
                                            Text(
                                              product.category,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: _getCategoryColor(
                                                    product.category),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: product.quantity > 0
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'स्टक: ${product.quantity}',
                                          style: TextStyle(
                                            color: product.quantity > 0
                                                ? Colors.green[700]
                                                : Colors.red[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'रू ${product.price.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E88E5),
                                            ),
                                          ),
                                          Text(
                                            'प्रति ${product.unit}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          // Quantity selector with +/- buttons
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.remove,
                                                      size: 20),
                                                  onPressed: () {
                                                    setState(() {
                                                      int current =
                                                          _productQuantityCounters[
                                                                  product
                                                                      .name] ??
                                                              1;
                                                      if (current > 1) {
                                                        _productQuantityCounters[
                                                                product.name] =
                                                            current - 1;
                                                      }
                                                    });
                                                  },
                                                  padding: EdgeInsets.all(4),
                                                  constraints: BoxConstraints(),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    '${_productQuantityCounters[product.name] ?? 1}',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon:
                                                      Icon(Icons.add, size: 20),
                                                  onPressed: () {
                                                    setState(() {
                                                      int current =
                                                          _productQuantityCounters[
                                                                  product
                                                                      .name] ??
                                                              1;
                                                      if (current < 5) {
                                                        _productQuantityCounters[
                                                                product.name] =
                                                            current + 1;
                                                      }
                                                    });
                                                  },
                                                  padding: EdgeInsets.all(4),
                                                  constraints: BoxConstraints(),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          // Buy and Sell buttons
                                          Row(
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  int qty =
                                                      _productQuantityCounters[
                                                              product.name] ??
                                                          1;
                                                  _buyProduct(product, qty);
                                                  setState(() {
                                                    _productQuantityCounters[
                                                            product.name] =
                                                        1; // Reset to 1
                                                  });
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                                  elevation: 3,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                        Icons.add_shopping_cart,
                                                        size: 16),
                                                    SizedBox(width: 4),
                                                    Text('किनियो',
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed: product.quantity > 0
                                                    ? () {
                                                        int qty =
                                                            _productQuantityCounters[
                                                                    product
                                                                        .name] ??
                                                                1;
                                                        _sellProduct(
                                                            product, qty);
                                                        setState(() {
                                                          _productQuantityCounters[
                                                                  product
                                                                      .name] =
                                                              1; // Reset to 1
                                                        });
                                                      }
                                                    : null,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                                  elevation: 3,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.sell, size: 16),
                                                    SizedBox(width: 4),
                                                    Text('बेचियो',
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Voice search button (bottom left)
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: 72,
                height: 72,
                child: FloatingActionButton(
                  heroTag: 'voiceFab',
                  backgroundColor: _isListening ? Colors.red : Colors.blueGrey,
                  onPressed: _listenVoice,
                  child: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: Colors.white,
                    size: 40, // bigger icon
                  ),
                  tooltip: "आवाज खोज",
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(),
        backgroundColor: Color(0xFF1E88E5),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('नयाँ उत्पादन थप्नुहोस्',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 8,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar:
          _buildBottomNavbar(), // <-- Add cool bottom navbar here
    );
  }

  void _showAnalytics() {
    final totalProducts = _products.length;
    final totalStock =
        _products.fold(0, (sum, product) => sum + product.quantity);
    final totalValue = _products.fold(
        0.0, (sum, product) => sum + (product.quantity * product.price));
    final lowStockItems =
        _products.where((product) => product.quantity <= 2).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text('पसल विश्लेषण', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnalyticsRow('कुल उत्पादन:', totalProducts.toString()),
            _buildAnalyticsRow('कुल स्टक:', totalStock.toString()),
            _buildAnalyticsRow(
                'स्टक मूल्य:', 'रू ${totalValue.toStringAsFixed(0)}'),
            _buildAnalyticsRow('कम स्टक चेतावनी:', lowStockItems.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('बन्द गर्नुहोस्'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final unitController = TextEditingController();
    String selectedCategory = _categories[1]; // Default to first real category

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('नयाँ उत्पादन थप्नुहोस्'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'उत्पादन नाम'),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(labelText: 'कोटि'),
                  items: _categories
                      .where((cat) => cat != 'सबै')
                      .map((cat) =>
                          DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedCategory = value!),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'मूल्य (रू)'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: unitController,
                  decoration:
                      InputDecoration(labelText: 'इकाई (केजी, वटा, लिटर)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('रद्द गर्नुहोस्'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty &&
                    unitController.text.isNotEmpty) {
                  final newProduct = Product(
                    name: nameController.text,
                    category: selectedCategory,
                    price: double.parse(priceController.text),
                    unit: unitController.text,
                    quantity: _rand(),
                  );
                  setState(() {
                    _products.add(newProduct);
                    _filterProducts();
                  });
                  Navigator.pop(context);
                  _showSnackBar('उत्पादन सफलतापूर्वक थपियो!', Colors.green);
                }
              },
              child: Text('थप्नुहोस्'),
            ),
          ],
        ),
      ),
    );
  }
}
