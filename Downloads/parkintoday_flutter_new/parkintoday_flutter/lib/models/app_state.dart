import 'package:flutter/foundation.dart';

enum VehicleType { car, suv }

extension VehicleTypeExtension on VehicleType {
  String get label => this == VehicleType.car ? 'Car' : 'SUV';
  String get emoji => this == VehicleType.car ? '🚗' : '🚙';
  String get iconPath => this == VehicleType.car ? 'car' : 'suv';
}

class Vehicle {
  final String id;
  final String plate;
  final VehicleType type;
  final String model;
  final String? rcImagePath;
  final bool isDefault;

  const Vehicle({
    required this.id,
    required this.plate,
    required this.type,
    required this.model,
    this.rcImagePath,
    this.isDefault = false,
  });

  Vehicle copyWith({
    String? id,
    String? plate,
    VehicleType? type,
    String? model,
    String? rcImagePath,
    bool? isDefault,
  }) =>
      Vehicle(
        id: id ?? this.id,
        plate: plate ?? this.plate,
        type: type ?? this.type,
        model: model ?? this.model,
        rcImagePath: rcImagePath ?? this.rcImagePath,
        isDefault: isDefault ?? this.isDefault,
      );
}

class UserProfile {
  final String name;
  final String phone;
  final List<Vehicle> vehicles;

  const UserProfile({
    required this.name,
    required this.phone,
    this.vehicles = const [],
  });

  UserProfile copyWith({String? name, String? phone, List<Vehicle>? vehicles}) =>
      UserProfile(name: name ?? this.name, phone: phone ?? this.phone, vehicles: vehicles ?? this.vehicles);

  Vehicle? get defaultVehicle => vehicles.isEmpty ? null : vehicles.firstWhere((v) => v.isDefault, orElse: () => vehicles.first);
}

class AppState extends ChangeNotifier {
  UserProfile? _user;
  int _navIndex = 0;
  bool _isLoggedIn = false;

  // Simulated "existing users" phone list (direct login, no OTP)
  static const Set<String> _existingUsers = {'9876543210', '9123456789', '6379474664'};

  UserProfile? get user => _user;
  int get navIndex => _navIndex;
  bool get isLoggedIn => _isLoggedIn;

  bool isExistingUser(String phone) => _existingUsers.contains(phone);

  void setNavIndex(int i) {
    _navIndex = i;
    notifyListeners();
  }

  void login(String phone, {String name = 'User'}) {
    final existingVehicle = Vehicle(
      id: '1',
      plate: 'TN09CD1234',
      type: VehicleType.car,
      model: 'Hyundai Creta',
      isDefault: true,
    );
    _user = UserProfile(name: name, phone: phone, vehicles: [existingVehicle]);
    _isLoggedIn = true;
    notifyListeners();
  }

  void registerUser({
    required String name,
    required String phone,
    required String plate,
    required VehicleType vehicleType,
    required String model,
    String? rcImagePath,
  }) {
    final vehicle = Vehicle(
      id: '1',
      plate: plate,
      type: vehicleType,
      model: model,
      rcImagePath: rcImagePath,
      isDefault: true,
    );
    _user = UserProfile(name: name, phone: phone, vehicles: [vehicle]);
    _isLoggedIn = true;
    notifyListeners();
  }

  void addVehicle(Vehicle v) {
    if (_user == null) return;
    final updated = List<Vehicle>.from(_user!.vehicles);
    // If this is the first vehicle or marked default, update others
    if (v.isDefault) {
      for (int i = 0; i < updated.length; i++) {
        updated[i] = updated[i].copyWith(isDefault: false);
      }
    }
    updated.add(v);
    _user = _user!.copyWith(vehicles: updated);
    notifyListeners();
  }

  void setDefaultVehicle(String vehicleId) {
    if (_user == null) return;
    final updated = _user!.vehicles.map((v) => v.copyWith(isDefault: v.id == vehicleId)).toList();
    _user = _user!.copyWith(vehicles: updated);
    notifyListeners();
  }

  void removeVehicle(String vehicleId) {
    if (_user == null) return;
    final updated = _user!.vehicles.where((v) => v.id != vehicleId).toList();
    if (updated.isNotEmpty && !updated.any((v) => v.isDefault)) {
      updated[0] = updated[0].copyWith(isDefault: true);
    }
    _user = _user!.copyWith(vehicles: updated);
    notifyListeners();
  }

  void logout() {
    _user = null;
    _isLoggedIn = false;
    _navIndex = 0;
    notifyListeners();
  }
}
