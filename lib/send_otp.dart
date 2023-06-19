import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'Project.dart';
import 'otp_screen.dart';
import 'package:flutter/material.dart';

class PaymentVerification extends StatefulWidget {
  final String userId;
  final Project project; 
  PaymentVerification({required this.userId, required this.project});

  @override
  State<PaymentVerification> createState() => _PaymentVerificationState();
}

class _PaymentVerificationState extends State<PaymentVerification> {
  final amount = TextEditingController();
  String email="";
  Future<void> getUserEmail(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        email=data['email'];
      }
    } catch (error) {
      print('Error retrieving user email: $error');
    }
  }
  EmailOTP myauth = EmailOTP();
  @override
  void initState() {
    super.initState();
    getUserEmail(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction security'),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Image.network(
              "https://img.freepik.com/free-vector/emails-concept-illustration_114360-1355.jpg?w=1380&t=st=1673699432~exp=1673700032~hmac=d65454eb5c72e8310209bf8ae770f849ea388f318dc6b9b1300b24b03e8886ca",
              height: 300,
            ),
          ),
          const SizedBox(
            height: 60,
            child: Text(
              "Enter the Investment amount",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            child: Column(
              children: [
                TextField(
                  controller: amount,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.attach_money,
                    ),
                    suffixIcon: IconButton(
                        onPressed: () async {
                          myauth.setConfig(
                              appEmail: "samal200174@gmail.com",
                              appName: "KazCrowdInvest Email OTP",
                              userEmail: email,
                              otpLength: 4,
                              otpType: OTPType.digitsOnly);
                          if (await myauth.sendOTP() == true) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("OTP has been sent"),
                            ));
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>   OtpScreen(myauth: myauth, userId: widget.userId, project: widget.project, email: email, amount: int.parse(amount.text.toString()),)));
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Oops, OTP send failed"),
                            ));
                          }
                        },
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.teal,
                        )),
                    hintText: "Investment Amount",
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}