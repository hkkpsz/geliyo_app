// Bu dosya Firebase CLI tarafından otomatik olarak oluşturulacak
// firebase_options.dart dosyası Firebase projenizi yapılandırdığınızda otomatik oluşur

// Geçici olarak boş bir yapılandırma sağlıyoruz
// Gerçek Firebase projenizi kurduktan sonra bu dosya değiştirilmelidir

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD28CngxCF9J0vak8oTugLQ3qcYkRDVplo',
    appId: '1:1052254127759:web:bbbada3652418f34dc92fa',
    messagingSenderId: '1052254127759',
    projectId: 'geliyoapp-68111',
    authDomain: 'geliyoapp-68111.firebaseapp.com',
    storageBucket: 'geliyoapp-68111.firebasestorage.app',
    measurementId: 'G-QX41FRKKB7',
  );

  // Bu değerler örnek değerlerdir - gerçek Firebase projenizinkilerle değiştirilmelidir

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAONVuGNW0V8Ze3gtlsehlFkkoZSdHXmPs',
    appId: '1:1052254127759:android:6a1fcc4d9c6de1d7dc92fa',
    messagingSenderId: '1052254127759',
    projectId: 'geliyoapp-68111',
    storageBucket: 'geliyoapp-68111.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAWruscL7OU04qS5voVffOGzy8AnskQjEo',
    appId: '1:1052254127759:ios:c86a2970f3eac7d3dc92fa',
    messagingSenderId: '1052254127759',
    projectId: 'geliyoapp-68111',
    storageBucket: 'geliyoapp-68111.firebasestorage.app',
    iosBundleId: 'com.example.geliyoApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAWruscL7OU04qS5voVffOGzy8AnskQjEo',
    appId: '1:1052254127759:ios:c86a2970f3eac7d3dc92fa',
    messagingSenderId: '1052254127759',
    projectId: 'geliyoapp-68111',
    storageBucket: 'geliyoapp-68111.firebasestorage.app',
    iosBundleId: 'com.example.geliyoApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD28CngxCF9J0vak8oTugLQ3qcYkRDVplo',
    appId: '1:1052254127759:web:e1942c53f15fe32adc92fa',
    messagingSenderId: '1052254127759',
    projectId: 'geliyoapp-68111',
    authDomain: 'geliyoapp-68111.firebaseapp.com',
    storageBucket: 'geliyoapp-68111.firebasestorage.app',
    measurementId: 'G-6M8MDSE3BH',
  );

}