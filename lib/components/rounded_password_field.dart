import 'package:flutter/material.dart';
import 'package:inventaris/components/text_field_container.dart';

import '../constants.dart';

class RoundedPasswordField extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const RoundedPasswordField({
    super.key,
    required this.onChanged,
  });

  @override
  _RoundedPasswordFieldState createState() => _RoundedPasswordFieldState();
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {
  bool _isObscured = true;
  final FocusNode _focusNode = FocusNode();

  void _toggleVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });

    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        focusNode: _focusNode,
        obscureText: _isObscured,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: "Password",
          icon: Icon(
            Icons.lock,
            color: kPrimaryColor,
          ),
          suffixIcon: GestureDetector(
            onTap: _toggleVisibility,
            child: Icon(
              _isObscured ? Icons.visibility : Icons.visibility_off,
              color: kPrimaryColor,
            ),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
