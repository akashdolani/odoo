import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SubmitReportScreen extends StatefulWidget {
  final Set<Marker> markers;
  final String userPhoneNumber;

  SubmitReportScreen({
    required this.markers,
    required this.userPhoneNumber,
  });

  @override
  _SubmitReportScreenState createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _currentDate = DateTime.now();
  DateTime _crimeDate = DateTime.now();
  List<XFile> _images = [];

  @override
  void initState() {
    super.initState();
    _typeController.text = '';
    _descriptionController.text = '';
  }

  Future<void> _pickImages() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        _images = selectedImages;
      });
    }
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState?.validate() ?? false) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.170.99:8000/api/submit_crime_report'),
      );

      request.fields['type_of_crime'] = _typeController.text;
      request.fields['location'] = _locationController.text;
      request.fields['current_date'] = _currentDate.toIso8601String();
      request.fields['crime_date'] = _crimeDate.toIso8601String();
      request.fields['description'] = _descriptionController.text;
      request.fields['markers'] = jsonEncode(widget.markers.map((marker) {
        return {
          'latitude': marker.position.latitude,
          'longitude': marker.position.longitude,
        };
      }).toList());
      request.fields['phone_number'] = widget.userPhoneNumber;

      for (var image in _images) {
        request.files.add(
          await http.MultipartFile.fromPath('images', image.path),
        );
      }

      try {
        var response = await request.send();

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Crime report submitted successfully')),
          );

          _formKey.currentState?.reset();
          setState(() {
            _images = [];
            _currentDate = DateTime.now();
            _crimeDate = DateTime.now();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit crime report')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting crime report: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Crime Report'),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(
              12, 12, 12, 1.0), // Background color RGBA(12, 12, 12, 1.0)
        ),
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(labelText: 'Type of Crime'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the type of crime';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text(
                  'Current Date & Time: ${_currentDate.toLocal().toString().split(' ')[0]} ${_currentDate.toLocal().hour}:${_currentDate.toLocal().minute}',
                ),
              ),
              ListTile(
                title: Text(
                  'Date & Time of Crime: ${_crimeDate.toLocal().toString().split(' ')[0]} ${_crimeDate.toLocal().hour}:${_crimeDate.toLocal().minute}',
                ),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _crimeDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_crimeDate),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _crimeDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: Icon(Icons.camera_alt),
                label: Text('Upload Images'),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromRGBO(
                      253, 112, 20, 1.0), // Background color RGB(253, 112, 20)
                  textStyle: TextStyle(fontSize: 18.0), // Adjust text size
                  padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 32.0), // Adjust padding as needed
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                  ),
                ),
              ),
              SizedBox(height: 10),
              _images.isNotEmpty
                  ? Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _images.map((image) {
                        return Image.file(
                          File(image.path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        );
                      }).toList(),
                    )
                  : Text('No images selected'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitReport,
                child: Text('Submit Report'),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromRGBO(
                      253, 112, 20, 1.0), // Background color RGB(253, 112, 20)
                  textStyle: TextStyle(fontSize: 18.0), // Adjust text size
                  padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 32.0), // Adjust padding as needed
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
