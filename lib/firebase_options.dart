// ignore_for_file: file_names
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // if (kIsWeb) {
    //   return web;
    // }
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCy6Bd6hGs5m44AChRgcupSi-gQTfGezoI',
    appId: '1:186476227140:android:f761f01680bdedc6d3ea11',
    messagingSenderId: '186476227140',
    projectId: 'fb-ui-auth-example',
    storageBucket: 'fb-ui-auth-example.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAjr1LU2YhCQKlK4H2YV0oAwpzJ7slEXBU',
    appId: '1:186476227140:ios:6df3388587368b3dd3ea11',
    messagingSenderId: '186476227140',
    projectId: 'fb-ui-auth-example',
    storageBucket: 'fb-ui-auth-example.appspot.com',
    iosClientId:
        '186476227140-5p2o9n9f9vii40p1p7ckeslt7uev46i0.apps.googleusercontent.com',
    iosBundleId: 'com.example.example',
  );
}
