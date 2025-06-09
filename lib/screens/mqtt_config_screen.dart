import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_project/services/config_service.dart';
import 'package:my_project/theme/app_colors.dart';

class MqttConfigScreen extends StatefulWidget {
  const MqttConfigScreen({super.key});

  @override
  State<MqttConfigScreen> createState() => _MqttConfigScreenState();
}

class _MqttConfigScreenState extends State<MqttConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _portController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentConfig() async {
    try {
      final url = await ConfigService.getBrokerUrl();
      final port = await ConfigService.getBrokerPort();
      
      _urlController.text = url;
      _portController.text = port.toString();
    } catch (e) {
      _showSnackBar('Error loading configuration: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final url = _urlController.text.trim();
      final port = int.parse(_portController.text.trim());
      
      await ConfigService.saveConfiguration(url, port);
      
      _showSnackBar('Configuration saved successfully!');
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate changes were saved
      }
    } catch (e) {
      _showSnackBar('Error saving configuration: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _resetToDefaults() {
    _urlController.text = ConfigService.defaultBrokerUrl;
    _portController.text = ConfigService.defaultBrokerPort.toString();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Broker URL is required';
    }
    
    final url = value.trim();
    if (url.length < 3) {
      return 'Please enter a valid broker URL';
    }
    
    return null;
  }

  String? _validatePort(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Port is required';
    }
    
    final port = int.tryParse(value.trim());
    if (port == null) {
      return 'Please enter a valid port number';
    }
    
    if (port < 1 || port > 65535) {
      return 'Port must be between 1 and 65535';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Configuration'),
        elevation: 0,
        backgroundColor: AppColors.surfacePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      color: AppColors.surfaceSecondary,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Broker Configuration',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Configure your MQTT broker connection settings',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // URL Input
                    TextFormField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        labelText: 'Broker URL',
                        hintText: 'broker.hivemq.com',
                        prefixIcon: const Icon(Icons.link),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceSecondary,
                      ),
                      validator: _validateUrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    
                    // Port Input
                    TextFormField(
                      controller: _portController,
                      decoration: InputDecoration(
                        labelText: 'Port',
                        hintText: '1883',
                        prefixIcon: const Icon(Icons.settings_ethernet),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceSecondary,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(5),
                      ],
                      validator: _validatePort,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 32),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isSaving ? null : _resetToDefaults,
                            icon: const Icon(Icons.restore),
                            label: const Text('Reset to Defaults'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveConfig,
                            icon: _isSaving 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.save),
                            label: Text(_isSaving ? 'Saving...' : 'Save'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 