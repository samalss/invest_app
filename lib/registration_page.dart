import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samal/MainScreen.dart';


class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  bool _showCardInfoForm = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _firstName = TextEditingController();
  late TextEditingController _lastName = TextEditingController();
  late TextEditingController _email = TextEditingController();
  late TextEditingController _password = TextEditingController();
  late TextEditingController _phoneNumber = TextEditingController();


  late TextEditingController _bankName = TextEditingController();
  late TextEditingController _cardExpiry = TextEditingController();
  late TextEditingController _cardNumber = TextEditingController();
  late TextEditingController _cvv = TextEditingController();


  List<Widget> _buildEmailPasswordForm() {
    return <Widget>[
      SizedBox(height: 35),
      Text(
        "KazCrowdInvest",
        style: TextStyle(
          color: Colors.black,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 30),
      TextFormField(
        controller: _lastName,
        obscureText: false,
        decoration: InputDecoration(
          labelText: "Name",
          fillColor: Colors.white.withOpacity(0.8),
          filled: true,
          prefixIcon: Icon(Icons.person),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Name cannot be empty';
          } else if (value!.length <= 2) {
            return 'Surname is too short';
          }
          return null;
        },
      ),
      SizedBox(height: 20),
      TextFormField(
        controller: _firstName,
        obscureText: false,
        decoration: InputDecoration(
          labelText: "Surname",
          fillColor: Colors.white.withOpacity(0.8),
          filled: true,
          prefixIcon: Icon(Icons.person),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Surname cannot be empty';
          } else if (value!.length <= 2) {
            return 'Surname is too short';
          }
          return null;
        },
      ),
      SizedBox(height: 20),
      TextFormField(
        controller: _phoneNumber,
        obscureText: false,
        decoration: InputDecoration(
          labelText: "Phone",
          fillColor: Colors.white.withOpacity(0.8),
          filled: true,
          prefixIcon: Icon(Icons.phone),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        validator: (value) {
          int? parsedNumber = int.tryParse(value.toString());
          if (parsedNumber == null) {
            return "Must be a number";
          } else if (value!.isEmpty) {
            return 'Phone cannot be empty';
          } else if (value!.length <= 2) {
            return 'Surname is too short';
          }
          return null;
        },
      ),
      SizedBox(height: 20),
      TextFormField(
        controller: _email,
        obscureText: false,
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
        controller: _password,
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
        onPressed: () => setState(() => _showCardInfoForm = true),
        child: Text('Next'),
      ),
    ];
  }

  List<Widget> _buildCardInfoForm() {
    return <Widget>[
      SizedBox(height: 35),
      Text(
        "KazCrowdInvest",
        style: TextStyle(
          color: Colors.pink,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 30),
      TextFormField(
        controller: _bankName,
        obscureText: false,
        decoration: InputDecoration(
          labelText: "Bank Name",
          fillColor: Colors.white.withOpacity(0.8),
          filled: true,
          prefixIcon: Icon(Icons.food_bank),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Cannot be empty';
          } else if (value!.length <= 2) {
            return 'Too short';
          }
          return null;
        },
      ),
      SizedBox(height: 20),
      TextFormField(
        controller: _cardNumber,
        obscureText: false,
        decoration: InputDecoration(
          labelText: "Card Number",
          fillColor: Colors.white.withOpacity(0.8),
          filled: true,
          prefixIcon: Icon(Icons.credit_card),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Cannot be empty';
          } else if (value!.length != 16) {
            return 'Must be 20';
          }
          return null;
        },
      ),
      SizedBox(height: 20),
      TextFormField(
        controller: _cardExpiry,
        obscureText: false,
        decoration: InputDecoration(
          labelText: "Card expiration date",
          fillColor: Colors.white.withOpacity(0.8),
          filled: true,
          prefixIcon: Icon(Icons.date_range),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Cannot be empty';
          }
          return null;
        },
      ),
      SizedBox(height: 20),
      TextFormField(
        controller: _cvv,
        obscureText: false,
        decoration: InputDecoration(
          labelText: "CVV",
          fillColor: Colors.white.withOpacity(0.8),
          filled: true,
          prefixIcon: Icon(Icons.security_rounded),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Cannot be empty';
          }
          return null;
        },
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pinkAccent, // Background color
        ),
        onPressed: signUp,
        child: Text('Sign Up'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pinkAccent,
          title: Text('Registration Page'),
        ),

        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Form(
              key: _formKey,
              child: Center(

                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _showCardInfoForm
                          ? _buildCardInfoForm()
                          : _buildEmailPasswordForm(),
                    ),
                  ),
                ),
              )
          ),
        )
    );
  }

  void signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );

        CollectionReference card = FirebaseFirestore.instance.collection('cards');

        DocumentReference docRef = await card.add({
          'cardNumber': _cardNumber.text.trim().toString(),
          'cardExpiry': _cardExpiry.text.trim().toString(),
          'cvv': _cvv.text.trim().toString(),
          'bankName': _bankName.text.trim().toString(),
          'userId': userCredential.user!.uid.toString(),
          'cardHolderName': _firstName.text.trim().toString()+" "+_lastName.text.trim().toString(),
        });
        String cardId = docRef.id;


        FirebaseFirestore.instance.collection('users').doc(
            userCredential.user!.uid).set({
          'firstName': _firstName.text.trim().toString(),
          'lastName': _lastName.text.trim().toString(),
          'email': _email.text.trim().toString(),
          'verified': false,
          'verification_documents': "",
          'iin': 0,
          'phoneNumber': int.parse(_phoneNumber.text.trim().toString()),
          'balance': 0,
          'cardId': cardId.toString()
        });

        final FlutterSecureStorage _storage = FlutterSecureStorage();
        User? user = userCredential.user;
        String storageUserId = user!.uid.toString();
        await _storage.write(key: 'userId', value: storageUserId);

        await FirebaseFirestore.instance.collection('users').doc(
            userCredential.user!.uid).update({'userId': storageUserId});



        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(userId: storageUserId)),
        );
      } catch (e) {
        print(e);
      }
    }
  }
}