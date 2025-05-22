import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionName = 'addresses';

  // Adres ekleme
  Future<bool> addAddress(Address address) async {
    try {
      await _db.collection(collectionName).add(address.toFirestore());
      return true;
    } catch (e) {
      print('Adres eklenirken hata: $e');
      return false;
    }
  }

  // Tüm adresleri getirme
  Stream<List<Address>> getAddresses() {
    return _db
        .collection(collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Address.fromFirestore(doc))
          .toList();
    });
  }

  // Teslim edilmemiş adresleri getirme
  Stream<List<Address>> getUndeliveredAddresses() {
    return _db
        .collection(collectionName)
        .where('isDelivered', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Address.fromFirestore(doc))
          .toList();
    });
  }

  // Adres güncelleme
  Future<bool> updateAddress(String addressId, Map<String, dynamic> updates) async {
    try {
      await _db.collection(collectionName).doc(addressId).update(updates);
      return true;
    } catch (e) {
      print('Adres güncellenirken hata: $e');
      return false;
    }
  }

  // Adresi teslim edildi olarak işaretleme
  Future<bool> markAsDelivered(String addressId) async {
    try {
      await _db.collection(collectionName).doc(addressId).update({
        'isDelivered': true,
        'deliveredAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print('Adres teslim edildi olarak işaretlenirken hata: $e');
      return false;
    }
  }

  // Adres silme
  Future<bool> deleteAddress(String addressId) async {
    try {
      await _db.collection(collectionName).doc(addressId).delete();
      return true;
    } catch (e) {
      print('Adres silinirken hata: $e');
      return false;
    }
  }

  // Belirli bir adresi getirme
  Future<Address?> getAddress(String addressId) async {
    try {
      DocumentSnapshot doc = await _db.collection(collectionName).doc(addressId).get();
      if (doc.exists) {
        return Address.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Adres getirilirken hata: $e');
      return null;
    }
  }
}