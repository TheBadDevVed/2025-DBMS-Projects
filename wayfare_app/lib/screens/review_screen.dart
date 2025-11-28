import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewScreen extends StatefulWidget {
  final String carId;

  const ReviewScreen({super.key, required this.carId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 0; // 1-5
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to review.')),
      );
      return;
    }

    setState(() => _submitting = true);

    final reviewsCol = FirebaseFirestore.instance
        .collection('cars')
        .doc(widget.carId)
        .collection('reviews');

    final reviewData = {
      'userId': user.uid,
      'userName': user.displayName ?? 'Anonymous',
      'rating': _selectedRating,
      'comment': _commentController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      // Add review
      await reviewsCol.add(reviewData);

      // Optionally maintain aggregates on the car document for efficient average calc
      final carRef = FirebaseFirestore.instance.collection('cars').doc(widget.carId);
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snapshot = await tx.get(carRef);
        final data = snapshot.data();
        final int currentCount = (data?['ratingCount'] ?? 0) as int;
        final int currentSum = (data?['ratingSum'] ?? 0) as int;
        tx.update(carRef, {
          'ratingCount': currentCount + 1,
          'ratingSum': currentSum + _selectedRating,
        });
      });

      _commentController.clear();
      setState(() => _selectedRating = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit review: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final carRef = FirebaseFirestore.instance.collection('cars').doc(widget.carId);
    final reviewsQuery = carRef
        .collection('reviews')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _RatingInput(
            rating: _selectedRating,
            onChanged: (val) => setState(() => _selectedRating = val),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _commentController,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Write your comment (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting || _selectedRating == 0 ? null : _submitReview,
                child: _submitting
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Submit Review'),
              ),
            ),
          ),
          const Divider(height: 24),
          // Average rating
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: carRef.snapshots(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data();
              final int count = (data?['ratingCount'] ?? 0) as int;
              final int sum = (data?['ratingSum'] ?? 0) as int;
              final double avg = count == 0 ? 0 : sum / count;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Text('Average:'),
                    const SizedBox(width: 8),
                    _Stars(rating: avg),
                    const SizedBox(width: 8),
                    Text(count == 0 ? 'No ratings yet' : '(${avg.toStringAsFixed(1)}) • $count reviews'),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: reviewsQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No reviews yet.'));
                }
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final String userName = (data['userName'] ?? 'Anonymous') as String;
                    final int rating = (data['rating'] ?? 0) as int;
                    final String comment = (data['comment'] ?? '') as String;
                    final Timestamp? ts = data['createdAt'] as Timestamp?;
                    final DateTime when = ts?.toDate() ?? DateTime.now();
                    return ListTile(
                      title: Row(
                        children: [
                          Expanded(child: Text(userName, style: const TextStyle(fontWeight: FontWeight.w600))),
                          _Stars(rating: rating.toDouble(), size: 16),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (comment.isNotEmpty) Text(comment),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(when),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }

  String _formatTime(DateTime when) {
    final now = DateTime.now();
    final diff = now.difference(when);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${when.year}-${when.month.toString().padLeft(2, '0')}-${when.day.toString().padLeft(2, '0')}';
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
          const Expanded(child: SizedBox()),
          Expanded(
            child: InkWell(
              onTap: () {},
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.rate_review), SizedBox(height: 2), Text('Reviews', style: TextStyle(fontSize: 10))]),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingInput extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;
  const _RatingInput({required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final star = index + 1;
        final isFilled = star <= rating;
        return IconButton(
          onPressed: () => onChanged(star),
          icon: Icon(
            isFilled ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 28,
          ),
        );
      }),
    );
  }
}

class _Stars extends StatelessWidget {
  final double rating; // 0..5
  final double size;
  const _Stars({required this.rating, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final star = index + 1;
        final isFilled = rating >= star - 0.25; // simple rounding
        return Icon(
          isFilled ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }
}


