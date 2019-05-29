import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'providers/identity_provider.dart';

class ProfileScreen extends StatelessWidget {
  final IdentityProvider identityProvider;

  const ProfileScreen({Key key, this.identityProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 8.0,
            ),
            Row(
              children: <Widget>[
                identityProvider.loggedInUser.imageAddress.isEmpty
                    ? CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey,
                        child: Text(
                          identityProvider.loggedInUser.getFirstLetters(),
                          textScaleFactor: 2,
                        ),
                      )
                    : CircleAvatar(
                        radius: 70,
                        child: ClipOval(
                          child: Image.network(
                            identityProvider.loggedInUser.imageAddress,
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                Column(
                  children: <Widget>[
                    RaisedButton.icon(
                        onPressed: _openCamera,
                        icon: Icon(Icons.add_a_photo),
                        label: Text("camera")),
                    RaisedButton.icon(
                        onPressed: _openGallery,
                        icon: Icon(Icons.add_photo_alternate),
                        label: Text("gallery")),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 8.0,
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                identityProvider.loggedInUser.email,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(identityProvider.loggedInUser.name),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(identityProvider.loggedInUser.surname),
            ),
          ],
        ),
      ),
    );
  }

  void _openCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
  }

  void _openGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
  }
}
