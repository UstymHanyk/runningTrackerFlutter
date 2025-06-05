# Flutter Heart Rate Monitor

A modern Flutter application for real-time heart rate monitoring using IoT devices (ESP8266) with MQTT communication.

## 🏥 Features

- **Real-time Heart Rate Monitoring** via MQTT protocol
- **ESP8266 Device Configuration** through QR codes and UART communication
- **Run Tracking** with distance and heart rate data collection
- **User Authentication** with secure credential storage
- **Profile Management** for personalized experience
- **Cross-platform Support** (iOS, Android, Windows, macOS, Linux)
- **Modern UI** with dark theme and responsive design

## 🏗️ Architecture

This project demonstrates modern Flutter development with:

- **State Management**: Cubit (BLoC) pattern for UI state management
- **Clean Architecture**: Separation of concerns with layers
- **Component-Based Design**: Reusable UI components
- **Dependency Injection**: Provider pattern for services
- **Secure Storage**: Encrypted credential storage

### Architecture Layers

```
┌─────────────────┐
│   Presentation  │  Screens & Widgets (StatelessWidget + Cubit)
├─────────────────┤
│   Business      │  Cubits & Services (Business Logic)
├─────────────────┤
│   Data          │  Repositories & Models (Data Access)
└─────────────────┘
```

## 🔄 StatefulWidget → StatelessWidget Conversion

This project successfully converted from StatefulWidget to StatelessWidget using Cubit pattern:

### Conversion Results
| Screen | Before | After | Reduction |
|--------|--------|-------|-----------|
| MicrocontrollerScreen | 493 lines | 132 lines | 73% |
| QRScannerScreen | 483 lines | 114 lines | 76% |
| MainScreen | 351 lines | 95 lines | 73% |
| HeartRateDashboardScreen | 264 lines | 158 lines | 40% |
| LoginScreen | 248 lines | 107 lines | 57% |
| ProfileScreen | 238 lines | 101 lines | 58% |
| RegistrationScreen | 183 lines | 57 lines | 69% |

**Total Reduction**: 2,260 → 764 lines (66% reduction)

### Benefits Achieved
- ✅ **Improved Performance** - Targeted rebuilds with BlocBuilder
- ✅ **Better Testability** - Separated business logic in Cubits
- ✅ **Enhanced Maintainability** - Single responsibility components
- ✅ **Code Reusability** - 30+ reusable components created

## 🚀 Getting Started

### Prerequisites
- Flutter 3.x or higher
- Dart 3.x or higher
- For hardware integration: ESP8266 development board
- MQTT broker access

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd flutter-heart-rate-monitor
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Hardware Setup (Optional)
For full IoT functionality, you'll need:
- ESP8266 development board (NodeMCU, Wemos D1, etc.)
- Heart rate sensor (MAX30102 or similar)
- MQTT broker (HiveMQ, Mosquitto, etc.)

## 📱 Screens Overview

### 1. Authentication
- **Login Screen**: User authentication with email/password
- **Registration Screen**: New user account creation
- **Profile Screen**: User profile management

### 2. Heart Rate Monitoring
- **Dashboard Screen**: Real-time heart rate display and device status
- **Main Screen**: Run tracking with distance input and heart rate data

### 3. Device Configuration
- **Microcontroller Screen**: ESP8266 device configuration
- **QR Scanner Screen**: QR code scanning for device credentials

## 🎨 UI Components

The app uses a component-based architecture with reusable widgets:

### Form Components
- `LoginForm` - User authentication form
- `RegistrationForm` - User registration form
- `EditProfileForm` - Profile editing form
- `RunInputSection` - Distance input for runs

### Display Components
- `ConfigurationStatusCard` - Device configuration status
- `HeartRateDisplayCard` - Real-time heart rate display
- `ConnectivityStatusBanner` - Network connectivity indicator
- `RunListItem` - Run history display

### Dialog Components
- `AppDialogs` - Success, error, and confirmation dialogs
- `SerialConfigDialog` - Device serial number configuration
- `LogoutDialog` - Logout confirmation

## 🔧 State Management

### Cubit Pattern Implementation

Each screen has its corresponding Cubit for state management:

```dart
// Example: AuthCubit
class AuthCubit extends Cubit<AuthState> {
  final AuthProviderInterface _authProvider;
  
  AuthCubit(this._authProvider) : super(AuthInitial());
  
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final success = await _authProvider.login(email, password);
      emit(success ? AuthSuccess() : AuthError('Invalid credentials'));
    } catch (e) {
      emit(AuthError('Login failed: $e'));
    }
  }
}
```

### State Management Flow
1. **User Action** → Triggers Cubit method
2. **Cubit** → Calls service layer
3. **Service** → Accesses repository/data layer
4. **State Change** → UI rebuilds with new state

## 🛡️ Security Features

- **Secure Storage**: Encrypted credential storage using `flutter_secure_storage`
- **Authentication Flow**: Proper login/logout with session management
- **Data Validation**: Input validation and sanitization
- **Error Handling**: Secure error messages without sensitive data exposure

## 🌐 IoT Integration

### MQTT Communication
- Real-time heart rate data streaming
- Device status monitoring
- Connection management with auto-reconnect

### ESP8266 Configuration
- QR code scanning for device credentials
- UART communication for device setup
- Serial number configuration

## 📊 Performance Optimizations

### Before Optimization
- Large StatefulWidgets with mixed concerns
- Full screen rebuilds on state changes
- Tightly coupled business logic and UI

### After Optimization
- Small, focused StatelessWidgets
- Targeted rebuilds with BlocBuilder
- Separated business logic in Cubits
- Component-based architecture

## 🧪 Testing Strategy

### Unit Tests
```bash
flutter test test/cubits/
```

### Widget Tests
```bash
flutter test test/widgets/
```

### Integration Tests
```bash
flutter test integration_test/
```

## 📚 Dependencies

### Core Dependencies
- `flutter_bloc` - State management
- `provider` - Dependency injection
- `equatable` - Value equality
- `flutter_secure_storage` - Secure data storage

### IoT Dependencies
- `mqtt_client` - MQTT communication
- `libserialport` - UART communication
- `qr_code_scanner` - QR code scanning

### UI Dependencies
- `connectivity_plus` - Network connectivity
- Material Design components

## 🔄 Development Workflow

### Project Structure
```
lib/
├── cubits/              # State management
├── models/              # Data models
├── navigation/          # Route management
├── repositories/        # Data access layer
├── screens/             # Main app screens
├── services/            # Business logic services
├── theme/               # UI theming
└── widgets/             # Reusable UI components
```

### Code Style
- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Add documentation for complex logic
- Maintain consistent file organization

## 🐛 Known Issues

Current areas for improvement:
- Replace `print()` statements with proper logging (22 instances)
- Add comprehensive unit tests
- Implement proper error handling patterns
- Create configuration constants file

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow the existing architecture patterns
- Write tests for new features
- Update documentation as needed
- Ensure all builds pass before submitting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

For questions or support:
- Create an issue in the GitHub repository
- Check the documentation in the `/docs` folder
- Review the code examples in `/examples`

## 🎯 Future Roadmap

- [ ] **Data Analytics** - Heart rate trends and insights
- [ ] **Cloud Sync** - Multi-device data synchronization
- [ ] **Wearable Integration** - Apple Watch/WearOS support
- [ ] **Social Features** - Share achievements and compete
- [ ] **Offline Mode** - Local data storage and sync
- [ ] **Push Notifications** - Alerts and reminders

---

**Built with ❤️ using Flutter**