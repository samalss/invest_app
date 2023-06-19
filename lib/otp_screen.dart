import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'MyInvests.dart';
import 'Project.dart';

class Otp extends StatelessWidget {
  Otp({
    Key? key,
    required this.otpController,
  }) : super(key: key);
  final TextEditingController otpController;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: TextFormField(
        controller: otpController,
        keyboardType: TextInputType.number,
        style: Theme.of(context).textTheme.headline6,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly
        ],
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty) {
            FocusScope.of(context).previousFocus();
          }
        },
        decoration: const InputDecoration(
          hintText: ('0'),
        ),
        onSaved: (value) {},
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  final String userId;
  final Project project;
  final String email;
  final int amount;
  const OtpScreen({Key? key,required this.myauth, required this.userId, required this.project, required this.email, required this.amount}) : super(key: key);
  final EmailOTP myauth ;
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {

  TextEditingController otp1Controller = TextEditingController();
  TextEditingController otp2Controller = TextEditingController();
  TextEditingController otp3Controller = TextEditingController();
  TextEditingController otp4Controller = TextEditingController();



  String otpController = "1234";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          const Icon(Icons.dialpad_rounded, size: 50),
          const SizedBox(
            height: 40,
          ),
          const Text(
            "Enter PIN",
            style: TextStyle(fontSize: 40),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Otp(
                otpController: otp1Controller,
              ),
              Otp(
                otpController: otp2Controller,
              ),
              Otp(
                otpController: otp3Controller,
              ),
              Otp(
                otpController: otp4Controller,
              ),
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          const Text(
            "Rider can't find a pin",
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(
            height: 40,
          ),
          ElevatedButton(
            onPressed: () async {
              if (await widget.myauth.verifyOTP(otp: otp1Controller.text +
                  otp2Controller.text +
                  otp3Controller.text +
                  otp4Controller.text) == true) {

                try {
                  final amount = int.parse(widget.amount.toString());
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


                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("OTP is verified"),
                    ));
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) =>  MyInvestmentPage(userId: widget.userId)));

                  } else {
                    print("not auth");
                  }
                } catch (e) {
                  print("parse error");
                }
               } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Invalid OTP"),
                ));
              }
            },
            child: const Text(
              "Confirm",
              style: TextStyle(fontSize: 20),
            ),
          )
        ],
      ),
    );
  }
}