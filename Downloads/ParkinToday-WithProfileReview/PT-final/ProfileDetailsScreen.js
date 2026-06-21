import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  StatusBar,
  Image,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  Alert,
} from 'react-native';
import * as ImagePicker from 'expo-image-picker';

const ACCENT = '#00b4d8';
const ACCENT_DARK = '#008da6';
const BG = '#eef2f5';
const CARD = '#ffffff';
const TEXT1 = '#111827';
const TEXT2 = '#6b7280';
const TEXT3 = '#9ca3af';
const BORDER = '#e2e5ea';

const VEHICLE_TYPES = ['Car', 'Bike', 'SUV', 'Other'];

export default function ProfileDetailsScreen({ onContinue }) {
  const [name, setName] = useState('');
  const [plate, setPlate] = useState('');
  const [vehicleType, setVehicleType] = useState('Car');
  const [vehicleModel, setVehicleModel] = useState('');
  const [rcImageUri, setRcImageUri] = useState(null);

  const isValid = name.trim().length > 1 && plate.trim().length >= 4 && !!rcImageUri;

  const handlePlateChange = (text) => {
    // Force uppercase as the user types — plate numbers are always shown in caps.
    setPlate(text.toUpperCase());
  };

  const pickFromGallery = async () => {
    const permission = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (!permission.granted) {
      Alert.alert('Permission needed', 'Allow photo library access to upload your RC book.');
      return;
    }
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      quality: 0.7,
      allowsEditing: true,
    });
    if (!result.canceled) setRcImageUri(result.assets[0].uri);
  };

  const takePhoto = async () => {
    const permission = await ImagePicker.requestCameraPermissionsAsync();
    if (!permission.granted) {
      Alert.alert('Permission needed', 'Allow camera access to photograph your RC book.');
      return;
    }
    const result = await ImagePicker.launchCameraAsync({
      quality: 0.7,
      allowsEditing: true,
    });
    if (!result.canceled) setRcImageUri(result.assets[0].uri);
  };

  const handleContinue = () => {
    if (!isValid) return;
    onContinue({ name: name.trim(), plate: plate.trim(), vehicleType, vehicleModel: vehicleModel.trim(), rcImageUri });
  };

  return (
    <KeyboardAvoidingView style={st.root} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <StatusBar barStyle="dark-content" backgroundColor={BG} />
      <ScrollView contentContainerStyle={st.content} showsVerticalScrollIndicator={false}>
        <Text style={st.title}>Set up your profile</Text>
        <Text style={st.subtitle}>
          We verify your vehicle once so check-in at any parking slot takes seconds.
        </Text>

        <View style={st.field}>
          <Text style={st.label}>Full name</Text>
          <TextInput
            style={st.input}
            placeholder="e.g. Arjun Kumar"
            placeholderTextColor={TEXT3}
            value={name}
            onChangeText={setName}
          />
        </View>

        <View style={st.field}>
          <Text style={st.label}>Vehicle plate number</Text>
          <TextInput
            style={[st.input, st.plateInput]}
            placeholder="TN 09 AB 1234"
            placeholderTextColor={TEXT3}
            autoCapitalize="characters"
            value={plate}
            onChangeText={handlePlateChange}
          />
        </View>

        <View style={st.field}>
          <Text style={st.label}>Vehicle type</Text>
          <View style={st.typeRow}>
            {VEHICLE_TYPES.map((t) => (
              <TouchableOpacity
                key={t}
                style={[st.typeChip, vehicleType === t && st.typeChipActive]}
                onPress={() => setVehicleType(t)}
              >
                <Text style={[st.typeChipText, vehicleType === t && st.typeChipTextActive]}>{t}</Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>

        <View style={st.field}>
          <Text style={st.label}>Vehicle model (optional)</Text>
          <TextInput
            style={st.input}
            placeholder="e.g. Hyundai Creta"
            placeholderTextColor={TEXT3}
            value={vehicleModel}
            onChangeText={setVehicleModel}
          />
        </View>

        <Text style={st.label}>RC book</Text>
        <Text style={st.helperText}>Used to verify ownership. Take a photo or upload from your gallery.</Text>

        {rcImageUri ? (
          <View style={st.rcPreviewWrap}>
            <Image source={{ uri: rcImageUri }} style={st.rcPreview} resizeMode="cover" />
            <View style={st.rcBadge}>
              <Text style={st.rcBadgeText}>✓ Uploaded</Text>
            </View>
            <TouchableOpacity style={st.rcReplace} onPress={() => setRcImageUri(null)}>
              <Text style={st.rcReplaceText}>Replace photo</Text>
            </TouchableOpacity>
          </View>
        ) : (
          <View style={st.rcButtonsRow}>
            <TouchableOpacity style={st.rcButton} onPress={takePhoto}>
              <Text style={st.rcButtonIcon}>📷</Text>
              <Text style={st.rcButtonText}>Take photo</Text>
            </TouchableOpacity>
            <TouchableOpacity style={st.rcButton} onPress={pickFromGallery}>
              <Text style={st.rcButtonIcon}>🖼️</Text>
              <Text style={st.rcButtonText}>From gallery</Text>
            </TouchableOpacity>
          </View>
        )}

        <View style={{ height: 28 }} />

        <TouchableOpacity
          style={[st.button, !isValid && st.buttonDisabled]}
          disabled={!isValid}
          onPress={handleContinue}
        >
          <Text style={st.buttonText}>Continue</Text>
        </TouchableOpacity>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const st = StyleSheet.create({
  root: { flex: 1, backgroundColor: BG },
  content: { paddingHorizontal: 24, paddingTop: 28, paddingBottom: 40 },

  title: { fontSize: 26, fontWeight: '800', color: TEXT1, lineHeight: 32 },
  subtitle: { fontSize: 14.5, color: TEXT2, marginTop: 8, lineHeight: 21, marginBottom: 26 },

  field: { marginBottom: 18 },
  label: { fontSize: 13, fontWeight: '700', color: TEXT2, marginBottom: 8 },
  helperText: { fontSize: 12.5, color: TEXT3, marginBottom: 14, lineHeight: 17 },
  input: {
    height: 54,
    borderRadius: 14,
    borderWidth: 1.5,
    borderColor: BORDER,
    backgroundColor: CARD,
    paddingHorizontal: 16,
    fontSize: 15,
    color: TEXT1,
  },
  plateInput: { fontFamily: 'monospace', fontWeight: '800', letterSpacing: 1.5 },

  typeRow: { flexDirection: 'row', flexWrap: 'wrap' },
  typeChip: {
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 12,
    borderWidth: 1.5,
    borderColor: BORDER,
    backgroundColor: CARD,
    marginRight: 10,
    marginBottom: 10,
  },
  typeChipActive: { backgroundColor: ACCENT, borderColor: ACCENT },
  typeChipText: { fontSize: 13.5, fontWeight: '600', color: TEXT2 },
  typeChipTextActive: { color: '#ffffff' },

  rcButtonsRow: { flexDirection: 'row', marginTop: 2 },
  rcButton: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 24,
    borderRadius: 16,
    borderWidth: 1.5,
    borderColor: BORDER,
    borderStyle: 'dashed',
    backgroundColor: CARD,
    marginRight: 10,
  },
  rcButtonIcon: { fontSize: 26, marginBottom: 8 },
  rcButtonText: { fontSize: 13, fontWeight: '600', color: TEXT2 },

  rcPreviewWrap: {
    borderRadius: 16,
    overflow: 'hidden',
    borderWidth: 1.5,
    borderColor: ACCENT,
    backgroundColor: CARD,
  },
  rcPreview: { width: '100%', height: 180 },
  rcBadge: {
    position: 'absolute',
    top: 10,
    right: 10,
    backgroundColor: '#16a34a',
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 999,
  },
  rcBadgeText: { color: '#ffffff', fontSize: 11.5, fontWeight: '700' },
  rcReplace: { paddingVertical: 12, alignItems: 'center' },
  rcReplaceText: { fontSize: 13, fontWeight: '700', color: ACCENT_DARK },

  button: {
    height: 54,
    borderRadius: 16,
    backgroundColor: ACCENT,
    alignItems: 'center',
    justifyContent: 'center',
  },
  buttonDisabled: { backgroundColor: '#a8d8e3' },
  buttonText: { color: '#ffffff', fontSize: 15.5, fontWeight: '700' },
});
