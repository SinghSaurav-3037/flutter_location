import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as goa;
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Location'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Location location;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    locationService();
    getLocation();
    getLocationData();
  }

  locationService() {
    location = Location();
  }

  String currLocation = "";

  PermissionStatus? grantPermission;
  bool serviceEnabled = false;

  String? lat, lang, country, adminArea;

  Future<LocationData?> getLocation() async {
    if (await _checkPermission()) {
      final locationData = location.getLocation();
      return locationData;
    }
    return null;
  }

  Future<bool> _checkPermission() async {
    if (await _checkService()) {
      grantPermission = await location.hasPermission();
      if (grantPermission == PermissionStatus.denied) {
        grantPermission = await location.requestPermission();
      }
    }
    return grantPermission == PermissionStatus.granted;
  }

  Future<bool> _checkService() async {
    try {
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
      }
    } on PlatformException catch (error) {
      print('error code is ${error.code} and message is = ${error.message}');
      serviceEnabled = false;
      await _checkService();
    }
    return serviceEnabled;
  }

  Future<goa.Placemark?> getPlaceMark({
    required LocationData locationData,
  }) async {
    final placeMarks = await goa.placemarkFromCoordinates(
      locationData.latitude ?? 0.0,
      locationData.longitude ?? 0.0,
    );
    if (placeMarks.isNotEmpty) {
      return placeMarks[0];
    }
    return null;
  }

  getLocationData({clicked = false}) async {
    final locationData = await getLocation();
    print("Location Data is ${locationData!.latitude}");

    final placeMarks = await getPlaceMark(locationData: locationData);
    setState(() {
      lat = locationData.latitude.toString();
      lang = locationData.latitude.toString();
      country = placeMarks!.country ?? "";
      adminArea = placeMarks.locality ?? "";

      currLocation =
          "${placeMarks.country}/${placeMarks.administrativeArea}/${placeMarks.locality}/${placeMarks.subLocality}/${placeMarks.subAdministrativeArea}/${placeMarks.street}/${placeMarks.street}";

      if (clicked) {
        currLocation =
            "${placeMarks.country}/${placeMarks.administrativeArea}/${placeMarks.locality}/${placeMarks.subLocality}/${placeMarks.subAdministrativeArea}/${placeMarks.street}";
      }
      print("${placeMarks.country}/${placeMarks.administrativeArea}/${placeMarks.locality}/${placeMarks.subLocality}/${placeMarks.subAdministrativeArea}/${placeMarks.street}",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text("Your Current Location :-$currLocation"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getLocationData(clicked: true);
        },
        tooltip: 'Location',
        child: const Icon(Icons.location_on),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
