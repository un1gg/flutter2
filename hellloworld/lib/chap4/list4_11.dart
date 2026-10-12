import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('flutterDataCollection')
                    .doc('flutterDataDocument')
                    .get()
                    .then((ref) {
                      print(ref.get("mydata"));
                    });
              },
              child: const Text("リスト4.10", style: TextStyle(fontSize: 50)),
            ),
            TextButton(
              // リスト4.11
              onPressed: () {
                FirebaseFirestore.instance
                    .doc('flutterDataCollection/flutterDataDocument')
                    .get()
                    .then((ref) {
                      print(ref.get("mydata"));
                    });
              },
              child: const Text("リスト4.11", style: TextStyle(fontSize: 50)),
            ),
          ],
        ),
      ),
    );
  }
}
