# IoT Heart Rate Monitor - Lab 4

A comprehensive Flutter IoT application with MQTT connectivity, authentication, and ESP8266 integration for real-time heart rate monitoring.

## Features

### 🔐 Authentication System
- **User Registration**: Secure user registration with validation
- **Login/Logout**: Standard login with connectivity checking
- **Auto-login**: Automatic login with stored credentials
- **Secure Storage**: Encrypted storage of user credentials
- **Offline Support**: Limited functionality when offline

### 🌐 Connectivity Monitoring
- **Real-time Connection Status**: Monitor WiFi/Mobile connectivity
- **Connection Alerts**: Visual indicators and warnings
- **Graceful Degradation**: App works offline with stored data

### 📡 MQTT IoT Integration
- **Real-time Data**: Live heart rate monitoring via MQTT
- **Public Broker**: Uses HiveMQ public broker (broker.hivemq.com)
- **Connection Management**: Automatic reconnection and error handling
- **Status Monitoring**: Device connection and health status

### 📱 Heart Rate Dashboard
- **Live Display**: Real-time heart rate with color-coded status
- **Health Indicators**: Visual feedback for heart rate ranges
- **Connection Status**: MQTT and device connectivity indicators
- **Manual Controls**: Connect/disconnect MQTT manually

### 🔧 ESP8266 Simulator
- **Realistic Data**: Simulated heart rate with activity patterns
- **WiFi Connectivity**: Automatic WiFi connection and recovery
- **MQTT Publishing**: Publishes to `esp8266/heartrate` topic
- **Status Updates**: Device status on `esp8266/status` topic

## Project Structure

```
lib/
├── main.dart                     # App entry point with providers
├── models/                       # Data models
├── navigation/                   # App routing
├── screens/
│   ├── login_screen.dart         # Enhanced login with connectivity
│   ├── registration_screen.dart  # User registration
│   ├── main_screen.dart          # Main dashboard with IoT access
│   ├── profile_screen.dart       # User profile management
│   └── heart_rate_dashboard_screen.dart  # IoT heart rate monitor
├── services/
│   ├── auth_provider.dart        # Enhanced authentication
│   ├── connectivity_service.dart # Network monitoring
│   ├── mqtt_service.dart         # MQTT client
│   └── secure_storage_service.dart # Encrypted storage
├── widgets/                      # Reusable UI components
└── theme/                        # App theming

esp8266_heart_rate_monitor.ino    # ESP8266 Arduino code
```

## Setup Instructions

### Flutter App Setup

1. **Clone and Install Dependencies**
   ```bash
   git clone <repository-url>
   cd my_project
   flutter pub get
   ```

2. **Required Dependencies**
   - `mqtt_client: ^10.2.0` - MQTT connectivity
   - `connectivity_plus: ^6.0.5` - Network monitoring
   - `flutter_secure_storage: ^9.2.2` - Secure credential storage
   - `provider: ^6.1.1` - State management

3. **Run the App**
   ```bash
   flutter run
   ```

### ESP8266 Setup

1. **Hardware Requirements**
   - ESP8266 (NodeMCU, Wemos D1 Mini, etc.)
   - USB cable for programming
   - Arduino IDE with ESP8266 board package

2. **Library Dependencies**
   Install these libraries in Arduino IDE:
   - `ESP8266WiFi` (included with ESP8266 core)
   - `PubSubClient` by Nick O'Leary
   - `ArduinoJson` by Benoit Blanchon

3. **Configuration**
   Edit `esp8266_heart_rate_monitor.ino`:
   ```cpp
   const char* ssid = "YOUR_WIFI_SSID";
   const char* password = "YOUR_WIFI_PASSWORD";
   ```

4. **Upload Code**
   - Connect ESP8266 to computer
   - Select correct board and port in Arduino IDE
   - Upload the code
   - Open Serial Monitor (115200 baud) to see status

## Usage Guide

### 1. Authentication Flow

**First Time Setup:**
1. Launch app → Registration screen
2. Create account with email/password
3. Automatic login and credential storage

**Subsequent Launches:**
1. App checks stored credentials
2. Auto-login if available
3. Connectivity check and warnings

**Logout:**
1. Use logout button in main screen menu
2. Confirmation dialog prevents accidental logout
3. Secure credential cleanup

### 2. Heart Rate Monitoring

**Setup:**
1. Configure and run ESP8266 with your WiFi credentials
2. ESP8266 connects to MQTT broker and starts publishing
3. Open Flutter app → Heart Rate Dashboard

**Features:**
- Real-time heart rate display (updates every second)
- Color-coded health indicators:
  - Gray: No data
  - Blue: Low (<60 bpm)
  - Green: Normal (60-100 bpm)
  - Orange: Elevated (100-150 bpm)
  - Red: High (>150 bpm)
- Connection status monitoring
- Manual connect/disconnect controls

### 3. Connectivity Handling

**Online Mode:**
- Full functionality available
- Real-time MQTT data
- Authentication and sync

**Offline Mode:**
- Warning banners displayed
- Stored credentials still work
- Limited functionality with local data

**Connection Recovery:**
- Automatic reconnection when available
- Status updates and notifications
- Graceful degradation and recovery

## Technical Implementation

### MQTT Topics

| Topic | Purpose | Data Format |
|-------|---------|-------------|
| `esp8266/heartrate` | Heart rate data | Integer (e.g., "75") |
| `esp8266/status` | Device status | String (e.g., "online") |

### Heart Rate Simulation

The ESP8266 generates realistic heart rate data:
- **Rest Mode**: 60-90 bpm
- **Active Mode**: 100-160 bpm
- **Transition**: Gradual changes between modes
- **Variation**: ±3 bpm random variation
- **Activity Cycles**: Changes every 30-60 seconds

### Security Features

- **Encrypted Storage**: User credentials encrypted using Flutter Secure Storage
- **Network Validation**: Connection checks before critical operations
- **Input Validation**: Email and password validation
- **Secure MQTT**: Uses standard MQTT over TCP (upgrade to TLS if needed)

## Troubleshooting

### Common Issues

**ESP8266 Not Connecting:**
- Check WiFi credentials in code
- Verify network allows IoT devices
- Check power supply stability
- Monitor Serial output for error messages

**MQTT Connection Failed:**
- Verify internet connectivity
- Check broker.hivemq.com accessibility
- Ensure firewall allows MQTT (port 1883)
- Check ESP8266 Serial output for MQTT status

**Flutter App Issues:**
- Run `flutter pub get` after cloning
- Check device/emulator connectivity
- Verify permissions for network access
- Clear app data if auth issues persist

**No Heart Rate Data:**
- Confirm ESP8266 is publishing (check Serial Monitor)
- Verify MQTT connection in app
- Check topic names match exactly
- Try manual reconnect in app

### Debug Tips

**ESP8266 Debugging:**
```cpp
// Add to setup() for detailed info
printDeviceInfo();
printWiFiStatus();
```

**Flutter Debugging:**
- Enable debug prints in MQTT service
- Check provider states in dev tools
- Monitor network connectivity changes
- Use `flutter logs` for detailed output

## Lab Requirements Checklist

✅ **Authentication Cycle:**
- [x] User registration
- [x] Regular login
- [x] Auto-login with stored session
- [x] Logout with confirmation dialog

✅ **MQTT Integration:**
- [x] Connect to public MQTT broker
- [x] Subscribe to sensor topic
- [x] Display received data
- [x] ESP8266 data simulation

✅ **Connectivity Monitoring:**
- [x] Login connectivity check
- [x] Post-login connection monitoring
- [x] Offline mode with warnings
- [x] Auto-login offline support

✅ **Additional Features:**
- [x] Secure storage implementation
- [x] Enhanced UI with status indicators
- [x] Realistic heart rate simulation
- [x] Connection recovery mechanisms

## Contributing

1. Follow the existing code style and structure
2. Add tests for new features
3. Update documentation for changes
4. Test both online and offline scenarios
5. Verify ESP8266 integration works

## License

This project is for educational purposes as part of IoT Flutter Lab assignments.