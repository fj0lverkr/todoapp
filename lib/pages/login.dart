import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todoapp/main.dart';
import 'package:todoapp/model/login.dart';

void closePopup(BuildContext context) {
  Navigator.of(context).pop();
}

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

  void _doCreateUser(String email, String password, String displayName) async {
    LoginResult result =
        await TodoLogin().createUser(email, password, displayName);
    if (!result.success) {
      // TODO send verification mail
    }
    _showSnackbar(result.message!);
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
                              await showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      _buildPopupDialog(
                                          context, _doCreateUser));
                            },
                            child: const Text('create account'),
                          ),
                          const SizedBox(
                            width: 25,
                          ),
                          GestureDetector(
                            onTap: () {
                              /* TODO
                              help restore password, possibly different sprint.
                              */
                            },
                            child: const Text('forgot password'),
                          ),
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

Widget _buildPopupDialog(BuildContext context, Function doCreateUser) {
  final formKey = GlobalKey<FormState>();
  late String login;
  late String password;
  late String displayName;
  return AlertDialog(
    title: const Text("Create new account"),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: TextFormField(
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) async {
                    if (formKey.currentState != null &&
                        formKey.currentState!.validate()) {
                      formKey.currentState!.save();
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
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) async {
                    if (formKey.currentState != null &&
                        formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                    }
                  },
                  validator: (String? value) {
                    return (value == null || value.isEmpty)
                        ? 'Invalid password.'
                        : null;
                  },
                  onSaved: (newValue) => password = newValue!,
                  decoration: const InputDecoration(
                      labelText: 'Password',
                      icon: Icon(Icons.password),
                      hintText: 'Your password.'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: TextFormField(
                  validator: (String? value) {
                    return (value == null || value.isEmpty)
                        ? 'Invalid display name.'
                        : null;
                  },
                  onSaved: (newValue) => displayName = newValue!,
                  decoration: const InputDecoration(
                      labelText: 'Display name',
                      icon: Icon(Icons.person_2_outlined),
                      hintText: 'Your desired display name.'),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ],
    ),
    actions: <Widget>[
      ElevatedButton(
        child: const Text("Create account"),
        onPressed: () {
          if (formKey.currentState != null &&
              formKey.currentState!.validate()) {
            formKey.currentState!.save();
            doCreateUser(login, password, displayName);
            closePopup(context);
          }
        },
      ),
      const SizedBox(
        width: 25,
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Close'),
      ),
    ],
  );
}
