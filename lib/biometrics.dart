import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import 'MainScreen.dart';


class BiometricsPage extends StatefulWidget {
  final String userId;

  BiometricsPage({required this.userId});

  @override
  _BiometricsPageState createState() => _BiometricsPageState();
}

class _BiometricsPageState extends State<BiometricsPage> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  bool _isFingerprintEnabled = false;
  String _errorMessage = '';


  Future<void> _checkBiometrics() async {
    try {
      bool isAvailable = await _localAuthentication.canCheckBiometrics;
      setState(() {
        _isFingerprintEnabled = isAvailable;
      });
    } catch (e) {
      print(e);
    }
  }


  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }


  Future<void> _authenticate() async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await _localAuthentication.authenticate(
          localizedReason: 'Please authenticate to proceed',
          options: const AuthenticationOptions(useErrorDialogs: false));
    } catch (e) {
      print(e);
    }

    if (isAuthenticated) {
      setState(() {
        _errorMessage = '';
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(userId: widget.userId,),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Fingerprint authentication failed, please try again';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/finger.jpg"),
            fit: BoxFit.cover,

          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              _isFingerprintEnabled
                  ? InkWell(
                onTap: _authenticate,
                child: Container(
                  child: const Opacity(
                    opacity: 0.0, // Set opacity to 0.0 to make the icon invisible
                    child: Icon(
                      Icons.visibility, // Replace with the desired icon
                      size: 150, // Replace with the desired size
                    ),
                  )
                )
              )
                  :
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.white, fontSize: 25),
                textAlign: TextAlign.center,
              ),


              /*
              Icon(
                Icons.lock_outline,
                size: 70,
                color: Colors.pink,
              ),

              SizedBox(height: 40),
              _isFingerprintEnabled
                  ? InkWell(
                  onTap: _authenticate,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.pink,
                        width: 2,
                      ),
                    ),
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (Rect bounds) =>
                          RadialGradient(
                            center: Alignment.topCenter,
                            stops: [.5, 1],
                            colors: [
                              Colors.pink,
                              Colors.yellow,
                            ],
                          ).createShader(bounds),
                      child: Icon(
                        Icons.fingerprint,
                        size: 150,
                      ),
                    ),
                  )
              )

                  : SizedBox(),
              SizedBox(height: 20),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red, fontSize: 25),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Press finger to unlock',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.pink, fontSize: 25),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}