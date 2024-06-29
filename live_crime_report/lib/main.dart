import 'package:flutter/material.dart';
import 'package:live_crime_report/home/admin.dart';
import 'package:live_crime_report/home/home.dart';
import 'package:live_crime_report/login/login.dart';
import 'package:live_crime_report/login/otp.dart';
import 'package:live_crime_report/pages/google_maps.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:live_crime_report/pages/google_maps.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool firstTimeLogin = prefs.getBool('firstTimeLogin') ?? true;
  runApp(MyApp(
    firstTimeLogin: firstTimeLogin,
  ));
}

class MyApp extends StatelessWidget {
  final bool firstTimeLogin;
  const MyApp({super.key, required this.firstTimeLogin});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => AnimatedSplash(
              firstTimeLogin: firstTimeLogin,
            ),
        '/login': (context) => LoginScreen(),
        '/otp': (context) => OtpScreen(),
      },
    );
  }
}

class AnimatedSplash extends StatefulWidget {
  final bool firstTimeLogin;
  const AnimatedSplash({Key? key, required this.firstTimeLogin})
      : super(key: key);
  @override
  _AnimatedSplashState createState() => _AnimatedSplashState();
}

class _AnimatedSplashState extends State<AnimatedSplash> {
  final String splashText = 'MobileOrlovAI';
  String _currentText = '';
  late String _phoneNumber = '';
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _animateText();
    await _getUserData();

    // Navigate to the main screen when text animation completes
    if (_phoneNumber == "7990187279") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              widget.firstTimeLogin ? LoginScreen() : AdminPage(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => widget.firstTimeLogin
              ? LoginScreen()
              : HomeScreen(
                  userPhoneNumber: _phoneNumber,
                ),
        ),
      );
    }
  }

  Future<void> _animateText() async {
    for (int i = 0; i <= splashText.length; i++) {
      setState(() {
        _currentText = splashText.substring(0, i);
      });
      await Future.delayed(
          Duration(milliseconds: 100)); // Adjust the delay as needed
    }
  }

  Future<void> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _phoneNumber = prefs.getString('phoneNumber') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(12, 12, 12, 1),
      ),
      child: Scaffold(
        backgroundColor:
            Color.fromRGBO(12, 12, 12, 1), // Set the background color
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/logo.png',
                  height: 200.0,
                  width: 200.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
