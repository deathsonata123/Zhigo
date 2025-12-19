import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../providers/auth_provider.dart';

class PartnerOnboardingScreen extends StatefulWidget {
  const PartnerOnboardingScreen({super.key});

  @override
  State<PartnerOnboardingScreen> createState() => _PartnerOnboardingScreenState();
}

class _PartnerOnboardingScreenState extends State<PartnerOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  
  int _currentStep = 0;
  final int _totalSteps = 4;
  bool _isSubmitting = false;
  bool _submissionSuccess = false;
  String _restaurantName = '';
  
  // Step 1: Business Information
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String _businessType = '';
  XFile? _photoFile;
  
  // Step 2: Tax & Legal
  String _hasBinVat = '';
  String _displayPriceWithVat = '';
  final _binVatNumberController = TextEditingController();
  
  // Step 3: Banking
  final _accountHolderController = TextEditingController();
  String _accountType = '';
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _routingNumberController = TextEditingController();
  
  // Step 4: Address & Pricing
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  String _pricingPlan = '';

  final List<String> _businessTypes = [
    "Restaurant",
    "Cloud Kitchen",
    "Cafe",
    "Bakery",
    "Sweet Shop",
    "Fast Food",
    "Fine Dining",
    "Food Truck"
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _binVatNumberController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
    _routingNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() => _photoFile = image);
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _nameController.text.length >= 2 &&
            _businessType.isNotEmpty &&
            _phoneController.text.length >= 11 &&
            _emailController.text.contains('@') &&
            _photoFile != null;
      case 1:
        if (_hasBinVat.isEmpty) return false;
        if (_hasBinVat == 'yes') {
          return _displayPriceWithVat.isNotEmpty &&
              _binVatNumberController.text.isNotEmpty;
        }
        return true;
      case 2:
        if (_accountHolderController.text.length < 2) return false;
        if (_accountType.isEmpty) return false;
        if (_accountNumberController.text.length < 5) return false;
        if (_accountType == 'bank') {
          return _bankNameController.text.isNotEmpty &&
              _branchNameController.text.isNotEmpty &&
              _routingNumberController.text.isNotEmpty;
        }
        return true;
      case 3:
        return _addressController.text.length >= 10 &&
            _cityController.text.length >= 2 &&
            _postalCodeController.text.length >= 4 &&
            _pricingPlan.isNotEmpty;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < _totalSteps - 1) {
        setState(() => _currentStep++);
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitApplication() async {
    if (!_validateCurrentStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Upload photo first
      String? photoUrl;
      if (_photoFile != null) {
        // For web, you'll need to implement S3 upload via backend
        // For now, we'll send photo as base64 or use backend upload endpoint
        final bytes = await _photoFile!.readAsBytes();
        final base64Image = base64Encode(bytes);
        
        // Call backend to upload to S3
        final uploadResponse = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/storage/upload'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'file': base64Image,
            'fileName': _photoFile!.name,
            'contentType': 'image/jpeg',
            'path': 'restaurant-photos',
          }),
        );

        if (uploadResponse.statusCode == 200) {
          final uploadData = json.decode(uploadResponse.body);
          photoUrl = uploadData['url'];
        }
      }

      // Submit restaurant application
      final restaurantData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'photoUrl': photoUrl,
        'ownerId': authProvider.user?.id,
        'status': 'pending',
        'businessType': _businessType,
        'hasBinVat': _hasBinVat,
        'binVatNumber': _hasBinVat == 'yes' ? _binVatNumberController.text : null,
        'displayPriceWithVat': _hasBinVat == 'yes' ? _displayPriceWithVat : null,
        'accountHolderName': _accountHolderController.text,
        'accountType': _accountType,
        'accountNumber': _accountNumberController.text,
        'bankName': _accountType == 'bank' ? _bankNameController.text : null,
        'branchName': _accountType == 'bank' ? _branchNameController.text : null,
        'routingNumber': _accountType == 'bank' ? _routingNumberController.text : null,
        'city': _cityController.text,
        'postalCode': _postalCodeController.text,
        'pricingPlan': _pricingPlan,
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/restaurants'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(restaurantData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _restaurantName = _nameController.text;
          _submissionSuccess = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully!')),
        );
      } else {
        throw Exception('Failed to submit application');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submissionSuccess) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Partner'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildStep1BusinessInfo(),
                _buildStep2TaxInfo(),
                _buildStep3Banking(),
                _buildStep4AddressPricing(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = (_currentStep + 1) / _totalSteps;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentStep + 1} of $_totalSteps',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            minHeight: 8,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStepIcon(0, Icons.store, 'Business'),
              _buildStepIcon(1, Icons.description, 'Tax Info'),
              _buildStepIcon(2, Icons.credit_card, 'Banking'),
              _buildStepIcon(3, Icons.trending_up, 'Pricing'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIcon(int step, IconData icon, String label) {
    final isActive = _currentStep >= step;
    
    return Column(
      children: [
        Icon(
          icon,
          color: isActive ? Colors.blue : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.blue : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStep1BusinessInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Let\'s start with the basics. Tell us about your restaurant.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          // Photo Upload
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _photoFile == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Click to upload restaurant photo'),
                        Text('PNG, JPG up to 10MB', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    )
                  : kIsWeb
                      ? Image.network(_photoFile!.path, fit: BoxFit.cover)
                      : Image.file(File(_photoFile!.path), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Business Name *',
              hintText: 'e.g., The Golden Spoon Restaurant',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _businessType.isEmpty ? null : _businessType,
            decoration: const InputDecoration(
              labelText: 'Business Type *',
              border: OutlineInputBorder(),
            ),
            items: _businessTypes.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) => setState(() => _businessType = value!),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Business Phone Number *',
              hintText: '01712345678',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Business Email *',
              hintText: 'contact@restaurant.com',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2TaxInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tax & Legal Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Help us understand your tax registration status.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          const Text('Do you have a BIN/VAT Certificate? *'),
          const SizedBox(height: 8),
          
          RadioListTile<String>(
            title: const Text('Yes, I have a BIN/VAT Certificate'),
            subtitle: const Text('Verified businesses get priority placement'),
            value: 'yes',
            groupValue: _hasBinVat,
            onChanged: (value) => setState(() => _hasBinVat = value!),
          ),
          RadioListTile<String>(
            title: const Text('No, I don\'t have one yet'),
            subtitle: const Text('You can still partner with us'),
            value: 'no',
            groupValue: _hasBinVat,
            onChanged: (value) => setState(() => _hasBinVat = value!),
          ),
          
          if (_hasBinVat == 'yes') ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _binVatNumberController,
              decoration: const InputDecoration(
                labelText: 'BIN/VAT Certificate Number *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Display Prices Including VAT? *'),
            const SizedBox(height: 8),
            RadioListTile<String>(
              title: const Text('Yes, include VAT in displayed prices'),
              subtitle: const Text('Customers see final price'),
              value: 'yes',
              groupValue: _displayPriceWithVat,
              onChanged: (value) => setState(() => _displayPriceWithVat = value!),
            ),
            RadioListTile<String>(
              title: const Text('No, add VAT at checkout'),
              subtitle: const Text('VAT calculated separately'),
              value: 'no',
              groupValue: _displayPriceWithVat,
              onChanged: (value) => setState(() => _displayPriceWithVat = value!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep3Banking() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Banking Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Where should we send your earnings?',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          TextFormField(
            controller: _accountHolderController,
            decoration: const InputDecoration(
              labelText: 'Account Holder Name *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          const Text('Account Type *'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Bank Account'),
                selected: _accountType == 'bank',
                onSelected: (selected) => setState(() => _accountType = 'bank'),
              ),
              ChoiceChip(
                label: const Text('bKash'),
                selected: _accountType == 'bkash',
                onSelected: (selected) => setState(() => _accountType = 'bkash'),
              ),
              ChoiceChip(
                label: const Text('Nagad'),
                selected: _accountType == 'nagad',
                onSelected: (selected) => setState(() => _accountType = 'nagad'),
              ),
              ChoiceChip(
                label: const Text('Rocket'),
                selected: _accountType == 'rocket',
                onSelected: (selected) => setState(() => _accountType = 'rocket'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _accountNumberController,
            decoration: const InputDecoration(
              labelText: 'Account Number *',
              border: OutlineInputBorder(),
            ),
          ),
          
          if (_accountType == 'bank') ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _bankNameController,
              decoration: const InputDecoration(
                labelText: 'Bank Name *',
                hintText: 'e.g., Dutch Bangla Bank',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _branchNameController,
              decoration: const InputDecoration(
                labelText: 'Branch Name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _routingNumberController,
              decoration: const InputDecoration(
                labelText: 'Routing Number *',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep4AddressPricing() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Address & Pricing Plan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Final step! Choose your plan and provide your address.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Complete Address *',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'City *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _postalCodeController,
            decoration: const InputDecoration(
              labelText: 'Postal Code *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Select Pricing Plan *',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildPricingCard(
            'Basic',
            '15% Commission',
            ['Standard listing', 'Basic support', 'Weekly payouts'],
            'basic',
          ),
          const SizedBox(height: 12),
          _buildPricingCard(
            'Growth Plus',
            '12% Commission',
            ['Priority listing', 'Priority support', 'Same-day payouts', 'Marketing tools'],
            'growth-plus',
          ),
          const SizedBox(height: 12),
          _buildPricingCard(
            'Growth Pro',
            '10% Commission',
            ['Top placement', '24/7 dedicated support', 'Instant payouts', 'Advanced analytics', 'Custom branding'],
            'growth-pro',
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(String title, String commission, List<String> features, String value) {
    final isSelected = _pricingPlan == value;
    
    return GestureDetector(
      onTap: () => setState(() => _pricingPlan = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.blue.withOpacity(0.1) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Colors.blue),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              commission,
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            const SizedBox(height: 12),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(feature),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : _currentStep == _totalSteps - 1
                      ? _submitApplication
                      : _nextStep,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_currentStep == _totalSteps - 1 ? 'Submit Application' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 24),
              const Text(
                'Application Submitted Successfully!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Thank you for partnering with Zhigo, $_restaurantName!',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.access_time, color: Colors.amber),
                    SizedBox(height: 8),
                    Text(
                      'Pending Admin Approval',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'We\'ll notify you via email within 1-2 business days.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
