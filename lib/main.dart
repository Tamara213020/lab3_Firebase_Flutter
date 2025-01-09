import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Импорти за екрани
import 'screens/home_screen.dart';
import 'screens/jokes_screen.dart';
import 'screens/random_joke_screen.dart';
import 'screens/favorites_screen.dart';

// Импорт за моделот Joke
import 'models/joke.dart';

// Глобална листа за омилени шеги
List<Joke> favoriteJokes = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Иницијализација на Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joke App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomeScreen(),
        '/jokes': (context) => JokesScreen(
          jokeType: ModalRoute.of(context)!.settings.arguments as String,
        ),
        '/random': (context) => RandomJokeScreen(
          joke: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>,
        ),
        '/favorites': (context) => FavoritesScreen(), // Додаден Favorites екран
      },
    );
  }
}
