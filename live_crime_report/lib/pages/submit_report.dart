import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SubmitReportScreen extends StatefulWidget {
  final Set<Marker> markers;

  SubmitReportScreen({required this.markers});

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
  TimeOfDay _crimeTime = TimeOfDay.now();
  List<XFile> _images = [];

  @override
  void initState() {
    super.initState();
    _typeController.text =
        'Type of Crime'; // Default value for type of crime field
    _descriptionController.text = ''; // Default value for description field
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
      // Convert TimeOfDay to DateTime for crime time
      DateTime crimeDateTime = DateTime(
        _crimeDate.year,
        _crimeDate.month,
        _crimeDate.day,
        _crimeTime.hour,
        _crimeTime.minute,
      );

      // Prepare data to send to backend
      Map<String, dynamic> formData = {
        'type_of_crime': _typeController.text,
        'location': _locationController.text,
        'current_date': _currentDate.toIso8601String(),
        'crime_date': crimeDateTime.toIso8601String(),
        'description': _descriptionController.text,
        'markers': markersToJson(widget.markers),
      };

      // Example API endpoint URL (replace with your actual endpoint)
      var url = Uri.parse(
          'http://your-fastapi-server-url.com/api/submit_crime_report');

      try {
        // Send POST request to backend
        var response = await http.post(
          url,
          body: jsonEncode(formData),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          // Handle success (optional)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Crime report submitted successfully')),
          );

          // Clear form and images after submission
          _formKey.currentState?.reset();
          setState(() {
            _images = [];
            _currentDate = DateTime.now();
            _crimeDate = DateTime.now();
            _crimeTime = TimeOfDay.now();
          });
        } else {
          // Handle error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit crime report')),
          );
        }
      } catch (e) {
        // Handle network or server errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting crime report: $e')),
        );
      }
    }
  }

  String markersToJson(Set<Marker> markers) {
    List<Map<String, dynamic>> markersList = markers.map((marker) {
      return {
        'latitude': marker.position.latitude,
        'longitude': marker.position.longitude,
      };
    }).toList();
    return jsonEncode(markersList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Crime Report'),
      ),
      body: Padding(
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
                    'Current Date: ${_currentDate.toLocal()}'.split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _currentDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null && pickedDate != _currentDate) {
                    setState(() {
                      _currentDate = pickedDate;
                    });
                  }
                },
              ),
              ListTile(
                title: Text(
                    'Date of Crime: ${_crimeDate.toLocal()}'.split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _crimeDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null && pickedDate != _crimeDate) {
                    setState(() {
                      _crimeDate = pickedDate;
                    });
                  }
                },
              ),
              ListTile(
                title: Text('Time of Crime: ${_crimeTime.format(context)}'),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _crimeTime,
                  );
                  if (pickedTime != null && pickedTime != _crimeTime) {
                    setState(() {
                      _crimeTime = pickedTime;
                    });
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
