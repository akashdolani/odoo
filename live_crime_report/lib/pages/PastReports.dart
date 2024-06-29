import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PastReportsPage extends StatefulWidget {
  final String userPhoneNumber;

  PastReportsPage({required this.userPhoneNumber});

  @override
  _PastReportsPageState createState() => _PastReportsPageState();
}

class _PastReportsPageState extends State<PastReportsPage> {
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPastReports();
  }

  Future<void> _fetchPastReports() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.170.99:8000/api/get_past_reports/${widget.userPhoneNumber}'),
      );

      if (response.statusCode == 200) {
        print('Response data: ${response.body}');
        setState(() {
          _reports =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load reports')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading reports: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Reports'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? Center(child: Text('No reports found'))
              : ListView.builder(
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    final report = _reports[index];
                    return Card(
                      margin: EdgeInsets.all(10.0),
                      child: ListTile(
                        title: Text('Crime ID: ${report['CrimeID'] ?? ''}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Location: ${report['Location'] ?? ''}'),
                            Text(
                                'Report Date: ${report['ReportDate'] ?? ''} ${report['ReportTime'] ?? ''}'),
                            Text(
                                'Crime Date: ${report['CrimeDate'] ?? ''} ${report['CrimeTime'] ?? ''}'),
                            Text('Description: ${report['Description'] ?? ''}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
