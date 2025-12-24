import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Partner Onboarding - 4 Step Wizard
/// Matches web version: Business → Tax → Banking → Pricing
class PartnerOnboardingScreen extends StatefulWidget {
  const PartnerOnboardingScreen({super.key});

  @override
  State<PartnerOnboardingScreen> createState() => _PartnerOnboardingScreenState();
}

class _PartnerOnboardingScreenState extends State<PartnerOnboardingScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;
  bool _submissionSuccess = false;
  
  // Form data
  final _formKey = GlobalKey<FormState>();
  Uint8List? _photoBytes; // For web compatibility
  String? _photoName;
  String _businessName = '';
  String _businessType = 'Restaurant';
  String _phone = '';
  String _email = '';
  String _hasBinVat = 'no';
  String _binVatNumber = '';
  String _displayPriceWithVat = 'yes';
  String _accountHolderName = '';
  String _accountType = 'bank';
  String _accountNumber = '';
  String _bankName = '';
  String _branchName = '';
  String _routingNumber = '';
  String _address = '';
  String _city = '';
  String _postalCode = '';
  String _pricingPlan = 'basic';

  final List<String> _businessTypes = [
    'Restaurant', 'Cloud Kitchen', 'Cafe', 'Bakery', 'Sweet Shop',
    'Fast Food', ' Fine Dining', 'Food Truck'
  ];

  double get _progress => ((_currentStep + 1) / 4) * 100;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _photoBytes = bytes;
        _photoName = pickedFile.name;
      });
    }
  }

  bool _validateStep() {
    switch (_currentStep) {
      case 0:
        // Photo is optional for testing - only require business info
        return _businessName.isNotEmpty &&
            _phone.length >= 11 &&
            _email.contains('@');
      case 1:
        if (_hasBinVat == 'yes') {
          return _binVatNumber.isNotEmpty;
        }
        return true;
      case 2:
        if (_accountType == 'bank') {
          return _accountHolderName.isNotEmpty &&
              _accountNumber.isNotEmpty &&
              _bankName.isNotEmpty;
        }
        return _accountHolderName.isNotEmpty && _accountNumber.isNotEmpty;
      case 3:
        return _address.isNotEmpty && _city.isNotEmpty && _postalCode.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _submitForm() async {
    if (!_validateStep()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Create restaurant data
      final restaurantData = {
        'name': _businessName,
        'email': _email,
        'phone': _phone,
        'address': _address,
        'photoUrl': 'placeholder.jpg', // TODO: Upload to S3
        'ownerId': 'dummy-user-id', // TODO: Get from auth
        'status': 'pending',
        'businessType': _businessType,
        'hasBinVat': _hasBinVat,
        'binVatNumber': _binVatNumber.isEmpty ? null : _binVatNumber,
        'displayPriceWithVat': _displayPriceWithVat,
        'accountHolderName': _accountHolderName,
        'accountType': _accountType,
        'accountNumber': _accountNumber,
        'bankName': _bankName.isEmpty ? null : _bankName,
        'branchName': _branchName.isEmpty ? null : _branchName,
        'routingNumber': _routingNumber.isEmpty ? null : _routingNumber,
        'city': _city,
        'postalCode': _postalCode,
        'pricingPlan': _pricingPlan,
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/restaurants'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(restaurantData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() => _submissionSuccess = true);
      } else {
        throw Exception('Failed to submit');
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
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenMarginHorizontal),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Application Submitted!', style: AppTextStyles.h1),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Thank you for partnering with Zhigo.',
                      style: AppTextStyles.bodyPrimary.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.pending, color: Colors.amber),
                              const SizedBox(width: 8),
                              Text('Waiting for Review', style: AppTextStyles.bodyEmphasized),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your application for $_businessName has been submitted successfully! We will review it and let you know within a few days.',
                            style: AppTextStyles.small,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                            ),
                            child: const Text('Go to Home', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Become a Partner'),
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${_currentStep + 1} of 4',
                      style: AppTextStyles.bodyEmphasized.copyWith(color: AppColors.accent),
                    ),
                    Text(
                      '${_progress.round()}%',
                      style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _progress / 100,
                  backgroundColor: AppColors.baseOffWhite,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildProgressIcon(Icons.store, 'Business', 0),
                    _buildProgressIcon(Icons.description, 'Tax', 1),
                    _buildProgressIcon(Icons.account_balance, 'Banking', 2),
                    _buildProgressIcon(Icons.payment, 'Pricing', 3),
                  ],
                ),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.screenMarginHorizontal),
                children: [
                  if (_currentStep == 0) _buildStep1(),
                  if (_currentStep == 1) _buildStep2(),
                  if (_currentStep == 2) _buildStep3(),
                  if (_currentStep == 3) _buildStep4(),
                ],
              ),
            ),
          ),

          // Navigation Buttons
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            if (_currentStep < 3) {
                              if (_validateStep()) {
                                setState(() => _currentStep++);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please fill all required fields')),
                                );
                              }
                            } else {
                              _submitForm();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            _currentStep < 3 ? 'Next' : 'Submit Application',
                            style: const TextStyle(color: Colors.white),
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

  Widget _buildProgressIcon(IconData icon, String label, int step) {
    final isActive = step <= _currentStep;
    return Column(
      children: [
        Icon(
          icon,
          color: isActive ? AppColors.accent : AppColors.textSecondary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Business Information', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Let\'s start with the basics. Tell us about your restaurant.',
          style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),

        // Photo Upload with cursor effect
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, width: 2),
                borderRadius: BorderRadius.circular(8),
                color: AppColors.baseOffWhite,
              ),
              child: _photoBytes == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload, size: 48, color: AppColors.textSecondary),
                        SizedBox(height: 8),
                        Text('Upload Restaurant Photo'),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.memory(_photoBytes!, fit: BoxFit.cover),
                    ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Business Name *',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _businessName = value,
        ),
        const SizedBox(height: AppSpacing.sm),

        DropdownButtonFormField<String>(
          value: _businessType,
          decoration: const InputDecoration(
            labelText: 'Business Type *',
            border: OutlineInputBorder(),
          ),
          items: _businessTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) => setState(() => _businessType = value!),
        ),
        const SizedBox(height: AppSpacing.sm),

        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Phone Number *',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          onChanged: (value) => _phone = value,
        ),
        const SizedBox(height: AppSpacing.sm),

        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Email *',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => _email = value,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tax & Legal Information', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Help us understand your tax registration status.',
          style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),

        Text('Do you have a BIN/VAT Certificate? *', style: AppTextStyles.bodyEmphasized),
        RadioListTile<String>(
          title: const Text('Yes, I have a BIN/VAT Certificate'),
          value: 'yes',
          groupValue: _hasBinVat,
          onChanged: (value) => setState(() => _hasBinVat = value!),
        ),
        RadioListTile<String>(
          title: const Text('No, I don\'t have one yet'),
          value: 'no',
          groupValue: _hasBinVat,
          onChanged: (value) => setState(() => _hasBinVat = value!),
        ),

        if (_hasBinVat == 'yes') ...[
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'BIN/VAT Number *',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _binVatNumber = value,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Display Prices Including VAT? *', style: AppTextStyles.bodyEmphasized),
          RadioListTile<String>(
            title: const Text('Yes, include VAT in displayed prices'),
            value: 'yes',
            groupValue: _displayPriceWithVat,
            onChanged: (value) => setState(() => _displayPriceWithVat = value!),
          ),
          RadioListTile<String>(
            title: const Text('No, add VAT at checkout'),
            value: 'no',
            groupValue: _displayPriceWithVat,
            onChanged: (value) => setState(() => _displayPriceWithVat = value!),
          ),
        ],
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Banking Information', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Where should we send your earnings?',
          style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),

        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Account Holder Name *',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _accountHolderName = value,
        ),
        const SizedBox(height: AppSpacing.sm),

        Text('Account Type *', style: AppTextStyles.bodyEmphasized),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Bank'),
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
        const SizedBox(height: AppSpacing.sm),

        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Account Number *',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _accountNumber = value,
        ),

        if (_accountType == 'bank') ...[
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Bank Name *',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _bankName = value,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Branch Name',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _branchName = value,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Routing Number',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _routingNumber = value,
          ),
        ],
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Address & Pricing', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Almost done! Just a few more details.',
          style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),

        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Address *',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          onChanged: (value) => _address = value,
        ),
        const SizedBox(height: AppSpacing.sm),

        TextFormField(
          decoration: const InputDecoration(
            labelText: 'City *',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _city = value,
        ),
        const SizedBox(height: AppSpacing.sm),

        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Postal Code *',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _postalCode = value,
        ),
        const SizedBox(height: AppSpacing.md),

        Text('Pricing Plan *', style: AppTextStyles.bodyEmphasized),
        const SizedBox(height: 8),
        RadioListTile<String>(
          title: const Text('Basic - Free'),
          subtitle: const Text('Standard features'),
          value: 'basic',
          groupValue: _pricingPlan,
          onChanged: (value) => setState(() => _pricingPlan = value!),
        ),
        RadioListTile<String>(
          title: const Text('Growth Plus - \$49/month'),
          subtitle: const Text('Advanced analytics + priority support'),
          value: 'growth-plus',
          groupValue: _pricingPlan,
          onChanged: (value) => setState(() => _pricingPlan = value!),
        ),
        RadioListTile<String>(
          title: const Text('Growth Pro - \$99/month'),
          subtitle: const Text('All features + dedicated account manager'),
          value: 'growth-pro',
          groupValue: _pricingPlan,
          onChanged: (value) => setState(() => _pricingPlan = value!),
        ),
      ],
    );
  }
}
