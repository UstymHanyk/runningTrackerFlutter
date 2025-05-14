import 'package:flutter/material.dart';
import 'package:my_project/navigation/app_routes.dart';
import 'package:my_project/navigation/route_generator.dart';

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
        colorScheme: ColorScheme.dark(
          primary: Colors.blueGrey[700]!,
          secondary: Colors.tealAccent[400]!,
          surface: Colors.black,
          error: Colors.redAccent[700]!,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          onError: Colors.white,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontSize: 16.0),
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 14.0),
          headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24.0),
          labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
          titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white38),
          border: const OutlineInputBorder(
             borderRadius: BorderRadius.all(Radius.circular(8.0)),
             borderSide: BorderSide(color: Colors.white54),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white54),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.tealAccent[400]!),
             borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
           errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent[700]!),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent[700]!, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey[700], 
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.tealAccent[400], 
          )
        ),
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20.0, 
              fontWeight: FontWeight.bold, 
              color: Colors.white,
            )
          ),
         cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.grey[900]?.withAlpha((255 * 0.7).round()),
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white70,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.tealAccent[400],
          foregroundColor: Colors.black,      
          elevation: 4.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      initialRoute: AppRoutes.login,
      onGenerateRoute: RouteGenerator.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
