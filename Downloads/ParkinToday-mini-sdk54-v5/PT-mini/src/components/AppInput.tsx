import React, { useState } from 'react';
import { View, Text, TextInput, TextInputProps } from 'react-native';
import { colors, fonts } from '../theme';

interface AppInputProps extends TextInputProps {
  label: string;
  prefix?: string;
  error?: string;
}

export default function AppInput({ label, prefix, error, ...rest }: AppInputProps) {
  const [focused, setFocused] = useState(false);

  return (
    <View style={{ marginBottom: 18 }}>
      <Text
        style={{
          fontFamily: fonts.bodyMedium,
          fontSize: 13,
          color: colors.mist,
          marginBottom: 8,
        }}
      >
        {label}
      </Text>
      <View
        style={{
          flexDirection: 'row',
          alignItems: 'center',
          height: 56,
          borderRadius: 16,
          borderWidth: 1.5,
          borderColor: error ? colors.full : focused ? colors.ink : colors.hairline,
          backgroundColor: colors.white,
          paddingHorizontal: 16,
        }}
      >
        {prefix ? (
          <Text style={{ fontFamily: fonts.bodySemibold, color: colors.graphite, marginRight: 8 }}>
            {prefix}
          </Text>
        ) : null}
        <TextInput
          {...rest}
          onFocus={() => setFocused(true)}
          onBlur={() => setFocused(false)}
          placeholderTextColor={colors.mist}
          style={{
            flex: 1,
            fontFamily: fonts.body,
            fontSize: 16,
            color: colors.graphite,
          }}
        />
      </View>
      {error ? (
        <Text style={{ fontFamily: fonts.body, fontSize: 12, color: colors.full, marginTop: 6 }}>
          {error}
        </Text>
      ) : null}
    </View>
  );
}
