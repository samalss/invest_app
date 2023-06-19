import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:samal/MainScreen.dart';
import 'admin_page.dart';
import 'biometrics.dart';
import 'login_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import 'moderator.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options:
  const FirebaseOptions(
    apiKey: 'AIzaSyBQ52cztvVKoNVzbI8QQxO5r_y9_HGBUOI',
    appId: '1:771806493132:android:b94940976fee874b344569',
    messagingSenderId: '771806493132',
    projectId: 'invest-b5cae',
    storageBucket: 'invest-b5cae.appspot.com',
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KazCrowdInvest',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthenticationPage(),

    );
  }
}


class AuthenticationPage extends StatefulWidget {
  AuthenticationPage({super.key});



  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final _storage = FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  bool _isLoading = true;
  bool _authorized = false;
  late String _userId;

  @override
  void initState() {
    super.initState();
    checkAuthorization();
  }

  Future<void> checkAuthorization() async {
    try {
      // Check if the user ID key is present
      String? userId = await _storage.read(key: 'userId');

      if (userId != null) {
        // Request fingerprint
        /*bool success = await _localAuth.authenticate(
          localizedReason: 'Authenticate to access the app',
        );*/
          // Navigate to the HomePage passing the userID

          setState(() {
            _authorized = true;
            _userId = userId;
            _isLoading=false;
          });

      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
    }
  }

  void login(String userId) async {
    // Save the user ID in the Secure Storage library
    await _storage.delete(key: 'userId');
    await _storage.write(key: 'userId', value: userId);

    // Request fingerprint
    bool success = await _localAuth.authenticate(
      localizedReason: 'Authenticate to access the app',
    );

    if (success) {
      // Navigate to the HomePage passing the userID
      setState(() {
        _authorized = true;
        _userId = userId;
      });
    } else {
      // Remove the user ID from Secure Storage library
      await _storage.delete(key: 'userId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _authorized && _userId=='gkN6xW74mkNV34T02qPaVxeXcPG3'
          ? AdminPage()
          : _authorized && _userId=='94yeL425qXTW8IsdlEMb2IE8Wjv2'
          ? ModeratorPage()
          : _authorized
          ? BiometricsPage(userId: _userId,)
          : LoginPage()
    );
  }
}
