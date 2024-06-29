import 'package:flutter/material.dart';
import 'package:live_crime_report/login/login.dart';
import 'package:live_crime_report/pages/PastReports.dart';
import 'package:live_crime_report/pages/google_maps.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class HomeScreen extends StatelessWidget {
  String userPhoneNumber;
  HomeScreen({
    super.key,
    required this.userPhoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Home'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                SharedPreferences.getInstance().then((prefs) {
                  prefs.remove('userPhoneNumber');
                  prefs.setBool('firstTimeLogin', true);
                });
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MapPage(
                                userPhoneNumber: userPhoneNumber,
                              )));
                },
                child: Text('Submit Crime Report'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PastReportsPage(
                                userPhoneNumber: userPhoneNumber,
                              )));
                },
                child: Text('View Pending Reports'),
              ),
            ],
          ),
        ));
  }
}
