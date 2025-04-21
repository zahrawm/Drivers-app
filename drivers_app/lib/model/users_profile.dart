import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String name;
  final String phoneNumber;
  final String? photoUrl;
  final double rating;
  final int totalRides;

  UserProfile({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.photoUrl,
    required this.rating,
    required this.totalRides,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      name: data['name'] ?? 'Unknown User',
      phoneNumber: data['phoneNumber'] ?? '',
      photoUrl: data['photoUrl'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalRides: data['totalRides'] ?? 0,
    );
  }
}
