import 'package:flutter/material.dart';

Widget CustomTextField(
    {required BuildContext context,
    String? label,
    int maxLines = 1,
      bool readOnly = false,
    TextInputType inputType = TextInputType.text,
    hintText = '',
      maxLength = null,
    FocusNode? node = null,
    String initialVal = '',
    Function(String data)? onSubmit = null,
    String validatorText = "Can't be empty",
    @required TextInputAction action = TextInputAction.done,
    @required Function(String val)? onChange}) {
  return TextFormField(
    focusNode: node,
    readOnly: readOnly,
    maxLength: maxLength,
    initialValue: initialVal,
    maxLines: maxLines,
    decoration: InputDecoration(
      focusedBorder: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(),
      //icon: Icon(Icons.person),
      labelText: label,
      hintText: hintText,
      labelStyle: TextStyle(color: Colors.black),
    ),
    textInputAction: action,
    onFieldSubmitted: onSubmit,
    keyboardType: inputType,
    validator: (value) {
      if (value!.isEmpty) {
        return validatorText;
      }
      return null;
    },
    onChanged: onChange,
  );
}

Widget CustomPwdField(
    {required BuildContext context,
    required String label, bool hide = true,
    required Function(bool hide) hideBtn,
    FocusNode? node,
    Function(String data)? onSubmit = null,
     TextInputAction action = TextInputAction.done,
     String validatorText = "Can't be empty",
     Function(String val)? onChange}) {
  return TextFormField(
    focusNode: node,
    obscureText: hide,
    decoration: InputDecoration(
      focusedBorder: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(),
      //icon: Icon(Icons.person),
      suffixIcon: IconButton(
          icon: Icon(
            Icons.remove_red_eye,
            color: Colors.black,
          ),
          onPressed: () => hideBtn(hide)),
      labelText: label,
      labelStyle: TextStyle(color: Colors.black),
    ),
    textInputAction: action,
    onFieldSubmitted: onSubmit,
    keyboardType: TextInputType.text,
    validator: (value) {
      if (value!.isEmpty) {
        return validatorText;
      }
      return null;
    },
    onChanged: onChange,
  );
}
