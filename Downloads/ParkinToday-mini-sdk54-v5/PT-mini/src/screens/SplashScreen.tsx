import React, { useEffect, useRef } from 'react';
import { View, Text, Animated, Easing, Image } from 'react-native';
import { colors, fonts } from '../theme';
import RadarRings from '../components/RadarRings';

export default function SplashScreen({ navigation }: any) {
  const logoScale = useRef(new Animated.Value(0.7)).current;
  const logoOpacity = useRef(new Animated.Value(0)).current;
  const wordmarkOpacity = useRef(new Animated.Value(0)).current;
  const wordmarkY = useRef(new Animated.Value(10)).current;
  const taglineOpacity = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.sequence([
      Animated.parallel([
        Animated.timing(logoOpacity, { toValue: 1, duration: 500, useNativeDriver: true }),
        Animated.timing(logoScale, {
          toValue: 1,
          duration: 600,
          easing: Easing.out(Easing.back(1.2)),
          useNativeDriver: true,
        }),
      ]),
      Animated.parallel([
        Animated.timing(wordmarkOpacity, { toValue: 1, duration: 420, useNativeDriver: true }),
        Animated.timing(wordmarkY, { toValue: 0, duration: 420, easing: Easing.out(Easing.ease), useNativeDriver: true }),
      ]),
      Animated.timing(taglineOpacity, { toValue: 1, duration: 350, useNativeDriver: true }),
    ]).start();

    const timer = setTimeout(() => {
      navigation.replace('Login');
    }, 2600);
    return () => clearTimeout(timer);
  }, []);

  return (
    <View
      style={{
        flex: 1,
        backgroundColor: colors.midnight,
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <View style={{ alignItems: 'center', justifyContent: 'center' }}>
        <RadarRings size={240} ringColor={colors.ink} pulse />
        <Animated.View
          style={{
            position: 'absolute',
            opacity: logoOpacity,
            transform: [{ scale: logoScale }],
            width: 96,
            height: 96,
            borderRadius: 24,
            backgroundColor: colors.harbor,
            alignItems: 'center',
            justifyContent: 'center',
            overflow: 'hidden',
          }}
        >
          <Image
            source={require('../../assets/logo.png')}
            style={{ width: 96, height: 96 }}
            resizeMode="cover"
          />
        </Animated.View>
      </View>

      <Animated.Text
        style={{
          marginTop: 36,
          opacity: wordmarkOpacity,
          transform: [{ translateY: wordmarkY }],
          fontFamily: fonts.displayBold,
          fontSize: 30,
          color: colors.white,
          letterSpacing: 0.2,
        }}
      >
        ParkinToday
      </Animated.Text>
      <Animated.Text
        style={{
          marginTop: 8,
          opacity: taglineOpacity,
          fontFamily: fonts.body,
          fontSize: 14,
          color: colors.mist,
        }}
      >
        Find your spot. Park today.
      </Animated.Text>
    </View>
  );
}
