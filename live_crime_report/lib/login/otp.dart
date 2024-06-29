import 'dart:ui';
import 'package:live_crime_report/home/admin.dart';
import 'package:live_crime_report/home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  bool _isLoading = false;

  // Function to handle OTP verification
  void showInvalidOtpSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Invalid OTP"),
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.grey[700],
        elevation: 6,
      ),
    );
  }

  // Function to resend OTP
  Future<void> resendOtp(String phoneNumber, BuildContext context) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.post(
        Uri.parse('http://192.168.170.99:8000/resend_otp'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'phone_number': phoneNumber}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        Navigator.pushReplacementNamed(
          context,
          '/otp',
          arguments: {
            'phoneNumber': phoneNumber,
            'receivedOtp': responseData['otp'],
          },
        );
      } else {
        print('Failed to resend OTP. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error resending OTP: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to verify OTP and navigate based on result
  void verifyOtp(String enteredOtp, String receivedOtp, String phoneNumber,
      BuildContext context) {
    if (receivedOtp == enteredOtp) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('phoneNumber', phoneNumber);
        prefs.setBool('firstTimeLogin', false);
      });

      if (phoneNumber == "7990187279") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminPage(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              userPhoneNumber: phoneNumber,
            ),
          ),
        );
      }
    } else {
      showInvalidOtpSnackBar(context);
    }
  }

  // Function to verify OTP with backend and navigate

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String phoneNumber = arguments['phoneNumber'];
    final String receivedOtp = arguments['receivedOtp'];
    final String enteredOtp = '';

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Color.fromRGBO(12, 12, 12, 0.9),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 40),
                  child: Text(
                    "+91 $phoneNumber",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                Pinput(
                  autofillHints: const [AutofillHints.oneTimeCode],
                  length: 6,
                  controller: TextEditingController(
                    text: enteredOtp,
                  ),
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                  onCompleted: (pin) =>
                      verifyOtp(pin, receivedOtp, phoneNumber, context),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () async {
                    await resendOtp(phoneNumber, context);
                  },
                  child: const Text(
                    "Resend OTP",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    verifyOtp(enteredOtp, receivedOtp, phoneNumber, context);
                  },
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : const Text(
                          "Verify",
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: CircularProgressIndicator(),
                      ),
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
