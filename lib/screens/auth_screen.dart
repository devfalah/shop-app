import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20),
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 94),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.deepOrange.shade900,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]),
                      child: Text(
                        "My Shop",
                        style: TextStyle(
                          color:
                              Theme.of(context).accentTextTheme.headline6.color,
                          fontSize: 50,
                          fontFamily: 'Anton',
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: AuthCart(),
                    flex: deviceSize.width > 600 ? 2 : 1,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AuthCart extends StatefulWidget {
  @override
  _AuthCartState createState() => _AuthCartState();
}

enum AuthMode { Login, SignUp }

class _AuthCartState extends State<AuthCart> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  AuthMode _authMode = AuthMode.Login;

  Future<void> _submit() async {
    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();
      _formKey.currentState.save();
      setState(() {
        _isLoading = true;
      });

      try {
        if (_authMode == AuthMode.Login) {
          await Provider.of<Auth>(context, listen: false)
              .login(_authData['email'], _authData['password']);
        } else {
          await Provider.of<Auth>(context, listen: false)
              .signUp(_authData['email'], _authData['password']);
        }
      } catch (error) {
        String errorMessage = "Authentication failed";
        if (error.toString().contains('EMAIL_EXISTS')) {
          errorMessage = 'The email address is already in use';
        } else if (error.toString().contains('INVALID_EMAIL')) {
          errorMessage = 'The is not a valid email address ';
        } else if (error.toString().contains('WEAK_PASSWORD')) {
        } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
          errorMessage = 'Colud not find the user with the email';
        } else if (error.toString().contains('WEAK_PASSWORD')) {
          errorMessage = 'This password is too weak ';
        } else if (error.toString().contains('INVALID_PASSWORD')) {
          errorMessage = 'Invalid password';
        }

        _showErrorDailog(errorMessage);
      }

      setState(() {
        _isLoading = false;
      });
    } else if (!_formKey.currentState.validate()) {
      return;
    }
  }

  void _showErrorDailog(errorMessage) {
    print(2);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Error"),
        content: Text(errorMessage),
        actions: [
          FlatButton(
            child: Text('Okay!'),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.SignUp;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.Login ? 260 : 320,
        width: deviceSize.width * 0.75,
        constraints: BoxConstraints(
          minHeight: _authMode == AuthMode.Login ? 260 : 320,
        ),
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  key: Key("email"),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                  ),
                  validator: (value) => value.length < 4 && !value.contains('@')
                      ? "Invalid email"
                      : null,
                  onSaved: (value) => _authData['email'] = value,
                ),
                TextFormField(
                  key: Key("password"),
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                  ),
                  validator: (value) =>
                      value.length < 4 ? "Password is too short " : null,
                  onSaved: (value) => _authData['password'] = value,
                ),
                if (_authMode == AuthMode.SignUp)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.SignUp ? 60 : 0,
                      maxHeight: _authMode == AuthMode.SignUp ? 120 : 0,
                    ),
                    child: TextFormField(
                      enabled: _authMode == AuthMode.SignUp,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        labelText: "Confirm password",
                      ),
                      validator: (value) => value != _passwordController.text
                          ? "Password do not match "
                          : null,
                    ),
                  ),
                SizedBox(height: 20),
                if (_isLoading)
                  SpinKitThreeBounce(
                    color: Colors.purple,
                    size: 50.0,
                  ),
                if (!_isLoading)
                  RaisedButton(
                    onPressed: _submit,
                    child:
                        Text(_authMode == AuthMode.Login ? "Login" : "SIGNUP"),
                    color: Theme.of(context).primaryColor,
                    textColor:
                        Theme.of(context).primaryTextTheme.headline6.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                  ),
                FlatButton(
                  onPressed: _switchAuthMode,
                  child: Text(
                      "${_authMode == AuthMode.SignUp ? "LOGIN" : "SIGNUP"} INSTEAD "),
                  textColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
