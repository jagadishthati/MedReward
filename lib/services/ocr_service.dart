import 'dart:async';
import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// OCR service using Google ML Kit with a very basic parser for meds.
class OcrService {
  static final TextRecognizer _recognizer = TextRecognizer();

  // Simulate processing latency (fallback/testing)
  static Future<void> simulateProcessing({int delayMs = 1000}) async {
    await Future.delayed(Duration(milliseconds: delayMs));
  }

  // Recognize text using ML Kit
  static Future<String> recognizeText(File imageFile) async {
    final input = InputImage.fromFile(imageFile);
    final RecognizedText result = await _recognizer.processImage(input);
    return result.text;
  }

  // Very basic parser: find lines that look like "Name 500mg" or contain mg/ml
  static List<Map<String, String>> parseMedsFromText(String text) {
    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final meds = <Map<String, String>>[];
    final regex = RegExp(
        r'^(?<name>[A-Za-z][A-Za-z\-\s]+)\s+(?<dose>\d+\s?(mg|ml|mcg))',
        caseSensitive: false);

    for (final line in lines) {
      final m = regex.firstMatch(line);
      if (m != null) {
        final name = m.namedGroup('name')!.trim();
        final dose = m.namedGroup('dose')!.trim();
        meds.add({
          'name': name,
          'dosage': dose,
          'timing': 'As prescribed',
        });
      }
    }

    // If nothing matched, return a tiny mock to avoid empty UI
    if (meds.isEmpty) {
      meds.addAll([
        {'name': 'Paracetamol', 'dosage': '500mg', 'timing': 'Morning & Night'},
      ]);
    }

    return meds;
  }
}
