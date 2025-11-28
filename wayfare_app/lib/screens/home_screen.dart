import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'signin_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for carousels
    final latestDeals = [
      'Deal 1: 20% off',
      'Deal 2: Weekend Special',
      'Deal 3: Free Upgrade',
    ];
    final otherDetails = [
      '24/7 Support',
      'Easy Cancellation',
      'Multiple Pickup Locations',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Rental Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Latest Deals",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 140,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.8),
                itemCount: latestDeals.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.blue[100 * (index % 9 + 1)],
                      child: Center(
                        child: Text(
                          latestDeals[index],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Other Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 120,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.7),
                itemCount: otherDetails.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.green[100 * (index % 9 + 1)],
                      child: Center(
                        child: Text(
                          otherDetails[index],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                "Welcome! Browse cars here.",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Since this is the home screen, we'll need to sign in first to book
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SignInScreen()),
          );
        },
        icon: const Icon(Icons.event_available),
        label: const Text('Book Now'),
      ),
    );
  }
}
