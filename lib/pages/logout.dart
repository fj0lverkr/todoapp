import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:todoapp/widgets/titlecard.dart';

class LogoutPage extends StatelessWidget {
  final Function _setIndex;
  final String uid;
  final String displayName;
  const LogoutPage(this._setIndex, this.uid, this.displayName, {super.key});

  Future<void> doLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('fb_uid');
    prefs.remove('fb_display');
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.primary,
    );
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Flexible(
              child: ListView(children: [
                TitleCard('Confirm logout', theme: theme),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 8, 15),
                  child:
                      Text('Are you sure you want to log out?', style: style),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
                  child: Text('Currently logged in as $displayName.'),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 15,
                      ),
                      ElevatedButton(
                        child: const Text("Yes"),
                        onPressed: () {
                          doLogout();
                        },
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                        child: const Text("No"),
                        onPressed: () {
                          _setIndex(0);
                        },
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
