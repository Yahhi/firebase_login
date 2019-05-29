import 'package:firebase_login/providers/identity_provider.dart';
import 'package:flutter/material.dart';

class HomeFragment extends StatelessWidget {
  final IdentityProvider identityProvider;

  const HomeFragment(
    this.identityProvider, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        StreamBuilder(
          initialData: LoginState.LOGGED_OUT,
          stream: identityProvider.loginState,
          builder:
              (BuildContext context, AsyncSnapshot<LoginState> loginState) {
            if (loginState.data == LoginState.LOGGED_IN) {
              return Text("Content for logged in user");
            } else {
              return Text("Content for any user");
            }
          },
        ),
      ],
    ));
  }
}
