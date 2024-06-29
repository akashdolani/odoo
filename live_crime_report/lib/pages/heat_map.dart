import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MarkerData {
  final String crimeId;
  final double latitude;
  final double longitude;

  MarkerData({
    required this.crimeId,
    required this.latitude,
    required this.longitude,
  });

  factory MarkerData.fromJson(Map<String, dynamic> json) {
    return MarkerData(
      crimeId: json['CrimeID'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

class CriminalMarkers extends StatefulWidget {
  @override
  _CriminalMarkersState createState() => _CriminalMarkersState();
}

class _CriminalMarkersState extends State<CriminalMarkers> {
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchMarkers();
  }

  Future<void> _fetchMarkers() async {
    final response =
        await http.get(Uri.parse('http://192.168.170.29:8000/api/get_markers'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      Set<Marker> markers = {};
      data.forEach((markerData) {
        double lat = double.parse(markerData['latitude'].toString());
        double lng = double.parse(markerData['longitude'].toString());
        markers.add(
          Marker(
            markerId: MarkerId(markerData['CrimeID']),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: markerData['CrimeID'],
              snippet: 'Lat: $lat, Lng: $lng',
            ),
          ),
        );
      });
      setState(() {
        _markers = markers;
      });
    } else {
      print('Failed to load markers. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crime Marker Map'),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(23.0845565,
              72.629863), // Initial position if no markers are available
          zoom: 12,
        ),
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {},
      ),
    );
  }
}
