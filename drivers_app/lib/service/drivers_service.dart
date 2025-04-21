import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class DriverService {
  final firestore = FirebaseFirestore.instance;
  
 
  final double defaultAccraLatitude = 5.6037;
  final double defaultAccraLongitude = -0.1870;

  // Helper method to calculate distance between two points
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // Convert meters to kilometers
  }

  // Get current position or use default Accra coordinates if permission denied
  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Return default Accra position instead of throwing exception
      return Position(
        latitude: defaultAccraLatitude,
        longitude: defaultAccraLongitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }

  
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Return default Accra position
        return Position(
          latitude: defaultAccraLatitude,
          longitude: defaultAccraLongitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      
      return Position(
        latitude: defaultAccraLatitude,
        longitude: defaultAccraLongitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }

   
    return await Geolocator.getCurrentPosition();
  }

  
  Stream<List<DocumentSnapshot>> getNearbyRequests(double radiusInKm) async* {
    
    final position = await _getCurrentPosition();
    
   
    final controller = StreamController<List<DocumentSnapshot>>();
    
    
    firestore.collection('ride_requests')
        .where('status', isEqualTo: 'waiting')
        .snapshots()
        .listen((snapshot) {
         
          final nearbyRequests = snapshot.docs.where((doc) {
            
            final data = doc.data() as Map<String, dynamic>;
            
            
            if (data['location'] == null || 
                data['location']['latitude'] == null || 
                data['location']['longitude'] == null) {
              return false;
            }
            
            final requestLat = data['location']['latitude'] as double;
            final requestLng = data['location']['longitude'] as double;
            
            
            final distance = _calculateDistance(
              position.latitude, 
              position.longitude, 
              requestLat, 
              requestLng
            );
            
           
            return distance <= radiusInKm;
          }).toList();
          
          
          controller.add(nearbyRequests);
        }, 
        onError: (e) {
          controller.addError(e);
        });
    
  
    yield* controller.stream;
  }

 
  Stream<bool> userHasActiveRequest(String userId) {
    return firestore.collection('ride_requests')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['waiting', 'accepted'])
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

 
  Stream<DocumentSnapshot?> getUserActiveRequest(String userId) {
    return firestore.collection('ride_requests')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['waiting', 'accepted'])
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty ? snapshot.docs.first : null);
  }

  Future<void> acceptRequest(String requestId, String driverId) async {
    await firestore.collection('ride_requests').doc(requestId).update({
      'status': 'accepted',
      'driverId': driverId,
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }
  
 
  Future<String> createRideRequest({
    required String userId,
    required String userName,
    required String userPhone,
    required double pickupLatitude,
    required double pickupLongitude,
    required String pickupAddress,
    required double destinationLatitude,
    required double destinationLongitude,
    required String destinationAddress,
    required double estimatedFare,
  }) async {
    final docRef = await firestore.collection('ride_requests').add({
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'status': 'waiting',
      'createdAt': FieldValue.serverTimestamp(),
      'location': {
        'latitude': pickupLatitude,
        'longitude': pickupLongitude,
      },
      'pickup': {
        'latitude': pickupLatitude,
        'longitude': pickupLongitude,
        'address': pickupAddress,
      },
      'destination': {
        'latitude': destinationLatitude,
        'longitude': destinationLongitude,
        'address': destinationAddress,
      },
      'estimatedFare': estimatedFare,
    });
    
    return docRef.id;
  }
  
  
  Future<void> updateDriverLocation(String driverId) async {
    try {
      final position = await _getCurrentPosition();
      
      await firestore.collection('drivers').doc(driverId).update({
        'location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'updatedAt': FieldValue.serverTimestamp(),
        }
      });
    } catch (e) {
      print('Error updating driver location: $e');
      rethrow;
    }
  }
  
 
  Future<void> cancelRequest(String requestId, {String? cancellationReason}) async {
    await firestore.collection('ride_requests').doc(requestId).update({
      'status': 'cancelled',
      'cancellationReason': cancellationReason,
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }
  
 
  Future<void> completeRide(String requestId, {required double finalFare}) async {
    await firestore.collection('ride_requests').doc(requestId).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
      'finalFare': finalFare,
    });
  }
  

  Stream<DocumentSnapshot?> getDriverActiveRide(String driverId) {
    return firestore.collection('ride_requests')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty ? snapshot.docs.first : null);
  }
}