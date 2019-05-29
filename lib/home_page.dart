import 'package:firebase_login/widgets/delivery_fragment.dart';
import 'package:firebase_login/widgets/drawer.dart';
import 'package:firebase_login/widgets/home_fragment.dart';
import 'package:firebase_login/widgets/news_fragment.dart';
import 'package:firebase_login/widgets/orders_fragment.dart';
import 'package:flutter/material.dart';

import 'interfaces/interface_drawer_listener.dart';
import 'providers/identity_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> implements DrawerListener {
  IdentityProvider identityProvider = new IdentityProvider();
  Widget _activeFragment;
  String _activeTitle;

  @override
  void initState() {
    super.initState();
    _activeFragment = new HomeFragment(identityProvider);
    _activeTitle = "Home";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_activeTitle),
      ),
      body: _activeFragment,
      drawer: DrawerMain(this, identityProvider),
    );
  }

  @override
  void logout() {
    identityProvider.signOutProviders();
  }

  @override
  void showMenuItem(HomeScreenMembers itemName) {
    switch (itemName) {
      case HomeScreenMembers.home:
        setState(() {
          _activeTitle = "Home";
          _activeFragment = new HomeFragment(identityProvider);
        });
        break;
      case HomeScreenMembers.delivery:
        setState(() {
          _activeTitle = "Delivery";
          _activeFragment = new DeliveryFragment();
        });
        break;
      case HomeScreenMembers.news:
        setState(() {
          _activeTitle = "News";
          _activeFragment = new NewsFragment();
        });
        break;
      case HomeScreenMembers.orders:
        setState(() {
          _activeTitle = "Orders";
          _activeFragment = new OrdersFragment();
        });
        break;
    }
  }
}
