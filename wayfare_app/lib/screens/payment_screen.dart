import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/booking_service.dart';
import 'receipt_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  const PaymentScreen({super.key, required this.bookingId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  Map<String, dynamic>? _booking;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId).get();
      setState(() {
        _booking = doc.data();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load booking: $e';
        _loading = false;
      });
    }
  }

  void _openCheckout() {
    final user = FirebaseAuth.instance.currentUser;
    if (_booking == null) return;
    final amountPaise = (_booking!['totalAmountPaise'] ?? 0) as int;

    final options = {
      'key': 'rzp_test_1234567890abcdef', // TODO: replace with your Key ID
      'amount': amountPaise, // paise
      'currency': 'INR',
      'name': 'Wayfare Rentals',
      'description': 'Car booking payment',
      'prefill': {
        'contact': user?.phoneNumber ?? '',
        'email': user?.email ?? '',
        'name': user?.displayName ?? '',
      },
      // Let user choose UPI app via Razorpay Checkout (supports intent/opening apps)
      'theme': {'color': '#1565C0'},
    };

    _razorpay.open(options);
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await BookingService().markPaymentSuccess(
        bookingId: widget.bookingId,
        paymentId: response.paymentId ?? '',
        orderId: response.orderId,
        signature: response.signature,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptScreen(bookingId: widget.bookingId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to record payment: $e')),
      );
    }
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    try {
      await BookingService().markPaymentFailed(
        bookingId: widget.bookingId,
        reason: response.message ?? 'Payment failed',
      );
    } catch (_) {}
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.code}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Not used, but required to avoid leaks
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (_booking!['carName'] ?? _booking!['carModel'] ?? 'Car'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text('Amount: ₹${((_booking!['totalAmountPaise'] ?? 0) as int) / 100}'),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openCheckout,
                          icon: const Icon(Icons.payment),
                          label: const Text('Pay with UPI (Razorpay)'),
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}


