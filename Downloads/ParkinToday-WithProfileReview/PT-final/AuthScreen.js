import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  StatusBar,
  Image,
  KeyboardAvoidingView,
  Platform,
  Animated,
} from 'react-native';

// ── PALETTE — matches ParkinDashboard.js exactly ──
const ACCENT = '#00b4d8';
const ACCENT_DARK = '#008da6';
const NAVY = '#0a1628';
const BG = '#eef2f5';
const CARD = '#ffffff';
const TEXT1 = '#111827';
const TEXT2 = '#6b7280';
const TEXT3 = '#9ca3af';
const BORDER = '#e2e5ea';
const DANGER = '#dc2626';

// Demo-only fixed code — no real SMS provider is wired up.
// Swap handleSendOtp / handleVerify for real backend calls when ready.
const DEMO_OTP = '123456';

const Logo = ({ size = 52 }) => (
  <View style={[st.logoOuter, { width: size, height: size, borderRadius: size * 0.3 }]}>
    <Image
      source={require('./logo.jpg')}
      style={{ width: size, height: size, borderRadius: size * 0.3 }}
      resizeMode="cover"
    />
  </View>
);

export default function AuthScreen({ onAuthenticated }) {
  const [mode, setMode] = useState('login'); // 'login' | 'register'
  const [step, setStep] = useState('details'); // 'details' | 'otp'
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [otp, setOtp] = useState(['', '', '', '', '', '']);
  const [seconds, setSeconds] = useState(30);
  const [loading, setLoading] = useState(false);
  const [otpError, setOtpError] = useState('');
  const otpRefs = useRef([]);

  const isRegister = mode === 'register';
  const isDetailsValid = phone.length === 10 && (!isRegister || name.trim().length > 1);
  const isOtpComplete = otp.every((d) => d.length === 1);

  useEffect(() => {
    if (step !== 'otp' || seconds === 0) return;
    const t = setTimeout(() => setSeconds((s) => s - 1), 1000);
    return () => clearTimeout(t);
  }, [step, seconds]);

  const switchMode = (next) => {
    setMode(next);
    setStep('details');
    setOtp(['', '', '', '', '', '']);
    setOtpError('');
  };

  const handleSendOtp = () => {
    setLoading(true);
    // DEMO: simulates an SMS dispatch — no backend connected yet.
    setTimeout(() => {
      setLoading(false);
      setStep('otp');
      setSeconds(30);
      setOtpError('');
      setOtp(['', '', '', '', '', '']);
    }, 700);
  };

  const handleOtpChange = (text, index) => {
    const digit = text.replace(/[^0-9]/g, '').slice(-1);
    const next = [...otp];
    next[index] = digit;
    setOtp(next);
    if (otpError) setOtpError('');
    if (digit && index < 5) otpRefs.current[index + 1]?.focus();
  };

  const handleOtpKeyPress = (key, index) => {
    if (key === 'Backspace' && !otp[index] && index > 0) {
      otpRefs.current[index - 1]?.focus();
    }
  };

  const handleVerify = () => {
    const entered = otp.join('');
    if (entered !== DEMO_OTP) {
      setOtpError('Incorrect code. Use the demo code shown below.');
      return;
    }
    setOtpError('');
    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      onAuthenticated();
    }, 700);
  };

  return (
    <KeyboardAvoidingView
      style={st.root}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <StatusBar barStyle="dark-content" backgroundColor={BG} />

      <View style={st.content}>
        <Logo size={56} />

        {step === 'details' && (
          <View style={st.tabSwitch}>
            <TouchableOpacity
              style={[st.tab, mode === 'login' && st.tabActive]}
              onPress={() => switchMode('login')}
            >
              <Text style={[st.tabText, mode === 'login' && st.tabTextActive]}>Log in</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[st.tab, mode === 'register' && st.tabActive]}
              onPress={() => switchMode('register')}
            >
              <Text style={[st.tabText, mode === 'register' && st.tabTextActive]}>Register</Text>
            </TouchableOpacity>
          </View>
        )}

        {step === 'details' ? (
          <>
            <Text style={st.title}>{isRegister ? 'Create your account' : 'Welcome back'}</Text>
            <Text style={st.subtitle}>
              {isRegister
                ? "Tell us your name and number — we'll text you a one-time code."
                : "Enter your mobile number to sign in. We'll text you a one-time code."}
            </Text>

            {isRegister && (
              <View style={st.field}>
                <Text style={st.label}>Full name</Text>
                <TextInput
                  style={st.input}
                  placeholder="e.g. Arjun Kumar"
                  placeholderTextColor={TEXT3}
                  value={name}
                  onChangeText={setName}
                />
              </View>
            )}

            <View style={st.field}>
              <Text style={st.label}>Mobile number</Text>
              <View style={st.phoneRow}>
                <Text style={st.prefix}>+91</Text>
                <TextInput
                  style={st.phoneInput}
                  placeholder="98765 43210"
                  placeholderTextColor={TEXT3}
                  keyboardType="number-pad"
                  maxLength={10}
                  value={phone}
                  onChangeText={(t) => setPhone(t.replace(/[^0-9]/g, ''))}
                />
              </View>
            </View>

            <View style={{ flex: 1 }} />

            <TouchableOpacity
              style={[st.button, !isDetailsValid && st.buttonDisabled]}
              disabled={!isDetailsValid || loading}
              onPress={handleSendOtp}
            >
              <Text style={st.buttonText}>{loading ? 'Sending…' : 'Send OTP'}</Text>
            </TouchableOpacity>

            <Text style={st.terms}>
              By continuing, you agree to ParkinToday's Terms of Service and Privacy Policy.
            </Text>
          </>
        ) : (
          <>
            <Text style={st.title}>Enter the code</Text>
            <Text style={st.subtitle}>
              We sent a 6-digit code to{' '}
              <Text style={{ fontWeight: '700', color: TEXT1 }}>+91 {phone}</Text>
            </Text>

            <View style={st.demoBanner}>
              <Text style={st.demoBannerText}>
                Demo mode — no SMS is actually sent. Enter{' '}
                <Text style={{ fontFamily: 'monospace', fontWeight: '800' }}>{DEMO_OTP}</Text> to
                continue.
              </Text>
            </View>

            <View style={st.otpRow}>
              {otp.map((digit, i) => (
                <TextInput
                  key={i}
                  ref={(r) => (otpRefs.current[i] = r)}
                  style={[st.otpBox, digit ? st.otpBoxFilled : null]}
                  value={digit}
                  onChangeText={(t) => handleOtpChange(t, i)}
                  onKeyPress={({ nativeEvent }) => handleOtpKeyPress(nativeEvent.key, i)}
                  keyboardType="number-pad"
                  maxLength={1}
                />
              ))}
            </View>

            {otpError ? <Text style={st.errorText}>{otpError}</Text> : null}

            <View style={st.resendRow}>
              {seconds > 0 ? (
                <Text style={st.resendText}>
                  Resend code in{' '}
                  <Text style={{ fontFamily: 'monospace', color: TEXT1 }}>
                    0:{seconds < 10 ? `0${seconds}` : seconds}
                  </Text>
                </Text>
              ) : (
                <TouchableOpacity onPress={() => setSeconds(30)}>
                  <Text style={st.resendLink}>Resend code</Text>
                </TouchableOpacity>
              )}
            </View>

            <View style={{ flex: 1 }} />

            <TouchableOpacity
              style={[st.button, !isOtpComplete && st.buttonDisabled]}
              disabled={!isOtpComplete || loading}
              onPress={handleVerify}
            >
              <Text style={st.buttonText}>{loading ? 'Verifying…' : 'Verify & continue'}</Text>
            </TouchableOpacity>

            <TouchableOpacity style={st.changeLink} onPress={() => setStep('details')}>
              <Text style={st.changeLinkText}>{isRegister ? 'Edit details' : 'Change number'}</Text>
            </TouchableOpacity>
          </>
        )}
      </View>
    </KeyboardAvoidingView>
  );
}

const st = StyleSheet.create({
  root: { flex: 1, backgroundColor: BG },
  content: { flex: 1, paddingHorizontal: 24, paddingTop: 36, paddingBottom: 24 },

  logoOuter: {
    overflow: 'hidden',
    borderWidth: 2,
    borderColor: 'rgba(0,180,216,0.3)',
    marginBottom: 24,
  },

  tabSwitch: {
    flexDirection: 'row',
    backgroundColor: '#e5e9ec',
    borderRadius: 14,
    padding: 4,
    marginBottom: 28,
  },
  tab: { flex: 1, paddingVertical: 10, borderRadius: 10, alignItems: 'center' },
  tabActive: {
    backgroundColor: CARD,
    elevation: 1,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.06,
    shadowRadius: 3,
  },
  tabText: { fontSize: 14, fontWeight: '700', color: TEXT2 },
  tabTextActive: { color: TEXT1 },

  title: { fontSize: 26, fontWeight: '800', color: TEXT1, lineHeight: 32 },
  subtitle: { fontSize: 14.5, color: TEXT2, marginTop: 8, lineHeight: 21, marginBottom: 26 },

  field: { marginBottom: 18 },
  label: { fontSize: 13, fontWeight: '700', color: TEXT2, marginBottom: 8 },
  input: {
    height: 54,
    borderRadius: 14,
    borderWidth: 1.5,
    borderColor: BORDER,
    backgroundColor: CARD,
    paddingHorizontal: 16,
    fontSize: 15,
    color: TEXT1,
  },
  phoneRow: {
    flexDirection: 'row',
    alignItems: 'center',
    height: 54,
    borderRadius: 14,
    borderWidth: 1.5,
    borderColor: BORDER,
    backgroundColor: CARD,
    paddingHorizontal: 16,
  },
  prefix: { fontSize: 15, fontWeight: '700', color: TEXT1, marginRight: 8 },
  phoneInput: { flex: 1, fontSize: 15, color: TEXT1 },

  button: {
    height: 54,
    borderRadius: 16,
    backgroundColor: ACCENT,
    alignItems: 'center',
    justifyContent: 'center',
  },
  buttonDisabled: { backgroundColor: '#a8d8e3' },
  buttonText: { color: '#ffffff', fontSize: 15.5, fontWeight: '700' },

  terms: {
    fontSize: 11.5,
    color: TEXT3,
    textAlign: 'center',
    marginTop: 16,
    lineHeight: 17,
  },

  demoBanner: {
    backgroundColor: '#ecfeff',
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#bae6fd',
    paddingVertical: 10,
    paddingHorizontal: 14,
    marginBottom: 22,
  },
  demoBannerText: { fontSize: 12, color: ACCENT_DARK, lineHeight: 17 },

  otpRow: { flexDirection: 'row', justifyContent: 'space-between' },
  otpBox: {
    width: 46,
    height: 56,
    borderRadius: 14,
    borderWidth: 1.5,
    borderColor: BORDER,
    backgroundColor: CARD,
    textAlign: 'center',
    fontSize: 20,
    fontWeight: '700',
    color: TEXT1,
  },
  otpBoxFilled: { borderColor: ACCENT },

  errorText: { fontSize: 12.5, color: DANGER, marginTop: 10, fontWeight: '600' },

  resendRow: { marginTop: 22, flexDirection: 'row', justifyContent: 'center' },
  resendText: { fontSize: 13, color: TEXT2 },
  resendLink: { fontSize: 13, fontWeight: '700', color: ACCENT },

  changeLink: { marginTop: 16, alignSelf: 'center' },
  changeLinkText: { fontSize: 13, fontWeight: '600', color: TEXT2 },
});
