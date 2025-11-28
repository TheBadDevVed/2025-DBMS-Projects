import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/booking_service.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final String carId;
  final String carName;
  final String carModel;
  final String ownerId;
  final String pricePerDay; // stored as string in cars

  const BookingScreen({
    super.key,
    required this.carId,
    required this.carName,
    required this.carModel,
    required this.ownerId,
    required this.pricePerDay,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _start;
  DateTime? _end;
  bool _creating = false;

  int get _dailyPrice {
    final s = widget.pricePerDay.replaceAll(RegExp(r'[^0-9]'), '');
    if (s.isEmpty) return 0;
    return int.tryParse(s) ?? 0;
  }

  int get _numDays {
    if (_start == null || _end == null) return 0;
    final d = _end!.difference(_start!).inDays;
    return d <= 0 ? 1 : d;
  }

  int get _total {
    return _dailyPrice * (_numDays == 0 ? 1 : _numDays);
  }

  String _fmt(DateTime? dt) {
    if (dt == null) return 'Select';
    return DateFormat('EEE, dd MMM yyyy').format(dt);
  }

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final res = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      initialDate: _start ?? DateTime(now.year, now.month, now.day),
    );
    if (res != null) {
      setState(() {
        _start = res;
        if (_end != null && !_end!.isAfter(_start!)) {
          _end = _start!.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _pickEnd() async {
    if (_start == null) {
      await _pickStart();
      if (_start == null) return;
    }
    final res = await showDatePicker(
      context: context,
      firstDate: _start!.add(const Duration(days: 1)),
      lastDate: DateTime(_start!.year + 2),
      initialDate: _end ?? _start!.add(const Duration(days: 1)),
    );
    if (res != null) {
      setState(() => _end = res);
    }
  }

  Future<void> _proceed() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to book.')),
      );
      return;
    }
    if (_start == null || _end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select start and end dates.')),
      );
      return;
    }
    if (_dailyPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid price for this car.')),
      );
      return;
    }

    setState(() => _creating = true);
    try {
      final service = BookingService();
      final ref = await service.createDraftBooking(
        carId: widget.carId,
        carName: widget.carName,
        carModel: widget.carModel,
        ownerId: widget.ownerId,
        startDate: _start!,
        endDate: _end!,
        dailyPrice: _dailyPrice,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            bookingId: ref.id,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create booking: $e')),
      );
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Car')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.carName.isNotEmpty ? widget.carName : widget.carModel,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Price per day: ₹$_dailyPrice'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickStart,
                    child: Text('Start: ${_fmt(_start)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickEnd,
                    child: Text('End: ${_fmt(_end)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_start != null && _end != null)
              Text('Duration: $_numDays day(s)'),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text('Total: ₹$_total',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: _creating ? null : _proceed,
                  child: _creating
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Proceed to Pay'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}


