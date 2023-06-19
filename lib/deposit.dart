import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DepositPage extends StatefulWidget {
  @override
  _DepositPageState createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  bool _isProcessing = false;

  void _addDeposit() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    final amount = double.parse(_amountController.text.trim());

    // Add the deposit amount to the user's balance
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .update({'balance': FieldValue.increment(amount)});

    // Add the deposit transaction to the transactions collection

    final date = Timestamp.fromDate(DateTime.now());
    await FirebaseFirestore.instance.collection('transactions').add({
      'date': date,
      'amount': amount,
      'type': 'deposit',
      'userId': user?.uid,
    });

    setState(() {
      _isProcessing = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Deposit added successfully')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Deposit'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'Amount'),
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Please enter amount';
                    } else if (double.tryParse(value.trim()) == null) {
                      return 'Please enter a valid number';
                    } else if (double.parse(value.trim()) <= 0) {
                      return 'Amount must be greater than zero';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _isProcessing ? null : _addDeposit,
                  child: _isProcessing
                      ? CircularProgressIndicator()
                      : Text('Add Deposit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
