enum AppointmentStatus { upcoming, completed, cancelled }
enum UserRole { patient, doctor, admin }

class Appointment {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final AppointmentStatus status;
  final double fee;

  Appointment({required this.id, required this.doctorName, required this.specialty, required this.dateTime, required this.status, required this.fee});
}

class PaymentRecord {
  final String id;
  final double amount;
  final String method; // UPI / Card
  final DateTime date;
  final bool success;
  PaymentRecord({required this.id, required this.amount, required this.method, required this.date, required this.success});
}

class MedicalRecordFile {
  final String id;
  final String fileName;
  final String type; // Prescription / Lab Report / Scan
  final DateTime uploadedOn;
  MedicalRecordFile({required this.id, required this.fileName, required this.type, required this.uploadedOn});
}

class FamilyMember {
  final String id;
  final String name;
  final String relation;
  final int age;
  final String bloodGroup;
  FamilyMember({required this.id, required this.name, required this.relation, required this.age, required this.bloodGroup});
}

class SymptomCheckResult {
  final List<String> possibleConditions;
  final String severity;
  final String suggestedSpecialist;
  SymptomCheckResult({required this.possibleConditions, required this.severity, required this.suggestedSpecialist});
}

class ReportAnalysis {
  final String summary;
  final List<String> abnormalFindings;
  final List<String> recommendations;
  ReportAnalysis({required this.summary, required this.abnormalFindings, required this.recommendations});
}

class PrescriptionExplanation {
  final String medicineName;
  final String purpose;
  final String dosage;
  final List<String> sideEffects;
  final List<String> precautions;
  PrescriptionExplanation({required this.medicineName, required this.purpose, required this.dosage, required this.sideEffects, required this.precautions});
}
