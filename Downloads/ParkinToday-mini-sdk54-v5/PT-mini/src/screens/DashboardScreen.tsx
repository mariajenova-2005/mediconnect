import React, { useEffect, useMemo, useState } from 'react';
import { View, Text, FlatList, Pressable, ActivityIndicator } from 'react-native';
import MapView, { Marker, Circle, PROVIDER_GOOGLE } from 'react-native-maps';
import { colors, fonts } from '../theme';
import { mockParkingSlots } from '../data/mockParkingSlots';
import ParkingSlotCard from '../components/ParkingSlotCard';
import AppButton from '../components/AppButton';
import LogoBadge from '../components/LogoBadge';
import { ParkingSlot } from '../types';
import { useUserLocation } from '../hooks/useUserLocation';
import { useLocationContext, FALLBACK_COORDS } from '../context/LocationContext';
import { distanceKm } from '../utils/distance';

const RADIUS_METERS = 3000;
const RADIUS_KM = RADIUS_METERS / 1000;

export default function DashboardScreen({ navigation }: any) {
  const { status, coords, requestLocation } = useUserLocation();
  const { coords: savedCoords, setCoords } = useLocationContext();
  const [filter, setFilter] = useState<'all' | 'live'>('all');

  // Ask for real device location the moment the dashboard mounts.
  useEffect(() => {
    requestLocation();
  }, []);

  // Persist the freshest fix into context so other screens can reuse it.
  useEffect(() => {
    if (coords) setCoords(coords);
  }, [coords]);

  const userLocation = coords ?? savedCoords ?? FALLBACK_COORDS;
  const usingFallback = !coords && !savedCoords;

  // Recompute real distance from the device to every slot, then keep only
  // what's actually within 3 km — this replaces the static mock distanceKm.
  const slotsWithLiveDistance = useMemo(() => {
    return mockParkingSlots
      .map((s) => ({
        ...s,
        distanceKm: distanceKm(userLocation, { latitude: s.latitude, longitude: s.longitude }),
      }))
      .filter((s) => s.distanceKm <= RADIUS_KM)
      .sort((a, b) => a.distanceKm - b.distanceKm);
  }, [userLocation]);

  const slots = useMemo(
    () =>
      filter === 'live'
        ? slotsWithLiveDistance.filter((s) => s.status !== 'full')
        : slotsWithLiveDistance,
    [filter, slotsWithLiveDistance]
  );

  return (
    <View style={{ flex: 1, backgroundColor: colors.paper }}>
      <View style={{ height: '42%' }}>
        <MapView
          provider={PROVIDER_GOOGLE}
          style={{ flex: 1 }}
          region={{
            latitude: userLocation.latitude,
            longitude: userLocation.longitude,
            latitudeDelta: 0.045,
            longitudeDelta: 0.045,
          }}
        >
          <Circle
            center={userLocation}
            radius={RADIUS_METERS}
            strokeColor={colors.ink}
            strokeWidth={1.5}
            fillColor="rgba(26,196,214,0.08)"
          />
          <Marker coordinate={userLocation}>
            <View
              style={{
                width: 18,
                height: 18,
                borderRadius: 9,
                backgroundColor: colors.ink,
                borderWidth: 3,
                borderColor: '#FFFFFF',
              }}
            />
          </Marker>
          {slots.map((slot) => (
            <Marker key={slot.id} coordinate={{ latitude: slot.latitude, longitude: slot.longitude }}>
              <View
                style={{
                  paddingHorizontal: 8,
                  paddingVertical: 5,
                  borderRadius: 10,
                  backgroundColor: slot.status === 'full' ? colors.harbor : colors.ink,
                }}
              >
                <Text style={{ color: '#FFFFFF', fontFamily: fonts.bodySemibold, fontSize: 11 }}>
                  ₹{slot.pricePerHour}
                </Text>
              </View>
            </Marker>
          ))}
        </MapView>

        <View
          style={{
            position: 'absolute',
            top: 16,
            left: 16,
            right: 16,
            flexDirection: 'row',
            justifyContent: 'space-between',
            alignItems: 'center',
          }}
        >
          <View
            style={{
              backgroundColor: '#FFFFFF',
              paddingHorizontal: 14,
              paddingVertical: 10,
              borderRadius: 16,
              shadowColor: '#000',
              shadowOpacity: 0.08,
              shadowRadius: 8,
              shadowOffset: { width: 0, height: 3 },
              elevation: 3,
              flexDirection: 'row',
              alignItems: 'center',
            }}
          >
            {status === 'requesting' && <ActivityIndicator size="small" color={colors.ink} style={{ marginRight: 8 }} />}
            <View>
              <Text style={{ fontFamily: fonts.body, fontSize: 11, color: colors.mist }}>
                {status === 'requesting' ? 'Locating you…' : usingFallback ? 'Showing default area' : 'Your location'}
              </Text>
              <Text style={{ fontFamily: fonts.bodySemibold, fontSize: 13, color: colors.graphite }}>
                {userLocation.latitude.toFixed(4)}, {userLocation.longitude.toFixed(4)}
              </Text>
            </View>
          </View>
          <LogoBadge
            size={40}
            style={{
              shadowColor: '#000',
              shadowOpacity: 0.1,
              shadowRadius: 6,
              elevation: 3,
            }}
          />
        </View>

        {status === 'denied' && (
          <View
            style={{
              position: 'absolute',
              bottom: 12,
              left: 16,
              right: 16,
              backgroundColor: colors.harbor,
              borderRadius: 16,
              padding: 12,
              flexDirection: 'row',
              alignItems: 'center',
              justifyContent: 'space-between',
            }}
          >
            <Text style={{ fontFamily: fonts.body, fontSize: 12, color: '#FFFFFF', flex: 1, marginRight: 10 }}>
              Location permission denied — showing a default area.
            </Text>
            <Pressable onPress={requestLocation}>
              <Text style={{ fontFamily: fonts.bodySemibold, fontSize: 12, color: colors.ink }}>Retry</Text>
            </Pressable>
          </View>
        )}
      </View>

      <View
        style={{
          flex: 1,
          backgroundColor: colors.paper,
          borderTopLeftRadius: 28,
          borderTopRightRadius: 28,
          marginTop: -24,
          paddingTop: 14,
          paddingHorizontal: 20,
        }}
      >
        <View
          style={{
            width: 40,
            height: 4,
            borderRadius: 2,
            backgroundColor: colors.hairline,
            alignSelf: 'center',
            marginBottom: 16,
          }}
        />

        <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 14 }}>
          <View>
            <Text style={{ fontFamily: fonts.displaySemibold, fontSize: 20, color: colors.graphite }}>
              Nearby parking
            </Text>
            <Text style={{ fontFamily: fonts.body, fontSize: 13, color: colors.mist, marginTop: 2 }}>
              {slots.length} spots within 3 km
            </Text>
          </View>
          <View style={{ flexDirection: 'row' }}>
            <FilterChip label="All" active={filter === 'all'} onPress={() => setFilter('all')} />
            <FilterChip label="Available" active={filter === 'live'} onPress={() => setFilter('live')} />
          </View>
        </View>

        {slots.length === 0 ? (
          <View style={{ alignItems: 'center', marginTop: 40 }}>
            <Text style={{ fontFamily: fonts.bodyMedium, fontSize: 14, color: colors.mist, marginBottom: 16 }}>
              No parking slots within 3 km of this location.
            </Text>
            <AppButton label="Retry location" variant="outline" onPress={requestLocation} />
          </View>
        ) : (
          <FlatList
            data={slots}
            keyExtractor={(item) => item.id}
            showsVerticalScrollIndicator={false}
            contentContainerStyle={{ paddingBottom: 24 }}
            renderItem={({ item }: { item: ParkingSlot }) => (
              <ParkingSlotCard slot={item} onPress={() => {}} />
            )}
          />
        )}
      </View>
    </View>
  );
}

function FilterChip({ label, active, onPress }: { label: string; active: boolean; onPress: () => void }) {
  return (
    <Pressable
      onPress={onPress}
      style={{
        paddingHorizontal: 12,
        paddingVertical: 7,
        borderRadius: 999,
        backgroundColor: active ? colors.ink : '#FFFFFF',
        borderWidth: 1,
        borderColor: active ? colors.ink : colors.hairline,
        marginLeft: 8,
      }}
    >
      <Text style={{ fontFamily: fonts.bodyMedium, fontSize: 12, color: active ? '#FFFFFF' : colors.mist }}>
        {label}
      </Text>
    </Pressable>
  );
}
