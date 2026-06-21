/**
 * Type system
 * Display  — Sora            headlines, splash wordmark, price/ETA numerals
 * Body     — Inter            running UI text, labels, descriptions
 * Utility  — JetBrains Mono   OTP digits, plate numbers, distance/ETA readouts
 *
 * Load these with @expo-google-fonts before the app renders (see App.tsx).
 */
export const fonts = {
  displayRegular: 'Sora_400Regular',
  displayMedium: 'Sora_500Medium',
  displaySemibold: 'Sora_600SemiBold',
  displayBold: 'Sora_700Bold',
  body: 'Inter_400Regular',
  bodyMedium: 'Inter_500Medium',
  bodySemibold: 'Inter_600SemiBold',
  mono: 'JetBrainsMono_500Medium',
  monoBold: 'JetBrainsMono_700Bold',
} as const;

export const type = {
  h1: { fontFamily: fonts.displaySemibold, fontSize: 28, lineHeight: 34 },
  h2: { fontFamily: fonts.displaySemibold, fontSize: 22, lineHeight: 28 },
  h3: { fontFamily: fonts.displayMedium, fontSize: 18, lineHeight: 24 },
  body: { fontFamily: fonts.body, fontSize: 15, lineHeight: 22 },
  bodyStrong: { fontFamily: fonts.bodySemibold, fontSize: 15, lineHeight: 22 },
  caption: { fontFamily: fonts.body, fontSize: 13, lineHeight: 18 },
  mono: { fontFamily: fonts.mono, fontSize: 15, lineHeight: 20 },
} as const;
