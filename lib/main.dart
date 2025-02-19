import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:myapp/Screens/demo_ai_screen.dart' show DemoAIScreen;

import 'Screens/signup_screen.dart';

const apiKey = '...';

void main() {
   Gemini.init(apiKey: apiKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
    // Primary color (Deep Sea Blue or Forest Green)
    primaryColor: const Color(0xFF191970), // Deep Sea Blue
    // primaryColor: const Color(0xFF228B22), // Forest Green (alternative)

    // Secondary color (Sage Green or Light Blue)
    secondaryHeaderColor: const Color(0xFF9ACD32), // Sage Green
    // secondaryHeaderColor: const Color(0xFFADD8E6), // Light Blue (alternative)

    // Accent color (Gold or Copper)
    colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: const Color(0xFFFFD700), // Gold
        // secondary: const Color(0xFFB87333), // Copper (alternative)
    ),
    
    // Background colors
    scaffoldBackgroundColor: const Color(0xFFF8F8FF), // Off-White
    canvasColor: const Color(0xFFD3D3D3), // Light Gray

    // Text theme
    textTheme: const TextTheme(
      // Default text style
      bodyMedium: TextStyle(
        color: Color(0xFF333333), // Dark Gray
      ),
      // Titles
      headlineLarge: TextStyle(
        color: Color(0xFF333333), // Dark Gray
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Color(0xFF333333), // Dark Gray
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: Color(0xFF333333), // Dark Gray
        fontWeight: FontWeight.bold,
      ),
    ),

    // App bar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF191970), // Deep Sea Blue
      foregroundColor: Colors.white, // White text
    ),

    // Button theme
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF191970),// Deep Sea Blue
      textTheme: ButtonTextTheme.primary, // White text on buttons
    ),

    //Floating action button Theme
     floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF191970), // Deep Sea Blue
    ),

    //input decoration theme
    inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF333333)), // Dark Gray border
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF191970)), // Deep Sea Blue focused
      ),
    ),
    // Other customizations...
  ),
      home: const DemoAIScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
