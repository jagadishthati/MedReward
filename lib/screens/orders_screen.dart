import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../theme.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(rewardsPointsProvider);
    final meds = ref.watch(medicationsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('My Orders',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text('$points',
                    style: const TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PrescriptionMedicinesSection(meds: meds),
                    const SizedBox(height: 20),
                    _DiscountSection(points: points),
                    const SizedBox(height: 20),
                    _NonPrescriptionSection(),
                    const SizedBox(height: 20),
                    _OrderSummary(),
                    const SizedBox(height: 100), // Space for checkout button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _CheckoutButton(),
    );
  }
}

// Prescription Medicines Section
class _PrescriptionMedicinesSection extends StatelessWidget {
  final List meds;
  const _PrescriptionMedicinesSection({required this.meds});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Prescription Medicines',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('AI Scanned',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text('From your scanned prescription',
            style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Medicines added to cart',
                style: TextStyle(color: Colors.black87, fontSize: 14)),
            const Spacer(),
            Text('${meds.length}/${meds.length}',
                style: const TextStyle(color: Colors.black87, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 1.0,
            minHeight: 6,
            backgroundColor: Colors.grey.withOpacity(0.3),
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...meds.map((med) => _PrescriptionMedicineCard(med: med)).toList(),
      ],
    );
  }
}

class _PrescriptionMedicineCard extends StatelessWidget {
  final med;
  const _PrescriptionMedicineCard({required this.med});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: roundedCardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF2196F3),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${med.name} ${med.dosage}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 4),
                Text('₹120 per pack',
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _QuantitySelector(),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatefulWidget {
  @override
  State<_QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<_QuantitySelector> {
  int quantity = 30;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (quantity > 1) {
              setState(() => quantity--);
            }
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.remove, color: Colors.grey, size: 16),
          ),
        ),
        const SizedBox(width: 12),
        Text('$quantity',
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            setState(() => quantity++);
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.add, color: Colors.grey, size: 16),
          ),
        ),
      ],
    );
  }
}

// Discount Section
class _DiscountSection extends StatelessWidget {
  final int points;
  const _DiscountSection({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Claim your Discount',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('You can save ₹60 with your MedPoints',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              const Spacer(),
              const Text('₹60 Available',
                  style: TextStyle(color: Color(0xFF2DBE74), fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _showDiscountDialog(context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2DBE74),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Apply Discount to Order',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Max discount ₹500 per order',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  void _showDiscountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply Discount'),
        content: const Text(
            '₹60 discount will be applied to your order. This discount is available through your MedPoints.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('₹60 discount applied to your order!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

// Non-Prescription Section
class _NonPrescriptionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Add Non-Prescription Products',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87)),
        const SizedBox(height: 12),
        Container(
          decoration: roundedCardDecoration(),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search health products, supplements...',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Suggested for You',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87)),
        const SizedBox(height: 12),
        ..._getSuggestedProducts()
            .map((product) => _SuggestedProductCard(product: product))
            .toList(),
      ],
    );
  }

  List<Map<String, String>> _getSuggestedProducts() {
    return [
      {
        'name': 'Vitamin D3 Tablets',
        'price': '₹299',
        'category': 'Supplements'
      },
      {'name': 'Omega-3 Capsules', 'price': '₹450', 'category': 'Supplements'},
      {
        'name': 'Blood Pressure Monitor',
        'price': '₹1200',
        'category': 'Medical Devices'
      },
      {
        'name': 'Glucose Test Strips',
        'price': '₹180',
        'category': 'Medical Devices'
      },
    ];
  }
}

class _SuggestedProductCard extends StatelessWidget {
  final Map<String, String> product;
  const _SuggestedProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: roundedCardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name']!,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 4),
                Text('${product['price']} • ${product['category']}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _showAddToCartDialog(context, product['name']!),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToCartDialog(BuildContext context, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Cart'),
        content: Text('$productName has been added to your cart.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Order Summary
class _OrderSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Order Summary',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87)),
        const SizedBox(height: 16),
        Container(
          decoration: roundedCardDecoration(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: const [
                  Text('Subtotal',
                      style: TextStyle(color: Colors.black87, fontSize: 16)),
                  Spacer(),
                  Text('₹16500',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Text('Total',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Spacer(),
                  Text('₹16500',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Checkout Button
class _CheckoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFF2DBE74), Color(0xFF0EAD69)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showCheckoutDialog(context),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Proceed to Checkout'),
        content: const Text(
            'This would redirect to the payment and delivery setup. For demo purposes, this shows the checkout flow.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Redirecting to checkout...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
