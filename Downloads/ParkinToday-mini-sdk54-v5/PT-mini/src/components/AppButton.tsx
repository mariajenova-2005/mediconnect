import React from 'react';
import { Pressable, Text, ActivityIndicator } from 'react-native';
import { colors, fonts } from '../theme';

interface AppButtonProps {
  label: string;
  onPress?: () => void;
  variant?: 'primary' | 'dark' | 'outline';
  disabled?: boolean;
  loading?: boolean;
}

export default function AppButton({
  label,
  onPress,
  variant = 'primary',
  disabled = false,
  loading = false,
}: AppButtonProps) {
  const isDisabled = disabled || loading;

  const bg =
    variant === 'primary' ? colors.ink : variant === 'dark' ? colors.harbor : 'transparent';
  const textColor = variant === 'outline' ? colors.harbor : colors.white;
  const borderColor = variant === 'outline' ? colors.hairline : 'transparent';

  return (
    <Pressable
      onPress={onPress}
      disabled={isDisabled}
      style={({ pressed }) => ({
        backgroundColor: bg,
        borderColor,
        borderWidth: variant === 'outline' ? 1.5 : 0,
        opacity: isDisabled ? 0.5 : pressed ? 0.85 : 1,
        height: 56,
        borderRadius: 18,
        alignItems: 'center',
        justifyContent: 'center',
        flexDirection: 'row',
      })}
    >
      {loading ? (
        <ActivityIndicator color={textColor} />
      ) : (
        <Text style={{ color: textColor, fontFamily: fonts.bodySemibold, fontSize: 16 }}>
          {label}
        </Text>
      )}
    </Pressable>
  );
}
