import 'dart:convert';

import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/models/auth_models/login_model.dart';
import 'package:mangaturn/models/auth_models/sign_up_model.dart';
import 'package:mangaturn/services/api.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import '../auth/auth_functions.dart';
import 'package:flutter/material.dart';

class Welcome extends StatefulWidget {
  static String routeName = 'welcome';


  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {


  @override
  void initState() {
    Utility.requestPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Image.asset(
                'assets/icon/icon.png',
                 height: 150,
              ),
              Container(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Enjoy your moment",
                    style: TextStyle(fontSize: 25),
                  )),
              Container(
                  width: 300,
                  child: ElevatedButton(
                      onPressed: () => AuthFunction.loginAcc(context),
                      child: Text('Login account'))),
              Container(
                  width: 300,
                  child: TextButton(
                      onPressed: () => AuthFunction.createAcc(context),
                      child: Text('Don\'t have an account?\nCreate one', textAlign: TextAlign.center,),)
              ),
              Spacer(),
              Container(
                width: 300,
                child: Text('Developed By Khant Win & San Sint Kyaw', textAlign: TextAlign.center,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
