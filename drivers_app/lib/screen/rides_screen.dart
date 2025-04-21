import 'package:drivers_app/service/drivers_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({Key? key}) : super(key: key);

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final DriverService _driverService = DriverService();

  final String _driverId = 'driver123';

  double _searchRadius = 5.0;

  void _acceptRideRequest(String requestId) async {
    try {
      await _driverService.acceptRequest(requestId, _driverId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ride request accepted!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to accept ride: $e')));
    }
  }

  @override
  void initState() {
    super.initState();

    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    Future.delayed(const Duration(seconds: 30), () {
      _driverService
          .updateDriverLocation(_driverId)
          .then((_) {
            _startLocationUpdates();
          })
          .catchError((error) {
            print('Error updating location: $error');
            _startLocationUpdates();
          });
    });
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';

    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else {
      return 'Just now';
    }

    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return 'no date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Available Rides', icon: Icon(Icons.search)),
              Tab(text: 'Active Ride', icon: Icon(Icons.directions_car)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Refreshed ride requests')),
                );
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [_buildAvailableRidesTab(), _buildActiveRideTab()],
        ),
      ),
    );
  }

  Widget _buildAvailableRidesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text('Search Radius: '),
              Expanded(
                child: Slider(
                  value: _searchRadius,
                  min: 1.0,
                  max: 20.0,
                  divisions: 19,
                  label: '${_searchRadius.round()} km',
                  onChanged: (value) {
                    setState(() {
                      _searchRadius = value;
                    });
                  },
                ),
              ),
              Text('${_searchRadius.round()} km'),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<DocumentSnapshot>>(
            stream: _driverService.getNearbyRequests(_searchRadius),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final requests = snapshot.data ?? [];

              if (requests.isEmpty) {
                return const Center(child: Text('No nearby ride requests'));
              }

              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final requestData =
                      requests[index].data() as Map<String, dynamic>;
                  final requestId = requests[index].id;

                  return _buildRideRequestCard(requestData, requestId);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRideRequestCard(
    Map<String, dynamic> requestData,
    String requestId,
  ) {
    final pickupAddress =
        requestData['pickup']['address'] ?? 'Unknown location';
    final destinationAddress =
        requestData['destination']['address'] ?? 'Unknown destination';
    final userName = requestData['userName'] ?? 'Unknown user';
    final estimatedFare =
        requestData['estimatedFare']?.toStringAsFixed(2) ?? '0.00';

    final timeAgo = _formatTimestamp(requestData['createdAt']);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  timeAgo,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pickupAddress,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(Icons.more_vert, color: Colors.grey, size: 16),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    destinationAddress,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimated fare: GH₵ $estimatedFare',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _acceptRideRequest(requestId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Accept',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveRideTab() {
    return StreamBuilder<DocumentSnapshot?>(
      stream: _driverService.getDriverActiveRide(_driverId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final activeRide = snapshot.data;

        if (activeRide == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.car_rental, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No active ride',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Accept a ride request to get started',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Active ride exists
        final rideData = activeRide.data() as Map<String, dynamic>;
        final rideId = activeRide.id;

        return _buildActiveRideDetails(rideData, rideId);
      },
    );
  }

  Widget _buildActiveRideDetails(Map<String, dynamic> rideData, String rideId) {
    final userName = rideData['userName'] ?? 'Unknown user';
    final userPhone = rideData['userPhone'] ?? 'No phone';
    final pickupAddress = rideData['pickup']['address'] ?? 'Unknown location';
    final destinationAddress =
        rideData['destination']['address'] ?? 'Unknown destination';
    final estimatedFare =
        rideData['estimatedFare']?.toStringAsFixed(2) ?? '0.00';

    // Format timestamp for accepted time if available
    final acceptedTime = _formatTimestamp(rideData['acceptedAt']);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(userPhone),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text('Accepted $acceptedTime'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'RIDE DETAILS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.circle, color: Colors.green, size: 16),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PICKUP',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              pickupAddress,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.more_vert, color: Colors.grey, size: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DESTINATION',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              destinationAddress,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estimated Fare', style: TextStyle(fontSize: 16)),
                  Text(
                    'GH₵ $estimatedFare',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),

          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                final fare = rideData['estimatedFare'] as double;
                _driverService.completeRide(rideId, finalFare: fare);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Ride completed')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Complete Ride',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
