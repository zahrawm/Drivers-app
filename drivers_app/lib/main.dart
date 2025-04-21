import 'package:drivers_app/firebase_options.dart';
import 'package:drivers_app/provider/email_provider.dart';
import 'package:drivers_app/provider/sign_up_provider.dart';
import 'package:drivers_app/screen/register_screen.dart';
import 'package:drivers_app/screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmailProvider()),
        ChangeNotifierProvider(create: (_) => ValidationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,

      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/register': (_) => const RegisterScreen(),
      },
    );
  }
}
