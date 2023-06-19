import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:samal/transactions.dart';


import 'Project.dart';

class AddInvestmentPage extends StatefulWidget {
  final Project project;

  AddInvestmentPage({super.key, required this.project});

  @override
  _AddInvestmentPageState createState() => _AddInvestmentPageState();
}



class _AddInvestmentPageState extends State<AddInvestmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _investmentAmountController = TextEditingController();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final amount = int.parse(_investmentAmountController.text.toString());
        final FirebaseAuth auth = FirebaseAuth.instance;
        String userId="";
        User? user = auth.currentUser;
        if (user != null) {
          setState(() {
            userId = auth.currentUser!.uid.toString();
          });
        }
        final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('projects').where(
            'project_name', isEqualTo: widget.project.projectName).get();
        if (querySnapshot.docs.isNotEmpty) {
          final DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
          final String documentId = documentSnapshot.id;
          final CollectionReference projectsCollection =
          FirebaseFirestore.instance.collection('projects');

          final DocumentReference projectRef = projectsCollection.doc(
              documentId);

          int currentAmount = (int.parse(
              widget.project.projectCurrentCost.toString()) +
              int.parse(amount.toString()));
          print(int.parse(widget.project.projectCurrentCost.toString()));
          projectRef.update({'project_current_cost': currentAmount})
              .then((value) => print("Field successfully updated!"))
              .catchError((error) => print("Failed to update field: $error"));


          if (user != null) {
            CollectionReference investmentsCollection =
            FirebaseFirestore.instance.collection('investments');
            Query query = investmentsCollection
                .where('userId', isEqualTo: userId)
                .where('projectId', isEqualTo: documentId);
            QuerySnapshot querySnapshot = await query.get();
            if (querySnapshot.docs.isNotEmpty) {
              // document already exists, update it with new investDetails
              DocumentSnapshot doc = querySnapshot.docs.first;
              await doc.reference.collection('investDetails').add({
                'date': Timestamp.fromDate(DateTime.now()),
                'amount': amount,
              });
            } else {
              // document doesn't exist, create a new one with given data

              final DocumentReference investmentDocRef = investmentsCollection
                  .doc();

              final Map<String, dynamic> investmentData = {
                'userId': userId,
                'projectId': documentId,
              };



              final DocumentReference investDetailsDocRef = investmentDocRef
                  .collection('investDetails').doc();
              final Map<String, dynamic> investDetailsData = {
                'date': Timestamp.fromDate(DateTime.now()),
                'amount': amount,
              };



              await investmentDocRef.set(investmentData);
              await investDetailsDocRef.set(investDetailsData);
            }
          }



          await FirebaseFirestore.instance.collection('transactions').add({
            'userId': userId.toString(),
            'projectId': documentId,
            'amount': amount,
            'type': "investment",
            'date': Timestamp.fromDate(DateTime.now())
          });


          Navigator.pop(context);
        } else {
          print("not auth");
        }
      } catch (e) {
        print("parse error");
      }
    }
  }

  @override
  void dispose() {
    _investmentAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Investment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _investmentAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Investment Amount',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter investment amount';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Add Investment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
