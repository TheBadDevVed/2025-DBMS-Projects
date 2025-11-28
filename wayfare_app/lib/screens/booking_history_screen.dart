import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'booking_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active Bookings'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _BookingsList(isActive: true),
          _BookingsList(isActive: false),
        ],
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final bool isActive;

  const _BookingsList({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text('Please sign in to view bookings'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .where(
            'status',
            whereIn: isActive ? ['draft', 'confirmed', 'paid'] : ['completed'],
          )
          .orderBy('startDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final bookings = snapshot.data!.docs;
        if (bookings.isEmpty) {
          return Center(
            child: Text(
              isActive ? 'No active bookings' : 'No completed bookings',
            ),
          );
        }

        return ListView.builder(
          itemCount: bookings.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final booking = bookings[index].data() as Map<String, dynamic>;
            final startDate = (booking['startDate'] as Timestamp).toDate();
            final endDate = (booking['endDate'] as Timestamp).toDate();
            final carName = booking['carName'] ?? booking['carModel'] ?? 'Car';
            final status = booking['status'] as String;
            final carId = booking['carId'] as String;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      carName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'From: ${DateFormat('MMM dd, yyyy').format(startDate)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'To: ${DateFormat('MMM dd, yyyy').format(endDate)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status: ${status[0].toUpperCase() + status.substring(1)}',
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (!isActive)
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookingScreen(
                                    carId: carId,
                                    carName: carName,
                                    carModel:
                                        carName, // Using carName as model since we don't have model in this context
                                    ownerId: booking['ownerId'] as String,
                                    pricePerDay: (booking['dailyPrice'] ?? 0)
                                        .toString(),
                                  ),
                                ),
                              );
                            },
                            child: const Text('Book Again'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'paid':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}
