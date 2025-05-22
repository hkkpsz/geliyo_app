import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/address_model.dart';
import '../services/firestore_service.dart';

class AddAddressScreen extends StatefulWidget {
  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _fullAddressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _fullAddressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _customerNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final address = Address(
        id: '',
        title: _titleController.text.trim(),
        fullAddress: _fullAddressController.text.trim(),
        latitude: double.parse(_latitudeController.text.trim()),
        longitude: double.parse(_longitudeController.text.trim()),
        customerName: _customerNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        createdAt: DateTime.now(),
      );

      final firestoreService = Provider.of<FirestoreService>(
          context, listen: false);
      bool success = await firestoreService.addAddress(address);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Adres başarıyla eklendi'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Adres eklenirken hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Geçersiz koordinat değerleri'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Adres Ekle'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Başlık alanı
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Adres Başlığı *',
                hintText: 'Örn: Ev, İş, Mağaza',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value
                    .trim()
                    .isEmpty) {
                  return 'Adres başlığı gereklidir';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Müşteri adı
            TextFormField(
              controller: _customerNameController,
              decoration: InputDecoration(
                labelText: 'Müşteri Adı *',
                hintText: 'Teslim alacak kişinin adı',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value
                    .trim()
                    .isEmpty) {
                  return 'Müşteri adı gereklidir';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Telefon numarası
            TextFormField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Telefon Numarası *',
                hintText: '0555 123 45 67',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value
                    .trim()
                    .isEmpty) {
                  return 'Telefon numarası gereklidir';
                }
                if (value
                    .trim()
                    .length < 10) {
                  return 'Geçerli bir telefon numarası girin';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Tam adres
            TextFormField(
              controller: _fullAddressController,
              decoration: InputDecoration(
                labelText: 'Tam Adres *',
                hintText: 'Mahalle, Sokak, Bina No, Daire No',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value
                    .trim()
                    .isEmpty) {
                  return 'Tam adres gereklidir';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Koordinat bilgileri bölümü
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.gps_fixed, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Konum Koordinatları',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Google Maps\'ten koordinatları alabilirsiniz. Konuma tıklayıp paylaş butonuna basın.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),

                    // Enlem
                    TextFormField(
                      controller: _latitudeController,
                      decoration: InputDecoration(
                        labelText: 'Enlem (Latitude) *',
                        hintText: '41.0082',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.explore),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: true),
                      validator: (value) {
                        if (value == null || value
                            .trim()
                            .isEmpty) {
                          return 'Enlem değeri gereklidir';
                        }
                        try {
                          double lat = double.parse(value.trim());
                          if (lat < -90 || lat > 90) {
                            return 'Enlem -90 ile 90 arasında olmalıdır';
                          }
                        } catch (e) {
                          return 'Geçerli bir enlem değeri girin';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Boylam
                    TextFormField(
                      controller: _longitudeController,
                      decoration: InputDecoration(
                        labelText: 'Boylam (Longitude) *',
                        hintText: '28.9784',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.explore),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: true),
                      validator: (value) {
                        if (value == null || value
                            .trim()
                            .isEmpty) {
                          return 'Boylam değeri gereklidir';
                        }
                        try {
                          double lon = double.parse(value.trim());
                          if (lon < -180 || lon > 180) {
                            return 'Boylam -180 ile 180 arasında olmalıdır';
                          }
                        } catch (e) {
                          return 'Geçerli bir boylam değeri girin';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Kaydet butonu
            ElevatedButton(
              onPressed: _isLoading ? null : _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Kaydediliyor...'),
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save),
                  SizedBox(width: 8),
                  Text('Adresi Kaydet'),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Yardım metni
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Koordinat Nasıl Alınır?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Google Maps uygulamasını açın\n'
                        '2. Hedef konuma tıklayın ve basılı tutun\n'
                        '3. Ekranın altında çıkan koordinatları kopyalayın\n'
                        '4. İlk sayı Enlem, ikinci sayı Boylam değeridir',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}