import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BankStatementPage extends StatefulWidget {
  final String userId;
  final DocumentSnapshot<Object?> card;
  final String date;
  final String amount;
  final String iin;
  BankStatementPage({required this.userId, required this.card, required this.date, required this.amount, required this.iin});

  @override
  _BankStatementPageState createState() => _BankStatementPageState();
}

  class _BankStatementPageState extends State<BankStatementPage> {

    String maskCardNumber(String cardNumber) {
      final visibleDigits = 4;
      final maskChar = '*';

      // Check if the card number is null or empty
      if (cardNumber == null || cardNumber.isEmpty) {
        return '';
      }

      // Apply the masking logic using a regular expression
      final maskedCardNumber = cardNumber.replaceAllMapped(
        RegExp(r'(?<=\d{4})\d(?=\d{4})'), // Matches a single digit between two groups of four digits
            (match) => maskChar,
      );

      return maskedCardNumber;
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bank Statement'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FlutterLogo(size: 48.0), // Replace with your app logo
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              'Payment Order',
              style: GoogleFonts.roboto(
                fontSize: 24.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              widget.date, // Replace with the actual date
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Table(
              columnWidths: {
                0: FlexColumnWidth(0.6),
                1: FlexColumnWidth(0.4),
              },
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sender',
                            style: GoogleFonts.roboto(
                              fontSize: 20.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text('Name: ${widget.card['cardHolderName']}',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),),
                          Text('IIN: ${widget.iin}',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),),
                          Text('Bank: ${widget.card['bankName']}',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),),
                          Text('Card: ${
                              maskCardNumber(widget.card['cardNumber'].toString())
                          }',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),),
                        ],
                      ),
                    ),
                    TableCell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Beneficiary',
                            style: GoogleFonts.roboto(
                              fontSize: 20.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),

                          ),
                          SizedBox(height: 8.0),
                          Text('Name: KazCrowdInvest',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),),
                          Text('IIN: 0987654321',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              'Amount: ${NumberFormat('###,###', 'en_US').format(int.parse(widget.amount)).replaceAll(',', ' ')} KZT',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            Text(
              'Value date: ${widget.date.substring(0, widget.date.length - 7)}', // Replace with the actual date
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            Text(
              'Status: Executed',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
