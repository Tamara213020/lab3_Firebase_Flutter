import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // За локални нотификации
import 'package:timezone/browser.dart';
import 'package:timezone/browser.dart';
import '../services/api_services.dart';
import '../main.dart'; // За пристап до глобалната листа favoriteJokes
import '../models/joke.dart'; // За Joke моделот
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> jokeTypes = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    fetchJokeTypes();
    initializeNotifications();
    scheduleDailyNotification(); // Планирање на дневна нотификација
  }

  void fetchJokeTypes() async {
    try {
      final types = await ApiService.fetchJokeTypes();
      setState(() {
        jokeTypes = types;
      });
    } catch (e) {
      print("Error fetching joke types: $e");
    }
  }

  bool isFavorite(String jokeType) {
    return favoriteJokes.any((fav) => fav.setup == jokeType);
  }

  void initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void scheduleDailyNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Channel for daily joke notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Daily Joke Reminder',
      'Don\'t forget to check the joke of the day!',
      _nextInstanceOfTime(9), // Планирај нотификација за 9 часот наутро
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Joke Types"),
        actions: [
          IconButton(
            icon: Row(
              children: [
                Icon(Icons.lightbulb),
                SizedBox(width: 8),
                Text("Joke of the Day"),
              ],
            ),
            onPressed: () async {
              final joke = await ApiService.fetchRandomJoke();
              Navigator.pushNamed(context, "/random", arguments: joke);
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
          ),
        ],
      ),
      body: jokeTypes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: jokeTypes.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  "/jokes",
                  arguments: jokeTypes[index],
                );
              },
              child: Card(
                color: Colors.deepPurpleAccent,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        jokeTypes[index],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      IconButton(
                        icon: Icon(
                          isFavorite(jokeTypes[index])
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFavorite(jokeTypes[index])
                              ? Colors.red
                              : Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            if (isFavorite(jokeTypes[index])) {
                              favoriteJokes.removeWhere(
                                      (fav) => fav.setup == jokeTypes[index]);
                            } else {
                              favoriteJokes.add(Joke(
                                setup: jokeTypes[index],
                                punchline: "Sample punchline for ${jokeTypes[index]}", // Placeholder
                              ));
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
