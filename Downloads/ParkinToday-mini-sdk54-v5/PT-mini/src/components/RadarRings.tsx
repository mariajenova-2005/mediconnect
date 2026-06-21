import React, { useEffect, useRef } from 'react';
import { Animated, Easing, View, StyleSheet } from 'react-native';
import { colors } from '../theme';

interface RadarRingsProps {
  size?: number;
  ringColor?: string;
  pulse?: boolean;
}

/**
 * The recurring brand motif: concentric rings, lifted from the logo's
 * nested "P" strokes. Used (a) drawing outward on the splash screen,
 * (b) pulsing under the pin while we locate the user, and (c) as the
 * soft 3 km search radius on the home map — three different jobs, one
 * consistent shape, so it always reads as "ParkinToday is searching."
 */
export default function RadarRings({ size = 220, ringColor = colors.ink, pulse = true }: RadarRingsProps) {
  const scale1 = useRef(new Animated.Value(0)).current;
  const scale2 = useRef(new Animated.Value(0)).current;
  const scale3 = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    if (!pulse) return;
    const makeLoop = (val: Animated.Value, delay: number) =>
      Animated.loop(
        Animated.sequence([
          Animated.delay(delay),
          Animated.timing(val, {
            toValue: 1,
            duration: 2200,
            easing: Easing.out(Easing.ease),
            useNativeDriver: true,
          }),
          Animated.timing(val, { toValue: 0, duration: 0, useNativeDriver: true }),
        ])
      );
    const loops = [makeLoop(scale1, 0), makeLoop(scale2, 700), makeLoop(scale3, 1400)];
    loops.forEach((l) => l.start());
    return () => loops.forEach((l) => l.stop());
  }, [pulse]);

  const ringStyle = (val: Animated.Value) => ({
    opacity: val.interpolate({ inputRange: [0, 0.15, 1], outputRange: [0, 0.5, 0] }),
    transform: [{ scale: val.interpolate({ inputRange: [0, 1], outputRange: [0.3, 1] }) }],
  });

  return (
    <View style={[styles.wrap, { width: size, height: size }]}>
      {[scale1, scale2, scale3].map((v, i) => (
        <Animated.View
          key={i}
          style={[
            styles.ring,
            { width: size, height: size, borderRadius: size / 2, borderColor: ringColor },
            ringStyle(v),
          ]}
        />
      ))}
      <View style={[styles.core, { backgroundColor: ringColor }]} />
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { alignItems: 'center', justifyContent: 'center' },
  ring: { position: 'absolute', borderWidth: 2 },
  core: { width: 14, height: 14, borderRadius: 7 },
});
