import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Car {
  final String id; // Firestore document ID
  final String name;
  final String model;
  final String year;
  final String price;
  final String description;
  final ImageProvider? image;
  final String? imageUrl;
  final String ownerId;
  final DateTime createdAt;
  final String? color;
  final String? brand;
  final String? type; // segment
  final String? transmission; // manual/automatic
  final int? totalKilometers;
  final String? fuelEconomy; // keep as string for simplicity (e.g., 15 km/l)
  final bool available;

  Car({
    required this.id,
    required this.name,
    required this.model,
    required this.year,
    required this.price,
    required this.description,
    required this.ownerId,
    required this.createdAt,
    this.image,
    this.imageUrl,
    this.color,
    this.brand,
    this.type,
    this.transmission,
    this.totalKilometers,
    this.fuelEconomy,
    this.available = true,
  });

  // Create a Car from Firestore data
  factory Car.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Car(
      id: doc.id,
      name: data['name'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? '',
      price: data['price'] ?? '',
      description: data['description'] ?? '',
      ownerId: data['ownerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      // Note: image will need to be handled separately with Firebase Storage
      image: null,
      imageUrl: data['imageUrl'] as String?,
      color: data['color'] as String?,
      brand: data['brand'] as String?,
      type: data['type'] as String?,
      transmission: data['transmission'] as String?,
      totalKilometers: (data['totalKilometers'] as num?)?.toInt(),
      fuelEconomy: data['fuelEconomy'] as String?,
      available: (data['available'] as bool?) ?? true,
    );
  }

  // Convert Car to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'model': model,
      'year': year,
      'price': price,
      'description': description,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (color != null) 'color': color,
      if (brand != null) 'brand': brand,
      if (type != null) 'type': type,
      if (transmission != null) 'transmission': transmission,
      if (totalKilometers != null) 'totalKilometers': totalKilometers,
      if (fuelEconomy != null) 'fuelEconomy': fuelEconomy,
      'available': available,
      // Note: image will need to be handled separately with Firebase Storage
    };
  }
}

class CarProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Car> _cars = [];

  List<Car> get cars => List.unmodifiable(_cars);

  List<Car> get myCars {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return [];
    return _cars.where((car) => car.ownerId == currentUserId).toList();
  }

  List<Car> get availableCars => _cars.where((c) => c.available).toList();

  // Initialize provider and listen to car updates
  CarProvider() {
    _listenToCars();
  }

  void _listenToCars() {
    _firestore
        .collection('cars')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _cars = snapshot.docs.map((doc) => Car.fromFirestore(doc)).toList();
          notifyListeners();
        });
  }

  // Add a new car to Firestore
  Future<void> addCar(Car car) async {
    try {
      await _firestore.collection('cars').add(car.toFirestore());
      // Note: If we need to upload images, we would use Firebase Storage here
    } catch (e) {
      print('Error adding car: $e');
      rethrow;
    }
  }

  // Delete a car from Firestore
  Future<void> deleteCar(String carId) async {
    try {
      await _firestore.collection('cars').doc(carId).delete();
    } catch (e) {
      print('Error deleting car: $e');
      rethrow;
    }
  }

  // Update a car in Firestore
  Future<void> updateCar(Car car) async {
    try {
      await _firestore.collection('cars').doc(car.id).update(car.toFirestore());
    } catch (e) {
      print('Error updating car: $e');
      rethrow;
    }
  }
}
