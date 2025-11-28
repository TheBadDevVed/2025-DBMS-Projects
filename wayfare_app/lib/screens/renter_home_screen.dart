import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import 'signin_screen.dart';
import 'profile_screen.dart';
import 'add_car_screen.dart';
import 'my_cars_screen.dart';
import 'package:provider/provider.dart';
import '../../services/car_provider.dart';
import 'booking_screen.dart';
import 'chat_inbox_screen.dart';
import 'car_details_screen.dart';
import 'favorites_screen.dart';
import 'package:flutter/rendering.dart';
import '../widgets/favorite_button.dart';
import 'booking_history_screen.dart';

class RenterHomeScreen extends StatefulWidget {
  const RenterHomeScreen({super.key});

  @override
  State<RenterHomeScreen> createState() => _RenterHomeScreenState();
}

class _RenterHomeScreenState extends State<RenterHomeScreen> {
  final searchController = TextEditingController();
  final auth = AuthService();
  final ScrollController _scrollController = ScrollController();
  bool _showSearch = true;
  String? _brandFilter;
  String? _typeFilter;
  String? _colorFilter;

  final List<String> _carBrands = const [
    'Maruti Suzuki',
    'Hyundai',
    'Tata',
    'Mahindra',
    'Honda',
    'Toyota',
    'Kia',
    'Skoda',
    'Volkswagen',
    'Renault',
    'Nissan',
    'MG',
    'Ford',
    'BMW',
    'Mercedes-Benz',
    'Audi',
    'Jeep',
    'Volvo',
  ];

  final List<String> _carTypes = const [
    'Hatchback',
    'Sedan',
    'SUV',
    'MUV',
    'Coupe',
    'Convertible',
    'Pickup',
    'Crossover',
    'Wagon',
    'Luxury',
  ];

  final List<String> _carColors = const [
    'Black',
    'White',
    'Silver',
    'Gray',
    'Red',
    'Blue',
    'Brown',
    'Green',
    'Beige',
    'Gold',
    'Orange',
    'Yellow',
    'Purple',
    'Bronze',
    'Maroon',
  ];

  Future<void> _showFilterDialog(BuildContext context) async {
    String? tempBrandFilter = _brandFilter;
    String? tempTypeFilter = _typeFilter;
    String? tempColorFilter = _colorFilter;

    final List<String> carBrands = const [
      'Maruti Suzuki',
      'Hyundai',
      'Tata',
      'Mahindra',
      'Honda',
      'Toyota',
      'Kia',
      'Skoda',
      'Volkswagen',
      'Renault',
      'Nissan',
      'MG',
      'Ford',
      'BMW',
      'Mercedes-Benz',
      'Audi',
      'Jeep',
      'Volvo',
    ];

    final List<String> carTypes = const [
      'Hatchback',
      'Sedan',
      'SUV',
      'MUV',
      'Coupe',
      'Convertible',
      'Pickup',
      'Crossover',
      'Wagon',
      'Luxury',
    ];

    final List<String> carColors = const [
      'Black',
      'White',
      'Silver',
      'Gray',
      'Red',
      'Blue',
      'Brown',
      'Green',
      'Beige',
      'Gold',
      'Orange',
      'Yellow',
      'Purple',
      'Bronze',
      'Maroon',
    ];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Cars'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Brand',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Any'),
                          selected: tempBrandFilter == null,
                          onSelected: (_) =>
                              setState(() => tempBrandFilter = null),
                        ),
                        ...carBrands.map(
                          (b) => FilterChip(
                            label: Text(b),
                            selected: tempBrandFilter == b,
                            onSelected: (_) => setState(
                              () => tempBrandFilter = tempBrandFilter == b
                                  ? null
                                  : b,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Type',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Any'),
                          selected: tempTypeFilter == null,
                          onSelected: (_) =>
                              setState(() => tempTypeFilter = null),
                        ),
                        ...carTypes.map(
                          (t) => FilterChip(
                            label: Text(t),
                            selected: tempTypeFilter == t,
                            onSelected: (_) => setState(
                              () => tempTypeFilter = tempTypeFilter == t
                                  ? null
                                  : t,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Color',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Any'),
                          selected: tempColorFilter == null,
                          onSelected: (_) =>
                              setState(() => tempColorFilter = null),
                        ),
                        ...carColors.map(
                          (c) => FilterChip(
                            label: Text(c),
                            selected: tempColorFilter == c,
                            onSelected: (_) => setState(
                              () => tempColorFilter = tempColorFilter == c
                                  ? null
                                  : c,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    super.setState(() {
                      _brandFilter = tempBrandFilter;
                      _typeFilter = tempTypeFilter;
                      _colorFilter = tempColorFilter;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rent Cars"),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
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
      body: Column(
        children: [
          // Search Bar Section
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _showSearch ? null : 0,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade700,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search cars by brand, model, color...',
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            searchController.clear();
                          });
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.filter_list,
                        color:
                            (_brandFilter != null ||
                                _typeFilter != null ||
                                _colorFilter != null)
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      onPressed: () => _showFilterDialog(context),
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          // Content starts after search bar

          // Content Area (will show search results or empty state)
          Expanded(
            child: NotificationListener<UserScrollNotification>(
              onNotification: (n) {
                if (n.direction == ScrollDirection.reverse && _showSearch) {
                  setState(() => _showSearch = false);
                } else if (n.direction == ScrollDirection.forward &&
                    !_showSearch) {
                  setState(() => _showSearch = true);
                }
                return false;
              },
              child: Builder(
                builder: (context) {
                  final cars = context.watch<CarProvider>().availableCars;
                  final query = searchController.text.trim().toLowerCase();
                  if (query.isEmpty) {
                    if (cars.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_car_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No cars uploaded yet',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(8),
                      controller: _scrollController,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.9,
                          ),
                      itemCount: cars.length,
                      itemBuilder: (context, index) {
                        final car = cars[index];
                        return Card(
                          elevation: 1,
                          child: InkWell(
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
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Icon(
                                            Icons.directions_car,
                                            size: 48,
                                            color: Colors.blue.shade400,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: FavoriteButton(carId: car.id),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    car.name.isNotEmpty ? car.name : car.model,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${car.model} • ${car.year}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    car.price,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BookingScreen(
                                              carId: car.id,
                                              carName: car.name,
                                              carModel: car.model,
                                              ownerId: car.ownerId,
                                              pricePerDay: car.price,
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Book'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  final results = cars.where((car) {
                    final name = car.name.toLowerCase();
                    final model = car.model.toLowerCase();
                    final year = car.year.toLowerCase();
                    final desc = car.description.toLowerCase();
                    final color = (car.color ?? '').toLowerCase();
                    final brand = (car.brand ?? '').toLowerCase();
                    final type = (car.type ?? '').toLowerCase();
                    final matchesText =
                        name.contains(query) ||
                        model.contains(query) ||
                        year.contains(query) ||
                        desc.contains(query) ||
                        color.contains(query) ||
                        brand.contains(query) ||
                        type.contains(query);
                    final matchesBrand =
                        _brandFilter == null ||
                        (car.brand ?? '') == _brandFilter;
                    final matchesType =
                        _typeFilter == null || (car.type ?? '') == _typeFilter;
                    final matchesColor =
                        _colorFilter == null ||
                        (car.color ?? '') == _colorFilter;
                    return matchesText &&
                        matchesBrand &&
                        matchesType &&
                        matchesColor;
                  }).toList();

                  if (results.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No results for "${searchController.text}"',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    controller: _scrollController,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final car = results[index];
                      return Card(
                        elevation: 1,
                        child: InkWell(
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
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Icon(
                                          Icons.directions_car,
                                          size: 48,
                                          color: Colors.blue.shade400,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: FavoriteButton(carId: car.id),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  car.name.isNotEmpty ? car.name : car.model,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${car.model} • ${car.year}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  car.price,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BookingScreen(
                                            carId: car.id,
                                            carName: car.name,
                                            carModel: car.model,
                                            ownerId: car.ownerId,
                                            pricePerDay: car.price,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('Book'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar - 5 evenly spaced items
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RenterHomeScreen()),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home, size: 26, color: Colors.blue.shade700),
                    const SizedBox(height: 2),
                    Text(
                      'Home',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatInboxScreen()),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 24,
                      color: Colors.black54,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Chat',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddCarScreen()),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade700, Colors.blue.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Add',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyCarsScreen()),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.directions_car_outlined,
                      size: 24,
                      color: Colors.black54,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'My Cars',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BookingHistoryScreen(),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.book_online,
                      size: 24,
                      color: Colors.black54,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bookings',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
