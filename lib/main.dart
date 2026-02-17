import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// FIXED: We only import Splash Screen here. Home Page is not needed in main.dart anymore.
import 'Presentation/Screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  print("DEBUG: APP STARTING WITH SPLASH SCREEN"); // <--- Add this line
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Chef',
      themeMode: ThemeMode.system,
      // The app starts here
      home: const SplashScreen(),
    );
  }
}
