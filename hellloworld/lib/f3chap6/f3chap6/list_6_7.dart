// リスト6-7
// ※ 注意 ブラウザ環境では動作しません
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generated App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = TextEditingController();
  double _r = 0.0;
  double _g = 0.0;
  double _b = 0.0;

  @override
  void initState() {
    super.initState();
    loadPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'PREFERENCES ACCESS.',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
            ),
            Padding(padding: EdgeInsets.all(10.0)),
            TextField(
              controller: _controller,
              style: TextStyle(fontSize: 24),
              minLines: 1,
              maxLines: 5,
            ),
            Padding(padding: EdgeInsets.all(10.0)),
            Slider(
              min: 0.0,
              max: 255.0,
              value: _r,
              divisions: 255,
              onChanged: (double value) {
                setState(() {
                  _r = value;
                });
              },
            ),
            Slider(
              min: 0.0,
              max: 255.0,
              value: _g,
              divisions: 255,
              onChanged: (double value) {
                setState(() {
                  _g = value;
                });
              },
            ),
            Slider(
              min: 0.0,
              max: 255.0,
              value: _b,
              divisions: 255,
              onChanged: (double value) {
                setState(() {
                  _b = value;
                });
              },
            ),
            Container(
              padding: EdgeInsets.all(20),
              width: 125,
              height: 125,
              color: Color.fromARGB(255, _r.toInt(), _g.toInt(), _b.toInt()),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.open_in_new),
        onPressed: () {
          savePref();
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text("saved!"),
              content: Text("save preferences."),
            ),
          );
        },
      ),
    );
  }

  Future<void> loadPref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _r = (prefs.getDouble('r') ?? 0.0);
      _g = (prefs.getDouble('g') ?? 0.0);
      _b = (prefs.getDouble('b') ?? 0.0);
      _controller.text = (prefs.getString('input') ?? '');
    });
  }

  Future<void> savePref() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('r', _r);
    prefs.setDouble('g', _g);
    prefs.setDouble('b', _b);
    prefs.setString('input', _controller.text);
  }
}
