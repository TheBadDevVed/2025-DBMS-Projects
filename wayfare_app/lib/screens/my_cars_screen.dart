import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/car_provider.dart';

class MyCarsScreen extends StatelessWidget {
  const MyCarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cars'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Consumer<CarProvider>(
        builder: (context, carProvider, child) {
          if (carProvider.myCars.isEmpty) {
            return const Center(
              child: Text(
                'You haven\'t listed any cars yet.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: carProvider.myCars.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final car = carProvider.myCars[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        height: 70,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                          image: car.image != null
                              ? DecorationImage(
                                  image: car.image!,
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: car.image == null
                            ? const Center(
                                child: Icon(
                                  Icons.directions_car,
                                  size: 32,
                                  color: Colors.grey,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(car.model),
                            Text('Year: ${car.year}'),
                            Text(
                              '₹${car.price}/day',
                              style: const TextStyle(color: Colors.blue),
                            ),
                            Text(
                              car.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          const Expanded(child: SizedBox()),
          const Expanded(child: SizedBox()),
          const Expanded(child: SizedBox()),
          Expanded(
            child: InkWell(
              onTap: () {},
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.directions_car_outlined), SizedBox(height: 2), Text('My Cars', style: TextStyle(fontSize: 10))]),
            ),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}
