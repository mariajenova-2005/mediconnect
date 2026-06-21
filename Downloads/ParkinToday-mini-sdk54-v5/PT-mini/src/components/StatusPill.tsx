import React from 'react';
import { View, Text } from 'react-native';
import { colors, fonts } from '../theme';
import { SlotStatus } from '../types';

const CONFIG: Record<SlotStatus, { label: string; fg: string; bg: string }> = {
  live: { label: 'Available', fg: colors.live, bg: colors.liveBg },
  busy: { label: 'Filling fast', fg: colors.busy, bg: colors.busyBg },
  full: { label: 'Full', fg: colors.full, bg: colors.fullBg },
};

export default function StatusPill({ status }: { status: SlotStatus }) {
  const c = CONFIG[status];
  return (
    <View
      style={{
        backgroundColor: c.bg,
        paddingHorizontal: 10,
        paddingVertical: 5,
        borderRadius: 999,
        flexDirection: 'row',
        alignItems: 'center',
      }}
    >
      <View style={{ width: 6, height: 6, borderRadius: 3, backgroundColor: c.fg, marginRight: 6 }} />
      <Text style={{ fontFamily: fonts.bodySemibold, fontSize: 12, color: c.fg }}>{c.label}</Text>
    </View>
  );
}
