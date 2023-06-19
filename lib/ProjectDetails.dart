import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Project.dart';
import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:samal/send_otp.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:intl/intl.dart';


class ProjectDetails extends StatefulWidget {
  final Project project;
  final String userId;
  ProjectDetails({required this.project, required this.userId});

  @override
  _ProjectDetailsState createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> {


  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy, HH:mm');


  @override
  Widget build(BuildContext context) {
    String percentageRaised = ((widget.project.projectCurrentCost /
        widget.project.projectTotalCost) * 100).toStringAsFixed(0);
    int value = int.parse(percentageRaised);
    if (value > 100) value = 100;


    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.projectName),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.network(
                        widget.project.img,
                        fit: BoxFit.cover,
                        height: 170,
                        width: 378,
                      ),
                    ],
                  ),
                  SizedBox(height: 15.0),
                  Row(
                    children: [
                    Text(
                      'Project Verification: ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                    ),
                    widget.project.verified
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : Icon(Icons.error, color: Colors.red),
                    ]
                  ),
                  SizedBox(height: 10.0),
                  const Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                  ),
                  SizedBox(height: 5.0),
                  Text(widget.project.projectDescription, style: TextStyle(fontSize: 19)),
                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      const Text(
                        'Project Interest Rate: ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                      ),
                      Text(widget.project.interest.toString()+"%", style: TextStyle(fontSize: 19)),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      const Text(
                        'Total cost: ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                      ),
                      Text( NumberFormat('###,###', 'en_US').format(int.parse(widget.project.projectTotalCost.toString())).replaceAll(',', ' ')+" KZT",  style: TextStyle(fontSize: 19)),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      const Text(
                        'Current cost: ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)
                      ),
                      Text( NumberFormat('###,###', 'en_US').format(int.parse(widget.project.projectCurrentCost.toString())).replaceAll(',', ' ')+" KZT",  style: TextStyle(fontSize: 19)),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      const Text(

                        'Date: ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                      ),
                      Text(_dateFormat.format(
                          widget.project.project_created_date.toDate()),  style: TextStyle(fontSize: 19)),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => View(url: widget.project.verification_documents),
                        ),
                      );

                    },
                    icon: Icon(Icons.file_open_outlined),
                    label: Text('Open the Documents'),
                  ),
                  SizedBox(height: 20),
                  Text("Funding Progress: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
                  SizedBox(height: 20),

                  Center(
                    child: SizedBox(
                      child: Stack(
                        children: [
                          SizedBox(height: 16),
                          CircularPercentIndicator(
                            radius: 50.0,
                            lineWidth: 15.0,
                            animation: true,
                            percent: value*0.01,
                            center: Text(
                              "$value%",
                              style:
                              const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 19.0),
                            ),

                            footer: const Text(
                              "Completion",
                              style:
                              TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 19.0),
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),


                ],
              ),
            ),

          ],

        ),

      ),
      floatingActionButton: ElevatedButton(

        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentVerification(project: widget.project, userId: widget.userId,),
            ),
          );
        },
        child: Text('Invest',  style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
class View extends StatelessWidget {
  final String url;
  Future<File> _decryptPdf(File inputFile) async {
    // Retrieve the decryption key from the database
    final snapshot = await FirebaseFirestore.instance.collection('keys').get();
    final key = snapshot.docs.first.get('key');


    // Decrypt the PDF file with the key
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypt.Encrypted(inputFile as Uint8List);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    var outputFile = await _getOutputFile();
    outputFile = decrypted as File;


    return outputFile;
  }
  Future<File> _getOutputFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/output.pdf';
    final outputFile = File(path);

    return outputFile;
  }

  const View({ required this.url});

  @override
  Widget build(BuildContext context) {
    PdfViewerController _pdfViewerController = PdfViewerController();
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Viewer"),
      ),
      body: SfPdfViewer.network(
        _decryptPdf
        as String,
        controller: _pdfViewerController,
      ),
    );
  }





















  getApplicationDocumentsDirectory() {}
}
