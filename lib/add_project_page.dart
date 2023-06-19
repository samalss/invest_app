import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Project.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'ProjectDetails.dart';

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';



class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage>  with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _shortController = TextEditingController();
  final TextEditingController _totalCostController = TextEditingController();
  final TextEditingController _currentCostController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _pdfFile;
  File? imageFile;
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  UploadTask? _uploadTaskPDF;
  UploadTask? _uploadTaskPNG;
  bool _isUploading = false;
  String downloadUrl = "";
  String downloadURLPNG="";
  late Project project;

  late var _key;
  late File _file;
  bool isSubmitted = false;


  Future<String> _getUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('User not found');
    }
  }


  Future<Uint8List> _generateRandomKey() async {
    final secureRandom = Random.secure();
    final key = List.generate(32, (i) => secureRandom.nextInt(256));
    return Uint8List.fromList(key);
  }


  Future<File> _encryptFile(File file, Uint8List key) async {
    final bytes = await file.readAsBytes();
    final iv = _generateRandomIv();
    final cipher = encrypt.AES(
        encrypt.Key(key), mode: encrypt.AESMode.cbc, padding: 'PKCS7');
    final encrypted = await cipher.encrypt(bytes, iv: encrypt.IV(iv));
    final encryptedBytes = Uint8List.fromList(encrypted.bytes);
    final encryptedFile = await _writeBytesToFile(encryptedBytes);
    final docRef = FirebaseFirestore.instance.collection('keys').doc();
    final String uid = await _getUserId();
    await docRef.set({
      'key': base64Url.encode(bytes),
      'doc': uid
    });
    return encryptedFile;
  }

  Uint8List _generateRandomIv() {
    final secureRandom = Random.secure();
    final iv = List.generate(16, (i) => secureRandom.nextInt(256));
    return Uint8List.fromList(iv);
  }

  Future<File> _writeBytesToFile(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/encryptedfile.pdf';
    final file = File(path);
    await file.writeAsBytes(bytes);
    return file;
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

  Future<void> _pickIMG() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _submitForm() async {
    final String uid = await _getUserId();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_pdfFile == null) return;
      String fileName = uid.toString();

      // Generate a random 256-bit AES key
      final key = await _generateRandomKey();
      // Read the file
      // Encrypt the file using AES-256 in CBC mode with PKCS7 padding
      final encryptedFile = await _encryptFile(_pdfFile!, key);
      // Upload the encrypted file to Firebase Storage
      // Encode the key as a string (Base64 encoding)
      final encodedKey = base64.encode(key);
      // Store the encoded key in the database (e.g. Firestore)
      setState(() {
        _key = encodedKey;
        _file = encryptedFile!;
      });
      Reference storageRefPDF = FirebaseStorage.instance.ref().child(
          'project_documents/${_nameController.text.trim().toString()}/$fileName');


      String storagePath = 'project_documents/${_nameController.text.trim().toString()}/Projects_Image';

      final Reference storageRefIMG = FirebaseStorage.instance.ref().child(
          storagePath);




      setState(() {
        _isUploading = true;
        _uploadTaskPDF = storageRefPDF.putFile(_pdfFile!);
        _uploadTaskPNG = storageRefIMG.putFile(imageFile!);
      });

      TaskSnapshot snapshot = await _uploadTaskPDF!.whenComplete(() {});

      downloadURLPNG = (await (await _uploadTaskPNG)?.ref.getDownloadURL())!;
      downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _isUploading = false;
      });

      project = Project(
          projectId: "",
          projectName: _nameController.text,
          projectDescription: _descriptionController.text,
          projectTotalCost: int.parse(_totalCostController.text),
          projectCurrentCost: int.parse(_currentCostController.text),
          userId: uid,
          verified: false,
          project_created_date: Timestamp.fromDate(DateTime.now()),
          verification_documents: downloadUrl,
          interest: int.parse(_interestController.text),
          img: downloadURLPNG,
          short_description: _shortController.text,
      );


      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File Uploaded Successfully')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }


    final User? user = FirebaseAuth.instance.currentUser;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (userDoc.exists && userDoc.get('verified')) {
      // Proceed with adding the project to the database


      final newDocRef = await FirebaseFirestore.instance.collection('projects')
          .add({
        'project_name': project.projectName,
        'project_description': project.projectDescription,
        'project_total_cost': project.projectTotalCost,
        'project_current_cost': project.projectCurrentCost,
        'user_id': project.userId,
        'verified': project.verified,
        'project_created_date': project.project_created_date,
        'verification_documents': project.verification_documents,
        'projectId': project.projectId,
        'status': "active",
        'img': project.img,
        'interest': int.parse(project.interest.toString()),
        'short_description': project.short_description.toString(),
      });

      final newDocId = newDocRef.id;

      // Update the project document with the ID
      await newDocRef.update({'projectId': newDocId});
    }

    else {
      // Show an alert dialog to inform the user that they do not have permissions
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text('Permission Denied'),
              content: Text('Only verified users can add Projects'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      );
    }
    _nameController.clear();
    _descriptionController.clear();
    _totalCostController.clear();
    _currentCostController.clear();
    _interestController.clear();
    _shortController.clear();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProjectDetails(project: project, userId: uid,)),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(
          child: Container(
            height: 30,
            child: LiquidLinearProgressIndicator(
              value: 0.8,
              // Set the progress value between 0.0 and 1.0
              valueColor: AlwaysStoppedAnimation(Colors.blue[600]!),
              // Customize the color
              backgroundColor: Colors.grey[300],
              // Customize the background color
              borderColor: Colors.black,
              // Customize the border color
              borderWidth: 5.0,
              // Customize the border width
              direction: Axis.horizontal,
              // Customize the direction (horizontal or vertical)
              center: Text('Encrypting...', style: GoogleFonts.roboto(
                fontSize: 20.0,
                color: Colors.black,
              ),), // Customize the center widget
            ),
          ),
        )
            : Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Project Name',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a project name';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _shortController,
                    decoration: InputDecoration(
                      labelText: 'Projects Short Description',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a project description';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Project Description',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a project description';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _totalCostController,
                    decoration: InputDecoration(
                      labelText: 'Total Cost',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the total cost of the project';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _currentCostController,
                    decoration: InputDecoration(
                      labelText: 'Current Cost',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the current cost of the project';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _interestController,
                    decoration: InputDecoration(
                      labelText: 'Projects interest Rate',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the interest rate of the project';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Card(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            'Upload Projects Image',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _pickIMG,
                            icon: Icon(Icons.upload_file),
                            label: Text('Choose Image'),
                          ),
                          const SizedBox(width: 10),
                          if (imageFile != null) Text(
                              'Selected file: ${imageFile!
                                  .path
                                  .split('/')
                                  .last}'),
                          SizedBox(height: 10),
                          /*TextFormField(
                    controller: _imageController,
                    decoration: InputDecoration(
                      labelText: 'Enter Images url',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a project description';
                      }
                      return null;
                    },
                  ),*/
                        ]
                    )
                ),
              ),
              Card(
                  child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            'Upload Project Documents',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _pickPDF,
                            icon: Icon(Icons.upload_file),
                            label: Text('Choose PDF'),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(height: 10),

                          if (_pdfFile != null) Text(
                              'Selected file: ${_pdfFile!
                                  .path
                                  .split('/')
                                  .last}'),
                        ],
                      )
                  )
              ),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Add Project'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
