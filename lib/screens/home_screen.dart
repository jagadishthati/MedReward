import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/app_providers.dart';
import '../theme.dart';
import '../services/ocr_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  File? _selectedImage;
  bool _isProcessing = false;
  String? _error;

  Future<void> _showUploadSheet() async {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: const [
                    Icon(Icons.receipt_long, color: Color(0xFF2DBE74)),
                    SizedBox(width: 8),
                    Text('Upload Prescription',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _pickAndProcess(ImageSource.camera);
                        },
                        icon: const Icon(Icons.photo_camera),
                        label: const Text('Take Photo'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _pickAndProcess(ImageSource.gallery);
                        },
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Choose from Gallery'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndProcess(ImageSource source) async {
    setState(() {
      _error = null;
    });

    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(source: source);
      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
        _isProcessing = true;
      });

      // Run ML Kit OCR
      String recognized = '';
      try {
        recognized = await OcrService.recognizeText(_selectedImage!);
      } catch (e) {
        _error = 'Failed to recognize text. Please try again.';
      }

      // Update recognized text in provider
      ref.read(recognizedTextProvider.notifier).state = recognized;

      // Parse meds from text (basic)
      final parsed = OcrService.parseMedsFromText(recognized);
      ref.read(medicationsProvider.notifier).setFromParsed(parsed);
    } catch (e) {
      // Likely permission denied or picker error
      setState(() {
        _error = 'Unable to access camera/gallery. Check permissions.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final meds = ref.watch(medicationsProvider);
    final progress = ref.read(medicationsProvider.notifier).adherenceProgress();
    final points = ref.watch(rewardsPointsProvider);
    final recognizedText = ref.watch(recognizedTextProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.location_on_outlined, size: 18),
            SizedBox(width: 6),
            Text('Mumbai', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.notifications_outlined)),
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.shopping_bag_outlined)),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileSummaryCard(),
                    const SizedBox(height: 12),
                    const _SearchField(),
                    const SizedBox(height: 12),
                    _UploadCard(
                      image: _selectedImage,
                      isProcessing: _isProcessing,
                      onUpload: _showUploadSheet,
                      error: _error,
                    ),
                    const SizedBox(height: 16),
                    const Text('Your Medications',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 8),
                    if (meds.isNotEmpty)
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: meds.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => _MedCard(index: index),
                      )
                    else
                      Container(
                        decoration: roundedCardDecoration(),
                        padding: const EdgeInsets.all(16),
                        child: const Text(
                            'No medications yet. Upload a prescription to get started.'),
                      ),
                    const SizedBox(height: 16),
                    _AiInteractionCheckerCard(),
                    const SizedBox(height: 16),
                    _AdherenceProgress(progress: progress),
                    const SizedBox(height: 16),
                    _RewardsGradientCard(points: points),
                    if (_selectedImage != null &&
                        recognizedText.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _RecognizedTextCard(text: recognizedText),
                    ],
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

// Small profile summary card like the design (name + conditions)
class _ProfileSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: roundedCardDecoration(),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: const [
          CircleAvatar(radius: 18, child: Icon(Icons.person)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Neeraj Kumar',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 2),
                Text('♡ Type 2 Diabetes, Hypertension',
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Search field placeholder
class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: roundedCardDecoration(),
      child: const TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search for medicines',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}

// Upload prescription section with camera/gallery and loading state
class _UploadCard extends StatelessWidget {
  final File? image;
  final bool isProcessing;
  final String? error;
  final VoidCallback onUpload;
  const _UploadCard(
      {required this.image,
      required this.isProcessing,
      required this.onUpload,
      this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: roundedCardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0x332DBE74),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.camera_alt, color: Color(0xFF2DBE74)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Add a Prescription',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              FilledButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Prescription'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Upload to view your medicines automatically',
              style: TextStyle(fontSize: 12, color: Colors.black54)),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(error!,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
          if (image != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.file(image!,
                      height: 140, width: double.infinity, fit: BoxFit.cover),
                  if (isProcessing)
                    Container(
                      height: 140,
                      width: double.infinity,
                      color: Colors.black.withOpacity(0.35),
                      child: const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF2DBE74)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isProcessing
                  ? 'AI is scanning your prescription...'
                  : 'Scan complete',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ]
        ],
      ),
    );
  }
}

class _RecognizedTextCard extends StatelessWidget {
  final String text;
  const _RecognizedTextCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: roundedCardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.text_snippet, color: Color(0xFF2DBE74)),
              SizedBox(width: 8),
              Text('Recognized Text',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}

// Per-medication card styled like the design
class _MedCard extends ConsumerWidget {
  final int index;
  const _MedCard({required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meds = ref.watch(medicationsProvider);
    final m = meds[index];
    final pct = m.taken ? 1.0 : 0.0; // placeholder adherence per med

    return Container(
      decoration: roundedCardDecoration(),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${m.name} ${m.dosage}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.access_time,
                            size: 14, color: Colors.black54),
                        SizedBox(width: 6),
                        Text('1 tablet after meal',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: m.taken,
                onChanged: (v) => ref
                    .read(medicationsProvider.notifier)
                    .toggleTaken(m.id, v ?? false),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Daily adherence',
              style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: const Color(0x142DBE74),
              color: const Color(0xFF2DBE74),
            ),
          ),
        ],
      ),
    );
  }
}

// AI Interaction Checker card
class _AiInteractionCheckerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: roundedCardDecoration().copyWith(
        color: const Color(0xFFEFFAF3),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: const [
          CircleAvatar(
              backgroundColor: Color(0x332DBE74),
              child: Icon(Icons.shield_outlined, color: Color(0xFF2DBE74))),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Interaction Checker',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                SizedBox(height: 2),
                Text('• No Interactions Found',
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.w600)),
                SizedBox(height: 2),
                Text('Your medications are safe to take together',
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Overall adherence progress bar (kept from earlier)
class _AdherenceProgress extends StatelessWidget {
  final double progress;
  const _AdherenceProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return Container(
      decoration: roundedCardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: Color(0xFF2DBE74)),
              const SizedBox(width: 8),
              const Text('Today\'s adherence',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('$pct%'),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 10,
              backgroundColor: const Color(0x142DBE74),
              color: const Color(0xFF2DBE74),
            ),
          ),
        ],
      ),
    );
  }
}

// Rewards gradient card
class _RewardsGradientCard extends StatelessWidget {
  final int points;
  const _RewardsGradientCard({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF6EE7B7), Color(0xFF2DBE74)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.star, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("You've earned $points MedPoints",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                const Text('Next milestone 200 points',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const LinearProgressIndicator(
                    value: 0.6,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.white)),
        ],
      ),
    );
  }
}
