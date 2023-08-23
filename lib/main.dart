// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sea Prayer Time',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: const PrayerTimesScreen(),
    );
  }
}

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  _PrayerTimesScreenState createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  loc.LocationData? _currentLocation;
  PrayerTimes? _prayerTimes;
  Stream<DateTime>? clockStream;
  String? _currentPlace;

  @override
  void initState() {
    super.initState();
    _getLocationAndCalculatePrayerTimes();
    clockStream = Stream<DateTime>.periodic(
      const Duration(seconds: 1),
      (_) {
        return DateTime.now();
      },
    );
  }

  Future<void> _getCityName(loc.LocationData position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude ?? 0.0, position.longitude ?? 0.0);
    if (placemarks.isNotEmpty) {
      setState(() {
        _currentPlace =
            '${placemarks[0].locality}, ${placemarks[0].administrativeArea}, ${placemarks[0].country}';
      });
    }
  }

  Future<void> _getLocationAndCalculatePrayerTimes() async {
    final location = loc.Location();
    final bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      final bool serviceRequest = await location.requestService();
      if (!serviceRequest) {
        return;
      }
    }

    final loc.PermissionStatus permissionGranted =
        await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      final loc.PermissionStatus permissionRequest =
          await location.requestPermission();
      if (permissionRequest != loc.PermissionStatus.granted) {
        return;
      }
    }

    final loc.LocationData locationData = await location.getLocation();
    final params = CalculationMethod.karachi.getParameters();
    final coordinates = Coordinates(
        locationData.latitude ?? 0.0, locationData.longitude ?? 0.0);
    DateTime today = DateTime.now();
    DateComponents dateComponents =
        DateComponents(today.year, today.month, today.day);
    final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

    setState(() {
      _getCityName(locationData);
      _currentLocation = locationData;
      _prayerTimes = prayerTimes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.1,
        centerTitle: true,
        titleTextStyle: const TextStyle(
            color: Colors.black54, fontSize: 25, fontWeight: FontWeight.bold),
        title: const Text(
          'Sea Prayer Times',
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: StreamBuilder<DateTime>(
            stream: clockStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                DateTime currentTime = snapshot.data!;
                String formattedTime =
                    DateFormat('HH:mm:ss').format(currentTime);
                String formattedDate =
                    DateFormat('dd/MM/yyyy').format(currentTime);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (_currentPlace != null)
                      Text(
                        _currentPlace ?? 'Unknown Location',
                        style: const TextStyle(fontSize: 18),
                      ),
                    if (_currentLocation != null)
                      Text(
                        '${_currentLocation!.latitude}, ${_currentLocation!.longitude}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    const SizedBox(height: 20),
                    if (_prayerTimes != null)
                      Column(
                        children: [
                          Text(
                            formattedTime,
                            style: const TextStyle(
                                fontSize: 48, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text('Jadwal Sholat Hari ini ($formattedDate)',
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 50),
                          Container(
                            margin: const EdgeInsets.fromLTRB(18, 0, 18, 5),
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(left: 16),
                                      margin:
                                          const EdgeInsetsDirectional.symmetric(
                                              vertical: 20),
                                      child: const Text(
                                        'Subuh',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(right: 16),
                                      margin:
                                          const EdgeInsetsDirectional.symmetric(
                                              vertical: 20),
                                      child: Text(
                                        DateFormat('HH:mm')
                                            .format(_prayerTimes!.fajr),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(18, 5, 18, 5),
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(left: 16),
                                      margin:
                                          const EdgeInsetsDirectional.symmetric(
                                              vertical: 20),
                                      child: const Text(
                                        'Duhur',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(right: 16),
                                      margin:
                                          const EdgeInsetsDirectional.symmetric(
                                              vertical: 20),
                                      child: Text(
                                        DateFormat('HH:mm')
                                            .format(_prayerTimes!.dhuhr),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(18, 5, 18, 5),
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(left: 16),
                                      margin:
                                          const EdgeInsetsDirectional.symmetric(
                                              vertical: 20),
                                      child: const Text(
                                        'Asar',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(right: 16),
                                      margin:
                                          const EdgeInsetsDirectional.symmetric(
                                              vertical: 20),
                                      child: Text(
                                        DateFormat('HH:mm')
                                            .format(_prayerTimes!.asr),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(18, 5, 18, 5),
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(left: 16),
                                      margin:
                                          const EdgeInsetsDirectional.symmetric(
                                              vertical: 20),
                                      child: const Text(
                                        'Maghrib',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(right: 16),
                                      margin:
                                          const EdgeInsetsDirectional.symmetric(
                                              vertical: 20),
                                      child: Text(
                                        DateFormat('HH:mm')
                                            .format(_prayerTimes!.maghrib),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(18, 5, 18, 5),
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(left: 16),
                                      margin:
                                          const EdgeInsetsDirectional.symmetric(
                                              vertical: 20),
                                      child: const Text(
                                        'Isya',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(right: 16),
                                      margin:
                                          const EdgeInsetsDirectional.symmetric(
                                              vertical: 20),
                                      child: Text(
                                        DateFormat('HH:mm')
                                            .format(_prayerTimes!.isha),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    if (_currentLocation == null ||
                        _prayerTimes == null ||
                        _currentPlace == null)
                      const CircularProgressIndicator(),
                  ],
                );
              } else {
                return const Text('Keluar dan coba masuk kembali!');
              }
            },
          ),
        ),
      ),
    );
  }
}
