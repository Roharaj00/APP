import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../widgets/qr_scanner_widget.dart';
import 'webview_screen.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _name;
  String? _email;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _qrResult = '';
  String _apiResponse = '';
  bool _isLoading = false;

  // To manage the email validation error
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    final data = await LocalStorageService.getUserPreferences();
    setState(() {
      _name = data['name'];
      _email = data['email'];
      _nameController.text = _name ?? '';
      _emailController.text = _email ?? '';
    });
  }

  Future<void> _saveUserPreferences() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and email cannot be empty!')),
      );
      return;
    }

    if (!_isValidEmail(_emailController.text)) {
      setState(() {
        _emailError = 'Please enter a valid email.';
      });
      return;
    } else {
      setState(() {
        _emailError = null;
      });
    }

    await LocalStorageService.saveUserPreferences(
      name: _nameController.text,
      email: _emailController.text,
    );
    _loadUserPreferences();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences saved successfully!')),
    );
  }

  // Email validation function
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegExp.hasMatch(email);
  }

  Future<void> _handleQrCodeResult(String result) async {
    setState(() {
      _qrResult = result;
      _isLoading = true;
    });
    try {
      final response = await ApiService.sendMockApiRequest(result);
      setState(() {
        _apiResponse = response;
        _isLoading = false;
      });
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(htmlContent: _apiResponse),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sample App')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('QR Code Scanner:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            QrScannerWidget(onQrResult: _handleQrCodeResult),
            if (_qrResult.isNotEmpty) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'QR Result: $_qrResult',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            if (_isLoading) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],
            const Text('User Preferences:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Enter Email',
                        border: const OutlineInputBorder(),
                        errorText: _emailError,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _saveUserPreferences,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Preferences'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
