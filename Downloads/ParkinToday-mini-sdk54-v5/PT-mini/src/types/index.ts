export type SlotStatus = 'live' | 'busy' | 'full';

export interface ParkingSlot {
  id: string;
  name: string;
  address: string;
  distanceKm: number;
  pricePerHour: number;
  status: SlotStatus;
  spotsLeft: number;
  rating: number;
  covered: boolean;
  evCharging: boolean;
  cctv: boolean;
  latitude: number;
  longitude: number;
}

export interface VehicleProfile {
  username: string;
  photoUri: string | null;
  carPhotoUri: string | null;
  rcBookUri: string | null;
  plateNumber: string;
}
