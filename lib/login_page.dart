import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samal/MainScreen.dart';
import 'package:samal/registration_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'admin_page.dart';
import 'moderator.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  bool _isLoading = false;
  bool _isObscure = true;
  String _errorMessage = '';

  void _toggleObscure() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }




  Future<void> _signInWithEmailAndPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      User? user = userCredential.user;
      String storageUserId=user!.uid.toString();
      await _storage.delete(key: 'userId');
      await _storage.write(key: 'userId', value: storageUserId); // store the user ID in Secure Storage
      if(storageUserId=="gkN6xW74mkNV34T02qPaVxeXcPG3"){
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AdminPage()), (Route<dynamic> route) => false);
      } else if(storageUserId=="94yeL425qXTW8IsdlEMb2IE8Wjv2"){
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => ModeratorPage()), (Route<dynamic> route) => false);
      } else{
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(userId: storageUserId)),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message!;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 80),
                  Text(
                    "KazCrowdInvest",
                    style: TextStyle(
                      color: Colors.pinkAccent,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 80),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      fillColor: Colors.white.withOpacity(0.8),
                      filled: true,
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Email cannot be empty';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      fillColor: Colors.white.withOpacity(0.8),
                      filled: true,
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Password cannot be empty';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent, // Background color
                    ),
                    onPressed: () {
                      _signInWithEmailAndPassword();
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Navigate to registration page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistrationPage()),
                  );
                },
                child: Text('Don\'t have an account? Register',
                  style: TextStyle(
                      color: Colors.pinkAccent,),),)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
