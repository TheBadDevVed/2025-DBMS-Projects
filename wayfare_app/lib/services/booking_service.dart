import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Booking {
  final String id;
  final String carId;
  final String carName;
  final String carModel;
  final String ownerId;
  final String renterId;
  final DateTime startDate;
  final DateTime endDate;
  final int dailyPrice;
  final int totalAmountPaise;
  final String status; // created, paid, failed, cancelled
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final String? razorpaySignature;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.carId,
    required this.carName,
    required this.carModel,
    required this.ownerId,
    required this.renterId,
    required this.startDate,
    required this.endDate,
    required this.dailyPrice,
    required this.totalAmountPaise,
    required this.status,
    required this.createdAt,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.razorpaySignature,
  });

  int get numDays {
    return endDate.difference(startDate).inDays.clamp(1, 3650);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'carId': carId,
      'carName': carName,
      'carModel': carModel,
      'ownerId': ownerId,
      'renterId': renterId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'dailyPrice': dailyPrice,
      'totalAmountPaise': totalAmountPaise,
      'status': status,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpayOrderId': razorpayOrderId,
      'razorpaySignature': razorpaySignature,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static Booking fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Booking(
      id: doc.id,
      carId: d['carId'] as String,
      carName: (d['carName'] ?? '') as String,
      carModel: (d['carModel'] ?? '') as String,
      ownerId: d['ownerId'] as String,
      renterId: d['renterId'] as String,
      startDate: (d['startDate'] as Timestamp).toDate(),
      endDate: (d['endDate'] as Timestamp).toDate(),
      dailyPrice: (d['dailyPrice'] ?? 0) as int,
      totalAmountPaise: (d['totalAmountPaise'] ?? 0) as int,
      status: d['status'] as String,
      razorpayPaymentId: d['razorpayPaymentId'] as String?,
      razorpayOrderId: d['razorpayOrderId'] as String?,
      razorpaySignature: d['razorpaySignature'] as String?,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }
}

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<DocumentReference<Map<String, dynamic>>> createDraftBooking({
    required String carId,
    required String carName,
    required String carModel,
    required String ownerId,
    required DateTime startDate,
    required DateTime endDate,
    required int dailyPrice,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Not signed in');
    }
    final days = endDate.difference(startDate).inDays;
    final clampedDays = days <= 0 ? 1 : days;
    final totalPaise = dailyPrice * clampedDays * 100;
    final data = Booking(
      id: '',
      carId: carId,
      carName: carName,
      carModel: carModel,
      ownerId: ownerId,
      renterId: userId,
      startDate: startDate,
      endDate: endDate,
      dailyPrice: dailyPrice,
      totalAmountPaise: totalPaise,
      status: 'created',
      createdAt: DateTime.now(),
    ).toFirestore();

    return await _db.collection('bookings').add(data);
  }

  Future<void> markPaymentSuccess({
    required String bookingId,
    required String paymentId,
    String? orderId,
    String? signature,
  }) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'paid',
      'razorpayPaymentId': paymentId,
      if (orderId != null) 'razorpayOrderId': orderId,
      if (signature != null) 'razorpaySignature': signature,
    });
    // After successful payment, mark the car as unavailable
    final booking = await _db.collection('bookings').doc(bookingId).get();
    final data = booking.data();
    final carId = data?['carId'] as String?;
    if (carId != null && carId.isNotEmpty) {
      await _db.collection('cars').doc(carId).set({
        'available': false,
      }, SetOptions(merge: true));
    }
  }

  Future<void> markPaymentFailed({
    required String bookingId,
    required String reason,
  }) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'failed',
      'failureReason': reason,
    });
  }

  Future<Booking> getBooking(String id) async {
    final doc = await _db.collection('bookings').doc(id).get();
    return Booking.fromFirestore(doc);
  }

  Future<void> markBookingCompleted(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });
    // Make the car available again
    final booking = await _db.collection('bookings').doc(bookingId).get();
    final data = booking.data();
    final carId = data?['carId'] as String?;
    if (carId != null && carId.isNotEmpty) {
      await _db.collection('cars').doc(carId).set({
        'available': true,
      }, SetOptions(merge: true));
    }
  }
}
