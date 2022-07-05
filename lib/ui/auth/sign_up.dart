import 'package:mangaturn/custom_widgets/custom_text_field.dart';
import 'package:mangaturn/models/auth_models/sign_up_model.dart';
import 'package:mangaturn/services/bloc/post/sign_up_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_functions.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();

  bool _signUpFail = false;
  String _error = '';
  late FocusNode pwdFocus;
  late FocusNode cpwdFocus;
  String _username = '';
  String _password = '';
  String _confrimPwd = '';
  bool _hidePwd = true;
  bool _hideCpwd = true;

  void initState() {
    pwdFocus = new FocusNode();
    cpwdFocus = new FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    pwdFocus.dispose();
    cpwdFocus.dispose();
    super.dispose();
  }

  void focusOnPwd() {
    FocusScope.of(context).requestFocus(pwdFocus);
  }

  void focusOnCPwd() {
    FocusScope.of(context).requestFocus(cpwdFocus);
  }

  void signUp() {
    if (_formKey.currentState!.validate()) {
      if (_password == _confrimPwd) {
        SignUpModel _signUpModel = new SignUpModel(
          username: _username,
          password: _password,
        );
        BlocProvider.of<SignUpCubit>(context, listen: false)
            .signUp(_signUpModel);
      } else {
        setState(() {
          _signUpFail = true;
          _error = "Password have to be the same.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),
          width: double.infinity,
          child: BlocConsumer<SignUpCubit, SignUpState>(
              listener: (context, state) {
            if (state is SignUpFail) {
              print(state.error);
              setState(() {
                _signUpFail = true;
                _error = state.error;
              });
            } else if (state is SignUpSuccess) {
              AuthFunction.GotoHome(context, state.auth.accessToken,
                  state.auth.user.role == "USER" ? false : true);
            }
          }, builder: (context, state) {
            if (state is SignUpLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _signUpFail
                          ? Container(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                '* ' + _error,
                                style: TextStyle(color: Colors.red),
                                textAlign: TextAlign.left,
                              ),
                            )
                          : Container(),
                      CustomTextField(
                          context: context,
                          label: 'Your name',
                          action: TextInputAction.next,
                          onSubmit: (_) {
                            focusOnPwd();
                          },
                          validatorText: 'Enter your name!',
                          onChange: (_name) {
                            setState(() {
                              _username = _name;
                            });
                          }),
                      Container(
                        height: 40,
                        width: double.infinity,
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      CustomPwdField(
                          context: context,
                          label: 'Your password',
                          validatorText: 'Need password!',
                          action: TextInputAction.next,
                          node: pwdFocus,
                          hide: _hidePwd,
                          hideBtn: (value) {
                            setState(() {
                              _hidePwd = !value;
                            });
                          },
                          onSubmit: (_) {
                            focusOnCPwd();
                          },
                          onChange: (_pwd) {
                            setState(() {
                              _password = _pwd;
                            });
                          }),
                      SizedBox(
                        height: 15,
                      ),
                      CustomPwdField(
                          context: context,
                          label: 'Confirm password',
                          action: TextInputAction.done,
                          validatorText: 'Enter same password!',
                          node: cpwdFocus,
                          hide: _hideCpwd,
                          hideBtn: (value) {
                            setState(() {
                              _hideCpwd = !value;
                            });
                          },
                          onSubmit: (_) {
                            signUp();
                          },
                          onChange: (_pwd) {
                            setState(() {
                              _confrimPwd = _pwd;
                            });
                          }),
                    ],
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(top: 10),
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          signUp();
                        },
                        child: Text('Create My Account'))),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    'If your given name is the same as others,\n Please change your name \nand create again',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
