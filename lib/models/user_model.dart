import 'dart:convert';

Users usersFromMap(String str) => Users.fromMap(json.decode(str));

String usersToMap(Users data) => json.encode(data.toMap());

class Users {
  final int? usrId;
  final String? fullName;
  final String email; // Now the unique identifier
  final String password;

  Users({
    this.usrId,
    this.fullName,
    required this.email,
    required this.password,
  });

  // copyWith allows you to update parts of the user object easily
  Users copyWith({
    int? usrId,
    String? fullName,
    String? email,
    String? password,
  }) =>
      Users(
        usrId: usrId ?? this.usrId,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        password: password ?? this.password,
      );

  factory Users.fromMap(Map<String, dynamic> json) => Users(
        usrId: json["usrId"],
        fullName: json["fullName"],
        email: json["email"], 
        password: json["usrPassword"], // Matches your database column name
      );

  Map<String, dynamic> toMap() => {
        "usrId": usrId,
        "fullName": fullName,
        "email": email,
        "usrPassword": password,
      };
}