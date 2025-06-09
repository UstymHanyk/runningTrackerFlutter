#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>

// WiFi credentials
const char* ssid = "Mi9";  // Replace with your WiFi SSID
const char* password = "823456788";  // Replace with your WiFi password

// MQTT broker settings
const char* mqtt_server = "broker.hivemq.com";
const int mqtt_port = 1883;
const char* client_id = "ESP8266_HeartRateMonitor";

// MQTT topics
const char* heartrate_topic = "esp8266/heartrate";
const char* status_topic = "esp8266/status";

// WiFi and MQTT clients
WiFiClient espClient;
PubSubClient client(espClient);

// Heart rate simulation variables
unsigned long lastHeartRateTime = 0;
const unsigned long heartRateInterval = 1000; // Send every 1 second
int baseHeartRate = 70; // Base heart rate
int currentHeartRate = 70;
bool isConnected = false;

// LED pin for status indication
const int LED_PIN = 2; // Built-in LED on most ESP8266 boards

void setup() {
    Serial.begin(115200);

    // Initialize LED
    pinMode(LED_PIN, OUTPUT);
    digitalWrite(LED_PIN, HIGH); // Turn off LED initially (inverted logic)

    // Initialize random seed
    randomSeed(analogRead(0));

    Serial.println();
    Serial.println("ESP8266 Heart Rate Monitor Starting...");

    // Connect to WiFi
    setup_wifi();

    // Setup MQTT
    client.setServer(mqtt_server, mqtt_port);
    client.setCallback(callback);

    Serial.println("Setup complete!");
}

void setup_wifi() {
    Serial.println();
    Serial.print("Connecting to ");
    Serial.println(ssid);

    WiFi.begin(ssid, password);

    unsigned long startAttemptTime = millis();
    const unsigned long wifiTimeout = 20000; // 20 seconds timeout

    while (WiFi.status() != WL_CONNECTED && millis() - startAttemptTime < wifiTimeout) {
        delay(500);
        Serial.print(".");
        digitalWrite(LED_PIN, !digitalRead(LED_PIN)); // Blink LED
    }

    if (WiFi.status() == WL_CONNECTED) {
        digitalWrite(LED_PIN, HIGH); // Turn off LED
        Serial.println("");
        Serial.println("WiFi connected");
        Serial.print("IP address: ");
        Serial.println(WiFi.localIP());
    } else {
        Serial.println("");
        Serial.println("WiFi connection failed. Will retry in loop().");
        digitalWrite(LED_PIN, HIGH); // Keep LED off
    }
}


void callback(char* topic, byte* payload, unsigned int length) {
    Serial.print("Message arrived [");
    Serial.print(topic);
    Serial.print("] ");

    String message = "";
    for (int i = 0; i < length; i++) {
        message += (char)payload[i];
    }
    Serial.println(message);

    // Handle incoming messages if needed
    // For example, you could receive commands to change simulation parameters
}

void reconnect() {
    // Loop until we're reconnected
    while (!client.connected()) {
        Serial.print("Attempting MQTT connection...");

        // Attempt to connect
        if (client.connect(client_id)) {
            Serial.println("connected");
            isConnected = true;
            digitalWrite(LED_PIN, LOW); // Turn on LED when MQTT connected

            // Send initial status
            client.publish(status_topic, "connected");

            // Subscribe to topics if needed
            // client.subscribe("esp8266/commands");

        } else {
            Serial.print("failed, rc=");
            Serial.print(client.state());
            Serial.println(" try again in 5 seconds");
            isConnected = false;
            digitalWrite(LED_PIN, HIGH); // Turn off LED when disconnected

            // Wait 5 seconds before retrying
            delay(5000);
        }
    }
}

int generateRealisticHeartRate() {
    // Generate a realistic heart rate with some variation
    // Simulate different activity levels and natural variation

    static unsigned long lastActivityChange = 0;
    static int targetHeartRate = 70;
    static bool isActive = false;

    unsigned long currentTime = millis();

    // Change activity level every 30-60 seconds
    if (currentTime - lastActivityChange > random(30000, 60000)) {
        lastActivityChange = currentTime;
        isActive = !isActive;

        if (isActive) {
            // Simulate exercise: 100-160 bpm
            targetHeartRate = random(100, 161);
            Serial.println("Simulating active state");
        } else {
            // Simulate rest: 60-90 bpm
            targetHeartRate = random(60, 91);
            Serial.println("Simulating rest state");
        }
    }

    // Gradually move current heart rate towards target
    if (currentHeartRate < targetHeartRate) {
        currentHeartRate += random(1, 4);
        if (currentHeartRate > targetHeartRate) {
            currentHeartRate = targetHeartRate;
        }
    } else if (currentHeartRate > targetHeartRate) {
        currentHeartRate -= random(1, 4);
        if (currentHeartRate < targetHeartRate) {
            currentHeartRate = targetHeartRate;
        }
    }

    // Add small random variation (+/- 3 bpm)
    int variation = random(-3, 4);
    int finalHeartRate = currentHeartRate + variation;

    // Ensure reasonable bounds
    if (finalHeartRate < 45) finalHeartRate = 45;
    if (finalHeartRate > 200) finalHeartRate = 200;

    return finalHeartRate;
}

void publishHeartRate() {
    if (client.connected()) {
        int heartRate = generateRealisticHeartRate();

        // Create JSON payload
        StaticJsonDocument<100> doc;
        doc["heartRate"] = heartRate;
        doc["timestamp"] = millis();
        doc["deviceId"] = "ESP8266_001";

        String jsonString;
        serializeJson(doc, jsonString);

        // Publish heart rate as simple number (for compatibility)
        String heartRateStr = String(heartRate);
        client.publish(heartrate_topic, heartRateStr.c_str());

        // Also publish detailed JSON to a different topic if needed
        // client.publish("esp8266/heartrate/detailed", jsonString.c_str());

        Serial.print("Published heart rate: ");
        Serial.print(heartRate);
        Serial.println(" bpm");

        // Blink LED on data transmission
        digitalWrite(LED_PIN, HIGH);
        delay(50);
        digitalWrite(LED_PIN, LOW);
    }
}

void publishStatus() {
    if (client.connected()) {
        StaticJsonDocument<200> statusDoc;
        statusDoc["status"] = "online";
        statusDoc["uptime"] = millis();
        statusDoc["freeHeap"] = ESP.getFreeHeap();
        statusDoc["rssi"] = WiFi.RSSI();
        statusDoc["ipAddress"] = WiFi.localIP().toString();

        String statusString;
        serializeJson(statusDoc, statusString);

        client.publish(status_topic, "online");
        // client.publish("esp8266/status/detailed", statusString.c_str());

        Serial.println("Status published");
    }
}

void loop() {
    static unsigned long lastWifiAttempt = 0;
    unsigned long currentTime = millis();

    if (WiFi.status() != WL_CONNECTED && currentTime - lastWifiAttempt > 10000) {
        Serial.println("WiFi disconnected, reconnecting...");
        lastWifiAttempt = currentTime;
        setup_wifi();
    }

    if (WiFi.status() == WL_CONNECTED) {
        if (!client.connected()) {
            reconnect();
        }
        client.loop();

        if (currentTime - lastHeartRateTime >= heartRateInterval) {
            lastHeartRateTime = currentTime;
            publishHeartRate();
        }

        static unsigned long lastStatusTime = 0;
        if (currentTime - lastStatusTime >= 30000) {
            lastStatusTime = currentTime;
            publishStatus();
        }
    }

    delay(10); // Avoid watchdog reset
}


// Function to handle deep sleep mode (optional, for battery saving)
void enterDeepSleep(unsigned int sleepTimeSeconds) {
    Serial.println("Entering deep sleep mode...");
    client.publish(status_topic, "sleeping");
    delay(100); // Give time for message to be sent

    ESP.deepSleep(sleepTimeSeconds * 1000000); // microseconds
}

// Additional utility functions

void debugPrintWiFiStatus() {
    Serial.print("WiFi Status: ");
    switch(WiFi.status()) {
        case WL_CONNECTED:
            Serial.println("Connected");
            break;
        case WL_NO_SHIELD:
            Serial.println("No WiFi shield");
            break;
        case WL_IDLE_STATUS:
            Serial.println("Idle");
            break;
        case WL_NO_SSID_AVAIL:
            Serial.println("No SSID available");
            break;
        case WL_SCAN_COMPLETED:
            Serial.println("Scan completed");
            break;
        case WL_CONNECT_FAILED:
            Serial.println("Connection failed");
            break;
        case WL_CONNECTION_LOST:
            Serial.println("Connection lost");
            break;
        case WL_DISCONNECTED:
            Serial.println("Disconnected");
            break;
        default:
            Serial.println("Unknown");
            break;
    }
}

void debugPrintDeviceInfo() {
    Serial.println("=== ESP8266 Heart Rate Monitor Info ===");
    Serial.print("Chip ID: ");
    Serial.println(ESP.getChipId());
    Serial.print("Flash Chip ID: ");
    Serial.println(ESP.getFlashChipId());
    Serial.print("Flash Size: ");
    Serial.println(ESP.getFlashChipSize());
    Serial.print("Free Heap: ");
    Serial.println(ESP.getFreeHeap());
    Serial.println("======================================");
}