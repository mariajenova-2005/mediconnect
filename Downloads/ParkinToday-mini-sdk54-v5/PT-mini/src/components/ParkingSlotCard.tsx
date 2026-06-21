import React from 'react';
import { Pressable, View, Text } from 'react-native';
import { colors, fonts } from '../theme';
import { ParkingSlot } from '../types';
import StatusPill from './StatusPill';

export default function ParkingSlotCard({
  slot,
  onPress,
}: {
  slot: ParkingSlot;
  onPress: () => void;
}) {
  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => ({
        backgroundColor: colors.white,
        borderRadius: 22,
        padding: 16,
        marginBottom: 14,
        borderWidth: 1,
        borderColor: colors.hairline,
        opacity: pressed ? 0.92 : 1,
      })}
    >
      <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start' }}>
        <View style={{ flex: 1, paddingRight: 10 }}>
          <Text style={{ fontFamily: fonts.bodySemibold, fontSize: 16, color: colors.graphite }}>
            {slot.name}
          </Text>
          <Text style={{ fontFamily: fonts.body, fontSize: 13, color: colors.mist, marginTop: 2 }}>
            {slot.address}
          </Text>
        </View>
        <StatusPill status={slot.status} />
      </View>

      <View
        style={{
          flexDirection: 'row',
          alignItems: 'center',
          marginTop: 14,
          paddingTop: 14,
          borderTopWidth: 1,
          borderTopColor: colors.hairline,
        }}
      >
        <Stat label="Distance" value={`${slot.distanceKm.toFixed(1)} km`} />
        <Divider />
        <Stat label="Price" value={`₹${slot.pricePerHour}/hr`} />
        <Divider />
        <Stat label="Rating" value={`★ ${slot.rating.toFixed(1)}`} />
        <Divider />
        <Stat
          label="Spots"
          value={slot.status === 'full' ? '0' : `${slot.spotsLeft}`}
          valueColor={slot.status === 'full' ? colors.full : colors.graphite}
        />
      </View>
    </Pressable>
  );
}

function Stat({ label, value, valueColor }: { label: string; value: string; valueColor?: string }) {
  return (
    <View style={{ flex: 1 }}>
      <Text style={{ fontFamily: fonts.mono, fontSize: 14, color: valueColor ?? colors.graphite }}>
        {value}
      </Text>
      <Text style={{ fontFamily: fonts.body, fontSize: 11, color: colors.mist, marginTop: 2 }}>
        {label}
      </Text>
    </View>
  );
}

function Divider() {
  return <View style={{ width: 1, height: 24, backgroundColor: colors.hairline, marginHorizontal: 8 }} />;
}
