# **IoT Sensor Monitoring System**

A real-time IoT sensor monitoring system built using Arduino (ESP8266), Flutter, Firebase, and WebSocket. This project collects data from BMP180, DHT11, and BH1750 sensors, processes it on the ESP8266, and visualizes it using a Flutter application.

---

## **Features**
- Real-time sensor data monitoring via WebSocket.
- Firebase integration for authentication and data storage.
- Dynamic data visualization with line charts using `fl_chart`.
- Product management functionality with CRUD operations.
- Scalable and modular architecture for adding more sensors or features.

---

## **Project Structure**
- **Arduino Code**: Reads data from sensors and communicates via WebSocket.
- **Flutter Application**: Displays sensor data, graphs, and provides user interaction.
- **Firebase Backend**: Manages user authentication and real-time data storage.

---

## **Setup Instructions**

### **Hardware Requirements**
1. **ESP8266 NodeMCU**
   - Connects to sensors and communicates with the Flutter app via WebSocket.
2. **Sensors**
   - **BMP180** for temperature and pressure.
   - **DHT11** for humidity and temperature.
   - **BH1750** for light intensity.
3. **Breadboard and Jumper Wires**

### **Hardware Setup**
1. Connect the sensors to the ESP8266 using the appropriate pins:
   - **BMP180**: I2C communication (SDA -> GPIO4, SCL -> GPIO5).
   - **BH1750**: I2C communication (SDA -> GPIO4, SCL -> GPIO5).
   - **DHT11**: Data pin -> GPIO14.
2. Power the ESP8266 via USB or an external power supply.

---

### **Software Setup**

#### **Arduino Code**
1. Install [Arduino IDE](https://www.arduino.cc/en/software).
2. Install necessary libraries:
   - `Adafruit_Sensor`
   - `Adafruit_BMP085`
   - `DHT`
   - `BH1750`
   - `WebSocketsServer`
3. Configure `arduino_secrets.h` with your Wi-Fi credentials:
   ```cpp
   const char* ssid = "YOUR_WIFI_SSID";
   const char* pass = "YOUR_WIFI_PASSWORD";

   #### **Flutter Application**
1. **Install Flutter SDK**
   - Follow the instructions to install the [Flutter SDK](https://flutter.dev/docs/get-started/install) for your operating system.

2. **Clone the Project**
   ```bash
   git clone (https://github.com/domnudragota/Simple-IoT-Weather-Station.git)
   cd iot-sensor-monitor

   ---

## **Firebase Setup**

To successfully run the project, Firebase integration must be set up properly. Follow these steps to configure Firebase:

### **1. Create a Firebase Project**
1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Click on **Add Project**.
3. Follow the prompts to create a new Firebase project. Provide a name and select your desired analytics settings.

---

### **2. Configure Firebase for Web**
1. Go to the **Project Settings** (gear icon).
2. Under **Your Apps**, select **Web App** and register the app.
3. Copy the Firebase configuration and replace it in your `main.dart` file:
   ```dart
   const firebaseConfig = FirebaseOptions(
     apiKey: "YOUR_API_KEY",
     authDomain: "YOUR_AUTH_DOMAIN",
     projectId: "YOUR_PROJECT_ID",
     storageBucket: "YOUR_STORAGE_BUCKET",
     messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
     appId: "YOUR_APP_ID",
     measurementId: "YOUR_MEASUREMENT_ID",
   );

