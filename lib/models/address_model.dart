import 'package:cloud_firestore/cloud_firestore.dart';

class Address {
  final String id;
  final String title;
  final String fullAddress;
  final double latitude;
  final double longitude;
  final String customerName;
  final String phoneNumber;
  final DateTime createdAt;
  double? distanceInKm;
  bool isDelivered;

  Address({
    required this.id,
    required this.title,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    required this.customerName,
    required this.phoneNumber,
    required this.createdAt,
    this.distanceInKm,
    this.isDelivered = false,
  });

  factory Address.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Address(
      id: doc.id,
      title: data['title'] ?? '',
      fullAddress: data['fullAddress'] ?? '',
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      customerName: data['customerName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isDelivered: data['isDelivered'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'fullAddress': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'isDelivered': isDelivered,
    };
  }

  Address copyWith({
    String? id,
    String? title,
    String? fullAddress,
    double? latitude,
    double? longitude,
    String? customerName,
    String? phoneNumber,
    DateTime? createdAt,
    double? distanceInKm,
    bool? isDelivered,
  }) {
    return Address(
      id: id ?? this.id,
      title: title ?? this.title,
      fullAddress: fullAddress ?? this.fullAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      distanceInKm: distanceInKm ?? this.distanceInKm,
      isDelivered: isDelivered ?? this.isDelivered,
    );
  }
}