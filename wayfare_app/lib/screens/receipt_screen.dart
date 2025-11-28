import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReceiptScreen extends StatelessWidget {
  final String bookingId;
  const ReceiptScreen({super.key, required this.bookingId});

  String _fmtDate(Timestamp ts) => DateFormat('dd MMM yyyy').format(ts.toDate());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Receipt')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('bookings').doc(bookingId).get(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('Receipt not found.'));
          }
          final d = snap.data!.data()!;
          final carName = (d['carName'] ?? d['carModel'] ?? 'Car') as String;
          final startTs = d['startDate'] as Timestamp;
          final endTs = d['endDate'] as Timestamp;
          final totalPaise = (d['totalAmountPaise'] ?? 0) as int;
          final totalInr = (totalPaise / 100).toStringAsFixed(2);
          final paymentId = (d['razorpayPaymentId'] ?? '-') as String;
          final status = (d['status'] ?? '-') as String;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wayfare Rentals', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Receipt #: $bookingId', style: const TextStyle(color: Colors.grey)),
                const Divider(height: 24),
                const Text('Booking Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Car: $carName'),
                Text('From: ${_fmtDate(startTs)}'),
                Text('To:   ${_fmtDate(endTs)}'),
                const SizedBox(height: 16),
                const Text('Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Amount: ₹$totalInr'),
                Text('Status: $status'),
                Text('Razorpay Payment ID: $paymentId'),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sharing receipt coming soon.')),
                      );
                    },
                    icon: const Icon(Icons.ios_share),
                    label: const Text('Share/Download Receipt'),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}


