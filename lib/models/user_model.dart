import 'dart:convert';

Users usersFromMap(String str) => Users.fromMap(json.decode(str));

String usersToMap(Users data) => json.encode(data.toMap());

class Users {
  final int? usrId;
  final String? fullName;
  final String email;
  final String password;
  final String? profilePicture;

  Users({
    this.usrId,
    this.fullName,
    required this.email,
    required this.password,
    this.profilePicture,
  });


  Users copyWith({
    int? usrId,
    String? fullName,
    String? email,
    String? password,
    String? profilePicture,
  }) =>
      Users(
        usrId: usrId ?? this.usrId,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        password: password ?? this.password,
        profilePicture: profilePicture ?? this.profilePicture,
      );

  factory Users.fromMap(Map<String, dynamic> json) => Users(
        usrId: json["usrId"],
        fullName: json["fullName"],
        email: json["email"], 
        password: json["usrPassword"], 
        profilePicture: json["profilePicture"],
      );

  Map<String, dynamic> toMap() => {
        "usrId": usrId,
        "fullName": fullName,
        "email": email,
        "usrPassword": password,
        "profilePicture": profilePicture,
      };
}