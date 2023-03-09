import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todoapp/main.dart';
import 'package:todoapp/model/login.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late String login;
  late String password;

  Future<LoginResult> _doLogin(String email, String password) async {
    return await TodoLogin().signInWithEmailAndPassword(email, password);
  }

  Future<LoginResult> _doCreateUser(String email, String password) async {
    return await TodoLogin().createUser(email, password);
  }

  void _showSnackbar(String title, {int durationSeconds = 10}) {
    final snackbar = SnackBar(
      content: Text(title),
      duration: Duration(seconds: durationSeconds),
    );
    scaffoldMessengerKey.currentState?.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    return LayoutBuilder(builder: (context, constraints) {
      if (!appState.isMailVerified) {
        _showSnackbar("Please verify your e-mail before logging in.",
            durationSeconds: 30);
      }
      return ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          body: Container(
            color: theme.colorScheme.background,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: TextFormField(
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) async {
                          if (_formKey.currentState != null &&
                              _formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            LoginResult result =
                                await _doLogin(login, password);
                            if (result.success) {
                              appState.isLoggedIn = true;
                              appState.uid = result.message!;
                            } else {
                              _showSnackbar(result.message!);
                            }
                          }
                        },
                        validator: (String? value) {
                          return (value == null || value.isEmpty)
                              ? 'Invalid E-mail address.'
                              : null;
                        },
                        decoration: const InputDecoration(
                            labelText: 'E-mail address',
                            icon: Icon(Icons.mail),
                            hintText: 'Your e-mail.'),
                        onSaved: (value) => login = value!,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: TextFormField(
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) async {
                          if (_formKey.currentState != null &&
                              _formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            LoginResult result =
                                await _doLogin(login, password);
                            if (result.success) {
                              appState.isLoggedIn = true;
                              appState.uid = result.message!;
                            } else {
                              _showSnackbar(result.message!);
                            }
                          }
                        },
                        validator: (String? value) {
                          return (value == null || value.isEmpty)
                              ? 'Invalid password.'
                              : null;
                        },
                        onSaved: (newValue) => password = newValue!,
                        obscureText: true,
                        decoration: const InputDecoration(
                            labelText: 'Password',
                            icon: Icon(Icons.password),
                            hintText: 'Your password.'),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 35,
                          ),
                          ElevatedButton(
                            child: const Text("Login"),
                            onPressed: () async {
                              if (_formKey.currentState != null &&
                                  _formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                LoginResult result =
                                    await _doLogin(login, password);
                                if (result.success) {
                                  appState.isLoggedIn = true;
                                  appState.uid = result.message!;
                                } else {
                                  _showSnackbar(result.message!);
                                }
                              }
                            },
                          ),
                          const SizedBox(
                            width: 25,
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (_formKey.currentState != null &&
                                  _formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                LoginResult result =
                                    await _doCreateUser(login, password);
                                if (result.success) {
                                  appState.isLoggedIn = true;
                                  appState.uid = result.message!;
                                } else {
                                  _showSnackbar(result.message!);
                                }
                              }
                            },
                            child: const Text('create account'),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
