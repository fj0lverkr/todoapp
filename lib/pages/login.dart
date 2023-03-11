import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todoapp/main.dart';
import 'package:todoapp/model/login.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void _showSnackbar(String title, {int durationSeconds = 10}) {
  final snackbar = SnackBar(
    content: Text(title),
    duration: Duration(seconds: durationSeconds),
  );
  scaffoldMessengerKey.currentState?.showSnackBar(snackbar);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late String login;
  late String password;
  late bool _passwordVisible;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  Future<LoginResult> _doLogin(String email, String password) async {
    return await TodoLogin().signInWithEmailAndPassword(email, password);
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
            width: double.infinity,
            height: double.infinity,
            color: theme.colorScheme.background,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          icon: const Icon(Icons.password),
                          hintText: 'Your password.',
                          suffixIcon: IconButton(
                            iconSize: 16,
                            focusNode: FocusNode(skipTraversal: true),
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
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
                                      const BuildPopupDialog());
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

class BuildPopupDialog extends StatefulWidget {
  const BuildPopupDialog({super.key});

  @override
  State<StatefulWidget> createState() => _BuildPopupDialog();
}

class _BuildPopupDialog extends State<BuildPopupDialog> {
  final _formKey = GlobalKey<FormState>();
  late String login;
  late String password;
  late String displayName;

  _BuildPopupDialog();

  late bool _newPasswordVisible;
  late bool _confirmPasswordVisible;

  @override
  void initState() {
    super.initState();
    _newPasswordVisible = false;
    _confirmPasswordVisible = false;
  }

  void _doCreateUser(String email, String password, String displayName) async {
    LoginResult result =
        await TodoLogin().createUser(email, password, displayName);
    _showSnackbar(result.message!);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create new account"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: TextFormField(
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
                    obscureText: !_newPasswordVisible,
                    onChanged: (value) => password = value,
                    validator: (String? value) {
                      return (value == null || value.isEmpty)
                          ? 'Invalid password.'
                          : null;
                    },
                    onSaved: (newValue) => password = newValue!,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      icon: const Icon(Icons.password),
                      hintText: 'Your password.',
                      suffixIcon: IconButton(
                        iconSize: 16,
                        focusNode: FocusNode(skipTraversal: true),
                        icon: Icon(
                          _newPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          setState(() {
                            _newPasswordVisible = !_newPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: TextFormField(
                    obscureText: !_confirmPasswordVisible,
                    validator: (String? value) {
                      return (value == null ||
                              value.isEmpty ||
                              value != password)
                          ? 'Passwords must match.'
                          : null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
                      icon: const Icon(Icons.verified_user),
                      hintText: 'Re-type your password.',
                      suffixIcon: IconButton(
                        iconSize: 16,
                        focusNode: FocusNode(skipTraversal: true),
                        icon: Icon(
                          _confirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          setState(() {
                            _confirmPasswordVisible = !_confirmPasswordVisible;
                          });
                        },
                      ),
                    ),
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
            if (_formKey.currentState != null &&
                _formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              _doCreateUser(login, password, displayName);
              Navigator.of(context).pop();
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
}
