import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:line_awesome_flutter/line_awesome_flutter.dart';
// import 'package:live_crime_report/home/home.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Added loading indicator state

  void _showInvalidNumberPopup(String message, String error) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void _hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  void _handleResponse(String responseMessage) {
    if (responseMessage.contains('Invalid phone number')) {
      _showInvalidNumberPopup(
          'Phone number is invalid.', 'INVALID_PHONE_NUMBER');
    } else {
      _showInvalidNumberPopup(
          'Failed to send OTP. Please try again later.', 'SERVER_ERROR');
    }
  }

  sendOtp(String phoneNumber) async {
    try {
      _showLoading(); // Show loading indicator

      final response = await http.post(
        Uri.parse('http://192.168.170.99:8000/send_otp'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'phone_number': phoneNumber}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['error'] != null) {
          _handleResponse(responseData['error']);
        } else {
          Navigator.pushNamed(
            context,
            '/otp',
            arguments: {
              'phoneNumber': phoneNumber,
              'receivedOtp': responseData['otp'],
            },
          );
        }
      } else {
        print('Failed to send OTP. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        _showInvalidNumberPopup(
            'Failed to send OTP. Please try again later.', 'SERVER_ERROR');
      }
    } catch (e) {
      print('Error sending OTP: $e');
      _showInvalidNumberPopup(
          'Failed to send OTP. Please try again later.', 'SERVER_ERROR');
    } finally {
      _hideLoading(); // Hide loading indicator regardless of success or failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color.fromRGBO(12, 12, 12, 0.7),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.43),
            Container(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Log in or sign up to continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Container(
                        child: TextFormField(
                          style: TextStyle(color: Colors.white),
                          keyboardType: TextInputType.phone,
                          controller: _phoneNumberController,
                          maxLength: 10,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length != 10) {
                              return 'Please enter a valid 10-digit phone number.';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            fillColor: Color.fromRGBO(100, 100, 100, 0.5),
                            filled: true,
                            prefixIcon: Icon(
                              Icons.phone,
                              color: Colors.white,
                            ),
                            hintText: 'Enter phone number without +91',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            labelText: 'Phone',
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                            helperText:
                                "we'll send you an OTP by SMS to confirm your number",
                            helperStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      // Container(
                      //   padding: EdgeInsets.only(left: 11.0, top: 5),
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       // ignore: deprecated_member_use
                      //       launch(
                      //           'https://orlovinnovations.com/privacyPolicy.html');
                      //     },
                      //     child: Text(
                      //       'By signing up, you agree to our Privacy Policy',
                      //       style: TextStyle(
                      //         fontSize: 11.0,
                      //         color: Colors.white,
                      //         decoration: TextDecoration.underline,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            sendOtp(_phoneNumberController.text);
                          } else {
                            _showInvalidNumberPopup(
                              'Please enter a valid 10-digit phone number.',
                              'INVALID_NUMBER',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'Get OTP',
                            style:
                                TextStyle(fontSize: 18.0, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
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
    );
  }
}
