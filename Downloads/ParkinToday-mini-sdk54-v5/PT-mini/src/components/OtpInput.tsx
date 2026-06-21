import React, { useRef } from 'react';
import { View, TextInput } from 'react-native';
import { colors, fonts } from '../theme';

interface OtpInputProps {
  length?: number;
  value: string[];
  onChange: (next: string[]) => void;
}

export default function OtpInput({ length = 6, value, onChange }: OtpInputProps) {
  const refs = useRef<Array<TextInput | null>>([]);

  const handleChange = (text: string, index: number) => {
    const next = [...value];
    next[index] = text.slice(-1);
    onChange(next);
    if (text && index < length - 1) refs.current[index + 1]?.focus();
  };

  const handleKeyPress = (key: string, index: number) => {
    if (key === 'Backspace' && !value[index] && index > 0) {
      refs.current[index - 1]?.focus();
    }
  };

  return (
    <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
      {Array.from({ length }).map((_, i) => (
        <TextInput
          key={i}
          ref={(r) => (refs.current[i] = r)}
          value={value[i] ?? ''}
          onChangeText={(t) => handleChange(t, i)}
          onKeyPress={({ nativeEvent }) => handleKeyPress(nativeEvent.key, i)}
          keyboardType="number-pad"
          maxLength={1}
          style={{
            width: 48,
            height: 56,
            borderRadius: 14,
            borderWidth: 1.5,
            borderColor: value[i] ? colors.ink : colors.hairline,
            backgroundColor: colors.white,
            textAlign: 'center',
            fontFamily: fonts.mono,
            fontSize: 20,
            color: colors.graphite,
          }}
        />
      ))}
    </View>
  );
}
