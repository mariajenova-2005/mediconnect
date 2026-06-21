import React, { createContext, useContext, useState, ReactNode } from 'react';

interface Coords {
  latitude: number;
  longitude: number;
}

interface LocationContextValue {
  coords: Coords | null;
  setCoords: (c: Coords) => void;
}

const LocationContext = createContext<LocationContextValue | undefined>(undefined);

// Fallback used only if someone reaches the map before granting permission
// (e.g. they tapped "Not now"). Keeps the screens from crashing on null.
export const FALLBACK_COORDS: Coords = { latitude: 13.0560, longitude: 80.2650 };

export function LocationProvider({ children }: { children: ReactNode }) {
  const [coords, setCoords] = useState<Coords | null>(null);
  return (
    <LocationContext.Provider value={{ coords, setCoords }}>
      {children}
    </LocationContext.Provider>
  );
}

export function useLocationContext() {
  const ctx = useContext(LocationContext);
  if (!ctx) throw new Error('useLocationContext must be used within a LocationProvider');
  return ctx;
}
