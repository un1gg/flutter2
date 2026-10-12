import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPS Log (SQLite)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'GPS Log (SQLite)'),
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
  List<Map<String, dynamic>> _logs = [];
  Database? _db;

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    _db = await openDatabase(
      '${dir.path}/gps_log.db',
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE logs(id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp TEXT, latitude REAL, longitude REAL)',
        );
      },
      version: 1,
    );
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final data = await _db!.query('logs', orderBy: 'id DESC');
    setState(() {
      _logs = data;
    });
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

    await _db!.insert('logs', {
      'timestamp': DateTime.now().toIso8601String(),
      'latitude': position.latitude,
      'longitude': position.longitude,
    });
    _loadLogs();
  }

  @override
  void dispose() {
    _db?.close();
    super.dispose();
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
            child: ListView(
              children: _logs
                  .map(
                    (log) => ListTile(
                      title: Text('${log['latitude']}, ${log['longitude']}'),
                      subtitle: Text(log['timestamp']),
                    ),
                  )
                  .toList(),
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
