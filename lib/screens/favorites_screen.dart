import 'package:flutter/material.dart';
import '../models/joke.dart';
import '../main.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Favorite Jokes")),
      body: favoriteJokes.isEmpty
          ? Center(child: Text("No favorite jokes yet!"))
          : ListView.builder(
        itemCount: favoriteJokes.length,
        itemBuilder: (context, index) {
          final joke = favoriteJokes[index];
          return ListTile(
            leading: Icon(Icons.favorite, color: Colors.red),
            title: Text(joke.setup),
            subtitle: Text(joke.punchline),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                favoriteJokes.removeAt(index);
                Navigator.pushReplacementNamed(context, '/favorites');
              },
            ),
          );
        },
      ),
    );
  }
}
