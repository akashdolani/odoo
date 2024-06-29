import 'package:flutter/material.dart';
import 'package:live_crime_report/login/login.dart';
import 'package:live_crime_report/pages/heat_map.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({Key? key}) : super(key: key);

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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(
              12, 12, 12, 1.0), // Background color RGBA(12, 12, 12, 1.0)
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CriminalMarkers(),
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
                child: Text('Heat Map'),
              ),
              ElevatedButton(
                onPressed: () {},
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
        ),
      ),
    );
  }
}
