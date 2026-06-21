import React, { useState, useEffect, useRef } from 'react';
import {
  StyleSheet, View, Text, Animated, Dimensions, Image, Easing,
} from 'react-native';
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context';
import Svg, { Path, Circle, Defs, LinearGradient, Stop } from 'react-native-svg';
import ParkinDashboard from './ParkinDashboard';
import AuthScreen from './AuthScreen';
import ProfileDetailsScreen from './ProfileDetailsScreen';
import ReviewDetailsScreen from './ReviewDetailsScreen';
import "./global.css";

const { width, height } = Dimensions.get('window');
const CYAN = '#00b4d8';
const NAVY = '#0a1628';

// ── Animated SVG wrappers ──
const AnimatedSvgCircle = Animated.createAnimatedComponent(Circle);

// ── Parking Pin SVG (appears after logo) ──
const ParkingPin = ({ size = 24 }) => (
  <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
    <Path
      d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"
      fill={CYAN}
      opacity="0.9"
    />
    <Circle cx="12" cy="9" r="3" fill="#ffffff" />
  </Svg>
);

// ── SPLASH SCREEN ──
function SplashScreen({ onFinish }) {
  // Logo
  const logoScale = useRef(new Animated.Value(0)).current;
  const logoOpacity = useRef(new Animated.Value(0)).current;
  const logoRotate = useRef(new Animated.Value(-0.05)).current;

  // Radar rings (3 expanding rings)
  const ring1Scale = useRef(new Animated.Value(0.2)).current;
  const ring1Opacity = useRef(new Animated.Value(0)).current;
  const ring2Scale = useRef(new Animated.Value(0.2)).current;
  const ring2Opacity = useRef(new Animated.Value(0)).current;
  const ring3Scale = useRef(new Animated.Value(0.2)).current;
  const ring3Opacity = useRef(new Animated.Value(0)).current;

  // Scanning arc rotation
  const scanRotation = useRef(new Animated.Value(0)).current;

  // Brand letters — "ParkinToday" = 11 chars
  const brandText = 'ParkinToday';
  const letterAnims = useRef(brandText.split('').map(() => new Animated.Value(0))).current;

  // Tagline
  const taglineOpacity = useRef(new Animated.Value(0)).current;

  // Progress bar
  const progressWidth = useRef(new Animated.Value(0)).current;

  // Location pins that pop in
  const pin1 = useRef(new Animated.Value(0)).current;
  const pin2 = useRef(new Animated.Value(0)).current;
  const pin3 = useRef(new Animated.Value(0)).current;

  // Exit animation
  const exitScale = useRef(new Animated.Value(1)).current;
  const exitOpacity = useRef(new Animated.Value(1)).current;

  // Glow pulse
  const glowPulse = useRef(new Animated.Value(0.4)).current;

  useEffect(() => {
    // ── 1. Background glow pulse (loops) ──
    const glowLoop = Animated.loop(
      Animated.sequence([
        Animated.timing(glowPulse, { toValue: 1, duration: 1200, easing: Easing.inOut(Easing.ease), useNativeDriver: true }),
        Animated.timing(glowPulse, { toValue: 0.4, duration: 1200, easing: Easing.inOut(Easing.ease), useNativeDriver: true }),
      ])
    );
    glowLoop.start();

    // ── 2. Radar rings fire in sequence ──
    const fireRing = (scale, opacity, delay) =>
      Animated.sequence([
        Animated.delay(delay),
        Animated.parallel([
          Animated.timing(scale, { toValue: 2.5, duration: 1200, easing: Easing.out(Easing.cubic), useNativeDriver: true }),
          Animated.sequence([
            Animated.timing(opacity, { toValue: 0.6, duration: 200, useNativeDriver: true }),
            Animated.timing(opacity, { toValue: 0, duration: 1000, useNativeDriver: true }),
          ]),
        ]),
      ]);

    Animated.stagger(300, [
      fireRing(ring1Scale, ring1Opacity, 0),
      fireRing(ring2Scale, ring2Opacity, 0),
      fireRing(ring3Scale, ring3Opacity, 0),
    ]).start();

    // ── 3. Scanning arc (rotating) ──
    const scanLoop = Animated.loop(
      Animated.timing(scanRotation, {
        toValue: 1,
        duration: 2000,
        easing: Easing.linear,
        useNativeDriver: true,
      })
    );
    scanLoop.start();

    // ── 4. Logo bounces in (after 400ms) ──
    Animated.sequence([
      Animated.delay(400),
      Animated.parallel([
        Animated.spring(logoScale, {
          toValue: 1,
          friction: 5,
          tension: 60,
          useNativeDriver: true,
        }),
        Animated.timing(logoOpacity, {
          toValue: 1,
          duration: 500,
          useNativeDriver: true,
        }),
        Animated.timing(logoRotate, {
          toValue: 0,
          duration: 600,
          easing: Easing.out(Easing.back(1.5)),
          useNativeDriver: true,
        }),
      ]),
    ]).start();

    // ── 5. Brand letters stagger in ──
    Animated.sequence([
      Animated.delay(1000),
      Animated.stagger(60, letterAnims.map(anim =>
        Animated.spring(anim, {
          toValue: 1,
          friction: 6,
          tension: 80,
          useNativeDriver: true,
        })
      )),
    ]).start();

    // ── 6. Location pins pop in ──
    Animated.sequence([
      Animated.delay(1400),
      Animated.stagger(150, [pin1, pin2, pin3].map(p =>
        Animated.spring(p, { toValue: 1, friction: 5, tension: 100, useNativeDriver: true })
      )),
    ]).start();

    // ── 7. Tagline fades in ──
    Animated.sequence([
      Animated.delay(1800),
      Animated.timing(taglineOpacity, {
        toValue: 1,
        duration: 400,
        useNativeDriver: true,
      }),
    ]).start();

    // ── 8. Progress bar fills ──
    Animated.sequence([
      Animated.delay(1200),
      Animated.timing(progressWidth, {
        toValue: 1,
        duration: 1800,
        easing: Easing.inOut(Easing.cubic),
        useNativeDriver: false, // width interpolation needs layout
      }),
    ]).start();

    // ── 9. Exit: zoom forward + fade ──
    setTimeout(() => {
      glowLoop.stop();
      scanLoop.stop();
      Animated.parallel([
        Animated.timing(exitScale, {
          toValue: 1.5,
          duration: 500,
          easing: Easing.in(Easing.cubic),
          useNativeDriver: true,
        }),
        Animated.timing(exitOpacity, {
          toValue: 0,
          duration: 500,
          useNativeDriver: true,
        }),
      ]).start(() => onFinish());
    }, 3400);
  }, []);

  const scanSpin = scanRotation.interpolate({
    inputRange: [0, 1],
    outputRange: ['0deg', '360deg'],
  });

  const logoRotateInterp = logoRotate.interpolate({
    inputRange: [-0.05, 0],
    outputRange: ['-12deg', '0deg'],
  });

  return (
    <Animated.View style={[
      ss.splash,
      { opacity: exitOpacity, transform: [{ scale: exitScale }] },
    ]}>
      {/* Background glow */}
      <Animated.View style={[ss.glow, { opacity: glowPulse }]} />

      {/* Radar rings */}
      {[[ring1Scale, ring1Opacity], [ring2Scale, ring2Opacity], [ring3Scale, ring3Opacity]].map(([s, o], i) => (
        <Animated.View
          key={i}
          style={[ss.ring, {
            opacity: o,
            transform: [{ scale: s }],
            borderColor: i === 0 ? CYAN : i === 1 ? '#0097b2' : '#006070',
          }]}
        />
      ))}

      {/* Scanning arc */}
      <Animated.View style={[ss.scanArcWrap, { transform: [{ rotate: scanSpin }] }]}>
        <View style={ss.scanArc} />
      </Animated.View>

      {/* Logo */}
      <Animated.View style={{
        opacity: logoOpacity,
        transform: [
          { scale: logoScale },
          { rotate: logoRotateInterp },
        ],
      }}>
        <View style={ss.logoOuter}>
          <View style={ss.logoInner}>
            <Image
              source={require('./logo.jpg')}
              style={ss.logoImg}
              resizeMode="cover"
            />
          </View>
        </View>
      </Animated.View>

      {/* Floating pins */}
      <View style={ss.pinRow}>
        {[
          { anim: pin1, x: -80, y: -60 },
          { anim: pin2, x: 90, y: -30 },
          { anim: pin3, x: -50, y: 50 },
        ].map((p, i) => (
          <Animated.View
            key={i}
            style={[ss.pin, {
              left: width / 2 + p.x - 12,
              top: height / 2 + p.y - 12,
              opacity: p.anim,
              transform: [{ scale: p.anim }],
            }]}
          >
            <ParkingPin size={24} />
          </Animated.View>
        ))}
      </View>

      {/* Brand letters */}
      <View style={ss.brandRow}>
        {brandText.split('').map((char, i) => {
          const isAccent = i >= 6; // "Today" part
          return (
            <Animated.Text
              key={i}
              style={[
                ss.brandLetter,
                isAccent && ss.brandAccentLetter,
                {
                  opacity: letterAnims[i],
                  transform: [
                    { translateY: letterAnims[i].interpolate({ inputRange: [0, 1], outputRange: [30, 0] }) },
                    { scale: letterAnims[i].interpolate({ inputRange: [0, 0.5, 1], outputRange: [0.3, 1.1, 1] }) },
                  ],
                },
              ]}
            >
              {char}
            </Animated.Text>
          );
        })}
      </View>

      {/* Tagline */}
      <Animated.Text style={[ss.tagline, { opacity: taglineOpacity }]}>
        Smart Parking, Simplified.
      </Animated.Text>

      {/* Progress bar */}
      <View style={ss.progressTrack}>
        <Animated.View style={[ss.progressFill, {
          width: progressWidth.interpolate({
            inputRange: [0, 1],
            outputRange: ['0%', '100%'],
          }),
        }]} />
      </View>
    </Animated.View>
  );
}

// ── MAIN APP ──
export default function App() {
  // 'splash' -> 'auth' -> 'profile' -> 'review' -> 'dashboard'
  const [stage, setStage] = useState('splash');
  const [profileDetails, setProfileDetails] = useState(null);

  if (stage === 'splash') {
    return <SplashScreen onFinish={() => setStage('auth')} />;
  }

  if (stage === 'auth') {
    return (
      <SafeAreaProvider>
        <SafeAreaView style={{ flex: 1, backgroundColor: '#eef2f5' }}>
          <AuthScreen onAuthenticated={() => setStage('profile')} />
        </SafeAreaView>
      </SafeAreaProvider>
    );
  }

  if (stage === 'profile') {
    return (
      <SafeAreaProvider>
        <SafeAreaView style={{ flex: 1, backgroundColor: '#eef2f5' }}>
          <ProfileDetailsScreen
            onContinue={(details) => {
              setProfileDetails(details);
              setStage('review');
            }}
          />
        </SafeAreaView>
      </SafeAreaProvider>
    );
  }

  if (stage === 'review') {
    return (
      <SafeAreaProvider>
        <SafeAreaView style={{ flex: 1, backgroundColor: '#eef2f5' }}>
          <ReviewDetailsScreen
            details={profileDetails}
            onEdit={() => setStage('profile')}
            onConfirm={() => setStage('dashboard')}
          />
        </SafeAreaView>
      </SafeAreaProvider>
    );
  }

  return (
    <SafeAreaProvider>
      <SafeAreaView style={{ flex: 1, backgroundColor: '#f0fbff' }}>
        <ParkinDashboard />
      </SafeAreaView>
    </SafeAreaProvider>
  );
}

// ── STYLES ──
const ss = StyleSheet.create({
  splash: {
    flex: 1,
    backgroundColor: NAVY,
    alignItems: 'center',
    justifyContent: 'center',
  },
  glow: {
    position: 'absolute',
    width: 350,
    height: 350,
    borderRadius: 175,
    backgroundColor: 'rgba(0, 180, 216, 0.06)',
  },

  // Radar rings
  ring: {
    position: 'absolute',
    width: 140,
    height: 140,
    borderRadius: 70,
    borderWidth: 2,
  },

  // Scanning arc
  scanArcWrap: {
    position: 'absolute',
    width: 180,
    height: 180,
    alignItems: 'center',
    justifyContent: 'center',
  },
  scanArc: {
    position: 'absolute',
    top: 0,
    left: '50%',
    marginLeft: -2,
    width: 4,
    height: 90,
    backgroundColor: CYAN,
    borderRadius: 2,
    opacity: 0.3,
  },

  // Logo
  logoOuter: {
    width: 120,
    height: 120,
    borderRadius: 32,
    backgroundColor: 'rgba(0, 180, 216, 0.1)',
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 2,
    borderColor: 'rgba(0, 229, 255, 0.25)',
  },
  logoInner: {
    width: 96,
    height: 96,
    borderRadius: 24,
    overflow: 'hidden',
    borderWidth: 2.5,
    borderColor: CYAN,
    shadowColor: '#00e5ff',
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.6,
    shadowRadius: 25,
    elevation: 15,
  },
  logoImg: { width: '100%', height: '100%' },

  // Pins
  pinRow: { position: 'absolute', width: '100%', height: '100%' },
  pin: { position: 'absolute' },

  // Brand text
  brandRow: {
    flexDirection: 'row',
    marginTop: 28,
    alignItems: 'center',
  },
  brandLetter: {
    fontSize: 30,
    fontWeight: '900',
    color: '#ffffff',
    letterSpacing: -0.5,
  },
  brandAccentLetter: {
    color: CYAN,
  },

  // Tagline
  tagline: {
    fontSize: 13,
    color: '#5da7bd',
    fontWeight: '600',
    letterSpacing: 2,
    marginTop: 10,
    textTransform: 'uppercase',
  },

  // Progress bar
  progressTrack: {
    position: 'absolute',
    bottom: 70,
    width: 160,
    height: 4,
    backgroundColor: '#1a2d44',
    borderRadius: 2,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: CYAN,
    borderRadius: 2,
    shadowColor: CYAN,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.8,
    shadowRadius: 6,
  },
});
