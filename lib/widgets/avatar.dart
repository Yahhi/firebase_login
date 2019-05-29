import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String photoAddress;
  final String fullName;
  final double radius;

  const Avatar({Key key, this.photoAddress, this.fullName, this.radius: 50.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return photoAddress == null || photoAddress.isEmpty
        ? CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey,
            child: Text(
              getUserLetters(),
              textScaleFactor: 2,
            ),
          )
        : CircleAvatar(
            radius: radius,
            child: ClipOval(
              child: Image.network(
                photoAddress,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
              ),
            ),
          );
  }

  String getUserLetters() {
    if (fullName == null || fullName.isEmpty) return "";
    List<String> userNames = fullName.split(" ");
    if (userNames.length >= 2) {
      return userNames[0].substring(0, 1) + userNames[1].substring(0, 1);
    } else if (userNames.length == 1) {
      return userNames[0].substring(0, 1);
    } else {
      return "";
    }
  }
}
