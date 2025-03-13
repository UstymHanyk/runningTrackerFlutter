import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Running Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.white),
        ),
      ),
      home: const MyHomePage(title: 'Running Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _distance = 0;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _runs = [];

  void _handleInput() {
    String input = _controller.text.trim();
    if (input.isNotEmpty && _distance > 0) {
      setState(() {
        _runs.add({
          'name': input,
          'distance': _distance,
        });
        _distance = 0;
      });
    }
    _controller.clear();
  }

  void _add100m() {
    setState(() {
      _distance += 0.1;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            const Text('Total Distance Run (in km):'),
            Text(
              '${_distance.toStringAsFixed(2)} km',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "Enter run name",
                  border: OutlineInputBorder(),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _handleInput,
              child: const Text("Save Run"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Runs Completed:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _runs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _runs[index]['name'],
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${_runs[index]['distance'].toStringAsFixed(2)} km',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _runs.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _add100m,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            backgroundColor: Colors.white,
          ),
          child: const Text(
            "Run 100m",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
