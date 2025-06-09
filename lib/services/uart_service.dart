import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:usb_serial/usb_serial.dart';

class UartService {
  UsbPort? _port;
  
  // Connection status
  bool get isConnected => _port != null;
  
  /// Connect to the first available USB device
  Future<bool> connect() async {
    try {
      final List<UsbDevice> devices = await UsbSerial.listDevices();
      
      if (devices.isEmpty) {
        debugPrint('UART: No USB devices found');
        return false;
      }

      // Try to connect to the first available device
      final targetDevice = devices.first;
      debugPrint('UART: Attempting to connect to device: ${targetDevice.productName}');
      
      _port = await targetDevice.create();
      if (_port == null) {
        debugPrint('UART: Failed to create port');
        return false;
      }

      final openResult = await _port!.open();
      if (!openResult) {
        debugPrint('UART: Failed to open port');
        _port = null;
        return false;
      }

      // Configure port parameters to match ESP8266 settings
      await _port!.setDTR(true);
      await _port!.setRTS(true);
      await _port!.setPortParameters(
        9600, // Baud rate matching ESP8266
        UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1,
        UsbPort.PARITY_NONE,
      );

      debugPrint('UART: Successfully connected');
      return true;
    } catch (e) {
      debugPrint('UART: Connection error: $e');
      _port = null;
      return false;
    }
  }

  /// Send JSON data to the ESP8266
  Future<void> sendJson(Map<String, dynamic> data) async {
    if (_port == null) {
      debugPrint('UART: Port not connected, cannot send data');
      return;
    }

    try {
      final jsonData = jsonEncode(data);
      final message = utf8.encode('$jsonData\n');
      
      debugPrint('UART: Sending JSON: $jsonData');
      await _port!.write(Uint8List.fromList(message));
    } catch (e) {
      debugPrint('UART: Error sending data: $e');
    }
  }

  /// Read response from ESP8266 with timeout
  Future<String?> readResponse({Duration timeout = const Duration(seconds: 5)}) async {
    if (_port == null) {
      debugPrint('UART: Port not connected, cannot read data');
      return null;
    }

    try {
      final buffer = StringBuffer();
      
      await for (final data in _port!.inputStream!.timeout(timeout)) {
        final decodedData = utf8.decode(data);
        buffer.write(decodedData);
        
        // Check if we received a complete JSON response (ends with newline)
        if (buffer.toString().contains('\n')) {
          break;
        }
      }

      final response = buffer.toString().trim();
      debugPrint('UART: Received response: $response');
      return response.isNotEmpty ? response : null;
    } catch (e) {
      debugPrint('UART: Error reading response: $e');
      return null;
    }
  }

  /// Disconnect from the device
  void disconnect() {
    if (_port != null) {
      try {
        _port!.close();
        debugPrint('UART: Disconnected');
      } catch (e) {
        debugPrint('UART: Error during disconnect: $e');
      } finally {
        _port = null;
      }
    }
  }

  /// Test credentials without updating serial number
  Future<Map<String, dynamic>> testCredentials(String username, String password) async {
    try {
      final connected = await connect();
      if (!connected) {
        return {
          'success': false,
          'message': 'Failed to connect to device'
        };
      }

      await sendJson({
        'username': username,
        'password': password,
      });

      final response = await readResponse();
      disconnect();

      if (response != null) {
        try {
          final jsonResponse = jsonDecode(response) as Map<String, dynamic>;
          final status = jsonResponse['status'];
          final message = jsonResponse['message'] ?? 'No message';
          
          return {
            'success': status == 'OK',
            'message': message,
            'raw_response': response
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Invalid response format: $response'
          };
        }
      } else {
        return {
          'success': false,
          'message': 'No response from device'
        };
      }
    } catch (e) {
      disconnect();
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  /// Update serial number with credentials
  Future<Map<String, dynamic>> updateSerialNumber(
    String username, 
    String password, 
    String serialNumber
  ) async {
    try {
      final connected = await connect();
      if (!connected) {
        return {
          'success': false,
          'message': 'Failed to connect to device'
        };
      }

      await sendJson({
        'username': username,
        'password': password,
        'serial_number': serialNumber,
      });

      final response = await readResponse();
      disconnect();

      if (response != null) {
        try {
          final jsonResponse = jsonDecode(response) as Map<String, dynamic>;
          final status = jsonResponse['status'];
          final message = jsonResponse['message'] ?? 'No message';
          
          return {
            'success': status == 'OK',
            'message': message,
            'raw_response': response
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Invalid response format: $response'
          };
        }
      } else {
        return {
          'success': false,
          'message': 'No response from device'
        };
      }
    } catch (e) {
      disconnect();
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }

  /// Read current serial number from device
  Future<Map<String, dynamic>> readSerialNumber() async {
    try {
      final connected = await connect();
      if (!connected) {
        return {
          'success': false,
          'message': 'Failed to connect to device'
        };
      }

      await sendJson({'action': 'read_serial'});

      final response = await readResponse();
      disconnect();

      if (response != null) {
        try {
          final jsonResponse = jsonDecode(response) as Map<String, dynamic>;
          final status = jsonResponse['status'];
          final message = jsonResponse['message'] ?? 'No message';
          
          return {
            'success': status == 'OK',
            'serial_number': message,
            'message': message,
            'raw_response': response
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Invalid response format: $response'
          };
        }
      } else {
        return {
          'success': false,
          'message': 'No response from device'
        };
      }
    } catch (e) {
      disconnect();
      return {
        'success': false,
        'message': 'Connection error: $e'
      };
    }
  }
} 