import 'package:finance_tracker/Pages/HomePage.dart';
import 'package:finance_tracker/Pages/auth.dart';
import 'package:finance_tracker/SplashScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Replace with your Firebase configuration
  );
  runApp(MyApp());
}



// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return SplashScreen();
//           }
//           if (snapshot.hasData) {
//             // User is logged in, show the homepage
//             return Homepage();
//           }
//           // User is not logged in, show the auth screen
//           return const AuthScreen();
//         },
//       ),
//     );
//   }
// }


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        // builder: (context, snapshot) {
        //   if (snapshot.connectionState == ConnectionState.waiting) {
        //     return const Center(child: CircularProgressIndicator());
        //   }
        //   if (snapshot.hasData) {
        //     // User is logged in, show the homepage
        //     return Homepage();
        //   }
        //   // User is not logged in, show the auth screen
        //   return const AuthScreen();
        // },
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            // User is logged in, show the homepage
            return Homepage();
          }
          // User is not logged in, show the auth screen
          return const AuthScreen();
        },

      ),
    );
  }
}
