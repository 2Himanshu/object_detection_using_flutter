import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:object_detection/notification/notification_services.dart';
import 'package:http/http.dart' as http;

class TestWidget extends StatelessWidget {
  const TestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 235, 88, 78),
          title: const Text('SOS'),
        ),
        body: const Center(
          child: SOSbutton(),
        ),
      ),
    );
  }
}

class SOSbutton extends StatefulWidget {
  const SOSbutton({super.key});

  @override
  State<SOSbutton> createState() => _SOSbuttonState();
}

class _SOSbuttonState extends State<SOSbutton> {
  NotificationServices notificationServices = NotificationServices();
  String key = '';
  LocationData? _currentLocation;

  getCurrentLocation() async {
    Location location = Location();
    await location.getLocation().then(
      (value) {
        _currentLocation = value;
        print('Current Location: $_currentLocation');
      },
    );

    setState(() {
      _currentLocation = _currentLocation;
    });
  }

  Future<void> sendLocationToFirestore() async {
    final CollectionReference beaconsCollection = FirebaseFirestore.instance.collection('users');
    final DocumentReference userDoc = beaconsCollection.doc(FirebaseAuth.instance.currentUser!.uid);
    Location location = Location();
    LocationData position = await location.getLocation();

    final Map<String, dynamic> locationData = {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': DateTime.now(),
    };

    print('Sending location to Firestore: $locationData');

    await userDoc.update(locationData);
  }

  @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();

    notificationServices.getDeviceToken().then((value) {
      if (kDebugMode) {
        setState(() {
          key = value.toString();
        });
        print(key);
      }
    });
  }

  _sendNotification() async {
    await getCurrentLocation();
    await notificationServices.getDeviceToken().then((value) async {
      var data = {
        'to':
            'dPD9oI6TSkyN4N_XCdhSWA:APA91bEhtvfbD3jNr6pSMWUd58ESKXAHdCr_dQi3KWuiGPEIj_WkFoJFzPwZBJ03ukDYcLAjIbn-awgSwISCUJ4v9Idepua3qjx6HQDaq520xD4phfNKDWwYT8m3cZ3Mvp2eH4zHIjrr',
        'notification': {
          'title': 'SOS Alert',
          'body':
              'The Person is in danger. Please help him/her. Current Location: http://www.google.com/maps/place/${_currentLocation!.latitude},${_currentLocation!.longitude}',
          "sound": "jetsons_doorbell.mp3",
        },
        'android': {
          'notification': {
            'notification_count': 23,
          },
        },
        'data': {'type': 'msj', 'id': 'Asif Taj'}
      };

      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'), body: jsonEncode(data), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
            'key=AAAAZ4OmdM4:APA91bFuHnuOLhZ3gha54UK05rGrfcsm-uUUCQvPePBaJDXOyWqql55ag-x0YDwyKgS0C0YKcXRv3efH47UqSmCPqdALRLql7iLUKZj2gLCralKnXDotqrfxynBariSG_bY3xS9Q9Yla',
      }).then((value) {
        if (kDebugMode) {
          print(value.body.toString());
        }
      }).onError((error, stackTrace) {
        if (kDebugMode) {
          print(error);
        }
      });
    });
  }

  @override
  void dispose() {
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await _sendNotification();
        // await sendLocationToFirestore();
      },
      child: Container(
        width: 300, // Set the width of the button
        height: 300, // Set the height of the button
        decoration: const BoxDecoration(

            // Make it a circle
            ),
        child: Center(
          child: Image.asset(
            'assets/sos.jpg', // Replace with your image asset
            width: 200, // Set the width of the image
            height: 200, // Set the height of the image
          ),
        ),
      ),
    );
  }
}
