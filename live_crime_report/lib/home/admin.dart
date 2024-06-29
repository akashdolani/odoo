import 'package:flutter/material.dart';
import 'package:live_crime_report/login/login.dart';
import 'package:live_crime_report/pages/heat_map.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

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
                          builder: (context) => CriminalMarkers()));
                },
                child: Text('Heat Map'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text('View Pending Reports'),
              ),
            ],
          ),
        ));
  }
}
