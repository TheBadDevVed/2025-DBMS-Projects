import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/car_provider.dart';
import 'car_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Sign in to view favorites.')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('favorites')
            .snapshots(),
        builder: (context, snapshot) {
          final favIds = (snapshot.data?.docs ?? []).map((d) => d.id).toSet();
          final cars = context.watch<CarProvider>().cars.where((c) => favIds.contains(c.id)).toList();
          if (cars.isEmpty) {
            return const Center(child: Text('No favorites yet.'));
          }
          return ListView.separated(
            itemCount: cars.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final car = cars[index];
              return ListTile(
                leading: const Icon(Icons.directions_car),
                title: Text(car.name.isNotEmpty ? car.name : car.model),
                subtitle: Text('${car.model} • ${car.year} • ${car.price}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CarDetailsScreen(
                        carId: car.id,
                        carName: car.name,
                        carModel: car.model,
                        year: car.year,
                        price: car.price,
                        description: car.description,
                        ownerId: car.ownerId,
                        imageUrl: car.imageUrl,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}


