import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../theme.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adherence =
        ref.read(medicationsProvider.notifier).adherenceProgress();
    final adherencePercent = (adherence * 100).round();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('My Progress',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2DBE74), Color(0xFF6EE7B7)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {},
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
                    _DiseaseProgressSection(adherencePercent: adherencePercent),
                    const SizedBox(height: 24),
                    _WeeklyAdherenceSection(),
                    const SizedBox(height: 24),
                    _HealthImprovementsSection(),
                    const SizedBox(height: 24),
                    _SuccessStoriesSection(),
                    const SizedBox(height: 24),
                    _CommunityStoriesSection(),
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

// Disease Progress Section
class _DiseaseProgressSection extends StatelessWidget {
  final int adherencePercent;
  const _DiseaseProgressSection({required this.adherencePercent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.favorite, color: Color(0xFF2DBE74), size: 20),
            SizedBox(width: 8),
            Text('Your Disease Progress',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ProgressCard(
                icon: Icons.track_changes,
                iconColor: const Color(0xFF2DBE74),
                backgroundColor: const Color(0xFFE8F5E8),
                number: '$adherencePercent%',
                label: 'Medications Taken',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ProgressCard(
                icon: Icons.calendar_today,
                iconColor: const Color(0xFF2196F3),
                backgroundColor: const Color(0xFFE3F2FD),
                number: '12',
                label: 'Days Streak',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ProgressCard(
                icon: Icons.emoji_events,
                iconColor: const Color(0xFF9C27B0),
                backgroundColor: const Color(0xFFF3E5F5),
                number: '44',
                label: 'To Next Milestone',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String number;
  final String label;

  const _ProgressCard({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(number,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// Weekly Adherence Section
class _WeeklyAdherenceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text('Weekly Adherence',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87)),
            Spacer(),
            Row(
              children: [
                Icon(Icons.trending_up, color: Color(0xFF2DBE74), size: 16),
                SizedBox(width: 4),
                Text('+8% this week',
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
              SizedBox(
                height: 120,
                child: CustomPaint(
                  painter: _WeeklyChartPainter(),
                  size: const Size(double.infinity, 120),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Text('Tue',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('Wed',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('Thu',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('Fri',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('Sat',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('Sun',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2DBE74)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = const Color(0xFF2DBE74)
      ..style = PaintingStyle.fill;

    // Weekly data points (matching the design)
    final points = [0.3, 0.2, 0.6, 0.5, 0.8, 0.9];
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

    // Add "Great Progress!" label near the peak
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Great Progress!',
        style: TextStyle(
          color: Color(0xFF2DBE74),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.7, size.height * 0.2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Health Improvements Section
class _HealthImprovementsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Health Improvements',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87)),
        const SizedBox(height: 16),
        Container(
          decoration: roundedCardDecoration(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: const [
              _HealthMetricItem(title: 'Sleep Quality', isActive: false),
              _HealthMetricItem(title: 'Energy Level', isActive: false),
              _HealthMetricItem(title: 'Blood Pressure', isActive: false),
              _HealthMetricItem(title: 'Blood Sugar', isActive: false),
            ],
          ),
        ),
      ],
    );
  }
}

class _HealthMetricItem extends StatelessWidget {
  final String title;
  final bool isActive;

  const _HealthMetricItem({required this.title, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isActive ? const Color(0xFF2DBE74) : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(title,
              style: TextStyle(
                color: isActive ? Colors.black87 : Colors.grey,
                fontSize: 16,
              )),
        ],
      ),
    );
  }
}

// Success Stories Section
class _SuccessStoriesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Success Stories',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87)),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _SuccessStoryCard(
                name: 'Maria, 34',
                condition: 'Diabetes',
                quote: 'From 9.1 to 6.2 HbA1c in 4 months',
                emoji: '🍺',
              ),
              const SizedBox(width: 12),
              _SuccessStoryCard(
                name: 'John, 28',
                condition: 'Hypertension',
                quote: 'Reduced BP from 160/100 to 120/80',
                emoji: '😊',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SuccessStoryCard extends StatelessWidget {
  final String name;
  final String condition;
  final String quote;
  final String emoji;

  const _SuccessStoryCard({
    required this.name,
    required this.condition,
    required this.quote,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0E6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    Text(condition,
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(quote,
              style: const TextStyle(color: Colors.black87, fontSize: 14)),
        ],
      ),
    );
  }
}

// Community Stories Section
class _CommunityStoriesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Community Stories',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87)),
        const SizedBox(height: 8),
        Row(
          children: const [
            Text('You\'re not alone in your journey',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            SizedBox(width: 4),
            Text('💙', style: TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: roundedCardDecoration(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFFFD54F),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Sarah M.',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('Diabetes',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.black54)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('2 hours ago',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Just hit 3 months of consistent medication! My HbA1c dropped from 8.2 to 6.8. Small steps, big changes! 👍',
                style: TextStyle(color: Colors.black87, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showCommentsDialog(context),
                    child: Row(
                      children: const [
                        Icon(Icons.chat_bubble_outline,
                            color: Colors.grey, size: 16),
                        SizedBox(width: 4),
                        Text('24',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _showEncourageDialog(context),
                    child: Row(
                      children: const [
                        Icon(Icons.favorite_border,
                            color: Colors.grey, size: 16),
                        SizedBox(width: 4),
                        Text('Encourage',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _showShareDialog(context),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Share',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2DBE74),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _showCommentsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comments'),
        content: const Text(
            'This would show all comments on Sarah\'s post. For demo purposes, this shows the comments feature.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEncourageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Encourage'),
        content: const Text(
            'You\'ve sent encouragement to Sarah! Keep supporting the community.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Your Story'),
        content: const Text(
            'This would open a form to share your own success story with the community.'),
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
                      Text('Your story has been shared with the community!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }
}
