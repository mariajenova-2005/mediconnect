import '../models/extra_models.dart';

/// Simple, gateway-free payments:
///  • "Pay at Clinic" — booking is confirmed, patient pays at reception.
///  • "UPI" — opens the patient's own UPI app (upi://pay deep link) pre-filled with the clinic's UPI ID
///    and the doctor's fee. The clinic confirms receipt; the app does not auto-verify UPI payments.
/// This keeps a local payment history for the session. For automatic verification you would need a
/// payment gateway (Razorpay, Stripe, Cashfree…), which is intentionally not used here.
class PaymentService {
  PaymentService._internal();
  static final PaymentService instance = PaymentService._internal();

  final List<PaymentRecord> _history = [];
  List<PaymentRecord> get history => List.unmodifiable(_history);

  Future<PaymentRecord> pay({required double amount, required String method}) async {
    final record = PaymentRecord(id: 'pay${_history.length + 1}', amount: amount, method: method, date: DateTime.now(), success: true);
    _history.add(record);
    return record;
  }
}
