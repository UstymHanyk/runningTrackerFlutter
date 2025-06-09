import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/theme/app_colors.dart';
import 'package:my_project/cubits/microcontroller_cubit.dart';
import 'package:my_project/widgets/microcontroller/configuration_status_card.dart';
import 'package:my_project/widgets/microcontroller/serial_number_card.dart';
import 'package:my_project/widgets/microcontroller/error_card.dart';
import 'package:my_project/widgets/microcontroller/screen_widgets.dart';

class MicrocontrollerScreen extends StatelessWidget {
  const MicrocontrollerScreen({super.key});

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
      body: BlocConsumer<MicrocontrollerCubit, MicrocontrollerState>(
        listener: (context, state) {
          if (state is MicrocontrollerInitial) {
            _initializeWithDelay(context);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildContent(context, state),
          );
        },
      ),
    );
  }

  void _initializeWithDelay(BuildContext context) {
    final cubit = context.read<MicrocontrollerCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (cubit.state is MicrocontrollerInitial) {
        cubit.initialize();
      }
    });
  }

  Widget _buildContent(BuildContext context, MicrocontrollerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state is MicrocontrollerLoaded) ...[
          _buildLoadedContent(context, state),
        ] else if (state is MicrocontrollerLoading || 
                   state is MicrocontrollerInitial) ...[
          MicrocontrollerScreenWidgets.buildLoadingState(),
        ] else if (state is MicrocontrollerError) ...[
          _buildErrorContent(context, state),
        ] else ...[
          MicrocontrollerScreenWidgets.buildUnknownState(
            context, 
            state.runtimeType.toString(),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadedContent(
    BuildContext context, 
    MicrocontrollerLoaded state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConfigurationStatusCard(
          isConfigured: state.isConfigured,
          hasStoredCredentials: state.hasStoredCredentials,
          storedUsername: state.storedUsername,
        ),
        const SizedBox(height: 16),
        SerialNumberCard(currentSerialNumber: state.currentSerialNumber),
        const SizedBox(height: 24),
        MicrocontrollerScreenWidgets.buildActionButtons(context, state),
        const Spacer(),
        if (state.hasStoredCredentials) 
          MicrocontrollerScreenWidgets.buildClearDataButton(context),
      ],
    );
  }

  Widget _buildErrorContent(
    BuildContext context, 
    MicrocontrollerError state,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ErrorCard(error: state.message),
        const SizedBox(height: 16),
        MicrocontrollerScreenWidgets.buildRetryButton(context),
      ],
    );
  }
} 