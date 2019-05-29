import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:toast/toast.dart';

import 'app_sizes.dart';
import 'providers/identity_provider.dart';
import 'widgets/login_text_field.dart';

class AccountCreateScreen extends StatefulWidget {
  final IdentityProvider identityProvider;

  const AccountCreateScreen(this.identityProvider, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _AccountCreateScreenState();
  }
}

class _AccountCreateScreenState extends State<AccountCreateScreen> {
  TextEditingController _loginController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _surnameController = new TextEditingController();
  final FocusNode _loginFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _surnameFocus = FocusNode();
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
        title: Text("Create account"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Text("Your info"),
              SizedBox(
                height: 26.0,
              ),
              LoginTextField(
                _loginController,
                "Email",
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter email';
                  } else if (EmailValidator.validate(value)) {
                    return "Email has incorrect format";
                  }
                },
                currentFocus: _loginFocus,
                nextFocus: _nameFocus,
              ),
              LoginTextField(
                _nameController,
                "Name",
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter name';
                  }
                },
                currentFocus: _nameFocus,
                nextFocus: _surnameFocus,
              ),
              LoginTextField(
                _surnameController,
                "Surname",
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter surname';
                  }
                },
                currentFocus: _surnameFocus,
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
                  child: Text("CREATE ACCOUNT"),
                  onPressed: () {
                    _formAction();
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
      widget.identityProvider.createUser(
          _nameController.text,
          _surnameController.text,
          _loginController.text,
          _passwordController.text);
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
