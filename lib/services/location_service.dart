import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/address_model.dart';
import 'dart:math';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    try {
      // İzin kontrolü
      PermissionStatus permission = await Permission.location.request();
      if (permission != PermissionStatus.granted) {
        return null;
      }

      // Konum servislerinin açık olup olmadığını kontrol et
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Mevcut konumu al
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print('Konum alınırken hata: $e');
      return null;
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km cinsinden dünya yarıçapı

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  List<Address> sortAddressesByDistance(List<Address> addresses, Position userLocation) {
    // Her adres için mesafeyi hesapla
    for (int i = 0; i < addresses.length; i++) {
      double distance = calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        addresses[i].latitude,
        addresses[i].longitude,
      );
      addresses[i] = addresses[i].copyWith(distanceInKm: distance);
    }

    // Mesafeye göre sırala (yakından uzağa)
    addresses.sort((a, b) => a.distanceInKm!.compareTo(b.distanceInKm!));

    return addresses;
  }

  Future<bool> requestLocationPermission() async {
    PermissionStatus permission = await Permission.location.request();
    return permission == PermissionStatus.granted;
  }
}