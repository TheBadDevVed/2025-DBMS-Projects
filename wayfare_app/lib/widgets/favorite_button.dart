import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteButton extends StatelessWidget {
  final String carId;
  const FavoriteButton({super.key, required this.carId});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();
    final favDoc = FirebaseFirestore.instance.collection('users').doc(uid).collection('favorites').doc(carId);
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: favDoc.snapshots(),
      builder: (context, snapshot) {
        final isFav = snapshot.data?.exists == true;
        return IconButton(
          icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.redAccent : Colors.black45),
          onPressed: () async {
            final ref = favDoc;
            final exists = (await ref.get()).exists;
            if (exists) {
              await ref.delete();
            } else {
              await ref.set({'addedAt': FieldValue.serverTimestamp()});
            }
          },
        );
      },
    );
  }
}


