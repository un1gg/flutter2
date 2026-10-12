// リスト3.10
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  String _altitude = "NoData";
  String _distanceInMeters = "NoData";
  String _bearing = "NoData";

  Future<void> getLocation() async {
    // 権限を取得
    LocationPermission permission = await Geolocator.requestPermission();
    // ignore: avoid_print
    print(permission);
    // 権限がない場合は戻る
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    // 位置情報を取得
    Position position = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      // 北緯がプラス、南緯がマイナス
      _latitude = "緯度: ${position.latitude.toStringAsFixed(2)}";
      // 東経がプラス、西経がマイナス
      _longitude = "経度: ${position.longitude.toStringAsFixed(2)}";
      // 高度
      _altitude = "高度: ${position.altitude.toStringAsFixed(2)}";
      // 距離を1000で割ってkmで返す(サンパウロとの距離)
      _distanceInMeters =
          "距離:${(Geolocator.distanceBetween(position.latitude, position.longitude, -23.61, -46.40) / 1000).toStringAsFixed(2)}";
      // 方位を返す(サンパウロとの方位)
      _bearing =
          "方位: ${(Geolocator.bearingBetween(position.latitude, position.longitude, -23.61, -46.40)).toStringAsFixed(2)}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_latitude, style: Theme.of(context).textTheme.headlineMedium),
            Text(_longitude, style: Theme.of(context).textTheme.headlineMedium),
            Text(_altitude, style: Theme.of(context).textTheme.headlineMedium),
            Text(
              _distanceInMeters,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(_bearing, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getLocation,
        child: const Icon(Icons.location_on),
      ),
    );
  }
}
