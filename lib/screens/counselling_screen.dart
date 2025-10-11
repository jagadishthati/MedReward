import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../theme.dart';

class CounsellingScreen extends ConsumerWidget {
  const CounsellingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meds = ref.watch(medicationsProvider);
    final adherence =
        ref.read(medicationsProvider.notifier).adherenceProgress();
    final adherencePercent = (adherence * 100).round();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Counselling',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black87),
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
                    _UserProfileSection(
                        meds: meds, adherencePercent: adherencePercent),
                    const SizedBox(height: 24),
                    _AiCounsellingVideosSection(),
                    const SizedBox(height: 24),
                    _AskQueriesSection(),
                    const SizedBox(height: 24),
                    _ScheduleVirtualCounsellingSection(),
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

// User Profile Section
class _UserProfileSection extends StatelessWidget {
  final List meds;
  final int adherencePercent;
  const _UserProfileSection(
      {required this.meds, required this.adherencePercent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Info Card
        Container(
          decoration: roundedCardDecoration(),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF2DBE74),
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Priya Sharma',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87)),
                    const SizedBox(height: 4),
                    const Text('34 years • Female',
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C27B0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Type 2 Diabetes',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Health Metrics Cards
        Row(
          children: [
            Expanded(
              child: _HealthMetricCard(
                value: '$adherencePercent%',
                label: 'Adherence Score',
                color: const Color(0xFF2DBE74),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _HealthMetricCard(
                value: '${meds.length}',
                label: 'Active Medications',
                color: const Color(0xFF2196F3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Medication Adherence Progress
        Container(
          decoration: roundedCardDecoration(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Medication Adherence',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.black87)),
                  const Spacer(),
                  Text('$adherencePercent%',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: adherencePercent / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text('Last visit: 15 Dec 2024',
            style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class _HealthMetricCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _HealthMetricCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: roundedCardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// AI Counselling Videos Section
class _AiCounsellingVideosSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.psychology, color: Color(0xFF2DBE74), size: 20),
            SizedBox(width: 8),
            Text('AI Counselling Videos',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87)),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _VideoCard(
                duration: '5:30',
                category: 'Medication Guide',
                title: 'Managing Diabetes: Daily Medication Tips',
                description:
                    'Learn proper timing and dosage management for diabetes medications',
              ),
              const SizedBox(width: 12),
              _VideoCard(
                duration: '3:45',
                category: 'Lifestyle',
                title: 'Nutrition for Better Health',
                description:
                    'Discover healthy eating habits for diabetes management',
              ),
              const SizedBox(width: 12),
              _VideoCard(
                duration: '4:20',
                category: 'Exercise',
                title: 'Safe Workouts for Diabetics',
                description:
                    'Exercise routines designed for people with diabetes',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VideoCard extends StatelessWidget {
  final String duration;
  final String category;
  final String title;
  final String description;

  const _VideoCard({
    required this.duration,
    required this.category,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showVideoDialog(context, title),
      child: Container(
        width: 280,
        height: 200,
        decoration: roundedCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Thumbnail
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6EE7B7), Color(0xFF2DBE74)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.play_circle_filled,
                        color: Colors.white, size: 48),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(duration,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2DBE74).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(category,
                          style: const TextStyle(
                              color: Color(0xFF2DBE74), fontSize: 10)),
                    ),
                    const SizedBox(height: 6),
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontSize: 13)),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(description,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 11)),
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

  void _showVideoDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Play Video: $title'),
        content: const Text(
            'This would open the video player. For demo purposes, this shows the video feature.'),
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

// Ask Queries Section
class _AskQueriesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.chat_bubble_outline,
                color: Color(0xFF2DBE74), size: 20),
            const SizedBox(width: 8),
            const Text('Ask Your Queries',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2DBE74),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('PharmD Available',
                  style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: roundedCardDecoration(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Chat Messages
              _ChatMessage(
                message:
                    'Hello Priya! I\'m Dr. Sarah, your pharmacist counsellor. How can I help you today?',
                isFromUser: false,
                sender: 'PharmD',
                time: '10:30 AM',
              ),
              const SizedBox(height: 12),
              _ChatMessage(
                message:
                    'Hi Dr. Sarah! I\'ve been experiencing some dizziness after taking my morning medications. Is this normal?',
                isFromUser: true,
                sender: 'You',
                time: '10:32 AM',
              ),
              const SizedBox(height: 12),
              _ChatMessage(
                message:
                    'I understand your concern. Dizziness can be a side effect of some diabetes medications. Let me help you...',
                isFromUser: false,
                sender: 'PharmD',
                time: '10:35 AM',
              ),
              const SizedBox(height: 16),
              // Message Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type your question about medication...',
                        hintStyle:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              BorderSide(color: Colors.grey.withOpacity(0.3)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2DBE74),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child:
                          const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Message sent to PharmD! You\'ll receive a response soon.'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class _ChatMessage extends StatelessWidget {
  final String message;
  final bool isFromUser;
  final String sender;
  final String time;

  const _ChatMessage({
    required this.message,
    required this.isFromUser,
    required this.sender,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isFromUser) ...[
          const CircleAvatar(
            radius: 12,
            backgroundColor: Color(0xFF2196F3),
            child: Icon(Icons.person, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isFromUser
                  ? const Color(0xFF2DBE74)
                  : const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 4),
                Text('$sender • $time',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
          ),
        ),
        if (isFromUser) ...[
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 12,
            backgroundColor: Color(0xFF2DBE74),
            child: Icon(Icons.person, color: Colors.white, size: 16),
          ),
        ],
      ],
    );
  }
}

// Schedule Virtual Counselling Section
class _ScheduleVirtualCounsellingSection extends StatefulWidget {
  @override
  State<_ScheduleVirtualCounsellingSection> createState() =>
      _ScheduleVirtualCounsellingSectionState();
}

class _ScheduleVirtualCounsellingSectionState
    extends State<_ScheduleVirtualCounsellingSection> {
  String selectedType = 'Video Call';
  DateTime? selectedDate;
  String? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.videocam, color: Color(0xFF2DBE74), size: 20),
            SizedBox(width: 8),
            Text('Schedule Virtual Counselling',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: roundedCardDecoration(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Counselling Type Buttons
              Row(
                children: [
                  Expanded(
                    child: _CounsellingTypeButton(
                      icon: Icons.videocam,
                      label: 'Video Call',
                      color: const Color(0xFF2196F3),
                      isSelected: selectedType == 'Video Call',
                      onTap: () => setState(() => selectedType = 'Video Call'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CounsellingTypeButton(
                      icon: Icons.phone,
                      label: 'Audio Call',
                      color: const Color(0xFF2DBE74),
                      isSelected: selectedType == 'Audio Call',
                      onTap: () => setState(() => selectedType = 'Audio Call'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CounsellingTypeButton(
                      icon: Icons.chat,
                      label: 'Text Chat',
                      color: const Color(0xFF9C27B0),
                      isSelected: selectedType == 'Text Chat',
                      onTap: () => setState(() => selectedType = 'Text Chat'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Date and Time Selection
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Preferred Date',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: Colors.grey, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  selectedDate != null
                                      ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                      : 'Select date',
                                  style: TextStyle(
                                      color: selectedDate != null
                                          ? Colors.black87
                                          : Colors.grey),
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_drop_down,
                                    color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Preferred Time',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _selectTime(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time,
                                    color: Colors.grey, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  selectedTime ?? 'Select time slot',
                                  style: TextStyle(
                                      color: selectedTime != null
                                          ? Colors.black87
                                          : Colors.grey),
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_drop_down,
                                    color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Schedule Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _scheduleAppointment(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2DBE74),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Schedule Appointment',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time != null) {
      setState(() => selectedTime =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
    }
  }

  void _scheduleAppointment(BuildContext context) {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both date and time'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appointment Scheduled'),
        content: Text(
            'Your $selectedType appointment has been scheduled for ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} at $selectedTime'),
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

class _CounsellingTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CounsellingTypeButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 20),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}
