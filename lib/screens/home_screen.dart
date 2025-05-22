import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/address_model.dart';
import '../services/location_service.dart';
import '../services/firestore_service.dart';
import '../services/map_service.dart';
import 'add_address_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  List<Address> _sortedAddresses = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    final locationService = Provider.of<LocationService>(context, listen: false);
    Position? position = await locationService.getCurrentLocation();

    setState(() {
      _currentPosition = position;
      _isLoadingLocation = false;
    });

    if (position == null) {
      _showLocationPermissionDialog();
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konum İzni Gerekli'),
          content: Text('Adresleri mesafeye göre sıralayabilmek için konum izni gereklidir.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _getCurrentLocation();
              },
              child: Text('Tekrar Dene'),
            ),
          ],
        );
      },
    );
  }

  void _sortAddresses(List<Address> addresses) {
    if (_currentPosition != null) {
      final locationService = Provider.of<LocationService>(context, listen: false);
      _sortedAddresses = locationService.sortAddressesByDistance(addresses, _currentPosition!);
    } else {
      _sortedAddresses = addresses;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Kargo Dağıtım'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
            tooltip: 'Konumu Yenile',
          ),
        ],
      ),
      body: Column(
        children: [
          // Konum durumu göstergesi
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: _currentPosition != null ? Colors.green.shade100 : Colors.orange.shade100,
            child: Row(
              children: [
                Icon(
                  _currentPosition != null ? Icons.location_on : Icons.location_off,
                  color: _currentPosition != null ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isLoadingLocation
                        ? 'Konum alınıyor...'
                        : _currentPosition != null
                        ? 'Konum aktif - Adresler mesafeye göre sıralanıyor'
                        : 'Konum izni verilmedi - Adresler ekleme tarihine göre sıralanıyor',
                    style: TextStyle(
                      color: _currentPosition != null ? Colors.green.shade700 : Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Adres listesi
          Expanded(
            child: StreamBuilder<List<Address>>(
              stream: firestoreService.getUndeliveredAddresses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: SpinKitWave(
                      color: Colors.blue,
                      size: 50.0,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text('Veriler yüklenirken hata oluştu'),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {});
                          },
                          child: Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  );
                }

                List<Address> addresses = snapshot.data ?? [];

                if (addresses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_city, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Henüz adres eklenmemiş',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Yeni adres eklemek için + butonuna tıklayın',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                _sortAddresses(addresses);

                return RefreshIndicator(
                  onRefresh: () async {
                    await _getCurrentLocation();
                    setState(() {});
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: _sortedAddresses.length,
                    itemBuilder: (context, index) {
                      return _buildAddressCard(_sortedAddresses[index], index + 1);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAddressScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Yeni Adres Ekle',
      ),
    );
  }

  Widget _buildAddressCard(Address address, int order) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _openNavigation(address),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        order.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          address.customerName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (address.distanceInKm != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${address.distanceInKm!.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                address.fullAddress,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openNavigation(address),
                      icon: Icon(Icons.navigation, size: 18),
                      label: Text('Yol Tarifi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => MapService.makePhoneCall(address.phoneNumber),
                    icon: Icon(Icons.phone, size: 18),
                    label: Text('Ara'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _markAsDelivered(address),
                    icon: Icon(Icons.check_circle, size: 18),
                    label: Text('Teslim'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openNavigation(Address address) {
    MapService.openNavigationDialog(
      address.latitude,
      address.longitude,
      address.title,
    );
  }

  void _markAsDelivered(Address address) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Teslim Onayı'),
          content: Text('${address.title} adresine teslim edildi olarak işaretlensin mi?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final firestoreService = Provider.of<FirestoreService>(context, listen: false);
                bool success = await firestoreService.markAsDelivered(address.id);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Adres teslim edildi olarak işaretlendi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('İşlem başarısız oldu'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text('Evet, Teslim Et'),
            ),
          ],
        );
      },
    );
  }
}