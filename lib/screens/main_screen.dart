import 'package:flutter/material.dart';
import 'package:my_project/navigation/app_routes.dart';
import 'package:my_project/widgets/run_list_item.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double _distance = 0;
  final TextEditingController _runNameController = TextEditingController();
  final List<Map<String, dynamic>> _runs = [];

  void _handleInput() {
    final String runName = _runNameController.text.trim();
    if (_distance > 0) {
      setState(() {
        _runs.insert(0, {
          'name': runName,
          'distance': _distance,
        });
        _distance = 0;
      });
      _runNameController.clear();
      FocusScope.of(context).unfocus();
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Run some distance first!')),
       );
    }
  }

  void _addDistance() {
    setState(() {
      _distance = (_distance * 10 + 1) / 10;
    });
  }

  void _deleteRun(int index) {
     setState(() {
        _runs.removeAt(index);
      });
  }

 @override
  void dispose() {
    _runNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Running Tracker'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 20),
            const Text(
              'CURRENT RUN',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.2),
            ),
            const SizedBox(height: 5),
            Text(
              '${_distance.toStringAsFixed(1)} km',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _runNameController,
              decoration: const InputDecoration(
                labelText: "Enter run name (optional)",
                hintText: 'e.g., Morning Jog'
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _distance > 0 ? _handleInput : null,
              style: ElevatedButton.styleFrom(
                  backgroundColor: _distance > 0 ? Colors.green[700] : Colors.grey[700],
                  foregroundColor: Colors.white,
              ),
              child: const Text("Save Current Run"),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
             const Text(
              "RUN HISTORY",
               textAlign: TextAlign.center,
               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.2),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _runs.isEmpty
              ? const Center(child: Text('No runs saved yet.', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                itemCount: _runs.length,
                itemBuilder: (context, index) {
                  return RunListItem(
                     key: ValueKey(_runs[index]),
                     runData: _runs[index],
                     index: index,
                     onDelete: () => _deleteRun(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
         padding: const EdgeInsets.only(bottom: 16.0),
         child: FloatingActionButton.extended(
          onPressed: _addDistance,
          tooltip: 'Add 0.1 km',
          icon: const Icon(Icons.directions_run),
          label: const Text(
            "Run 0.1km",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
             ), 
      ),
       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
} 