import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samal/user_verification_page.dart';
import 'MyProjects.dart';
import 'Users.dart';
import 'bank_account.dart';


class ProfilePage extends StatefulWidget {
  Function exit_button;

  ProfilePage({required this.exit_button});


  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  String userId = '';


  Future<void> _logout() async {
    await _storage.delete(key: 'userId');
    await _auth.signOut();
    widget.exit_button();
  }

  Future<void> getUserData() async {
    User? user = auth.currentUser;
    if (user != null) {
      setState(() {
        userId = auth.currentUser!.uid;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward_ios_rounded),
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: firestore.collection('users').doc(userId).snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            Map<String, dynamic> data = snapshot.data!.data() as Map<
                String,
                dynamic>;

            Users profile_user = Users(
                userId: userId,
                lastName: data['lastName'].toString(),
                firstName: data['firstName'].toString(),
                iin: int.parse(data['iin'].toString()),
                email: data['email'].toString(),
                phoneNumber: int.parse(data['phoneNumber'].toString()),
                cardNumber: 0,
                verified: data['verified'],
                balance: 0
              //
            );
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 75,
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/person.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                    MyProjectsPage(userId: userId)),
                              );
                            },
                            child: Row(
                              children: const [
                                Icon(Icons.list_alt, color: Colors.indigo,
                                  size: 30,),
                                SizedBox(width: 10),
                                Text(
                                  'My Projects',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                    BankAccountPage(userId: userId)),
                              );
                            },
                            child: Row(
                                children: const [
                                  Icon(Icons.credit_card, color: Colors.indigo,
                                    size: 30,),
                                  SizedBox(width: 14),
                                  Text(
                                    'Credit Card',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ]),
                          ),
                        ],
                      )
                    ],
                  ),

                  SizedBox(height: 30),
                  ListTile(
                    leading: Icon(Icons.person, size: 30,),
                    title: const Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${data['firstName']} ${data['lastName']}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${data['email']}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: Text(
                      'Phone',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${data['phoneNumber']}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.privacy_tip),
                    title: Text(
                      'IIN',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${data['iin']}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.verified_user),
                    title: Text(
                      'Verification Status',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: profile_user.verified
                        ? Icon(Icons.check_circle)
                        : ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              UserVerificationPage(
                                  uid: auth.currentUser!.uid.toString())),
                        );
                      },
                      child: Text('Verify your account'),
                    ),
                  ),

                ],
              ),
            );
          } else {
            return const Center(
              child: Text('No data available'),
            );
          }
        },
      ),

    );
  }
}