import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'analytics.dart';

class MyInvestmentPage extends StatefulWidget {
  final String userId;

  MyInvestmentPage({required this.userId});

  @override
  _MyInvestmentPageState createState() => _MyInvestmentPageState();
}

class _MyInvestmentPageState extends State<MyInvestmentPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy, HH:mm');


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Investments"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db
            .collection('investments')
            .where('userId', isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          final List<DocumentSnapshot> investments = snapshot.data!.docs;
          return ListView.builder(
            itemCount: investments.length,
            itemBuilder: (context, index) {
              final invests = investments[index];
              final projectId = invests['projectId'];
              return StreamBuilder<DocumentSnapshot>(
                stream: _db.collection('projects').doc(projectId).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  final project = snapshot.data!;

                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.fact_check_outlined),
                      title: Text(project['project_name'], style: TextStyle(fontSize: 20)),
                      subtitle: Text(project['short_description'], style: TextStyle(fontSize: 17)),
                      trailing: Text(""),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => InvestmentDetailsPage(projectId: project.id, userId: widget.userId, project_name: project['project_name']),
                        ));
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: ElevatedButton(

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnalyticsPage(userId: widget.userId),
            ),
          );
        },
        child: Text('Analytics', style: TextStyle(fontSize: 18)),
      ),
    );
  }

}


class InvestmentDetailsPage extends StatefulWidget {
  final String userId;
  final String projectId;
  final String project_name;
  InvestmentDetailsPage({required this.userId, required this.projectId, required this.project_name});

  @override
  _InvestmentDetailsPageState createState() => _InvestmentDetailsPageState();
}

class _InvestmentDetailsPageState extends State<InvestmentDetailsPage> {
  late Stream<QuerySnapshot> _investDetailsStream;
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy, HH:mm');



  @override
  void initState() {
    super.initState();
    _investDetailsStream = FirebaseFirestore.instance
        .collection('investments')
        .where('userId', isEqualTo: widget.userId)
        .where('projectId', isEqualTo: widget.projectId)
        .limit(1)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.first)
        .asyncMap((docSnapshot) =>
        docSnapshot.reference.collection('investDetails').get());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Investment Details for ${widget.project_name}'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _investDetailsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          List<QueryDocumentSnapshot> investDetails =
          snapshot.data!.docs as List<QueryDocumentSnapshot>;
          return ListView.builder(
            itemCount: investDetails.length,
            itemBuilder: (context, index) {
              final investDetail = investDetails[index];
              final date = _dateFormat.format(investDetail['date'].toDate());
              final amount = investDetail['amount'];
              return ListTile(
                subtitle: Text('Date: $date', style: TextStyle(fontSize: 17),),
                title: Text('Amount: ${NumberFormat('###,###', 'en_US').format(int.parse(amount.toString())).replaceAll(',', ' ')}', style: TextStyle(fontSize: 20)),
              );
            },
          );
        },
      ),
    );
  }
}


/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
class MyInvestmentPage extends StatefulWidget {
  final String uid;

  const MyInvestmentPage({Key? key, required this.uid}) : super(key: key);

  @override
  _MyInvestmentPageState createState() => _MyInvestmentPageState();
}

class _MyInvestmentPageState extends State<MyInvestmentPage> {
  late Stream<List<Project>> _projectsStream;

  @override
  void initState() {
    super.initState();
    _projectsStream = _getInvestedProjects();
  }

  Stream<List<Project>> _getInvestedProjects() {
    return FirebaseFirestore.instance
        .collection('investments')
        .where('userId', isEqualTo: widget.uid)
        .snapshots()
        .asyncMap((querySnapshot) async {
      final projectIds = <String>{};
      for (final doc in querySnapshot.docs) {
        projectIds.add(doc.get('projectId'));
      }

      final projects = <Project>[];
      for (final projectId in projectIds) {
        final projectDoc =
        await FirebaseFirestore.instance.collection('projects').doc(projectId).get();
        if (projectDoc.exists) {
          projects.add(Project.fromSnapshot(projectDoc));
        }
      }
      return projects;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Investments'),
      ),
      body: StreamBuilder<List<Project>>(
        stream: _projectsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No investments found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final project = snapshot.data![index];
              return Card(
                child: ListTile(
                  title: Text(project.title),
                  subtitle: Text(project.description),
                  trailing: Text('\$${project.totalInvestmentByUser(widget.uid)}'),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => InvestmentDetailsPage(projectId: project.id, userId: widget.uid),
                    ));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class InvestmentDetailsPage extends StatefulWidget {
  final String projectDetail;
  final String userId;
  InvestmentDetailsPage({required this.projectDetail, required this.userId});

  @override
  _InvestmentDetailsPageState createState() => _InvestmentDetailsPageState();
}

class _InvestmentDetailsPageState extends State<InvestmentDetailsPage> {
  late Stream<QuerySnapshot> _investmentsStream;
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy, HH:mm');

  @override
  void initState() {
    super.initState();

    // Retrieve the investment details for the project
    _investmentsStream = FirebaseFirestore.instance
        .collection('investments')
        .where('projectId', isEqualTo: widget.projectDetail)
        .where('userId', isEqualTo: widget.userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.projectDetail} - Investment Details'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _investmentsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No investments found'));
          }

          // Build the list of investment details
          List<Widget> investmentDetails = snapshot.data!.docs.map((doc) {
            Map<String, dynamic> investmentData = doc.data() as Map<String, dynamic>;

            return ListTile(
              title: Text(investmentData['project_name']),
              subtitle: Text(_dateFormat.format(investmentData['date'].toDate())),
              trailing: Text('\$${investmentData['investmentAmount']}'),
            );
          }).toList();

          return ListView(children: investmentDetails);
        },
      ),
    );
  }
}

*/
/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyInvestmentPage extends StatefulWidget {
  final String userId;

  const MyInvestmentPage({Key? key, required this.userId}) : super(key: key);

  @override
  _MyInvestmentPageState createState() => _MyInvestmentPageState();
}

class _MyInvestmentPageState extends State<MyInvestmentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Investments'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('investments')
            .where('userId', isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final investmentDocs = snapshot.data!.docs;
          if (investmentDocs.isEmpty) {
            return Center(
              child: Text('No Investments found.'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              var investmentData = snapshot.data?.docs[index];
              return Card(
                child: ListTile(
                  title: Text(investmentData!['project_name']),
                  subtitle: Text('Amount: ${investmentData['investmentAmount']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InvestmentDetailsPage(
                          investment: investmentData,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

*/

