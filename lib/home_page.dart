import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'Project.dart';
import 'ProjectDetails.dart';



class HomePage extends StatefulWidget {
  final String userId;
  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> projects;


  Future<String> _getUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('User not found');
    }
  }


  @override
  void initState() {
    super.initState();
    projects = firestore.collection('projects').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: projects,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No projects found'),
            );
          }
          final projects = snapshot.data!.docs;

          List<Project> list = [];

          for (int i = 0; i < projects.length; i++) {
            final project = projects[i].data() as Map<String, dynamic>;
            if (project['verified']) {
              Project data = Project(
                projectId: project['projectId'].toString(),
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
                interest: int.parse(project['interest'].toString()),
                img: project['img'].toString(),
                short_description: project['short_description'].toString(),
              );
              list.add(data);
            }
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProjectDetails(project: list[index], userId: widget.userId),
                    ),
                  );
                },
                child: Card(

                    child: Column(
                      children: [
                        Image.network(
                          list[index].img,
                          fit: BoxFit.cover,
                          height: 170,
                          width: 410,
                        ),
                        ListTile(
                          title: Text(list[index].projectName, style: TextStyle(fontSize: 20),),
                          subtitle: Text(list[index].short_description,  style: TextStyle(fontSize: 17)),
                          trailing: Icon(Icons.arrow_forward_ios_outlined),
                        ),
                      ],
                    )
                ),
              );
            },
          );
        },
      ),
    );
  }
}
