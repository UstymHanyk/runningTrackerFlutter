import 'package:flutter/material.dart';
import 'package:my_project/theme/app_colors.dart';
import 'package:my_project/services/microcontroller_service.dart';
import 'package:my_project/screens/qr_scanner_screen.dart';
import 'package:provider/provider.dart';

class MicrocontrollerScreen extends StatefulWidget {
  const MicrocontrollerScreen({super.key});

  @override
  State<MicrocontrollerScreen> createState() => _MicrocontrollerScreenState();
}

class _MicrocontrollerScreenState extends State<MicrocontrollerScreen> {
  final TextEditingController _serialController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch current device data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MicrocontrollerService>().fetchCurrentSerialNumber();
    });
  }

  @override
  void dispose() {
    _serialController.dispose();
    super.dispose();
  }

  void _showSerialInputDialog() {
    final mcService = context.read<MicrocontrollerService>();
    
    // Pre-fill with current serial number
    _serialController.text = mcService.currentSerialNumber ?? '';

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfacePrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Update Serial Number',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!mcService.hasStoredCredentials) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No credentials stored. Please scan QR code first.',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                'Enter new serial number:',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _serialController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Enter device serial number',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.surfaceSecondary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.accent),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            Consumer<MicrocontrollerService>(
              builder: (context, mcService, child) {
                return ElevatedButton(
                  onPressed: (!mcService.hasStoredCredentials || mcService.isLoading)
                      ? null
                      : () async {
                          final serialNumber = _serialController.text.trim();
                          if (serialNumber.isEmpty) {
                            _showMessage('Error', 'Serial number cannot be empty.', false);
                            return;
                          }

                          final success = await mcService.updateSerialNumber(serialNumber);
                          
                          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                          
                          if (success) {
                            _showMessage('Success!', 'Serial number updated successfully.\nNew serial: $serialNumber', true);
                          } else {
                            _showMessage('Error', mcService.error ?? 'Failed to update serial number', false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.textPrimary,
                  ),
                  child: mcService.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String title, String message, bool isSuccess) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surfacePrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textPrimary,
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Device Configuration',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surfacePrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Consumer<MicrocontrollerService>(
        builder: (context, mcService, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Configuration Status Card
                Card(
                  color: AppColors.surfacePrimary,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              mcService.isConfigured ? Icons.check_circle : Icons.warning,
                              color: mcService.isConfigured ? Colors.green : Colors.orange,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Configuration Status',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildStatusRow(
                          'Credentials',
                          mcService.hasStoredCredentials ? 'Stored' : 'Not configured',
                          mcService.hasStoredCredentials,
                        ),
                        const SizedBox(height: 8),
                        _buildStatusRow(
                          'Username',
                          mcService.storedUsername ?? 'N/A',
                          mcService.storedUsername != null,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Current Serial Number Card
                Card(
                  color: AppColors.surfacePrimary,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Serial Number',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withAlpha((0.2 * 255).round()),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.accent.withAlpha((0.3 * 255).round())),
                          ),
                          child: Text(
                            mcService.currentSerialNumber ?? 'Not fetched',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action Buttons
                ElevatedButton.icon(
                  onPressed: mcService.isLoading
                      ? null
                      : () => mcService.fetchCurrentSerialNumber(),
                  icon: mcService.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(mcService.isLoading ? 'Fetching...' : 'Fetch Device Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QRScannerScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan QR for Credentials'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceSecondary,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                ElevatedButton.icon(
                  onPressed: mcService.hasStoredCredentials
                      ? _showSerialInputDialog
                      : null,
                  icon: const Icon(Icons.edit),
                  label: const Text('Update Serial Number'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mcService.hasStoredCredentials 
                        ? AppColors.surfaceSecondary 
                        : AppColors.surfaceSecondary.withAlpha((0.5 * 255).round()),
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                
                if (mcService.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            mcService.error!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const Spacer(),
                
                // Clear Data Button
                if (mcService.hasStoredCredentials)
                  TextButton.icon(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.surfacePrimary,
                          title: const Text(
                            'Clear All Data',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                          content: const Text(
                            'This will remove all stored credentials and configuration. Are you sure?',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                if (context.mounted) Navigator.pop(context);
                                mcService.clearStoredData();
                                _showMessage('Cleared', 'All data has been cleared.', true);
                              },
                              child: const Text(
                                'Clear',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text(
                      'Clear All Data',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check : Icons.close,
          color: isValid ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
} 