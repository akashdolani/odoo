import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _currentLocation;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Marker? _currentLocationMarker;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _currentLocationMarker = Marker(
        markerId: MarkerId('currentLocation'),
        position: _currentLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: 'Current Location'),
      );
      _markers.add(_currentLocationMarker!);
    });

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLocation!, zoom: 13),
      ),
    );
  }

  void _onMapTapped(LatLng position) {
    final marker = Marker(
      markerId: MarkerId(position.toString()),
      position: position,
    );
    setState(() {
      _markers.add(marker);
    });
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

  Future<void> _shareMarkers() async {
    if (_markers.isEmpty) {
      _showNoMarkersDialog();
      return;
    }

    String jsonData = markersToJson(_markers);
    var url = Uri.parse('http://your-fastapi-server-url.com/api/save_markers');

    try {
      var response = await http.post(
        url,
        body: jsonData,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _showSnackBar('Markers shared successfully');
      } else {
        _showSnackBar(
            'Failed to share markers. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error sharing markers: $e');
    }
  }

  void _deleteMarkers() {
    if (_markers.isEmpty || _markers.length == 1) {
      _showNoMarkersDialog();
      return;
    }

    setState(() {
      _markers = {
        _currentLocationMarker!
      }; // Retain only the current location marker
    });
  }

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _showNoMarkersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('No Markers'),
        content: Text('Please mark at least one location on the map.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map with Markers'),
      ),
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) => _mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation!,
                    zoom: 13,
                  ),
                  markers: _markers,
                  onTap: _onMapTapped,
                  zoomControlsEnabled: false, // Disable built-in zoom controls
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        onPressed: _zoomIn,
                        mini: true,
                        child: Icon(Icons.zoom_in),
                      ),
                      SizedBox(height: 8),
                      FloatingActionButton(
                        onPressed: _zoomOut,
                        mini: true,
                        child: Icon(Icons.zoom_out),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _shareMarkers,
            tooltip: 'Share Markers',
            child: Icon(Icons.share),
            heroTag: 'share',
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _deleteMarkers,
            tooltip: 'Delete Markers',
            child: Icon(Icons.delete),
            heroTag: 'delete',
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
