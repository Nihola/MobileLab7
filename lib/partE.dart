import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(CurrencyApp());
}

class CurrencyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Rates (CBU.uz)',
      home: CurrencyPage(),
    );
  }
}

class CurrencyPage extends StatefulWidget {
  @override
  _CurrencyPageState createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  final TextEditingController _dateController = TextEditingController();

  final List<String> _currencyOptions = [
    'ALL',
    'USD',
    'EUR',
    'RUB',
    'GBP',
    'JPY',
    'CNY',
    'KZT',
  ];

  String? _selectedCurrency = 'ALL';

  List<dynamic> _rates = [];
  bool _isLoading = false;
  String _error = '';

  Future<void> fetchRates() async {
    final date = _dateController.text.trim();
    final code = _selectedCurrency?.toUpperCase() ?? 'ALL';

    if (date.isEmpty) {
      setState(() {
        _error = 'Please enter a valid date.';
        _rates = [];
      });
      return;
    }

    String endpoint;

    if (code == 'ALL') {
      endpoint = 'https://cbu.uz/ru/arkhiv-kursov-valyut/json/all/$date/';
    } else {
      endpoint = 'https://cbu.uz/ru/arkhiv-kursov-valyut/json/$code/$date/';
    }

    setState(() {
      _isLoading = true;
      _error = '';
      _rates = [];
    });

    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _rates = data is List ? data : [data];
        });
      } else {
        setState(() {
          _error = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch data. Please check your internet and inputs.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Rates (UZS)'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Enter date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: InputDecoration(
                labelText: 'Select Currency Code',
                border: OutlineInputBorder(),
              ),
              items: _currencyOptions.map((code) {
                return DropdownMenuItem<String>(
                  value: code,
                  child: Text(code),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchRates,
              child: Text('Fetch Rates'),
            ),
            SizedBox(height: 16),
            if (_isLoading) CircularProgressIndicator(),
            if (_error.isNotEmpty)
              Text(
                _error,
                style: TextStyle(color: Colors.red),
              ),
            if (_rates.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _rates.length,
                  itemBuilder: (context, index) {
                    final item = _rates[index];
                    return Card(
                      child: ListTile(
                        title: Text('${item['CcyNm_EN']} (${item['Ccy']})'),
                        subtitle: Text('Rate: ${item['Rate']} UZS'),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
