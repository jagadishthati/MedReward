class Medication {
  final String id;
  final String name;
  final String dosage; // e.g., "500mg"
  final String timing; // e.g., "Morning & Night"
  final bool taken;

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.timing,
    this.taken = false,
  });

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? timing,
    bool? taken,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      timing: timing ?? this.timing,
      taken: taken ?? this.taken,
    );
  }
}
