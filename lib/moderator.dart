import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'main.dart';

class ModeratorPage extends StatefulWidget {
  @override
  _ModeratorPageState createState() => _ModeratorPageState();
}

class _ModeratorPageState extends State<ModeratorPage> {
  late Stream<QuerySnapshot> usersStream;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // Fetch the users collection from Firebase Firestore
    usersStream = FirebaseFirestore.instance.collection('users').snapshots();
  }
  Future<void> _logout() async {
    await _storage.delete(key: 'userId');
    await _auth.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => AuthenticationPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward_ios_rounded),
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          // Extract the user documents from the snapshot
          final users = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              return ListTile(

                title: Text(user['firstName']+' '+user['lastName'], style: TextStyle(fontSize: 20)),
                subtitle: Text(user['email']),
                leading: Checkbox(
                  value: user['verified'],
                  onChanged: (value) {
                    FirebaseFirestore.instance.collection('users').doc(user['userId']).update({'verified': value});
                  },
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    // Delete project from Firebase database
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user['userId'].toString())
                        .delete();

                    // Update project list
                    setState(() {
                      user.remove(index);
                    });
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailsPage(user: user),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class UserDetailsPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserDetailsPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ListTile(
              leading: Icon(Icons.person, size: 30),
              title: Row(
                  children: [
                    Text(
                      '${user['lastName'] + " " + user['firstName']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22.0,
                      ),
                    ),
                    SizedBox(width: 10),
                    user['verified']
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : Icon(Icons.error, color: Colors.red),
                  ]
              ),

            ),
            ListTile(
              leading: Icon(Icons.email, size: 28),
              title: Text(
                'Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              subtitle: Text(user['email'], style: TextStyle(
                fontSize: 22.0,
              ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip, size: 28),
              title: Text(
                'IIN',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              subtitle: Text(user['iin'].toString(), style: TextStyle(
                fontSize: 22.0,
              ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.phone, size: 28),
              title: Text(
                'Phone',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              subtitle: Text(user['phoneNumber'].toString(), style: TextStyle(
                fontSize: 22.0,
              ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.file_copy_sharp, size: 28),

              title: user['verified'] ? Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            View(url: user['verification_documents']),
                      ),
                    );
                  },
                  icon: Icon(Icons.file_copy_sharp, size: 28),
                  label: const Text(
                    'Open the Documents', style: TextStyle(fontSize: 20),),
                ),
              ) : const Text(
                      'No documents',
                      style: TextStyle(fontSize: 22)
                  )
              ),
            // Add more user details here
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FirebaseFirestore.instance.collection('users')
              .doc(user['userId'])
              .update({'verified': true});
          Navigator.of(context).pop();
          // implement project verification functionality
        },
        child: Icon(Icons.check),
      ),
    );
  }
}


class View extends StatelessWidget {
  final String url;

  const View({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PdfViewerController _pdfViewerController = PdfViewerController();
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Viewer"),
      ),
      body: SfPdfViewer.network(
        url,
        controller: _pdfViewerController,
      ),
    );
  }
}