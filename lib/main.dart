import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kThemeModeKey = 'theme_mode';

// Global notifier for the app's ThemeMode
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_kThemeModeKey);
  themeNotifier.value = _themeModeFromString(saved);

  runApp(MyApp());
}

ThemeMode _themeModeFromString(String? s) {
  switch (s) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}

String _themeModeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
    default:
      return 'system';
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
          darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
          themeMode: mode,
          debugShowCheckedModeBanner: false,
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const CompassPage(),
    const LevelPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compass'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      backgroundColor: const HSLColor.fromAHSL(1, 0, 0, 0.05).toColor(),
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Compass'),
          BottomNavigationBarItem(
            icon: Icon(Icons.architecture),
            label: 'Level',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Filtered accelerometer values container
class FilteredAccelerometer {
  final double x;
  final double y;
  final double z;
  const FilteredAccelerometer(this.x, this.y, this.z);
}

// A filtered accelerometer stream that applies a simple low-pass filter and
// suppresses small-magnitude changes to reduce jitter/disturbance.
Stream<FilteredAccelerometer> filteredAccelerometerStream({
  double alpha = 0.15,
  double threshold = 0.12,
}) {
  double fx = 0, fy = 0, fz = 0;
  double prevMag = 0;

  // Use the non-deprecated package stream as source
  return accelerometerEventStream().transform(
    StreamTransformer<AccelerometerEvent, FilteredAccelerometer>.fromHandlers(
      handleData:
          (AccelerometerEvent event, EventSink<FilteredAccelerometer> sink) {
            fx = alpha * event.x + (1 - alpha) * fx;
            fy = alpha * event.y + (1 - alpha) * fy;
            fz = alpha * event.z + (1 - alpha) * fz;

            final mag = math.sqrt(fx * fx + fy * fy + fz * fz);
            if ((mag - prevMag).abs() > threshold) {
              prevMag = mag;
              // Emit filtered values so consumers get smoothed data
              sink.add(FilteredAccelerometer(fx, fy, fz));
            }
            // otherwise drop the sample to avoid UI jitter
          },
    ),
  );
}

class CompassPage extends StatefulWidget {
  const CompassPage({super.key});

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;
        double size = math.min(width, height) * 0.9;

        return StreamBuilder<CompassEvent>(
          stream: FlutterCompass.events,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error reading heading: ${snapshot.error}'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            double? direction = snapshot.data?.heading;

            if (direction == null) {
              return const Center(
                child: Text("Device does not have sensors !"),
              );
            }

            int ang = direction.round();
            return Stack(
              alignment: Alignment.center,
              children: [
                // Compass Image
                Container(
                  width: size,
                  height: size,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEBEBEB),
                  ),
                  child: Transform.rotate(
                    angle: (direction * (math.pi / 180) * -1),
                    child: Image.asset('assets/compass.png'),
                  ),
                ),
                // Heading Text
                Text(
                  "$ang°",
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Indicator Line
                Positioned(
                  top: (height - size) / 2,
                  child: Container(width: 4, height: 30, color: Colors.red),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class LevelPage extends StatefulWidget {
  const LevelPage({super.key});

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FilteredAccelerometer>(
      stream: filteredAccelerometerStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading level sensors"));
        }

        double x = 0;
        double y = 0;

        if (snapshot.hasData) {
          x = snapshot.data!.x;
          y = snapshot.data!.y;
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "X: ${x.toStringAsFixed(1)} Y: ${y.toStringAsFixed(1)}",
                style: const TextStyle(fontSize: 24, color: Colors.white70),
              ),
              const SizedBox(height: 50),
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      color: Colors.black26,
                    ),
                  ),
                  // Inner target
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white54, width: 1),
                    ),
                  ),
                  // The bubble
                  Transform.translate(
                    offset: Offset(x * 12, y * 12),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.greenAccent,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.greenAccent,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0'),
            leading: Icon(Icons.info_outline),
          ),
          // Theme selection
          ExpansionTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            children: [
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, mode, _) {
                  Future<void> save(ThemeMode m) async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString(
                      _kThemeModeKey,
                      _themeModeToString(m),
                    );
                    themeNotifier.value = m;
                  }

                  return Column(
                    children: [
                      RadioListTile<ThemeMode>(
                        title: const Text('System'),
                        value: ThemeMode.system,
                        groupValue: mode,
                        onChanged: (v) => v != null ? save(v) : null,
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('Light'),
                        value: ThemeMode.light,
                        groupValue: mode,
                        onChanged: (v) => v != null ? save(v) : null,
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('Dark'),
                        value: ThemeMode.dark,
                        groupValue: mode,
                        onChanged: (v) => v != null ? save(v) : null,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          ListTile(
            title: const Text('Open source licenses'),
            leading: const Icon(Icons.code),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'Compass',
                applicationVersion: '1.0.0',
              );
            },
          ),
          ListTile(
            title: const Text('Privacy notice'),
            leading: const Icon(Icons.privacy_tip_outlined),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const PrivacyScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy notice')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: const Text(
          'Privacy notice placeholder. This demo reads sensor values locally and does not transmit data. Update this page with your real privacy policy.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
