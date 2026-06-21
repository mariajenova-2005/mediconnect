import React, { useEffect, useState } from 'react';
import { View, Text, KeyboardAvoidingView, Platform, Pressable } from 'react-native';
import { colors, fonts } from '../theme';
import ScreenContainer from '../components/ScreenContainer';
import AppInput from '../components/AppInput';
import AppButton from '../components/AppButton';
import OtpInput from '../components/OtpInput';
import LogoBadge from '../components/LogoBadge';

type Mode = 'login' | 'register';
type Step = 'details' | 'otp';

// Fixed demo code — for the live demo, this is the code that always works.
// Swap handleSendOtp / handleVerify for real backend calls when ready.
const DEMO_OTP = '123456';

export default function LoginScreen({ navigation }: any) {
  const [mode, setMode] = useState<Mode>('login');
  const [step, setStep] = useState<Step>('details');
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [otp, setOtp] = useState<string[]>(['', '', '', '', '', '']);
  const [seconds, setSeconds] = useState(30);
  const [loading, setLoading] = useState(false);
  const [otpError, setOtpError] = useState('');

  const isRegister = mode === 'register';
  const isDetailsValid = phone.length === 10 && (!isRegister || name.trim().length > 1);
  const isOtpComplete = otp.every((d) => d.length === 1);

  useEffect(() => {
    if (step !== 'otp' || seconds === 0) return;
    const t = setTimeout(() => setSeconds((s) => s - 1), 1000);
    return () => clearTimeout(t);
  }, [step, seconds]);

  const switchMode = (next: Mode) => {
    setMode(next);
    setStep('details');
    setOtp(['', '', '', '', '', '']);
    setOtpError('');
  };

  const handleSendOtp = () => {
    setLoading(true);
    // DEMO: simulates an SMS dispatch. No real backend wired up yet —
    // the code that "arrives" is always DEMO_OTP, shown on screen below.
    setTimeout(() => {
      setLoading(false);
      setStep('otp');
      setSeconds(30);
      setOtpError('');
    }, 700);
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
      navigation.replace('Dashboard');
    }, 800);
  };

  return (
    <ScreenContainer>
      <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
        <LogoBadge size={52} style={{ marginTop: 28, marginBottom: 20 }} />

        {step === 'details' && (
          <View
            style={{
              flexDirection: 'row',
              backgroundColor: colors.hairline,
              borderRadius: 14,
              padding: 4,
              marginBottom: 28,
            }}
          >
            <ModeTab label="Log in" active={mode === 'login'} onPress={() => switchMode('login')} />
            <ModeTab label="Register" active={mode === 'register'} onPress={() => switchMode('register')} />
          </View>
        )}

        {step === 'details' ? (
          <>
            <View style={{ marginBottom: 28 }}>
              <Text style={{ fontFamily: fonts.displaySemibold, fontSize: 26, color: colors.graphite, lineHeight: 32 }}>
                {isRegister ? 'Create your account' : 'Welcome back'}
              </Text>
              <Text style={{ fontFamily: fonts.body, fontSize: 15, color: colors.mist, marginTop: 8, lineHeight: 22 }}>
                {isRegister
                  ? "Tell us your name and number — we'll text you a one-time code."
                  : "Enter your mobile number to sign in. We'll text you a one-time code."}
              </Text>
            </View>

            {isRegister && (
              <AppInput
                label="Full name"
                placeholder="e.g. Arjun Kumar"
                value={name}
                onChangeText={setName}
              />
            )}

            <AppInput
              label="Mobile number"
              prefix="+91"
              placeholder="98765 43210"
              keyboardType="number-pad"
              maxLength={10}
              value={phone}
              onChangeText={(t) => setPhone(t.replace(/[^0-9]/g, ''))}
            />

            <View style={{ flex: 1 }} />

            <AppButton
              label="Send OTP"
              disabled={!isDetailsValid}
              loading={loading}
              onPress={handleSendOtp}
            />

            <Text
              style={{
                fontFamily: fonts.body,
                fontSize: 12,
                color: colors.mist,
                textAlign: 'center',
                marginTop: 16,
                marginBottom: 8,
                lineHeight: 18,
              }}
            >
              By continuing, you agree to ParkinToday's Terms of Service and Privacy Policy.
            </Text>
          </>
        ) : (
          <>
            <View style={{ marginBottom: 24 }}>
              <Text style={{ fontFamily: fonts.displaySemibold, fontSize: 28, color: colors.graphite, lineHeight: 34 }}>
                Enter the code
              </Text>
              <Text style={{ fontFamily: fonts.body, fontSize: 15, color: colors.mist, marginTop: 8, lineHeight: 22 }}>
                We sent a 6-digit code to{' '}
                <Text style={{ fontFamily: fonts.bodySemibold, color: colors.graphite }}>+91 {phone}</Text>
              </Text>
            </View>

            {/* DEMO-ONLY banner — remove once a real SMS provider is wired in */}
            <View
              style={{
                backgroundColor: colors.inkLight,
                borderRadius: 14,
                paddingVertical: 10,
                paddingHorizontal: 14,
                marginBottom: 20,
              }}
            >
              <Text style={{ fontFamily: fonts.bodyMedium, fontSize: 12, color: colors.inkDark }}>
                Demo mode — no SMS is actually sent. Enter{' '}
                <Text style={{ fontFamily: fonts.mono }}>{DEMO_OTP}</Text> to continue.
              </Text>
            </View>

            <OtpInput
              value={otp}
              onChange={(next) => {
                setOtp(next);
                if (otpError) setOtpError('');
              }}
            />

            {otpError ? (
              <Text style={{ fontFamily: fonts.body, fontSize: 12, color: colors.full, marginTop: 10 }}>
                {otpError}
              </Text>
            ) : null}

            <View style={{ marginTop: 24, flexDirection: 'row', justifyContent: 'center' }}>
              {seconds > 0 ? (
                <Text style={{ fontFamily: fonts.body, fontSize: 13, color: colors.mist }}>
                  Resend code in{' '}
                  <Text style={{ fontFamily: fonts.mono, color: colors.graphite }}>
                    0:{seconds < 10 ? `0${seconds}` : seconds}
                  </Text>
                </Text>
              ) : (
                <Pressable onPress={() => setSeconds(30)}>
                  <Text style={{ fontFamily: fonts.bodySemibold, fontSize: 13, color: colors.ink }}>
                    Resend code
                  </Text>
                </Pressable>
              )}
            </View>

            <View style={{ flex: 1 }} />

            <AppButton label="Verify & continue" disabled={!isOtpComplete} loading={loading} onPress={handleVerify} />

            <Pressable onPress={() => setStep('details')} style={{ marginTop: 16, alignSelf: 'center' }}>
              <Text style={{ fontFamily: fonts.bodyMedium, fontSize: 13, color: colors.mist }}>
                {isRegister ? 'Edit details' : 'Change number'}
              </Text>
            </Pressable>
          </>
        )}
      </KeyboardAvoidingView>
    </ScreenContainer>
  );
}

function ModeTab({ label, active, onPress }: { label: string; active: boolean; onPress: () => void }) {
  return (
    <Pressable
      onPress={onPress}
      style={{
        flex: 1,
        paddingVertical: 10,
        borderRadius: 10,
        alignItems: 'center',
        backgroundColor: active ? colors.white : 'transparent',
      }}
    >
      <Text
        style={{
          fontFamily: fonts.bodySemibold,
          fontSize: 14,
          color: active ? colors.graphite : colors.mist,
        }}
      >
        {label}
      </Text>
    </Pressable>
  );
}
