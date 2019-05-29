import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  final FormFieldValidator<String> validator;
  final TextInputType keyboard;
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final bool isFinal;
  final FocusNode currentFocus;
  final FocusNode nextFocus;
  final VoidCallback formAction;

  const LoginTextField(
    this.controller,
    this.label, {
    Key key,
    this.validator,
    this.keyboard: TextInputType.text,
    this.isPassword: false,
    this.isFinal: false,
    @required this.currentFocus,
    this.nextFocus,
    this.formAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 8.0),
      child: TextFormField(
        obscureText: isPassword,
        validator: validator,
        keyboardType: keyboard,
        controller: controller,
        focusNode: currentFocus,
        textInputAction: isFinal ? TextInputAction.done : TextInputAction.next,
        onFieldSubmitted: (term) {
          currentFocus.unfocus();
          if (nextFocus == null) {
            formAction();
          } else {
            FocusScope.of(context).requestFocus(nextFocus);
          }
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[700]),
        ),
      ),
    );
  }
}
