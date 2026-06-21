import React from 'react';
import { View, Image, ViewStyle } from 'react-native';
import { colors } from '../theme';

interface LogoBadgeProps {
  size?: number;
  style?: ViewStyle;
}

/** Real logo image in a rounded harbor-colored tile — used on Login and Dashboard headers. */
export default function LogoBadge({ size = 52, style }: LogoBadgeProps) {
  return (
    <View
      style={[
        {
          width: size,
          height: size,
          borderRadius: size * 0.32,
          backgroundColor: colors.harbor,
          alignItems: 'center',
          justifyContent: 'center',
          overflow: 'hidden',
        },
        style,
      ]}
    >
      <Image
        source={require('../../assets/logo.png')}
        style={{ width: size, height: size }}
        resizeMode="cover"
      />
    </View>
  );
}
