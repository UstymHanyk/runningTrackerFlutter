import 'package:flutter/material.dart';
import 'package:my_project/theme/app_colors.dart';

class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((0.5 * 255).round()),
      ),
      child: Center(
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.accent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: _CornerIndicator(
                  topBorder: true,
                  leftBorder: true,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: _CornerIndicator(
                  topBorder: true,
                  rightBorder: true,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: _CornerIndicator(
                  bottomBorder: true,
                  leftBorder: true,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: _CornerIndicator(
                  bottomBorder: true,
                  rightBorder: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScannerInstructions extends StatelessWidget {
  const ScannerInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfacePrimary.withAlpha((0.9 * 255).round()),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.qr_code_scanner,
              color: AppColors.accent,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'Position QR code within the frame',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'The QR code should contain device credentials',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProcessingIndicator extends StatelessWidget {
  const ProcessingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha((0.7 * 255).round()),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfacePrimary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
              SizedBox(height: 16),
              Text(
                'Processing QR Code...',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CornerIndicator extends StatelessWidget {
  final bool topBorder;
  final bool bottomBorder;
  final bool leftBorder;
  final bool rightBorder;

  const _CornerIndicator({
    this.topBorder = false,
    this.bottomBorder = false,
    this.leftBorder = false,
    this.rightBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border(
          top: topBorder ? const BorderSide(color: AppColors.accent, width: 4) : BorderSide.none,
          bottom: bottomBorder ? const BorderSide(color: AppColors.accent, width: 4) : BorderSide.none,
          left: leftBorder ? const BorderSide(color: AppColors.accent, width: 4) : BorderSide.none,
          right: rightBorder ? const BorderSide(color: AppColors.accent, width: 4) : BorderSide.none,
        ),
      ),
    );
  }
} 