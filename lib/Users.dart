class Users {
  final String userId;
  final String firstName;
  final String lastName;
  final int iin;
  final String email;
  final int phoneNumber;
  final int cardNumber;
  final bool verified;
  double balance;

  Users({
    required this.firstName,
    required this.lastName,
    required this.iin,
    required this.email,
    required this.phoneNumber,
    required this.cardNumber,
    required this.verified,
    required this.balance,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': firstName,
      'surname': lastName,
      'iin': iin,
      'email': email,
      'number': phoneNumber,
      'cardId': cardNumber,
      'verified': verified,
      'userId': userId,
    };
  }

}
