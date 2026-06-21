import React from 'react';
import { View, Text, Image, TouchableOpacity, StyleSheet, StatusBar, ScrollView } from 'react-native';

const ACCENT = '#00b4d8';
const ACCENT_DARK = '#008da6';
const BG = '#eef2f5';
const CARD = '#ffffff';
const TEXT1 = '#111827';
const TEXT2 = '#6b7280';
const TEXT3 = '#9ca3af';
const BORDER = '#e2e5ea';

export default function ReviewDetailsScreen({ details, onConfirm, onEdit }) {
  const { name, plate, vehicleType, vehicleModel, rcImageUri } = details;

  return (
    <View style={st.root}>
      <StatusBar barStyle="dark-content" backgroundColor={BG} />
      <ScrollView contentContainerStyle={st.content} showsVerticalScrollIndicator={false}>
        <Text style={st.title}>Review your details</Text>
        <Text style={st.subtitle}>
          Make sure everything is correct before you continue. You can edit anything below.
        </Text>

        <View style={st.card}>
          <Row label="Name" value={name} />
          <Divider />
          <Row label="Plate number" value={plate} mono />
          <Divider />
          <Row label="Vehicle type" value={vehicleType} />
          {vehicleModel ? (
            <>
              <Divider />
              <Row label="Model" value={vehicleModel} />
            </>
          ) : null}
        </View>

        <Text style={st.label}>RC book</Text>
        <View style={st.rcCard}>
          <Image source={{ uri: rcImageUri }} style={st.rcImage} resizeMode="cover" />
        </View>

        <TouchableOpacity style={st.editLink} onPress={onEdit}>
          <Text style={st.editLinkText}>Edit details</Text>
        </TouchableOpacity>

        <View style={{ height: 16 }} />

        <TouchableOpacity style={st.button} onPress={onConfirm}>
          <Text style={st.buttonText}>Confirm & continue</Text>
        </TouchableOpacity>
      </ScrollView>
    </View>
  );
}

function Row({ label, value, mono }) {
  return (
    <View style={st.row}>
      <Text style={st.rowLabel}>{label}</Text>
      <Text style={[st.rowValue, mono && st.rowValueMono]}>{value}</Text>
    </View>
  );
}

function Divider() {
  return <View style={st.divider} />;
}

const st = StyleSheet.create({
  root: { flex: 1, backgroundColor: BG },
  content: { paddingHorizontal: 24, paddingTop: 28, paddingBottom: 40 },

  title: { fontSize: 26, fontWeight: '800', color: TEXT1, lineHeight: 32 },
  subtitle: { fontSize: 14.5, color: TEXT2, marginTop: 8, lineHeight: 21, marginBottom: 24 },

  card: {
    backgroundColor: CARD,
    borderRadius: 16,
    borderWidth: 1.5,
    borderColor: BORDER,
    paddingHorizontal: 18,
    paddingVertical: 6,
    marginBottom: 24,
  },
  row: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingVertical: 14 },
  rowLabel: { fontSize: 13.5, color: TEXT2, fontWeight: '600' },
  rowValue: { fontSize: 14.5, color: TEXT1, fontWeight: '700', maxWidth: '60%', textAlign: 'right' },
  rowValueMono: { fontFamily: 'monospace', letterSpacing: 1 },
  divider: { height: 1, backgroundColor: BORDER },

  label: { fontSize: 13, fontWeight: '700', color: TEXT2, marginBottom: 10 },
  rcCard: {
    borderRadius: 16,
    overflow: 'hidden',
    borderWidth: 1.5,
    borderColor: BORDER,
    backgroundColor: CARD,
  },
  rcImage: { width: '100%', height: 200 },

  editLink: { alignSelf: 'center', marginTop: 18 },
  editLinkText: { fontSize: 13.5, fontWeight: '700', color: ACCENT_DARK },

  button: {
    height: 54,
    borderRadius: 16,
    backgroundColor: ACCENT,
    alignItems: 'center',
    justifyContent: 'center',
  },
  buttonText: { color: '#ffffff', fontSize: 15.5, fontWeight: '700' },
});
