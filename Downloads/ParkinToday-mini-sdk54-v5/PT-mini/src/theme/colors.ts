/**
 * ParkinToday color tokens
 * Primary + secondary are sampled directly from the logo mark.
 * Everything else is a neutral/semantic scaffold built around those two.
 */
export const colors = {
  // Primary — the teal from the logo's concentric "P" + pin
  ink: '#1AC4D6',
  inkDark: '#0E96A4',   // pressed states, map route shadow
  inkLight: '#E3FAFB',  // tints, selected-row backgrounds

  // Secondary — the charcoal slate from the logo plate
  harbor: '#334049',
  midnight: '#1B2329',  // splash background, deepest surfaces

  // Neutrals
  paper: '#F7F9FA',
  graphite: '#1C242B',
  mist: '#9AA5AC',
  hairline: '#E4E8EA',
  white: '#FFFFFF',

  // Semantic — slot availability states
  live: '#2BAE7C',
  liveBg: '#E7F7EF',
  busy: '#F0A93E',
  busyBg: '#FDF3E1',
  full: '#E15B53',
  fullBg: '#FCEAE8',
} as const;

export type ColorToken = keyof typeof colors;
