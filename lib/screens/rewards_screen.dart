import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../theme.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(rewardsPointsProvider);
    final adherence =
        ref.read(medicationsProvider.notifier).adherenceProgress();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: const [
            Icon(Icons.emoji_events, color: Color(0xFF2DBE74)),
            SizedBox(width: 8),
            Text('My Rewards & Progress',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        centerTitle: false,
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
                    const Text(
                      'Stay consistent and earn more benefits!',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    _MedPointsSummaryCard(points: points, adherence: adherence),
                    const SizedBox(height: 16),
                    _ClaimDiscountCard(),
                    const SizedBox(height: 24),
                    const Text('Redeem Your Points',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18)),
                    const SizedBox(height: 12),
                    _RedeemPointsSection(),
                    const SizedBox(height: 24),
                    _DailyPointsSection(),
                    const SizedBox(height: 24),
                    _KeepGoingButton(),
                    const SizedBox(height: 24),
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

// MedPoints Summary Card with gradient
class _MedPointsSummaryCard extends StatelessWidget {
  final int points;
  final double adherence;
  const _MedPointsSummaryCard({required this.points, required this.adherence});

  @override
  Widget build(BuildContext context) {
    final adherencePercent = (adherence * 100).round();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF6EE7B7), Color(0xFF2DBE74)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$points MedPoints',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Total Reward Points Earned',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'Medication Adherence Streak',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '$adherencePercent%',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: adherence,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Icon(Icons.flag, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  "You're doing great! Just 8% away from your next reward tier",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Claim Discount Card
class _ClaimDiscountCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB74D).withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB74D).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_cart, color: Color(0xFFFF9800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'You can claim ₹60 off on your next medicine order!',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Discount auto-applied at checkout',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _showOrderDialog(context),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('Order Now',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Medicine'),
        content: const Text(
            'This would redirect to a pharmacy ordering system. For demo purposes, this shows the discount is applied.'),
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
                  content:
                      Text('₹60 discount applied! Redirecting to pharmacy...'),
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

// Redeem Points Section
class _RedeemPointsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(rewardsPointsProvider);

    return Column(
      children: [
        _RedeemCard(
          icon: Icons.shopping_cart,
          iconColor: const Color(0xFF2DBE74),
          title: 'Convert to Discount',
          subtitle: '₹50 off next order',
          points: '100 pts',
          buttonText: 'Redeem',
          canRedeem: points >= 100,
          onTap: () => _showRedeemDialog(
              context, 'Convert to Discount', '₹50 off next order', 100, ref),
        ),
        const SizedBox(height: 12),
        _RedeemCard(
          icon: Icons.card_giftcard,
          iconColor: Colors.grey,
          title: 'Health Store Voucher',
          subtitle: '₹100 voucher',
          points: '150 pts',
          buttonText: 'Redeem',
          canRedeem: points >= 150,
          onTap: () => _showRedeemDialog(
              context, 'Health Store Voucher', '₹100 voucher', 150, ref),
        ),
        const SizedBox(height: 12),
        _RedeemCard(
          icon: Icons.workspace_premium,
          iconColor: Colors.grey,
          title: 'Join Premium Tier',
          subtitle: 'Unlock exclusive benefits',
          points: '500 pts',
          buttonText: 'Redeem',
          canRedeem: points >= 500,
          onTap: () => _showRedeemDialog(context, 'Join Premium Tier',
              'Unlock exclusive benefits', 500, ref),
        ),
      ],
    );
  }

  void _showRedeemDialog(BuildContext context, String title, String description,
      int cost, WidgetRef ref) {
    final points = ref.read(rewardsPointsProvider);
    if (points < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('You need ${cost - points} more points to redeem this item'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Redeem $title'),
        content: Text(
            'Are you sure you want to redeem $description for $cost points?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(rewardsPointsProvider.notifier).state -= cost;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully redeemed $description!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }
}

class _RedeemCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String points;
  final String buttonText;
  final bool canRedeem;
  final VoidCallback onTap;

  const _RedeemCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.buttonText,
    required this.canRedeem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: roundedCardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(points,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black54)),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: canRedeem ? onTap : null,
            style: FilledButton.styleFrom(
              backgroundColor: canRedeem ? iconColor : Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(buttonText, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// Daily Points Section
class _DailyPointsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text('Daily Points Earned',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.trending_up, color: Color(0xFF2DBE74), size: 16),
                SizedBox(width: 4),
                Text('+12% from last week',
                    style: TextStyle(color: Color(0xFF2DBE74), fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: roundedCardDecoration(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Simple line chart representation
              SizedBox(
                height: 120,
                child: CustomPaint(
                  painter: _LineChartPainter(),
                  size: const Size(double.infinity, 120),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Text('Tue',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                  Text('Wed',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                  Text('Thu',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                  Text('Fri',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                  Text('Sat',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                  Text('Sun',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Keep Going Button
class _KeepGoingButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showMotivationDialog(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Keep Going!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMotivationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Great Job!'),
        content: const Text(
            'You\'re doing amazing with your medication adherence! Keep up the excellent work and continue earning rewards.'),
        actions: [
          FilledButton(
            onPressed: () {
              // Add some bonus points for motivation
              ref.read(rewardsPointsProvider.notifier).state += 5;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('+5 bonus points for staying motivated! 🎉'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Thanks!'),
          ),
        ],
      ),
    );
  }
}

// Simple line chart painter
class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2DBE74)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = const Color(0xFF2DBE74)
      ..style = PaintingStyle.fill;

    // Sample data points (normalized to 0-1)
    final points = [0.3, 0.5, 0.4, 0.7, 0.8, 0.6, 0.9];
    final path = Path();

    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - (points[i] * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw points
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
