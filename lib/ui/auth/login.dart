import 'package:mangaturn/custom_widgets/custom_text_field.dart';
import 'package:mangaturn/models/auth_models/login_model.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mangaturn/services/bloc/post/login_cubit.dart';

class Login extends StatefulWidget {

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _loginFail = false;
  bool _hidePwd = true;
  String _error = "Error";
  late FocusNode pwdFocus;

  void login(){
    if(_formKey.currentState!.validate()){
      LoginModel _loginModel = new LoginModel(
          username: _username, password: _password);
      BlocProvider.of<LoginCubit>(context, listen: false)
          .login(_loginModel);
    }
  }

  void initState() {
    _username = '';
    _password = '';
    pwdFocus = new FocusNode();
    super.initState();
  }

  void focusOnPwd() {
    FocusScope.of(context).requestFocus(pwdFocus);
  }



  @override
  void dispose() {
    pwdFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.0),
          child: BlocConsumer<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state is LoginFail) {
                setState(() {
                  _loginFail = true;
                  _error = state.error;
                });
              } else if (state is LoginSuccess) {
               AuthFunction.GotoHome(context, state.auth.accessToken,
                  state.auth.user.role == "USER" ? false : true);
              }
            },
            builder: (context, state) {
              if (state is LoginLoading) {
                return Container(
                  height: 300,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          "Welcome Back!",
                          style: TextStyle(fontSize: 25),
                        )),
                    _loginFail
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
                        validatorText: 'Enter your name!',
                        action: TextInputAction.next,
                        onSubmit: (_){
                          focusOnPwd();
                        },
                        onChange: (String name) {
                          setState(() {
                            _username = name;
                          });
                        }),
                    SizedBox(
                      height: 15,
                    ),
                    CustomPwdField(
                      context: context,
                      label: 'Your Password',
                      action: TextInputAction.done,
                      hide: _hidePwd,
                      hideBtn: (bool hide){
                        print(hide);
                        setState(() {
                          _hidePwd = !hide;
                        });
                      },
                      onChange: (String pwd){
                        setState(() {
                          _password = pwd;
                        });
                      },
                      validatorText: 'Need password.',
                      node: pwdFocus,
                      onSubmit: (_){
                        login();
                      },
                    ),
                    Container(
                        padding: EdgeInsets.only(top: 10),
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () {
                              login();
                            },
                            child: Text('Login')))
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
