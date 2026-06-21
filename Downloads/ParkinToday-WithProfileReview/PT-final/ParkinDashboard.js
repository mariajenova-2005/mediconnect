import React, { useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  Dimensions,
  StyleSheet,
  StatusBar,
  Image,
} from 'react-native';
import Svg, { Path, Circle, Rect, Line, Defs, LinearGradient, Stop } from 'react-native-svg';

const { width } = Dimensions.get('window');

// ── PALETTE ──
const ACCENT = '#00b4d8';
const ACCENT_DARK = '#008da6';
const BG = '#eef2f5';
const CARD = '#ffffff';
const DARK = '#0c1a2a';
const DARK2 = '#142236';
const HEADER_BG = '#ecfeff'; // Premium soft ice-cyan tint
const TEXT1 = '#111827';
const TEXT2 = '#6b7280';
const TEXT3 = '#9ca3af';
const BORDER = '#e2e5ea';

// ── LOGO ──
const Logo = () => (
  <Image
    source={require('./logo.jpg')}
    style={{ width: 34, height: 34, borderRadius: 9 }}
    resizeMode="cover"
  />
);

// ── ICON SYSTEM ──
const I = ({ name, size = 22, color = '#fff', sw = 1.8 }) => {
  const d = {
    profile: <><Circle cx="12" cy="8" r="4" stroke={color} strokeWidth={sw} fill="none" /><Path d="M20 21a8 8 0 10-16 0" stroke={color} strokeWidth={sw} fill="none" strokeLinecap="round" /></>,
    search: <><Circle cx="11" cy="11" r="7" stroke={color} strokeWidth={sw} fill="none" /><Path d="M21 21l-4.35-4.35" stroke={color} strokeWidth={sw} strokeLinecap="round" /></>,
    bell: <><Path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9M13.73 21a2 2 0 01-3.46 0" stroke={color} strokeWidth={sw} strokeLinecap="round" fill="none" /></>,
    pin: <><Path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z" stroke={color} strokeWidth={sw} fill="none" /><Circle cx="12" cy="9" r="2.5" stroke={color} strokeWidth={sw} fill="none" /></>,
    calendar: <><Rect x="3" y="4" width="18" height="18" rx="2" stroke={color} strokeWidth={sw} fill="none" /><Path d="M16 2v4M8 2v4M3 10h18" stroke={color} strokeWidth={sw} strokeLinecap="round" /><Path d="M9 16l2 2 4-4" stroke={color} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" /></>,
    clock: <><Circle cx="12" cy="12" r="9" stroke={color} strokeWidth={sw} fill="none" /><Path d="M12 7v5l3 3" stroke={color} strokeWidth={sw} strokeLinecap="round" /></>,
    doc: <><Path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z" stroke={color} strokeWidth={sw} fill="none" /><Path d="M14 2v6h6M9 13h6M9 17h4" stroke={color} strokeWidth={sw} strokeLinecap="round" /></>,
    bolt: <><Path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z" stroke={color} strokeWidth={sw} fill="none" strokeLinejoin="round" /></>,
    key: <><Circle cx="12" cy="10" r="3" stroke={color} strokeWidth={sw} fill="none" /><Path d="M12 13v4M10 17h4M12 2v5" stroke={color} strokeWidth={sw} strokeLinecap="round" /><Path d="M7 5l3.5 3.5M17 5l-3.5 3.5" stroke={color} strokeWidth={sw} strokeLinecap="round" /></>,
    tag: <><Path d="M20.59 13.41l-7.17 7.17a2 2 0 01-2.83 0L2 12V2h10l8.59 8.59a2 2 0 010 2.82z" stroke={color} strokeWidth={sw} fill="none" /><Circle cx="7" cy="7" r="1.5" fill={color} /></>,
    grid: <><Rect x="3" y="3" width="7" height="7" rx="1.5" stroke={color} strokeWidth={sw} fill="none" /><Rect x="14" y="3" width="7" height="7" rx="1.5" stroke={color} strokeWidth={sw} fill="none" /><Rect x="3" y="14" width="7" height="7" rx="1.5" stroke={color} strokeWidth={sw} fill="none" /><Rect x="14" y="14" width="7" height="7" rx="1.5" stroke={color} strokeWidth={sw} fill="none" /></>,
    shield: <><Path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" stroke={color} strokeWidth={sw} fill="none" /><Path d="M9 12l2 2 4-4" stroke={color} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" /></>,
    home: <><Path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" stroke={color} strokeWidth={sw} fill="none" /><Path d="M9 22V12h6v10" stroke={color} strokeWidth={sw} /></>,
    bookmark: <><Path d="M19 21l-7-5-7 5V5a2 2 0 012-2h10a2 2 0 012 2v16z" stroke={color} strokeWidth={sw} fill="none" /></>,
    wallet: <><Rect x="2" y="5" width="20" height="16" rx="2" stroke={color} strokeWidth={sw} fill="none" /><Path d="M2 10h20" stroke={color} strokeWidth={sw} /><Circle cx="17" cy="15" r="1.5" fill={color} /></>,
    user: <><Circle cx="12" cy="8" r="4" stroke={color} strokeWidth={sw} fill="none" /><Path d="M20 21a8 8 0 10-16 0" stroke={color} strokeWidth={sw} fill="none" strokeLinecap="round" /></>,
    right: <Path d="M9 5l7 7-7 7" stroke={color} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" fill="none" />,
    plus: <><Line x1="12" y1="5" x2="12" y2="19" stroke={color} strokeWidth={sw} strokeLinecap="round" /><Line x1="5" y1="12" x2="19" y2="12" stroke={color} strokeWidth={sw} strokeLinecap="round" /></>,
    car: <><Path d="M7 17h10M7 17l1.5-6h7l1.5 6" stroke={color} strokeWidth={sw} strokeLinecap="round" fill="none" /><Path d="M9.5 11l.5-3h4l.5 3" stroke={color} strokeWidth={sw} strokeLinecap="round" fill="none" /><Circle cx="9" cy="17" r="1" fill={color} /><Circle cx="15" cy="17" r="1" fill={color} /></>,
  };
  return <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">{d[name]}</Svg>;
};

// ── MAIN ──
export default function ParkinDashboard() {
  const [tab, setTab] = useState('Home');
  const [hasVehicle, setHasVehicle] = useState(false);
  const [plate, setPlate] = useState('MH12 AB 1234');

  const services = [
    { label: 'Find\nParking', icon: 'pin', bg: '#e0f7fa', fg: '#00838f' },
    { label: 'Pre-Book\nSlot', icon: 'calendar', bg: '#e8f5e9', fg: '#2e7d32' },
    { label: 'Challan\nCheck', icon: 'doc', bg: '#fff3e0', fg: '#e65100' },
    { label: 'Parking\nHistory', icon: 'clock', bg: '#ede7f6', fg: '#5e35b1' },
    { label: 'EV\nCharging', icon: 'bolt', bg: '#e3f2fd', fg: '#1565c0' },
    { label: 'Valet\nService', icon: 'key', bg: '#fce4ec', fg: '#c62828' },
    { label: 'Offers &\nDeals', icon: 'tag', bg: '#fff8e1', fg: '#f9a825' },
    { label: 'View\nAll', icon: 'grid', bg: '#f3f4f6', fg: '#374151' },
  ];

  const cyclePlate = () => {
    const all = ['MH12 AB 1234', 'DL3C CY 9988', 'KA51 MB 4567'];
    setPlate(all[(all.indexOf(plate) + 1) % all.length]);
  };

  const navItems = [
    { n: 'Home', i: 'home' },
    { n: 'Bookings', i: 'bookmark' },
    { n: 'Wallet', i: 'wallet' },
    { n: 'Profile', i: 'user' },
  ];

  return (
    <View style={st.root}>
      <StatusBar barStyle="dark-content" backgroundColor={HEADER_BG} />
      <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={{ paddingBottom: 90 }} bounces={false}>

        {/* ═══════════════════════════════════════════════
            LIGHT HEADER ZONE
        ═══════════════════════════════════════════════ */}
        <View style={st.headerZone}>
          {/* Top row */}
          <View style={st.topRow}>
            <View style={st.topLeft}>
              <TouchableOpacity style={st.profileCircle}>
                <I name="profile" size={18} color="#475569" />
              </TouchableOpacity>
              <View style={st.logoBadge}>
                <Logo />
              </View>
              <View>
                <Text style={st.brand}>Parkin<Text style={{ color: ACCENT }}>Today</Text></Text>
                <Text style={st.brandSub}>Smart Parking</Text>
              </View>
            </View>
            <View style={st.topRight}>
              <TouchableOpacity style={st.headerIcon}>
                <I name="search" size={18} color="#475569" />
              </TouchableOpacity>
              <TouchableOpacity style={st.headerIcon}>
                <View style={st.redDot} />
                <I name="bell" size={18} color="#475569" />
              </TouchableOpacity>
            </View>
          </View>

          {/* Vehicle banner */}
          <View style={st.vehicleBanner}>
            <View style={st.vbTopRow}>
              <View style={st.vbDot} />
              <Text style={st.vbTitle}>ADD YOUR VEHICLE</Text>
              <View style={st.vbDot} />
            </View>
            <Text style={st.vbSub}>Unlock <Text style={{ color: ACCENT, fontWeight: '700' }}>smart parking</Text> & save up to 50%</Text>

            {hasVehicle && (
              <TouchableOpacity onPress={cyclePlate} style={st.plateChip}>
                <I name="car" size={16} color={ACCENT} />
                <Text style={st.plateChipText}>{plate}</Text>
                <I name="right" size={14} color={TEXT2} />
              </TouchableOpacity>
            )}

            <TouchableOpacity style={st.addBtn} onPress={() => setHasVehicle(true)}>
              <I name="plus" size={14} color={ACCENT} />
              <Text style={st.addBtnText}>{hasVehicle ? 'Add Another' : 'Add Vehicle'}</Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* ═══════════════════════════════════════════════
            SERVICES GRID
        ═══════════════════════════════════════════════ */}
        <View style={st.servicesWrap}>
          <Text style={st.secTitle}>Smart Services</Text>
          <View style={st.gridCard}>
            {services.map((s, i) => (
              <TouchableOpacity key={i} style={st.gridItem} activeOpacity={0.7}>
                <View style={[st.gridIcon, { backgroundColor: s.bg }]}>
                  <I name={s.icon} size={22} color={s.fg} sw={1.7} />
                </View>
                <Text style={st.gridLabel}>{s.label}</Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>

        {/* ═══════════════════════════════════════════════
            PROMOTIONAL BANNERS
        ═══════════════════════════════════════════════ */}
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={{ paddingHorizontal: 16, paddingTop: 4 }}>
          <View style={[st.promo, { backgroundColor: DARK }]}>  
            <View style={{ flex: 1 }}>
              <Text style={st.promoTag}>LIMITED OFFER</Text>
              <Text style={st.promoTitle}>First Parking{'\n'}Session FREE</Text>
              <TouchableOpacity style={st.promoCta}>
                <Text style={st.promoCtaText}>Claim Now →</Text>
              </TouchableOpacity>
            </View>
            <View style={[st.promoCircle, { backgroundColor: 'rgba(0,180,216,0.12)' }]}>
              <I name="pin" size={34} color={ACCENT} sw={1.5} />
            </View>
          </View>

          <View style={[st.promo, { backgroundColor: '#1a2744' }]}>  
            <View style={{ flex: 1 }}>
              <Text style={st.promoTag}>INVITE FRIENDS</Text>
              <Text style={st.promoTitle}>Refer & Earn{'\n'}₹100 Credits</Text>
              <TouchableOpacity style={st.promoCta}>
                <Text style={st.promoCtaText}>Share Now →</Text>
              </TouchableOpacity>
            </View>
            <View style={[st.promoCircle, { backgroundColor: 'rgba(16,185,129,0.12)' }]}>
              <I name="tag" size={34} color="#10b981" sw={1.5} />
            </View>
          </View>

          <View style={[st.promo, { backgroundColor: '#2d1b4e', marginRight: 20 }]}>  
            <View style={{ flex: 1 }}>
              <Text style={st.promoTag}>PREMIUM</Text>
              <Text style={st.promoTitle}>Insurance{'\n'}Cover Plans</Text>
              <TouchableOpacity style={st.promoCta}>
                <Text style={st.promoCtaText}>Explore →</Text>
              </TouchableOpacity>
            </View>
            <View style={[st.promoCircle, { backgroundColor: 'rgba(168,85,247,0.12)' }]}>
              <I name="shield" size={34} color="#a855f7" sw={1.5} />
            </View>
          </View>
        </ScrollView>
        <View style={st.dots}>
          <View style={[st.dot, st.dotActive]} />
          <View style={st.dot} />
          <View style={st.dot} />
        </View>

        {/* ═══════════════════════════════════════════════
            QUICK ACTIONS
        ═══════════════════════════════════════════════ */}
        <View style={{ paddingHorizontal: 16, marginTop: 20 }}>
          <Text style={st.secTitle2}>Quick Actions</Text>

          <TouchableOpacity style={st.qCard} activeOpacity={0.7}>
            <View style={[st.qIconBox, { backgroundColor: '#e0f7fa' }]}>
              <I name="pin" size={20} color="#00838f" />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={st.qTitle}>Find Nearby Parking</Text>
              <Text style={st.qSub}>3 spots available within 500m</Text>
            </View>
            <I name="right" size={16} color={TEXT3} />
          </TouchableOpacity>

          <TouchableOpacity style={st.qCard} activeOpacity={0.7}>
            <View style={[st.qIconBox, { backgroundColor: '#e3f2fd' }]}>
              <I name="bolt" size={20} color="#1565c0" />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={st.qTitle}>EV Charging Stations</Text>
              <Text style={st.qSub}>2 stations within 1 km</Text>
            </View>
            <I name="right" size={16} color={TEXT3} />
          </TouchableOpacity>
        </View>

        {/* ═══════════════════════════════════════════════
            COMMUNITY
        ═══════════════════════════════════════════════ */}
        <View style={{ paddingHorizontal: 16, marginTop: 24 }}>
          <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
            <Text style={st.secTitle2}>Latest on Community</Text>
            <TouchableOpacity><Text style={st.viewAll}>View All  ›</Text></TouchableOpacity>
          </View>

          <TouchableOpacity style={st.commCard}>
            <View style={st.commEmoji}><Text style={{ fontSize: 18 }}>💡</Text></View>
            <View style={{ flex: 1 }}>
              <Text style={st.commTitle}>5 tips to save on daily parking</Text>
              <Text style={st.commMeta}>2.4k readers  •  3 min read</Text>
            </View>
            <TouchableOpacity style={st.commBtn}><Text style={st.commBtnText}>See now</Text></TouchableOpacity>
          </TouchableOpacity>

          <TouchableOpacity style={st.commCard}>
            <View style={st.commEmoji}><Text style={{ fontSize: 18 }}>🚗</Text></View>
            <View style={{ flex: 1 }}>
              <Text style={st.commTitle}>New car plans? 5 lakh+ real reviews</Text>
              <Text style={st.commMeta}>1.8k readers  •  2 min read</Text>
            </View>
            <TouchableOpacity style={st.commBtn}><Text style={st.commBtnText}>See now</Text></TouchableOpacity>
          </TouchableOpacity>
        </View>

      </ScrollView>

      {/* ═══════════════════════════════════════════════
          BOTTOM NAV
      ═══════════════════════════════════════════════ */}
      <View style={st.nav}>
        {navItems.map(({ n, i: icon }) => {
          const active = tab === n;
          return (
            <TouchableOpacity key={n} style={st.navItem} onPress={() => setTab(n)}>
              {active && <View style={st.navBar} />}
              <I name={icon} size={21} color={active ? ACCENT : TEXT3} sw={active ? 2.2 : 1.7} />
              <Text style={[st.navText, active && st.navTextActive]}>{n}</Text>
            </TouchableOpacity>
          );
        })}
      </View>
    </View>
  );
}

// ── STYLES ──
const st = StyleSheet.create({
  root: { flex: 1, backgroundColor: BG },

  // ── Header zone (light top) ──
  headerZone: {
    backgroundColor: HEADER_BG,
    paddingBottom: 20,
    borderBottomLeftRadius: 24,
    borderBottomRightRadius: 24,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(0,180,216,0.1)',
  },
  topRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingTop: 10,
    paddingBottom: 14,
  },
  topLeft: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  profileCircle: {
    width: 36,
    height: 36,
    borderRadius: 18,
    borderWidth: 1,
    borderColor: 'rgba(0,180,216,0.15)',
    backgroundColor: '#ffffff',
    alignItems: 'center',
    justifyContent: 'center',
  },
  logoBadge: {
    borderRadius: 10,
    overflow: 'hidden',
    borderWidth: 1.5,
    borderColor: 'rgba(0,180,216,0.4)',
  },
  brand: { fontSize: 17, fontWeight: '700', color: '#0f172a', letterSpacing: -0.3 },
  brandSub: { fontSize: 10, color: '#64748b', fontWeight: '500', marginTop: 1 },
  topRight: { flexDirection: 'row', gap: 4 },
  headerIcon: {
    width: 36,
    height: 36,
    borderRadius: 18,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#ffffff',
    borderWidth: 1,
    borderColor: 'rgba(0,180,216,0.15)',
  },
  redDot: {
    position: 'absolute', top: 7, right: 8, width: 7, height: 7,
    borderRadius: 4, backgroundColor: '#ef4444', zIndex: 1,
    borderWidth: 1.5, borderColor: '#ffffff',
  },

  // ── Vehicle banner ──
  vehicleBanner: {
    marginHorizontal: 16,
    backgroundColor: '#ffffff',
    borderRadius: 16,
    borderWidth: 1,
    borderColor: 'rgba(0,180,216,0.15)',
    overflow: 'hidden',
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.05,
    shadowRadius: 10,
  },
  vbTopRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 10,
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderBottomColor: '#f1f5f9',
  },
  vbDot: { width: 5, height: 5, borderRadius: 3, backgroundColor: ACCENT },
  vbTitle: { color: '#475569', fontSize: 11, fontWeight: '700', letterSpacing: 2.5 },
  vbSub: { textAlign: 'center', color: '#475569', fontSize: 12, paddingTop: 12, paddingHorizontal: 16 },
  plateChip: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    marginHorizontal: 20,
    marginTop: 10,
    paddingVertical: 9,
    backgroundColor: '#ecfeff',
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#bae6fd',
  },
  plateChipText: { fontSize: 13, fontWeight: '800', fontFamily: 'monospace', color: '#0f172a', letterSpacing: 1.5 },
  addBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 6,
    marginHorizontal: 20,
    marginTop: 10,
    marginBottom: 14,
    paddingVertical: 11,
    borderRadius: 10,
    borderWidth: 1.5,
    borderColor: 'rgba(0,180,216,0.4)',
    borderStyle: 'dashed',
    backgroundColor: 'rgba(0,180,216,0.02)',
  },
  addBtnText: { fontSize: 13, fontWeight: '600', color: ACCENT },

  // ── Services ──
  servicesWrap: { marginTop: 20, paddingHorizontal: 16 },
  secTitle: { fontSize: 16, fontWeight: '700', color: TEXT1, marginBottom: 12, paddingHorizontal: 4 },
  gridCard: {
    backgroundColor: CARD,
    borderRadius: 18,
    paddingVertical: 18,
    paddingHorizontal: 4,
    flexDirection: 'row',
    flexWrap: 'wrap',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 8,
  },
  gridItem: { width: '25%', alignItems: 'center', marginBottom: 14 },
  gridIcon: {
    width: 50,
    height: 50,
    borderRadius: 15,
    alignItems: 'center',
    justifyContent: 'center',
  },
  gridLabel: { fontSize: 10.5, fontWeight: '600', color: TEXT1, textAlign: 'center', marginTop: 7, lineHeight: 14 },

  // ── Promos ──
  promo: {
    width: width * 0.76,
    borderRadius: 16,
    padding: 18,
    marginRight: 12,
    flexDirection: 'row',
    alignItems: 'center',
    height: 140,
  },
  promoTag: { fontSize: 9, fontWeight: '800', color: ACCENT, letterSpacing: 1.5, marginBottom: 6 },
  promoTitle: { color: '#fff', fontSize: 17, fontWeight: '800', lineHeight: 23 },
  promoCta: {
    marginTop: 10,
    backgroundColor: '#fff',
    paddingHorizontal: 14,
    paddingVertical: 7,
    borderRadius: 20,
    alignSelf: 'flex-start',
  },
  promoCtaText: { fontSize: 11, fontWeight: '700', color: TEXT1 },
  promoCircle: {
    width: 68,
    height: 68,
    borderRadius: 34,
    alignItems: 'center',
    justifyContent: 'center',
    marginLeft: 8,
  },
  dots: { flexDirection: 'row', justifyContent: 'center', gap: 5, marginTop: 14 },
  dot: { width: 7, height: 7, borderRadius: 4, backgroundColor: '#d1d5db' },
  dotActive: { backgroundColor: DARK, width: 18, borderRadius: 4 },

  // ── Quick Actions ──
  secTitle2: { fontSize: 15, fontWeight: '700', color: TEXT1, marginBottom: 12 },
  qCard: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    backgroundColor: CARD,
    borderRadius: 14,
    padding: 14,
    marginBottom: 10,
    elevation: 1,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.04,
    shadowRadius: 4,
  },
  qIconBox: { width: 42, height: 42, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  qTitle: { fontSize: 13, fontWeight: '600', color: TEXT1 },
  qSub: { fontSize: 11, color: TEXT2, marginTop: 2 },
  viewAll: { fontSize: 12, fontWeight: '600', color: ACCENT },

  // ── Community ──
  commCard: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    backgroundColor: CARD,
    borderRadius: 14,
    padding: 13,
    marginBottom: 10,
    elevation: 1,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.04,
    shadowRadius: 4,
  },
  commEmoji: { width: 38, height: 38, borderRadius: 19, backgroundColor: '#f3f4f6', alignItems: 'center', justifyContent: 'center' },
  commTitle: { fontSize: 12.5, fontWeight: '600', color: TEXT1, lineHeight: 17 },
  commMeta: { fontSize: 10.5, color: TEXT3, marginTop: 3 },
  commBtn: { backgroundColor: '#f3f4f6', paddingHorizontal: 12, paddingVertical: 6, borderRadius: 8 },
  commBtnText: { fontSize: 11, fontWeight: '700', color: TEXT1 },

  // ── Bottom Nav ──
  nav: {
    position: 'absolute',
    bottom: 0, left: 0, right: 0,
    flexDirection: 'row',
    backgroundColor: CARD,
    borderTopWidth: 1,
    borderTopColor: '#e5e7eb',
    paddingTop: 6,
    paddingBottom: 18,
    elevation: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -3 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
  },
  navItem: { flex: 1, alignItems: 'center', paddingVertical: 4, position: 'relative' },
  navBar: { position: 'absolute', top: -1, left: 16, right: 16, height: 3, backgroundColor: ACCENT, borderRadius: 2 },
  navText: { fontSize: 10, fontWeight: '600', color: TEXT3, marginTop: 4 },
  navTextActive: { color: ACCENT, fontWeight: '700' },
});
