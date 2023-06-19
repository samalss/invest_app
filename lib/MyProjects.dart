import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:samal/ProjectDetails.dart';

import 'Project.dart';


class MyProjectsPage extends StatefulWidget {
  final String userId;

  MyProjectsPage({required this.userId});

  @override
  _MyProjectsPageState createState() => _MyProjectsPageState();
}

class _MyProjectsPageState extends State<MyProjectsPage> {
  late Stream<QuerySnapshot> _projectsStream;
  List<DocumentSnapshot> _projects = [];
  int _completedProjectsCount = 0;
  int _activeProjectsCount=0;

  @override
  void initState() {
    super.initState();
    _projectsStream = FirebaseFirestore.instance
        .collection('projects')
        .where('user_id', isEqualTo: widget.userId)
        .snapshots();

    _projectsStream.listen((QuerySnapshot snapshot) {
      setState(() {
        _projects = snapshot.docs;
        _completedProjectsCount = _calculateCompletedProjectsCount();
        _activeProjectsCount = _calculateActiveProjectsCount();
      });
    });
  }

  int _calculateActiveProjectsCount() {
    int count = 0;
    for (var projectDoc in _projects) {
      final project = projectDoc.data() as Map<String,dynamic>;
      if (project['status'] == 'active') {
        count++;
      }
    }
    return count;
  }


  int _calculateCompletedProjectsCount() {
    int count = 0;
    for (var projectDoc in _projects) {
      final project = projectDoc.data() as Map<String,dynamic>;;
      if (project['status'] == 'completed') {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Projects'),
      ),
      body:
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('projects')
            .where('user_id', isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final projects = snapshot.data?.docs ?? [];

          return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(50,20,65,15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Completed',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                '${_completedProjectsCount}',
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[600],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'In Progress',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                '${_activeProjectsCount}',
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          final project = projects[index].data() as Map<String,dynamic>;
                          Project data = Project(
                            projectId: project['projectId'].toString(),
                            projectName: project['project_name'].toString(),
                            projectDescription: project['project_description']
                                .toString(),
                            projectTotalCost: int.parse(
                                project['project_total_cost'].toString()),
                            projectCurrentCost: int.parse(
                                project['project_current_cost'].toString()),
                            userId: project['user_id'].toString(),
                            verified: project['verified'],
                            project_created_date: project['project_created_date'],
                            verification_documents: project['verification_documents'],
                            interest: int.parse(project['interest'].toString()),
                            img: project['img'].toString(),
                            short_description: project['short_description']
                                .toString(),
                          );

                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.symmetric(horizontal: 10,
                                vertical: 5),
                            child: ListTile(
                              title: Text(
                                project['project_name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(project['short_description']),
                              leading: Icon(
                                Icons.folder,
                                color: Colors.blue,
                              ),
                              trailing: Icon(Icons.arrow_forward_ios_rounded),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>
                                      ProjectDetails(
                                          project: data, userId: widget.userId)),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    )
                  ]
              )
          );
        },
      ),

    );
  }
}