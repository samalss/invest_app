import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UserVerificationPage extends StatefulWidget {
  final String uid;

  const UserVerificationPage({Key? key, required this.uid}) : super(key: key);

  @override
  _UserVerificationPageState createState() => _UserVerificationPageState();
}

class _UserVerificationPageState extends State<UserVerificationPage> {
  File? _pdfFile;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _iinController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  UploadTask? _uploadTask;
  bool _isLoading = false;
  String downloadURLPNG="";
  Future<void> _uploadFile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_pdfFile == null) return;

      String fileName = widget.uid.toString();

      Reference storageRef = FirebaseStorage.instance.ref().child(
          'verification-documents/$fileName');

      setState(() {
        _uploadTask = storageRef.putFile(_pdfFile!);
      });

      TaskSnapshot snapshot = await _uploadTask!.whenComplete(() {});

      String downloadUrl = await snapshot.ref.getDownloadURL();

      FirebaseFirestore.instance.collection('users').doc(widget.uid).update(
          {'verification_documents': downloadUrl});
      FirebaseFirestore.instance.collection('users').doc(widget.uid).update(
          {'lastName': _surnameController.text.trim().toString()});
      FirebaseFirestore.instance.collection('users').doc(widget.uid).update(
          {'firstName': _nameController.text.trim().toString()});
      FirebaseFirestore.instance.collection('users').doc(widget.uid).update(
          {'iin': int.parse(_iinController.text.trim().toString())});

      downloadURLPNG = (await (await _uploadTask)?.ref.getDownloadURL())!;

      FirebaseFirestore.instance.collection('users').doc(widget.uid).update(
          {'img': downloadURLPNG});


      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File Uploaded Successfully')));
      Navigator.pop(context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        setState(() {
          _pdfFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('User Verification'),
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('users').doc(widget.uid).snapshots(),
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

                if (data['verification_documents'].toString() != "") {
                  return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text(
                          'You have already uploaded a verification document. Please wait for the admin to verify your account.',
                          style: TextStyle(fontSize: 25)
                      )
                      )

                  );
                } else {
                  return SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text('Step 1: Enter your information', style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),),
                                    SizedBox(height: 16.0),
                                    TextFormField(
                                      controller: _surnameController,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        labelText: "Name",
                                        fillColor: Colors.white.withOpacity(
                                            0.8),
                                        filled: true,
                                        prefixIcon: Icon(Icons.person),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius
                                              .circular(8.0),
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
                                    SizedBox(height: 8.0),
                                    TextFormField(
                                      controller: _nameController,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        labelText: "Surname",
                                        fillColor: Colors.white.withOpacity(
                                            0.8),
                                        filled: true,
                                        prefixIcon: Icon(Icons.person),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius
                                              .circular(8.0),
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
                                    SizedBox(height: 8.0),
                                    TextFormField(
                                      controller: _iinController,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        labelText: "IIN",
                                        fillColor: Colors.white.withOpacity(
                                            0.8),
                                        filled: true,
                                        prefixIcon: Icon(
                                            Icons.privacy_tip_outlined),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius
                                              .circular(8.0),
                                        ),
                                      ),
                                      validator: (value) {
                                        int? parsedNumber = int.tryParse(
                                            value.toString());
                                        if (parsedNumber == null) {
                                          return "Must be a number";
                                        } else if (value!.isEmpty) {
                                          return 'IIN cannot be empty';
                                        } else if (value!.length != 12) {
                                          return 'Must be 12 digits';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Card(
                              child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                        'Step 2: Upload Your Document',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 20),
                                      ElevatedButton.icon(
                                        onPressed: _pickPDF,
                                        icon: Icon(Icons.upload_file),
                                        label: Text('Choose PDF'),
                                      ),
                                      SizedBox(height: 10),
                                      if (_pdfFile != null) Text(
                                          'Selected file: ${_pdfFile!
                                              .path
                                              .split('/')
                                              .last}'),
                                      SizedBox(height: 20),
                                    ],
                                  )
                              )
                          ),
                          Card(
                              child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        const Text(
                                          'Step 3: Submit Your Verification',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight
                                                  .bold),
                                        ),
                                        SizedBox(height: 20),
                                        _isLoading
                                            ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                            : ElevatedButton.icon(
                                          onPressed: _uploadFile,
                                          icon: Icon(Icons.cloud_upload),
                                          label: Text(
                                              'Upload Verification'),
                                        ),
                                      ]
                                  )

                              )
                          ),
                        ]
                    ),
                  );
                }
              } else {
                return const Center(
                  child: Text('No data available'),
                );
              }
            }

        )
    );
  }
}
