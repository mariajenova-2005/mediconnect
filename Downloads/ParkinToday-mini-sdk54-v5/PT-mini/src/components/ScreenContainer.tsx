import React from 'react';
import { View, ViewStyle } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { colors } from '../theme';

interface ScreenContainerProps {
  children: React.ReactNode;
  background?: string;
  noPadding?: boolean;
  style?: ViewStyle;
}

export default function ScreenContainer({
  children,
  background = colors.paper,
  noPadding = false,
  style,
}: ScreenContainerProps) {
  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: background }}>
      <View style={[{ flex: 1, paddingHorizontal: noPadding ? 0 : 24 }, style]}>{children}</View>
    </SafeAreaView>
  );
}
