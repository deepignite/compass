import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:compass/privacy_policy.dart';
import 'open_source_licenses.dart';
import 'package:nowa_runtime/nowa_runtime.dart';

const String _kThemeModeKey = 'theme_mode';

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
      return 'system';
  }
}

@NowaGenerated()
class MyApp extends StatelessWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) => MaterialApp(
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
        themeMode: mode,
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(),
        routes: {
          'MyHomePage': (context) => const MyHomePage(),
          'SettingsScreen': (context) => const SettingsScreen(),
          'PrivacyPolicyScreen': (context) => const PrivacyPolicyScreen(),
        },
      ),
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

class FilteredAccelerometer {
  final double x;
  final double y;
  final double z;
  const FilteredAccelerometer(this.x, this.y, this.z);
}

Stream<FilteredAccelerometer> filteredAccelerometerStream({
  double alpha = 0.2,
}) {
  double fx = 0, fy = 0, fz = 0;
  var hasInitialSample = false;

  return accelerometerEventStream(
    samplingPeriod: SensorInterval.gameInterval,
  ).transform(
    StreamTransformer<AccelerometerEvent, FilteredAccelerometer>.fromHandlers(
      handleData:
          (AccelerometerEvent event, EventSink<FilteredAccelerometer> sink) {
            if (!hasInitialSample) {
              fx = event.x;
              fy = event.y;
              fz = event.z;
              hasInitialSample = true;
            } else {
              fx = alpha * event.x + (1 - alpha) * fx;
              fy = alpha * event.y + (1 - alpha) * fy;
              fz = alpha * event.z + (1 - alpha) * fz;
            }

            sink.add(FilteredAccelerometer(fx, fy, fz));
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
  late final Stream<CompassEvent>? _compassStream;

  @override
  void initState() {
    super.initState();
    _compassStream = FlutterCompass.events;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;
        double size = math.min(width, height) * 0.9;

        return StreamBuilder<CompassEvent>(
          stream: _compassStream,
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

            final ang = direction.round() % 360;
            return Center(
              child: SizedBox.square(
                dimension: size,
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFEBEBEB),
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: _ShortestAngleTween(
                        end: direction * (math.pi / 180),
                      ),
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOut,
                      builder: (context, angle, child) =>
                          Transform.rotate(angle: -angle, child: child),
                      child: Image.asset(
                        'assets/images/compass.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Center(
                      child: Text(
                        "$ang°",
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 4,
                          height: 30,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
  late final Stream<FilteredAccelerometer> _accelerometerStream;

  @override
  void initState() {
    super.initState();
    _accelerometerStream = filteredAccelerometerStream();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FilteredAccelerometer>(
      stream: _accelerometerStream,
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

class _ShortestAngleTween extends Tween<double> {
  _ShortestAngleTween({required double end}) : super(end: end);

  @override
  double lerp(double t) {
    final start = begin ?? 0;
    final finish = end ?? start;
    final delta = ((finish - start + math.pi) % (2 * math.pi)) - math.pi;
    return start + delta * t;
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

                  return RadioGroup<ThemeMode>(
                    groupValue: mode,
                    onChanged: (value) {
                      if (value != null) save(value);
                    },
                    child: Column(
                      children: [
                        RadioListTile<ThemeMode>(
                          title: const Text('System'),
                          value: ThemeMode.system,
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text('Light'),
                          value: ThemeMode.light,
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text('Dark'),
                          value: ThemeMode.dark,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          ListTile(
            title: const Text('Open source licenses'),
            leading: const Icon(Icons.code),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OpenSourceLicensesPage(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            leading: const Icon(Icons.privacy_tip_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
