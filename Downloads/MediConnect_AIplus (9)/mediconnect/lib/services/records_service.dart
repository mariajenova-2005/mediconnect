import '../models/extra_models.dart';

/// Medical records + family healthcare data. `uploadFile` is shaped for
/// the backend (local disk): pick a file client-side, POST it to your backend, backend
/// uploads to the backend (local disk) and stores the record details alongside
/// the record metadata (see backend/routes/recordRoutes.js).
class RecordsService {
  RecordsService._internal();
  static final RecordsService instance = RecordsService._internal();

  final List<MedicalRecordFile> _records = [
    MedicalRecordFile(id: 'r1', fileName: 'Blood_Test_Sep2026.pdf', type: 'Lab Report', uploadedOn: DateTime.now().subtract(const Duration(days: 20))),
    MedicalRecordFile(id: 'r2', fileName: 'Prescription_Dr_Rao.pdf', type: 'Prescription', uploadedOn: DateTime.now().subtract(const Duration(days: 6))),
  ];

  final List<FamilyMember> _family = [
    FamilyMember(id: 'f1', name: 'Rajesh Sharma', relation: 'Father', age: 58, bloodGroup: 'B+'),
    FamilyMember(id: 'f2', name: 'Kavya Sharma', relation: 'Daughter', age: 6, bloodGroup: 'O+'),
  ];

  List<MedicalRecordFile> getRecords() => List.unmodifiable(_records);
  List<FamilyMember> getFamily() => List.unmodifiable(_family);

  void addRecord(String fileName, String type) {
    _records.add(MedicalRecordFile(id: 'r${_records.length + 1}', fileName: fileName, type: type, uploadedOn: DateTime.now()));
  }

  void addFamilyMember(FamilyMember member) => _family.add(member);
}
