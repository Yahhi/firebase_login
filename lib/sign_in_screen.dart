import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:toast/toast.dart';

import 'account_create_screen.dart';
import 'app_sizes.dart';
import 'providers/identity_provider.dart';
import 'widgets/login_text_field.dart';

class SignInScreen extends StatefulWidget {
  final IdentityProvider identityProvider;

  const SignInScreen(this.identityProvider, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _SignInScreenState();
  }
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _loginController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  final FocusNode _loginFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  ProgressDialog pr;

  @override
  void initState() {
    super.initState();
    widget.identityProvider.loginState.listen(_closeWhenFinished);

    pr = new ProgressDialog(context, ProgressDialogType.Normal);
    widget.identityProvider.actionState.listen(_showErrorOrProgress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Text("Login"),
              SizedBox(
                height: 26.0,
              ),
              LoginTextField(
                _loginController,
                "Email",
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter email';
                  }
                },
                currentFocus: _loginFocus,
                nextFocus: _passwordFocus,
              ),
              LoginTextField(
                _passwordController,
                "Password",
                isPassword: true,
                isFinal: true,
                currentFocus: _passwordFocus,
                formAction: _formAction,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter password';
                  }
                },
              ),
              SizedBox(
                height: 30.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: AppSizes.WHITE_BUTTON_SMALL_PADDING_HORIZONTAL),
                child: RaisedButton(
                  child: Text("LOGIN"),
                  onPressed: () {
                    _formAction();
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: AppSizes.WHITE_BUTTON_SMALL_PADDING_HORIZONTAL),
                child: RaisedButton(
                  child: Text("CREATE ACCOUNT"),
                  onPressed: () {
                    Navigator.of(context).push(new PageRouteBuilder(
                        pageBuilder: (_, __, ___) =>
                            new AccountCreateScreen(widget.identityProvider)));
                  },
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              Text("OR"),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: AppSizes.WHITE_BUTTON_SMALL_PADDING_HORIZONTAL),
                child: RaisedButton(
                  child: Text("Google Sign-In"),
                  onPressed: () {
                    widget.identityProvider.handleGoogleSignIn();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _formAction() {
    if (_passwordFocus.hasFocus) _passwordFocus.unfocus();
    if (_formKey.currentState.validate()) {
      widget.identityProvider
          .handleEmailSignIn(_loginController.text, _passwordController.text);
    }
  }

  void _closeWhenFinished(LoginState event) {
    if (event == LoginState.LOGGED_IN) {
      Navigator.pop(context);
    }
  }

  void _showErrorOrProgress(String event) {
    if (event.isEmpty) {
      _setProgressVisibility(false);
    } else if (event == IdentityProvider.STATE_IN_PROGRESS) {
      _setProgressVisibility(true);
    } else {
      _setProgressVisibility(false);
      Toast.show(event, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
    }
  }

  void _setProgressVisibility(bool visible) {
    if (visible) {
      pr.show();
    } else {
      pr.hide();
    }
  }
}
