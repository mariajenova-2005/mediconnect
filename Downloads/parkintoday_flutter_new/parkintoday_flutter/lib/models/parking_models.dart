enum SpotType { open, covered }
enum SpotStatus { available, limited, full }

class LatLng {
  final double latitude;
  final double longitude;
  const LatLng(this.latitude, this.longitude);
}

class ParkingSpot {
  final int id;
  final String name;
  final String address;
  final String distance;
  final int available;
  final int total;
  final String pricePerHour;
  final SpotType type;
  final LatLng coords;

  const ParkingSpot({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.available,
    required this.total,
    required this.pricePerHour,
    required this.type,
    required this.coords,
  });

  SpotStatus get status {
    if (available == 0) return SpotStatus.full;
    if (available <= 3) return SpotStatus.limited;
    return SpotStatus.available;
  }

  double get priceNum =>
      double.tryParse(pricePerHour.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
}

class EVStation {
  final int id;
  final String name;
  final String address;
  final String distance;
  final int available;
  final int total;
  final String pricePerKwh;
  final String chargerType;
  final String power;
  final String connector;
  final LatLng coords;

  const EVStation({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.available,
    required this.total,
    required this.pricePerKwh,
    required this.chargerType,
    required this.power,
    required this.connector,
    required this.coords,
  });

  SpotStatus get status {
    if (available == 0) return SpotStatus.full;
    if (available == 1) return SpotStatus.limited;
    return SpotStatus.available;
  }
}

// ── Mock data ──
const _base = LatLng(12.9715987, 77.5945627);

final List<ParkingSpot> mockParkingSpots = [
  ParkingSpot(id: 1, name: 'City Square Parking', address: 'MG Road, Bengaluru', distance: '120 m', available: 8, total: 20, pricePerHour: '₹20/hr', type: SpotType.open, coords: LatLng(_base.latitude + 0.0011, _base.longitude + 0.0008)),
  ParkingSpot(id: 2, name: 'Park Avenue Basement', address: 'Brigade Road, Bengaluru', distance: '340 m', available: 3, total: 50, pricePerHour: '₹30/hr', type: SpotType.covered, coords: LatLng(_base.latitude - 0.0012, _base.longitude + 0.0021)),
  ParkingSpot(id: 3, name: 'Green Mall Parking', address: 'Koramangala, Bengaluru', distance: '510 m', available: 0, total: 40, pricePerHour: '₹25/hr', type: SpotType.covered, coords: LatLng(_base.latitude + 0.0025, _base.longitude - 0.0015)),
  ParkingSpot(id: 4, name: 'Metro Hub Parking', address: 'Shivaji Nagar, Bengaluru', distance: '780 m', available: 15, total: 60, pricePerHour: '₹15/hr', type: SpotType.open, coords: LatLng(_base.latitude - 0.0030, _base.longitude - 0.0010)),
  ParkingSpot(id: 5, name: 'Tech Park Lot B', address: 'Whitefield, Bengaluru', distance: '950 m', available: 2, total: 30, pricePerHour: '₹40/hr', type: SpotType.covered, coords: LatLng(_base.latitude + 0.0040, _base.longitude + 0.0025)),
];

final List<EVStation> mockEVStations = [
  EVStation(id: 1, name: 'Tata Power EZ Charge', address: 'MG Road, Bengaluru', distance: '180 m', available: 3, total: 4, pricePerKwh: '₹18/kWh', chargerType: 'DC Fast', power: '60 kW', connector: 'CCS2', coords: LatLng(_base.latitude + 0.0015, _base.longitude + 0.0010)),
  EVStation(id: 2, name: 'Zeon Charging Hub', address: 'Brigade Road, Bengaluru', distance: '420 m', available: 1, total: 2, pricePerKwh: '₹22/kWh', chargerType: 'DC Super', power: '120 kW', connector: 'CCS2', coords: LatLng(_base.latitude - 0.0015, _base.longitude + 0.0018)),
  EVStation(id: 3, name: 'Jio-bp Pulse Station', address: 'Koramangala, Bengaluru', distance: '650 m', available: 0, total: 4, pricePerKwh: '₹16/kWh', chargerType: 'AC Charger', power: '22 kW', connector: 'Type 2', coords: LatLng(_base.latitude + 0.0028, _base.longitude - 0.0020)),
  EVStation(id: 4, name: 'ChargeZone Hub', address: 'Indiranagar, Bengaluru', distance: '810 m', available: 4, total: 6, pricePerKwh: '₹19/kWh', chargerType: 'DC Fast', power: '50 kW', connector: 'CCS2 & CHAdeMO', coords: LatLng(_base.latitude - 0.0035, _base.longitude - 0.0012)),
  EVStation(id: 5, name: 'Shell Recharge Point', address: 'HSR Layout, Bengaluru', distance: '1.2 km', available: 2, total: 2, pricePerKwh: '₹24/kWh', chargerType: 'DC Super', power: '150 kW', connector: 'CCS2', coords: LatLng(_base.latitude + 0.0045, _base.longitude + 0.0030)),
];
