import 'package:firebase_login/interfaces/interface_drawer_listener.dart';
import 'package:firebase_login/providers/identity_provider.dart';
import 'package:flutter/material.dart';

import '../profile_screen.dart';
import '../sign_in_screen.dart';
import 'avatar.dart';

class DrawerMain extends StatelessWidget {
  final DrawerListener listener;
  final IdentityProvider identityProvider;

  DrawerMain(this.listener, this.identityProvider);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: identityProvider.loggedInUser == null
                ? Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(new PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                new SignInScreen(identityProvider)));
                      },
                      child: Avatar(
                        fullName: "Login",
                      ),
                    ),
                  )
                : Center(
                    child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(new PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  new ProfileScreen()));
                        },
                        child: Column(children: <Widget>[
                          Avatar(
                              photoAddress:
                                  identityProvider.loggedInUser.imageAddress,
                              fullName:
                                  identityProvider.loggedInUser.getFullName()),
                          Text(identityProvider.loggedInUser
                                  .getFullName()
                                  .isEmpty
                              ? "Unknown user"
                              : identityProvider.loggedInUser.getFullName()),
                        ]))),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            title: Text("Home"),
            onTap: () {
              Navigator.of(context).pop();
              listener.showMenuItem(HomeScreenMembers.home);
            },
          ),
          ListTile(
            title: Text("News"),
            onTap: () {
              Navigator.of(context).pop();
              listener.showMenuItem(HomeScreenMembers.news);
            },
          ),
          identityProvider.loggedInUser == null
              ? null
              : ListTile(
                  title: Text("Orders"),
                  onTap: () {
                    Navigator.of(context).pop();
                    listener.showMenuItem(HomeScreenMembers.orders);
                  },
                ),
          identityProvider.loggedInUser == null
              ? null
              : ListTile(
                  title: Text("Delivery"),
                  onTap: () {
                    Navigator.of(context).pop();
                    listener.showMenuItem(HomeScreenMembers.delivery);
                  },
                ),
          identityProvider.loggedInUser == null
              ? null
              : ListTile(
                  title: Text("Logout"),
                  onTap: () {
                    Navigator.of(context).pop();
                    listener.showMenuItem(HomeScreenMembers.home);
                    listener.logout();
                  },
                )
        ].where(notNull).toList(),
      ),
    );
  }

  bool notNull(Object o) => o != null;
}
