import 'package:flutter/material.dart';
import 'booking_screen.dart';
import 'chat_screen.dart';

class CarDetailsScreen extends StatelessWidget {
  final String carId;
  final String carName;
  final String carModel;
  final String year;
  final String price;
  final String description;
  final String ownerId;
  final String? imageUrl;

  const CarDetailsScreen({
    super.key,
    required this.carId,
    required this.carName,
    required this.carModel,
    required this.year,
    required this.price,
    required this.description,
    required this.ownerId,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Car Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(imageUrl!, fit: BoxFit.cover),
                      )
                    : Icon(Icons.directions_car, size: 72, color: Colors.blue.shade400),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              carName.isNotEmpty ? carName : carModel,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text('$carModel • $year', style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            Text(price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const Divider(height: 32),
            const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(description.isEmpty ? 'No description provided.' : description),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(ownerId: ownerId, carId: carId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Chat with Owner'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingScreen(
                            carId: carId,
                            carName: carName,
                            carModel: carModel,
                            ownerId: ownerId,
                            pricePerDay: price,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.event_available),
                    label: const Text('Book Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


