import 'dart:convert';

Users usersFromMap(String str) => Users.fromMap(json.decode(str));

String usersToMap(Users data) => json.encode(data.toMap());

class Users {
  final int? usrId;
  final String? fullName;
  final String usrName;
  final String password;

  Users({
    this.usrId,
    this.fullName,
    required this.usrName,
    required this.password,
  });

  //These json value must be same as your column name in database that we have already defined

  factory Users.fromMap(Map<String, dynamic> json) => Users(
    usrId: json["usrId"],
    fullName: json["fullName"],
    usrName: json["usrName"],
    password: json["usrPassword"],
  );

  Map<String, dynamic> toMap() => {
    "usrId": usrId,
    "fullName": fullName,
    "usrName": usrName,
    "usrPassword": password,
  };
}