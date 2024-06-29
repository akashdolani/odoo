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
        backgroundColor: Color.fromRGBO(12, 12, 12, 1),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(253, 112, 20, 1),
          shadowColor: Colors.transparent,
          title: Center(child: Text('Home')),
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
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 32.0), // Adjust padding as needed
                  textStyle: TextStyle(fontSize: 18.0), // Adjust text size
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                  ),
                  primary: Color.fromRGBO(
                      253, 112, 20, 1.0), // Background color RGB(253, 112, 20)
                ),
                child: Text('Submit Crime Report'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PastReportsPage(
                        userPhoneNumber: userPhoneNumber,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 32.0), // Adjust padding as needed
                  textStyle: TextStyle(fontSize: 18.0), // Adjust text size
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                  ),
                  primary: Color.fromRGBO(
                      253, 112, 20, 1.0), // Background color RGB(253, 112, 20)
                ),
                child: Text('View Pending Reports'),
              ),
            ],
          ),
        ));
  }
}
