#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BMP085_U.h>
#include <BH1750.h>
#include <DHT.h>
#include <DHT_U.h>
#include <ESP8266WiFi.h>
#include <WebSocketsServer.h>
#include "arduino_secrets.h" // Include the header for WiFi credentials

// BMP180
Adafruit_BMP085_Unified bmp = Adafruit_BMP085_Unified(10085);

// BH1750
BH1750 lightMeter;

// DHT11
#define DHTPIN 14  // Pinul GPIO al plăcii conectat la DATA (OUT) al senzorului
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

// I2C Pins
#define SDA_PIN 4  // SDA conectat la GPIO4 (D2)
#define SCL_PIN 5  // SCL conectat la GPIO5 (D1)

// WiFi and WebSocket Configuration
WebSocketsServer webSocket(81); // WebSocket server on port 81

void connectToWiFi() {
  Serial.print("Attempting to connect to WiFi: ");
  Serial.println(ssid);
  WiFi.begin(ssid, pass);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(1000);
  }
  Serial.println("\nConnected to WiFi!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
}

void handleWebSocketMessage(uint8_t num, uint8_t *payload, size_t length) {
  String request = "";
  for (size_t i = 0; i < length; i++) {
    request += (char)payload[i];
  }
  request.trim();

  Serial.print("Received WebSocket request: ");
  Serial.println(request);

  String response;

  if (request == "BMP180") {
    sensors_event_t bmpEvent;
    bmp.getEvent(&bmpEvent);
    if (bmpEvent.pressure) {
      float temperature;
      bmp.getTemperature(&temperature);
      response += "BMP180 Temperature: ";
      response += String(temperature);
      response += " \u00B0C\n";

      response += "BMP180 Pressure: ";
      response += String(bmpEvent.pressure);
      response += " hPa\n";
    }
  } else if (request == "BH1750") {
    float lux = lightMeter.readLightLevel();
    response += "BH1750 Luminosity: ";
    response += String(lux);
    response += " lx\n";
  } else if (request == "DHT11") {
    float humidity = dht.readHumidity();
    float temperature = dht.readTemperature();

    if (isnan(humidity) || isnan(temperature)) {
      response += "Failed to read from DHT11 sensor!\n";
    } else {
      response += "DHT11 Humidity: ";
      response += String(humidity);
      response += " %\n";

      response += "DHT11 Temperature: ";
      response += String(temperature);
      response += " \u00B0C\n";
    }
  } else {
    response += "Invalid request. Use BMP180, BH1750, or DHT11.\n";
  }

  webSocket.sendTXT(num, response);
}

void webSocketEvent(uint8_t num, WStype_t type, uint8_t *payload, size_t length) {
  switch (type) {
    case WStype_DISCONNECTED:
      Serial.printf("[%u] Disconnected!\n", num);
      break;
    case WStype_CONNECTED:
      {
        IPAddress ip = webSocket.remoteIP(num);
        Serial.printf("[%u] Connection from ", num);
        Serial.println(ip.toString());
      }
      break;
    case WStype_TEXT:
      handleWebSocketMessage(num, payload, length);
      break;
  }
}

void setup() {
  Serial.begin(115200);
  Serial.println("Initializing sensors and WiFi...");

  // Initialize I2C
  Wire.begin(SDA_PIN, SCL_PIN);

  // Initialize BMP180
  if (!bmp.begin()) {
    Serial.println("BMP180 not detected. Check connections!");
    while (1);
  }
  Serial.println("BMP180 initialized successfully.");

  // Initialize BH1750
  if (!lightMeter.begin(BH1750::CONTINUOUS_HIGH_RES_MODE, 0x23)) {
    Serial.println("BH1750 not detected at 0x23. Trying 0x5C...");
    if (!lightMeter.begin(BH1750::CONTINUOUS_HIGH_RES_MODE, 0x5C)) {
      Serial.println("BH1750 not detected at 0x5C!");
      while (1);
    }
  }
  Serial.println("BH1750 initialized successfully.");

  // Initialize DHT11
  dht.begin();
  Serial.println("DHT11 initialized successfully.");

  // Connect to WiFi
  connectToWiFi();

  // Start WebSocket server
  webSocket.begin();
  webSocket.onEvent(webSocketEvent);
  Serial.println("WebSocket server started on port 81");
}

void loop() {
  webSocket.loop();
}
