import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit 7 - API Calls"),
      ),
      body: FutureBuilder(
        // setup the URL for your API here
        future: () async {
          final response =
              await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?f=a'));
          if (response.statusCode == 200) {
            final Map<String, dynamic> jsonData = json.decode(response.body);
            final List<dynamic> mealsJson = jsonData['meals'];
            return mealsJson
                .map((data) => Meal.fromJson(data))
                .toList();
          } else {
            throw Exception('Failed to load data');
          }
        }(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ExpandedTileList.builder(
                  itemCount: snapshot.data!.length,
                  maxOpened: 10,
                  itemBuilder: (context, index, con) {
                    final meal = snapshot.data![index];
                    return ExpandedTile(
                      theme: const ExpandedTileThemeData(
                        headerColor: Colors.green,
                        headerPadding: EdgeInsets.all(24.0),
                        headerSplashColor: Colors.red,
                        contentBackgroundColor: Colors.blue,
                        contentPadding: EdgeInsets.all(24.0),
                    ),
                    title: Text(
                      meal.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          meal.image,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tags: ${meal.tags}",
                          style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    controller: con,
                  );
                },
                );
          } else {
            return const Center(
              child: Text("Error"),
            );
          }
        },
      ),
    );
  }
}

class Meal {
  final String name;
  final String image;
  final List<String> tags;

  Meal({
    required this.name,
    required this.image,
    required this.tags,
  });

   factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['strMeal'],
      image: json['strMealThumb'],
      tags: json['strTags'] != null
          ? json['strTags'].split(',') // Split the string into a list
          : [], // If null, return an empty list
    );
  }
}
