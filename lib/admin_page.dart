import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samal/project_detail_for_admin.dart';

import 'Project.dart';
import 'main.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}



class _AdminPageState extends State<AdminPage> {
  CollectionReference projects = FirebaseFirestore.instance.collection(
      'projects');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  void _showDeleteConfirmationDialog(BuildContext context, Project project,
      var doc, var projects, var index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete project"),
          content: Text("Are you sure you want to delete this project?"),
          actions: <Widget>[
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () async {
                // Delete project from Firebase database
                await FirebaseFirestore.instance
                    .collection('projects')
                    .doc(doc.id)
                    .delete();

                // Update project list
                setState(() {
                  projects.removeAt(index);
                });

                // Close dialog
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    await _storage.delete(key: 'userId');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => AuthenticationPage()),
            (Route<dynamic> route) => false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Moderator Page"),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: _signOut,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('projects').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<DocumentSnapshot> projects = snapshot.data!.docs;

          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (BuildContext context, int index) {
              final doc = snapshot.requireData.docs[index];
              final project = projects[index].data() as Map<String, dynamic>;
              Project data = Project(
                projectName: project['project_name'].toString(),
                projectDescription: project['project_description'].toString(),
                projectTotalCost: int.parse(
                    project['project_total_cost'].toString()),
                projectCurrentCost: int.parse(
                    project['project_current_cost'].toString()),
                userId: project['user_id'].toString(),
                verified: project['verified'],
                project_created_date: project['project_created_date'],
                verification_documents: project['verification_documents'],
                interest: project['interest'],
                projectId: project['projectId'],
                img: project['img'],
                short_description: project['short_description'],
              );
              return Dismissible(
                  key: Key(data.projectName),
                  background: Container(color: Colors.red),
                  child: Card(

                    child: Column(
                      children: [
                        Image.network(
                          data.img,
                          fit: BoxFit.cover,
                          height: 150,
                          width: 410,
                        ),
                        ListTile(

                          title: Text(data.projectName,
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              )
                          ),
                          subtitle: Text(data.short_description),
                          leading: Checkbox(
                            value: project['verified'],
                            onChanged: (value) {
                              FirebaseFirestore.instance.collection('projects').doc(
                                  doc
                                      .id).update({'verified': value});
                            },
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              // Delete project from database
                              _showDeleteConfirmationDialog(
                                  context, data, doc, projects, index);
                              // Remove project from local list
                              setState(() {
                                projects.removeAt(index);
                              });
                            },
                          ),
                          onTap: () {
                            // Navigate to ProjectDetailsAdminPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProjectDetailsAdminPage(project: data),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                  )
              );
            },
          );
        },

      ),

    );
  }
}