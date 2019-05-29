import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Person {
  String uid;
  String name;
  String surname;
  String email;
  String imageAddress;

  Person(FirebaseUser user) {
    uid = user.uid;
    List<String> userNames = user.displayName.split(" ");
    if (userNames.length >= 2) {
      name = userNames[0];
      surname = userNames[1];
    } else if (userNames.length == 1) {
      name = user.displayName;
      surname = "";
    } else {
      name = "-";
      surname = "-";
    }
    imageAddress = user.photoUrl;
    email = user.email;
  }

  String getFullName() {
    return name + " " + surname;
  }

  Map<String, Object> toStorage() {
    return {
      'name': name,
      'surname': surname,
      'image_address': imageAddress,
      'last_update': DateTime.now().toIso8601String(),
    };
  }

  Person.fromSnapshot(DataSnapshot snapshot) {
    uid = snapshot.key;
    name = snapshot.value['name'];
    surname = snapshot.value['surname'];
    imageAddress = snapshot.value['image_address'];
  }

  String getFirstLetters() {
    return (name.length > 0 ? name.substring(0, 1) : "") +
        (surname.length > 0 ? surname.substring(0, 1) : "");
  }
}
