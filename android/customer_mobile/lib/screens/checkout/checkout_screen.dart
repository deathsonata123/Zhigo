import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Simple Checkout Screen - Multi-step frictionless flow
/// Steps: 1) Order Summary, 2) Delivery Address, 3) Payment
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  final int _maxSteps = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
        ),
        title: Text(
          'Checkout',
          style: AppTextStyles.bodyEmphasized.copyWith(
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),
          
          // Step Content
          Expanded(
            child: _buildStepContent(),
          ),
          
          // Action Button
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenMarginHorizontal),
      color: AppColors.surface,
      child: Row(
        children: [
          for (int i = 0; i < _maxSteps; i++) ...[
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i <= _currentStep ? AppColors.accent : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (i < _maxSteps - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildOrderSummary();
      case 1:
        return _buildDeliveryAddress();
      case 2:
        return _buildPayment();
      default:
        return const SizedBox();
    }
  }

  Widget _buildOrderSummary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenMarginHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Sample cart items
          _buildCartItem('Beef Burger', 1, 12.99),
          _buildCartItem('Spring Rolls', 2, 5.99),
          
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          
          // Price Breakdown
          _buildPriceRow('Subtotal', 24.97),
          _buildPriceRow('Delivery Fee', 2.99),
          _buildPriceRow('Tax', 2.52),
          const SizedBox(height: AppSpacing.xs),
          const Divider(),
          const SizedBox(height: AppSpacing.xs),
          _buildPriceRow('Total', 30.48, isBold: true),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenMarginHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Address',
            style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          
          TextField(
            decoration: const InputDecoration(
              labelText: 'Street Address',
              hintText: '123 Main St',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          
          TextField(
            decoration: const InputDecoration(
              labelText: 'City',
              hintText: 'Dhaka',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          
          TextField(
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '+880 1234567890',
            ),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildPayment() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenMarginHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          
          _buildPaymentOption('Cash on Delivery', Icons.attach_money),
          const SizedBox(height: AppSpacing.sm),
          _buildPaymentOption('Credit/Debit Card', Icons.credit_card),
          const SizedBox(height: AppSpacing.sm),
          _buildPaymentOption('Mobile Banking', Icons.phone_android),
        ],
      ),
    );
  }

  Widget _buildCartItem(String name, int quantity, double price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.baseOffWhite,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fastfood, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyEmphasized),
                Text('Qty: $quantity', style: AppTextStyles.small.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            '\$${(price * quantity).toStringAsFixed(2)}',
            style: AppTextStyles.bodyEmphasized.copyWith(color: AppColors.accent),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? AppTextStyles.bodyEmphasized
                : AppTextStyles.bodyPrimary.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: isBold
                ? AppTextStyles.bodyEmphasized.copyWith(fontSize: 18)
                : AppTextStyles.bodyPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textPrimary),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextStyles.bodyPrimary),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenMarginHorizontal),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_currentStep < _maxSteps - 1) {
                setState(() {
                  _currentStep++;
                });
              } else {
                // Complete order
                _showSuccessDialog();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _currentStep < _maxSteps - 1 ? 'Continue' : 'Confirm and Pay',
              style: AppTextStyles.button.copyWith(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(AppSpacing.sectionSpacing),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Order Confirmed!',
              style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Your order has been placed successfully',
              style: AppTextStyles.bodyPrimary.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close checkout
                },
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
