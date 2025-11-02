import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/app_providers.dart';
import '../theme.dart';
import '../services/ocr_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medreward/providers/user_provider.dart';

// JS interop for web geolocation
@JS('requestBrowserLocation')
external JSPromise _requestBrowserLocationJS();

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  File? _selectedImage;
  bool _isProcessing = false;
  String? _error;
  String city = "Detecting...";
  bool _locationError = false;

  @override
  void initState() {
    super.initState();
    _detectCity();
  }

  Future<String> _reverseGeocodeWithAPI(double lat, double lon) async {
    try {
      debugPrint('Attempting API geocoding for: $lat, $lon');

      // Using Nominatim (OpenStreetMap) - free, no API key needed
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=10&addressdetails=1');

      debugPrint('API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'MedReward-App/1.0',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('API Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('API Response data: $data');

        if (data.containsKey('address')) {
          final address = data['address'];

          // Try to get city from various fields
          String? cityName = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['municipality'] ??
              address['state_district'] ??
              address['county'] ??
              address['state'];

          debugPrint('API Geocoding result: $cityName');

          if (cityName != null && cityName.isNotEmpty) {
            return cityName;
          }
        }
      } else {
        debugPrint('API returned non-200 status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('API Geocoding failed: $e');
      debugPrint('Stack trace: $stackTrace');
    }
    return 'Your Location';
  }

  Future<void> _detectCity() async {
    try {
      // For web, request browser permission first
      if (kIsWeb) {
        try {
          final completer = Completer<void>();
          _requestBrowserLocationJS().toDart.then((_) {
            completer.complete();
          }).catchError((error) {
            completer.completeError(error);
          });

          await completer.future;
          debugPrint('Browser location permission granted');
        } catch (e) {
          debugPrint('Browser location error: $e');
          if (mounted) {
            setState(() => city = "Location Blocked");
          }
          return;
        }
      }

      // Check location service status
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        if (mounted) {
          setState(() => city = "Location Service Off");
        }
        return;
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('Current permission: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('Permission after request: $permission');
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => city = "Location Denied");
        }
        return;
      }

      // Get current position with timeout
      debugPrint('Getting position...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Location request timed out');
        },
      );

      debugPrint(
          'Position obtained: ${position.latitude}, ${position.longitude}');

      // Get place name from coordinates
      String locationName = "Your Location";

      // First try the geocoding package
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('Geocoding package timeout');
            return [];
          },
        );

        debugPrint('Placemarks received: ${placemarks.length}');

        if (placemarks.isNotEmpty) {
          final place = placemarks[0];
          // debugPrint(
          //     'Place details - Locality: ${place.locality}, SubAdmin: ${place.subAdministrativeArea}, Admin: ${place.administrativeArea}');
          debugPrint('========== PLACEMARK DETAILS ==========');
          debugPrint('Full placemark: $place');
          debugPrint('Name: ${place.name}');
          debugPrint('Street: ${place.street}');
          debugPrint('IsoCountryCode: ${place.isoCountryCode}');
          debugPrint('Country: ${place.country}');
          debugPrint('PostalCode: ${place.postalCode}');
          debugPrint('AdministrativeArea: ${place.administrativeArea}');
          debugPrint('SubAdministrativeArea: ${place.subAdministrativeArea}');
          debugPrint('Locality: ${place.locality}');
          debugPrint('SubLocality: ${place.subLocality}');
          debugPrint('Thoroughfare: ${place.thoroughfare}');
          debugPrint('SubThoroughfare: ${place.subThoroughfare}');
          debugPrint('======================================');

          // Try multiple fields to find a good city name
          locationName = place.locality ??
              place.subAdministrativeArea ??
              place.administrativeArea ??
              place.subLocality ??
              "Your Location";
        }
      } catch (e) {
        debugPrint('Geocoding package error: $e');
      }

      // If geocoding package failed, try web API as fallback
      if (locationName == "Your Location" && kIsWeb) {
        debugPrint('Trying API-based geocoding as fallback...');
        locationName = await _reverseGeocodeWithAPI(
          position.latitude,
          position.longitude,
        );
      }

      // Final fallback to coordinates
      if (locationName == "Your Location") {
        locationName =
            "${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}";
      }

      if (mounted) {
        setState(() {
          city = locationName;
        });
      }
    } on TimeoutException catch (e) {
      debugPrint('Timeout: $e');
      if (mounted) {
        setState(() => city = "Location Timeout");
      }
    } catch (e) {
      debugPrint('Location error: $e');
      if (mounted) {
        setState(() => city = "Location Unavailable");
      }
    }
  }

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

      // Parse meds from text
      final parsed = OcrService.parseMedsFromText(recognized);
      ref.read(medicationsProvider.notifier).setFromParsed(parsed);
    } catch (e) {
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
          children: [
            const Icon(Icons.location_on_outlined, size: 18),
            const SizedBox(width: 6),
            Text(city, style: const TextStyle(fontWeight: FontWeight.w600)),
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

// class _ProfileSummaryCard extends StatelessWidget {
// Add this to your _ProfileSummaryCard widget in home_screen.dart

class _ProfileSummaryCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Container(
      decoration: roundedCardDecoration(),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF2DBE74),
            child: Text(
              user?.fullName.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? 'Loading...',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  user != null
                      ? '${user.age} years old • ${user.gender}'
                      : 'Fetching user info...',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          // Optional: Add edit profile button
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: () {
              // Navigate to profile edit screen
            },
          ),
        ],
      ),
    );
  }
}

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
                label: const Text('Upload'),
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

class _MedCard extends ConsumerWidget {
  final int index;
  const _MedCard({required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meds = ref.watch(medicationsProvider);
    final m = meds[index];
    final pct = m.taken ? 1.0 : 0.0;

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
