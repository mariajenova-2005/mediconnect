enum Severity { mild, moderate, severe }

extension SeverityX on Severity {
  String get label => switch (this) {
        Severity.mild => 'Mild',
        Severity.moderate => 'Moderate',
        Severity.severe => 'Severe',
      };
}

class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String bloodGroup;
  final List<String> allergies;
  final List<String> medicalHistory;
  final String contactNumber;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.allergies,
    required this.medicalHistory,
    required this.contactNumber,
  });

  factory Patient.fromMap(Map<String, dynamic> map) => Patient(
        id: map['id'],
        name: map['name'],
        age: map['age'],
        gender: map['gender'],
        bloodGroup: map['bloodGroup'],
        allergies: List<String>.from(map['allergies'] ?? []),
        medicalHistory: List<String>.from(map['medicalHistory'] ?? []),
        contactNumber: map['contactNumber'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'age': age,
        'gender': gender,
        'bloodGroup': bloodGroup,
        'allergies': allergies,
        'medicalHistory': medicalHistory,
        'contactNumber': contactNumber,
      };
}

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final bool isAvailableNow;
  final int experienceYears;
  final String hospital;
  final String avatarSeed;
  final double fee;

  Doctor({
    this.fee = 600,
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.isAvailableNow,
    required this.experienceYears,
    required this.hospital,
    required this.avatarSeed,
  });
}

class HospitalInfo {
  final String id;
  final String name;
  final double distanceKm;
  final double lat;
  final double lng;
  final bool hasER;
  final int etaMinutes;

  HospitalInfo({
    required this.id,
    required this.name,
    required this.distanceKm,
    required this.lat,
    required this.lng,
    required this.hasER,
    required this.etaMinutes,
  });
}

class ChatMessage {
  final String text;
  final bool fromUser;
  final DateTime time;

  ChatMessage({required this.text, required this.fromUser, required this.time});
}
