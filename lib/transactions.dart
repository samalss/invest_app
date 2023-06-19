import 'package:cloud_firestore/cloud_firestore.dart';

class AllTransactions {
  final String type; // deposit or withdrawal
  final double amount;
  final Timestamp date;

  AllTransactions({
    required this.type,
    required this.amount,
    required this.date,
  });

  factory AllTransactions.fromMap(Map<String, dynamic> map) {
    return AllTransactions(
      type: map['type'],
      amount: map['amount'],
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap(String userId) {
    return {
      'type': type,
      'amount': amount,
      'date': date,
      'userId': userId
    };
  }
  static int compareByTime(AllTransactions a, AllTransactions b) {
    return b.date.compareTo(a.date);
  }
}
