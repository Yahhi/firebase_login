import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login/model/person.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image/image.dart' as image_convert;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

class IdentityProvider {
  static final String STATE_IN_PROGRESS = "progress";
  static final IdentityProvider _singleton = new IdentityProvider._internal();
  factory IdentityProvider() {
    return _singleton;
  }

  IdentityProvider.forTests(FirebaseAuth auth, GoogleSignIn googleSignIn) {
    _auth = auth;
    this.googleSignIn = googleSignIn;
  }

  IdentityProvider._internal() {
    _auth = FirebaseAuth.instance;
    googleSignIn = new GoogleSignIn();
    _doDefaultLogin();
  }

  FirebaseAuth _auth;
  GoogleSignIn googleSignIn;
  Person loggedInUser;
  DateTime _lastLogin;
  StreamController<LoginState> _loginState = new BehaviorSubject();
  StreamController<String> _actionController = new BehaviorSubject();

  Stream<LoginState> get loginState => _loginState.stream;
  Stream<String> get actionState => _actionController.stream;

  void handleGoogleSignIn() async {
    _loginState.add(LoginState.IN_PROGRESS);
    _actionController.add(STATE_IN_PROGRESS);
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication googleAuth =
          await googleUser.authentication.catchError((onError) {
        print("Error $onError");
        _actionController.add(onError);
        _loginState.add(LoginState.LOGGED_OUT);
        return;
      });
      if (googleAuth.accessToken != null) {
        try {
          AuthCredential credential = GoogleAuthProvider.getCredential(
              idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
          FirebaseUser user = await _auth.signInWithCredential(credential);
          loggedInUser = new Person(user);
          _loginState.add(LoginState.LOGGED_IN);
          _actionController.add("");
        } catch (e) {
          _actionController.add(e.toString());
          _loginState.add(LoginState.LOGGED_OUT);
        }
      } else {
        _actionController.add("");
        _loginState.add(LoginState.LOGGED_OUT);
      }
    } else {
      _actionController.add("Problem signing in");
      _loginState.add(LoginState.LOGGED_OUT);
    }
  }

  void handleEmailSignIn(String email, String password) async {
    _loginState.add(LoginState.IN_PROGRESS);
    _actionController.add(STATE_IN_PROGRESS);
    FirebaseUser user;
    try {
      user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      print(user);
    } catch (exception) {
      _actionController.add(exception.toString());
      _loginState.add(LoginState.LOGGED_OUT);
    }

    if (user != null) {
      _loginState.add(LoginState.LOGGED_IN);
    }
    print("user logged in");
    _actionController.add("");
  }

  Future<String> emailIsAvailable(String email) async {
    _actionController.add(STATE_IN_PROGRESS);
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      List<String> providers =
          await auth.fetchSignInMethodsForEmail(email: email);
      print(providers);
      _actionController.add("");

      if (providers == null || providers.isEmpty) {
        return "";
      } else if (providers.contains('password')) {
        return "password";
      } else {
        return providers[0];
      }
    } catch (exception) {
      print(exception);
      _actionController.add(exception.toString());
      return "";
    }
  }

  void createUser(
      String name, String surname, String email, String password) async {
    _actionController.add(STATE_IN_PROGRESS);
    try {
      FirebaseUser user = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("user created");
      try {
        var userUpdateInfo = new UserUpdateInfo();
        userUpdateInfo.displayName = name + " " + surname;
        await user.updateProfile(userUpdateInfo);
        _actionController.add("");
        print("user modified");
        handleEmailSignIn(email, password);
      } catch (e) {
        _actionController.add(e.toString());
      }
    } on PlatformException catch (e) {
      print(e.details);
      _actionController.add(e.details);
    }
  }

  void sendPasswordReset(String email) async {
    _actionController.add(STATE_IN_PROGRESS);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _actionController.add("");
    } catch (exception) {
      _actionController.add(exception.toString());
    }
  }

  void signOutProviders() async {
    _loginState.add(LoginState.IN_PROGRESS);
    _actionController.add(STATE_IN_PROGRESS);
    var currentUser = await _auth.currentUser();
    if (currentUser != null) {
      await _signOut(currentUser.providerData);
    }

    return await _auth.signOut();
  }

  Future<dynamic> _signOut(Iterable providers) async {
    return Future.forEach(providers, (p) async {
      switch (p.providerId) {
        case 'google.com':
          await googleSignIn.signOut();
          break;
      }
    });
  }

  void _doDefaultLogin() async {
    _loginState.add(LoginState.IN_PROGRESS);
    FirebaseUser user = await _auth.currentUser();
    if (user == null) {
      _loginState.add(LoginState.LOGGED_OUT);
    } else {
      loggedInUser = new Person(user);
      _loginState.add(LoginState.LOGGED_IN);
    }
  }

  static image_convert.Image _reduceImage(File imageFile) {
    image_convert.Image image =
        image_convert.decodeImage(imageFile.readAsBytesSync());

    // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
    image_convert.Image thumbnail = image_convert.copyResize(image, width: 400);
    return thumbnail;
  }

  Future<dynamic> uploadImage(File _image) async {
    image_convert.Image image = await compute(_reduceImage, _image);

    // Save the thumbnail as a PNG.
    final directory = await getApplicationDocumentsDirectory();
    File thumbnailFile = new File('${directory.path}/${loggedInUser.uid}.jpg');

    thumbnailFile.writeAsBytesSync(image_convert.encodeJpg(image, quality: 60));

    final StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('profile')
        .child('${loggedInUser.uid}.jpg');
    final StorageUploadTask uploadTask = ref.putFile(thumbnailFile);
    await uploadTask.onComplete;
    return ref.getDownloadURL();
  }
}

enum LoginState { LOGGED_IN, LOGGED_OUT, IN_PROGRESS, ERROR }
