import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../../services/car_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'signin_screen.dart';
import 'profile_screen.dart';
// import 'my_cars_screen.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  String? carName;
  String? carModel;
  String? carYear;
  String? carPrice;
  String? carDescription;
  String? carColor;
  String? carBrand;
  String? carType;
  String? carTransmission; // manual/automatic
  String? carFuelEconomy; // e.g., 15 km/l
  String? carKm; // total kilometers as string input

  final List<String> _brands = const [
    'Maruti Suzuki', 'Hyundai', 'Tata', 'Mahindra', 'Honda', 'Toyota', 'Kia', 'Skoda', 'Volkswagen', 'Renault', 'Nissan', 'MG', 'Ford', 'BMW', 'Mercedes-Benz', 'Audi', 'Jeep', 'Volvo'
  ];
  final List<String> _types = const [
    'Hatchback', 'Sedan', 'SUV', 'MUV', 'Coupe', 'Convertible', 'Pickup', 'Crossover', 'Wagon', 'Luxury'
  ];

  Future<void> _pickFromList({required List<String> items, required ValueChanged<String> onSelected, required String title}) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    return ListTile(
                      title: Text(items[i]),
                      onTap: () => Navigator.of(ctx).pop(items[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    if (selected != null) onSelected(selected);
  }
  File? _pickedImageFile;
  String? _uploadedImageUrl;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _pickedImageFile = File(picked.path);
      });
    }
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
                    if (_pickedImageFile != null)
                      Container(
                        width: 180,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(image: FileImage(_pickedImageFile!), fit: BoxFit.cover),
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
                  labelText: 'Color',
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => carColor = val,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Transmission',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Manual', child: Text('Manual')),
                  DropdownMenuItem(value: 'Automatic', child: Text('Automatic')),
                ],
                onChanged: (v) => carTransmission = v,
                onSaved: (v) => carTransmission = v,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Fuel Economy (e.g., 15 km/l)',
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => carFuelEconomy = val,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Total Kilometers',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onSaved: (val) => carKm = val,
              ),
              const SizedBox(height: 16),
              // Brand picker
              GestureDetector(
                onTap: () async {
                  await _pickFromList(
                    items: _brands,
                    title: 'Select Brand',
                    onSelected: (v) => setState(() => carBrand = v),
                  );
                },
                child: AbsorbPointer(
                  absorbing: true,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Brand',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    controller: TextEditingController(text: carBrand ?? ''),
                    onSaved: (val) => carBrand = val,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Car Type picker
              GestureDetector(
                onTap: () async {
                  await _pickFromList(
                    items: _types,
                    title: 'Select Car Type',
                    onSelected: (v) => setState(() => carType = v),
                  );
                },
                child: AbsorbPointer(
                  absorbing: true,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Car Type (Hatchback, Sedan, SUV, etc.)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    controller: TextEditingController(text: carType ?? ''),
                    onSaved: (val) => carType = val,
                  ),
                ),
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
                  onPressed: () async {
                    // Check if user is logged in first
                    final currentUser = auth.auth.currentUser;
                    if (currentUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please log in to list a car'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      try {
                        // Upload image if selected
                        String? imageUrl;
                        if (_pickedImageFile != null) {
                          final storageRef = FirebaseStorage.instance
                              .ref()
                              .child('cars/${currentUser.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
                          await storageRef.putFile(_pickedImageFile!);
                          imageUrl = await storageRef.getDownloadURL();
                          _uploadedImageUrl = imageUrl;
                        }

                        final car = Car(
                          id: '', // Firestore will generate this
                          name: carName ?? '',
                          model: carModel ?? '',
                          year: carYear ?? '',
                          price: carPrice ?? '',
                          description: carDescription ?? '',
                          image: null,
                          imageUrl: _uploadedImageUrl,
                          ownerId: currentUser.uid,
                          createdAt: DateTime.now(),
                          color: carColor,
                          brand: carBrand,
                          type: carType,
                          transmission: carTransmission,
                          totalKilometers: int.tryParse(carKm ?? ''),
                          fuelEconomy: carFuelEconomy,
                          available: true,
                        );
                        final carProvider = Provider.of<CarProvider>(
                          context,
                          listen: false,
                        );
                        await carProvider.addCar(car);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Car listed successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        _formKey.currentState!.reset();
                        setState(() {
                          _pickedImageFile = null;
                          _uploadedImageUrl = null;
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error listing car: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   icon: const Icon(Icons.directions_car),
      //   label: const Text('My Cars'),
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (_) => const MyCarsScreen()),
      //     );
      //   },
      // ),
    );
  }
}
