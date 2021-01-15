import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String teks = '';

  //deklarasi firebase messaging
  final _firebaseMessaging = FirebaseMessaging();

  //deklarasi local notification
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  var mymap = {};
  var title = '';
  var body = {};
  var mytoken = '';

  @override
  void initState() {
    super.initState();
    var android = AndroidInitializationSettings('mipmap/ic_launcher');
    var ios = IOSInitializationSettings();
    var platform = InitializationSettings(android: android, iOS: ios);
    flutterLocalNotificationsPlugin.initialize(platform);

    _firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('on message $message');
      //jadikan mymap = message
      mymap = message;
      //tampilkan notifikasi
      displayNotifikasi(message);
    }, onResume: (Map<String, dynamic> message) {
      print('on resume $message');
    }, onLaunch: (Map<String, dynamic> message) {
      print('on launch $message');
    });

    _firebaseMessaging
        .requestNotificationPermissions(const IosNotificationSettings(
      sound: true,
      alert: true,
      badge: true,
    ));
    _firebaseMessaging.getToken().then((token) {
      updateToken(token);
      print(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FCM Notif Apps'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$teks'),
          ],
        ),
      ),
    );
  }

  displayNotifikasi(Map<String, dynamic> msg) async {
    var android =
        AndroidNotificationDetails("1", "channelName", "channelDescription");
    var ios = IOSNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: ios);

    msg.forEach((nTitle, nBody) {
      title = nTitle;
      body = nBody;
      setState(() {});
    });
    await flutterLocalNotificationsPlugin.show(
        0, msg['notification']['title'], msg['notification']['body'], platform);
  }

  updateToken(String token) {
    print(token);
    var databaseReference = FirebaseDatabase().reference();
    databaseReference.child('fcm-token/$token').set({"token": token});
    mytoken = token;
    teks = mytoken;
    setState(() {});
  }
}
