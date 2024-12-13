import 'dart:async';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'products.dart'; // Import your products.dart file
import 'manage_products.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart'; // Add this import for Rx.combineLatestList




// Firebase configuration for web, replace with your actual tokens
const firebaseConfig = FirebaseOptions(
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_AUTH_DOMAIN",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_STORAGE_BUCKET",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID",
  measurementId: "YOUR_MEASUREMENT_ID",
);



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with different options based on the platform
  if (kIsWeb) {
    await Firebase.initializeApp(options: firebaseConfig);
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => RegistrationPage(),
        '/products': (context) => ProductsPage(),
        '/manage': (context) => ManageProductsPage(),
        '/tcp': (context) => Scaffold(
          appBar: AppBar(title: Text("WebSocket Sensor Data")),
          body: WebSocketSensorClient(),
        ),
        '/chart': (context) => SensorChartPage(
          collections: const ['BMP180Data', 'DHT11Data'],
          title: 'Combined Sensor Data',
        ),

      },
    );
  }
}



class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pushNamed(context, '/products'); // Redirect to ProductsPage on successful login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Log In',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Corrected here
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      backgroundColor: Colors.lightBlue[100],
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomTextField(
              controller: emailController,
              labelText: 'Email',
            ),
            SizedBox(height: 10),
            CustomTextField(
              controller: passwordController,
              labelText: 'Password',
              obscureText: true,
            ),
            SizedBox(height: 20),
            CustomElevatedButton(
              text: 'Log in',
              onPressed: () {
                loginUser(context);
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegistrationPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> registerUser(BuildContext context) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pop(context); // Go back to login after successful registration
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Register',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      backgroundColor: Colors.lightBlue[100],
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomTextField(
              controller: emailController,
              labelText: 'Email',
            ),
            SizedBox(height: 10),
            CustomTextField(
              controller: passwordController,
              labelText: 'Password',
              obscureText: true,
            ),
            SizedBox(height: 20),
            CustomElevatedButton(
              text: 'Register',
              onPressed: () {
                registerUser(context);
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom TextField widget
// Custom TextField widget
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;

  const CustomTextField({
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.blueAccent,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}


class WebSocketSensorClient extends StatefulWidget {
  @override
  _WebSocketSensorClientState createState() => _WebSocketSensorClientState();
}

class _WebSocketSensorClientState extends State<WebSocketSensorClient> {
  final TextEditingController _ipController =
  TextEditingController(text: "192.168.185.99"); // Replace with ESP8266 IP
  final TextEditingController _portController = TextEditingController(text: "81");
  late WebSocketChannel _channel;
  late StreamSubscription _subscription;
  String _sensorData = "No data received yet";
  String? _lastRequestSent;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  @override
  void dispose() {
    // Cancel the subscription to prevent callbacks after disposal
    _subscription.cancel();

    // Close the WebSocket with a valid close code for the web
    _channel.sink.close(1000, "Normal closure");
    super.dispose();
  }

  void _connectWebSocket() {
    final url = "ws://${_ipController.text}:${_portController.text}/";
    _channel = WebSocketChannel.connect(Uri.parse(url));

    _subscription = _channel.stream.listen(
          (message) async {
        if (!mounted) return;

        setState(() {
          _sensorData = message;
        });

        // Dynamically store data in Firestore based on the last request sent
        if (_lastRequestSent == "BMP180") {
          var parsedData = _parseBMP180Data(message);
          await _storeSensorData("BMP180Data", parsedData);
        } else if (_lastRequestSent == "BH1750") {
          var parsedData = _parseBH1750Data(message);
          await _storeSensorData("BH1750Data", parsedData);
        } else if (_lastRequestSent == "DHT11") {
          var parsedData = _parseDHT11Data(message);
          await _storeSensorData("DHT11Data", parsedData);
        }

        _lastRequestSent = null; // Reset after handling
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _sensorData = "Error: $error";
        });
      },
      onDone: () {
        if (!mounted) return;
        setState(() {
          _sensorData = "Connection closed.";
        });
      },
    );
  }

  void _sendRequest(String request) {
    _lastRequestSent = request;
    _channel.sink.add(request);
  }

  Future<void> _storeSensorData(String collectionName, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection(collectionName).add(data);
      print("Data added to $collectionName collection: $data");
    } catch (e) {
      print("Failed to store data: $e");
    }
  }

  Map<String, dynamic> _parseBMP180Data(String message) {
    final lines = message.split('\n').map((line) => line.trim()).toList();
    final nonEmptyLines = lines.where((line) => line.isNotEmpty).toList();

    if (nonEmptyLines.length < 2) {
      return {
        "timestamp": DateTime.now().toIso8601String(),
        "error": "Invalid BMP180 data format: '$message'"
      };
    }

    final cleanedLines = nonEmptyLines.map((line) {
      var cleaned = line.replaceAll("BMP180 ", "").trim();
      if (cleaned.endsWith(',')) {
        cleaned = cleaned.substring(0, cleaned.length - 1).trim();
      }
      return cleaned;
    }).toList();

    double? temperature;
    double? pressure;

    for (var line in cleanedLines) {
      if (line.startsWith("Temperature:")) {
        final tempStr = line.split(":")[1].trim().replaceAll("°C", "").trim();
        temperature = double.tryParse(tempStr);
      } else if (line.startsWith("Pressure:")) {
        final pressStr = line.split(":")[1].trim().replaceAll("hPa", "").trim();
        pressure = double.tryParse(pressStr);
      }
    }

    if (temperature == null || pressure == null) {
      return {
        "timestamp": DateTime.now().toIso8601String(),
        "error": "Could not parse BMP180 data: '$message'"
      };
    }

    return {
      "timestamp": DateTime.now().toIso8601String(),
      "temperature": temperature,
      "pressure": pressure,
    };
  }

  Map<String, dynamic> _parseDHT11Data(String message) {
    final lines = message.split('\n').map((line) => line.trim()).toList();
    final nonEmptyLines = lines.where((line) => line.isNotEmpty).toList();

    if (nonEmptyLines.length < 2) {
      return {
        "timestamp": DateTime.now().toIso8601String(),
        "error": "Invalid DHT11 data format: '$message'"
      };
    }

    final cleanedLines = nonEmptyLines.map((line) {
      return line.replaceAll("DHT11 ", "").trim();
    }).toList();

    double? humidity;
    double? temperature;

    for (var line in cleanedLines) {
      if (line.startsWith("Humidity:")) {
        final humStr = line.split(":")[1].trim().replaceAll("%", "").trim();
        humidity = double.tryParse(humStr);
      } else if (line.startsWith("Temperature:")) {
        final tempStr = line.split(":")[1].trim().replaceAll("°C", "").trim();
        temperature = double.tryParse(tempStr);
      }
    }

    if (humidity == null || temperature == null) {
      return {
        "timestamp": DateTime.now().toIso8601String(),
        "error": "Could not parse DHT11 data: '$message'"
      };
    }

    return {
      "timestamp": DateTime.now().toIso8601String(),
      "humidity": humidity,
      "temperature": temperature,
    };
  }

  Map<String, dynamic> _parseBH1750Data(String message) {
    final line = message.trim();
    var cleaned = line.replaceAll("BH1750 ", "").trim();

    if (!cleaned.contains("Luminosity:")) {
      return {
        "timestamp": DateTime.now().toIso8601String(),
        "error": "Invalid BH1750 data format: '$message'"
      };
    }

    final parts = cleaned.split(":");
    if (parts.length < 2) {
      return {
        "timestamp": DateTime.now().toIso8601String(),
        "error": "Invalid BH1750 data format: '$message'"
      };
    }

    final luxStr = parts[1].trim().replaceAll("lx", "").trim();
    final lux = double.tryParse(luxStr);

    if (lux == null) {
      return {
        "timestamp": DateTime.now().toIso8601String(),
        "error": "Could not parse BH1750 data: '$message'"
      };
    }

    return {
      "timestamp": DateTime.now().toIso8601String(),
      "luminosity": lux,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WebSocket Sensor Client"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ipController,
              decoration: InputDecoration(labelText: "ESP8266 IP Address"),
            ),
            TextField(
              controller: _portController,
              decoration: InputDecoration(labelText: "Port"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _sendRequest("BMP180"),
                  child: Text("BMP180"),
                ),
                ElevatedButton(
                  onPressed: () => _sendRequest("BH1750"),
                  child: Text("BH1750"),
                ),
                ElevatedButton(
                  onPressed: () => _sendRequest("DHT11"),
                  child: Text("DHT11"),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "Sensor Data:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _sensorData,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}







class SensorChartPage extends StatelessWidget {
  // Instead of a single collectionName, we now accept multiple collections
  final List<String> collections;
  final String title;

  SensorChartPage({
    required this.collections,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // Create a list of streams from each collection
    final streams = collections.map((c) => FirebaseFirestore.instance
        .collection(c)
        .orderBy('timestamp', descending: true)
        .snapshots());

    // Combine all collection streams into one stream of List<QuerySnapshot>
    final mergedStream = Rx.combineLatestList<QuerySnapshot>(streams);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: StreamBuilder<List<QuerySnapshot>>(
        stream: mergedStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // Combine all documents from all collections
          final documents = snapshot.data!
              .expand((querySnapshot) => querySnapshot.docs)
              .toList();

          if (documents.isEmpty) {
            return Center(child: Text('No data available.'));
          }

          // Parse data for graph
          final List<FlSpot> temperatureData = [];
          final List<FlSpot> humidityData = [];
          final List<FlSpot> pressureData = [];
          final List<FlSpot> luminosityData = [];

          for (int i = 0; i < documents.length; i++) {
            final data = documents[i].data() as Map<String, dynamic>;
            final timestamp = i.toDouble(); // Use index as x-axis as before
            if (data.containsKey('temperature')) {
              temperatureData.add(FlSpot(
                timestamp,
                (data['temperature'] as num).toDouble(),
              ));
            }
            if (data.containsKey('humidity')) {
              humidityData.add(FlSpot(
                timestamp,
                (data['humidity'] as num).toDouble(),
              ));
            }
            if (data.containsKey('pressure')) {
              pressureData.add(FlSpot(
                timestamp,
                (data['pressure'] as num).toDouble(),
              ));
            }
            if (data.containsKey('luminosity')) {
              luminosityData.add(FlSpot(
                timestamp,
                (data['luminosity'] as num).toDouble(),
              ));
            }
          }

          // Determine Y-axis interval by checking min and max of all data points
          double? minY, maxY;
          void updateMinMax(List<FlSpot> spots) {
            for (final s in spots) {
              if (minY == null || s.y < minY!) minY = s.y;
              if (maxY == null || s.y > maxY!) maxY = s.y;
            }
          }

          updateMinMax(temperatureData);
          updateMinMax(humidityData);
          updateMinMax(pressureData);
          updateMinMax(luminosityData);

          // Default interval if minY or maxY not found (e.g., no data)
          final double yInterval = (minY != null && maxY != null && (maxY! - minY!) > 0)
              ? (maxY! - minY!) / 5
              : 1.0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: LineChart(
                    LineChartData(
                      // Add intervals for Y-axis
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: yInterval,
                            getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(1)),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text("T${value.toInt()}"),
                          ),
                        ),
                      ),
                      lineBarsData: [
                        if (temperatureData.isNotEmpty)
                          LineChartBarData(
                            spots: temperatureData,
                            isCurved: true,
                            barWidth: 2,
                            color: Colors.red,
                            belowBarData: BarAreaData(show: false),
                          ),
                        if (humidityData.isNotEmpty)
                          LineChartBarData(
                            spots: humidityData,
                            isCurved: true,
                            barWidth: 2,
                            color: Colors.blue,
                            belowBarData: BarAreaData(show: false),
                          ),
                        if (pressureData.isNotEmpty)
                          LineChartBarData(
                            spots: pressureData,
                            isCurved: true,
                            barWidth: 2,
                            color: Colors.green,
                            belowBarData: BarAreaData(show: false),
                          ),
                        if (luminosityData.isNotEmpty)
                          LineChartBarData(
                            spots: luminosityData,
                            isCurved: true,
                            barWidth: 2,
                            color: Colors.yellow,
                            belowBarData: BarAreaData(show: false),
                          ),
                      ],
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey),
                      ),
                      gridData: FlGridData(show: true),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipRoundedRadius: 8,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Legend:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 10,
                  children: [
                    LegendItem(color: Colors.red, label: 'Temperature'),
                    LegendItem(color: Colors.blue, label: 'Humidity'),
                    LegendItem(color: Colors.green, label: 'Pressure'),
                    LegendItem(color: Colors.yellow, label: 'Luminosity'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 10,
          color: color,
        ),
        SizedBox(width: 5),
        Text(label),
      ],
    );
  }
}
