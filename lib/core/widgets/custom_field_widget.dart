import 'package:flutter/material.dart';

class CustomFieldWidget extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool isObscureText;
  final bool readOnly;
  final bool isEnabled;
  final VoidCallback? onTap;
  final Icon? prefixIcon;
  final IconButton? suffixIcon;
  final FormFieldValidator? validator;

  const CustomFieldWidget({
    super.key,
    required this.hintText,
    required this.controller,
    this.isObscureText = false,
    this.readOnly = false,
    this.isEnabled = true,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      readOnly: readOnly,
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      obscureText: isObscureText,
      enabled: isEnabled,
    );
  }
}
