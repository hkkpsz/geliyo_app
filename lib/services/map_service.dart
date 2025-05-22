import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class MapService {
  static Future<void> openGoogleMaps(double latitude, double longitude, String destinationName) async {
    String googleMapsUrl;

    if (Platform.isAndroid) {
      googleMapsUrl = 'google.navigation:q=$latitude,$longitude&mode=d';
    } else if (Platform.isIOS) {
      googleMapsUrl = 'comgooglemaps://?daddr=$latitude,$longitude&directionsmode=driving';
    } else {
      googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';
    }

    try {
      bool launched = await launchUrl(
        Uri.parse(googleMapsUrl),
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // Google Maps uygulaması yoksa web versiyonunu aç
        await _openWebGoogleMaps(latitude, longitude);
      }
    } catch (e) {
      print('Google Maps açılırken hata: $e');
      await _openWebGoogleMaps(latitude, longitude);
    }
  }

  static Future<void> _openWebGoogleMaps(double latitude, double longitude) async {
    final String webUrl = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';

    try {
      await launchUrl(
        Uri.parse(webUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('Web Google Maps açılırken hata: $e');
    }
  }

  static Future<void> openAppleMaps(double latitude, double longitude, String destinationName) async {
    if (Platform.isIOS) {
      final String appleMapsUrl = 'http://maps.apple.com/?daddr=$latitude,$longitude&dirflg=d';

      try {
        await launchUrl(
          Uri.parse(appleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        print('Apple Maps açılırken hata: $e');
        await _openWebGoogleMaps(latitude, longitude);
      }
    } else {
      // iOS değilse Google Maps'i aç
      await openGoogleMaps(latitude, longitude, destinationName);
    }
  }

  static Future<void> openNavigationDialog(double latitude, double longitude, String destinationName) async {
    // Varsayılan olarak Google Maps'i aç
    await openGoogleMaps(latitude, longitude, destinationName);
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');

    try {
      await launchUrl(phoneUri);
    } catch (e) {
      print('Telefon araması yapılırken hata: $e');
    }
  }
}
