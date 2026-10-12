import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPS Log',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'GPS Log'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _latitude = "NoData";
  String _longitude = "NoData";
  String _log = "";

  @override
  void initState() {
    super.initState();
    _loadLog();
  }

  Future<File> _getLogFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/gps_log.txt');
  }

  Future<void> _getLocationAndSave() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _latitude = "緯度: ${position.latitude.toStringAsFixed(6)}";
      _longitude = "経度: ${position.longitude.toStringAsFixed(6)}";
    });

    // テキストファイルにログ追記
    final file = await _getLogFile();
    final timestamp = DateTime.now().toIso8601String();
    await file.writeAsString(
      '$timestamp, ${position.latitude}, ${position.longitude}\n',
      mode: FileMode.append,
    );
    _loadLog();
  }

  Future<void> _loadLog() async {
    final file = await _getLogFile();
    if (await file.exists()) {
      final content = await file.readAsString();
      setState(() {
        _log = content;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  _latitude,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  _longitude,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(_log),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getLocationAndSave,
        child: const Icon(Icons.location_on),
      ),
    );
  }
}
