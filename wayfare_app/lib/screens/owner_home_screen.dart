import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../../services/car_provider.dart';
import 'signin_screen.dart';
import 'profile_screen.dart';
import 'my_cars_screen.dart';
import 'review_screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  String? carName;
  String? carModel;
  String? carYear;
  String? carPrice;
  String? carDescription;
  ImageProvider? carImage;
  // In a real app, use image_picker package
  void _pickImage() async {
    // TODO: Integrate image_picker for real image selection
    setState(() {
      carImage = const AssetImage('assets/placeholder_car.png');
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Your Car"),
        backgroundColor: Colors.blue.shade700,
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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SignInScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    if (carImage != null)
                      Container(
                        width: 180,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: carImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 180,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.directions_car,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text('Add Image of Car'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(160, 40),
                      ),
                      onPressed: _pickImage,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Car Name',
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => carName = val,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter car name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Model',
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => carModel = val,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter model' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onSaved: (val) => carYear = val,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter year' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Rental Price per Day',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onSaved: (val) => carPrice = val,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter price' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (val) => carDescription = val,
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('List Car'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(160, 48),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final car = Car(
                        id: '',
                        name: carName ?? '',
                        model: carModel ?? '',
                        year: carYear ?? '',
                        price: carPrice ?? '',
                        description: carDescription ?? '',
                        image: carImage,
                        ownerId: auth.auth.currentUser?.uid ?? '',
                        createdAt: DateTime.now(),
                      );
                      Provider.of<CarProvider>(
                        context,
                        listen: false,
                      ).addCar(car);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Car listed successfully!'),
                        ),
                      );
                      _formKey.currentState!.reset();
                      setState(() {
                        carImage = null;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'fab-mycars',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyCarsScreen()),
              );
            },
            tooltip: 'My Cars',
            child: const Icon(Icons.directions_car),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'fab-reviews',
            onPressed: () async {
              final cars = context.read<CarProvider>().myCars.isNotEmpty
                  ? context.read<CarProvider>().myCars
                  : context.read<CarProvider>().cars;
              if (cars.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No cars available.')),
                );
                return;
              }
              // ignore: use_build_context_synchronously
              final selectedId = await showModalBottomSheet<String>(
                context: context,
                builder: (ctx) {
                  return SafeArea(
                    child: ListView.separated(
                      itemCount: cars.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, index) {
                        final car = cars[index];
                        return ListTile(
                          title: Text(car.name.isNotEmpty ? car.name : 'Car ${index + 1}'),
                          subtitle: Text('${car.model} • ${car.year}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(ctx).pop(car.id),
                        );
                      },
                    ),
                  );
                },
              );
              if (selectedId != null && selectedId.isNotEmpty) {
                // ignore: use_build_context_synchronously
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ReviewScreen(carId: selectedId)),
                );
              }
            },
            tooltip: 'Reviews',
            child: const Icon(Icons.rate_review),
          ),
        ],
      ),
    );
  }
}
