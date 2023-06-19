import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:samal/send_otp.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'Project.dart';
import 'package:intl/intl.dart';


class ProjectDetailsAdminPage extends StatefulWidget {
  final Project project;

  ProjectDetailsAdminPage({required this.project});

  @override
  _ProjectDetailsAdminPageState createState() => _ProjectDetailsAdminPageState();
}

class _ProjectDetailsAdminPageState extends State<ProjectDetailsAdminPage> {


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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FirebaseFirestore.instance.collection('projects').doc(widget.project.projectId).update({'verified': true});
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
