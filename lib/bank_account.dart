import 'package:awesome_card/credit_card.dart';
import 'package:awesome_card/extra/card_type.dart';
import 'package:awesome_card/style/card_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:samal/deposit.dart';
import 'BankStatement.dart';
import 'transactions.dart';

class BankAccountPage extends StatefulWidget {
  final String userId;

  const BankAccountPage({Key? key, required this.userId}) : super(key: key);

  @override
  _BankAccountPageState createState() => _BankAccountPageState();
}

class _BankAccountPageState extends State<BankAccountPage> {
  List<AllTransactions> _alltransactions = [];

  Future<List<AllTransactions>> getTransactionsForUser(String userId) async {
    List<AllTransactions> transactions = [];
    final querySnapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .get();

    for (final transaction in querySnapshot.docs) {
      final data = transaction.data();
      transactions.add(AllTransactions(
          date: data['date'],
          amount: double.parse(data['amount'].toString()),
          type: data['type']));
    }
    transactions.sort(AllTransactions.compareByTime);
    return transactions;
  }

  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy, HH:mm');


  final FirebaseFirestore _db = FirebaseFirestore.instance;


  String formatCardNumber(int cardNumber) {
    String cardString = cardNumber.toString();
    RegExp regex = RegExp(r".{1,4}");
    Iterable<Match> matches = regex.allMatches(cardString);
    List<String?> groups = matches.map((match) => match.group(0)).toList();
    return groups.join(" ");
  }

  @override
  void initState() {
    super.initState();
    getTransactionsForUser(widget.userId).then((alltransactions) {
      setState(() {
        _alltransactions = alltransactions;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Credit Card'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _db.collection('users')
            .doc(widget.userId.toString())
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          final user = snapshot.data!;
          // Get the card ID from the user document
          final String cardId = user['cardId'].toString();
          final String iin=user['iin'].toString();
          return StreamBuilder<DocumentSnapshot>(
            stream: _db.collection('cards').doc(cardId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                    child: CircularProgressIndicator()
                );
              }
              final card = snapshot.data!;

              return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      children: [
                        CreditCard(
                            cardNumber: formatCardNumber(
                                int.parse(card['cardNumber'].toString())),
                            cardExpiry: card['cardExpiry'],
                            cardHolderName: card['cardHolderName'],
                            cvv: card['cvv'].toString(),
                            bankName: card['bankName'],
                            cardType: CardType.masterCard,
                            // Optional if you want to override Card Type
                            showBackSide: false,
                            frontBackground: CardBackgrounds.black,
                            backBackground: CardBackgrounds.black,
                            showShadow: true,
                            textExpDate: 'Exp. Date',
                            textName: 'Name',
                            textExpiry: 'MM/YY'
                        ),
                        // Transaction history section
                        SizedBox(height: 10.0),
                        ListTile(

                          trailing: Text(
                            'Balance: ${NumberFormat('###,###', 'en_US').format(int.parse(user['balance'].toStringAsFixed(0))).replaceAll(',', ' ')} KZT',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          'Transaction History',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _alltransactions.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BankStatementPage(iin: iin,
                                                userId: widget.userId,
                                                card: card,
                                                date: _dateFormat.format(
                                                    _alltransactions[index].date
                                                        .toDate()),
                                                amount: _alltransactions[index]
                                                    .amount
                                                    .toStringAsFixed(0)),
                                      ),
                                    );
                                  },
                                  child: ListTile(
                                    leading: Icon(
                                      _alltransactions[index].type ==
                                          "investment"
                                          ? Icons.trending_up
                                          : _alltransactions[index].type ==
                                          "withdrawal"
                                          ? Icons.trending_down
                                          : Icons.money,
                                      color: _alltransactions[index].type ==
                                          "investment"
                                          ? Colors.green
                                          : _alltransactions[index].type ==
                                          "withdrawal"
                                          ? Colors.red
                                          : Colors.blue,
                                      size: 30,
                                    ),
                                    title: Text(_alltransactions[index].type
                                        .toString()
                                        .split('.')
                                        .last, style: TextStyle(fontSize: 19.0,)),
                                    subtitle: Text('${_dateFormat.format(
                                        _alltransactions[index].date
                                            .toDate())}',  style: TextStyle(fontSize: 18.0,)),
                                    trailing: Text(
                                      NumberFormat('###,###', 'en_US').format(int.parse(_alltransactions[index].amount
                                          .toStringAsFixed(0))).replaceAll(',', ' ')+" KZT",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        color: _alltransactions[index].type ==
                                            "investment"
                                            ? Colors.green
                                            : _alltransactions[index].type ==
                                            "withdrawal"
                                            ? Colors.red
                                            : Colors.blue,
                                      ),
                                    ),
                                  )
                              );
                            },
                          ),
                        ),
                      ]
                  )
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DepositPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}


