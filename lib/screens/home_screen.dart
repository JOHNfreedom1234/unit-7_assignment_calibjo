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
              await http.get(Uri.parse('https://narutodb.xyz/api/character'));
          if (response.statusCode == 200) {
            final Map<String, dynamic> jsonData = json.decode(response.body);
            final List<dynamic> charactersJson = jsonData['characters'];
            return charactersJson
                .map((data) => Character.fromJson(data))
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
                    final character = snapshot.data![index];
                    return ExpandedTile(
                      theme: const ExpandedTileThemeData(
                        headerColor: Colors.green,
                        headerPadding: EdgeInsets.all(24.0),
                        headerSplashColor: Colors.red,
                        contentBackgroundColor: Colors.blue,
                        contentPadding: EdgeInsets.all(24.0),
                    ),
                    title: Text(
                      character.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(character.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Unique Traits",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    controller: con,
                  );
                });
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

class Character {
  final String name;
  final String image;
  final List<String> uniqueTraits;

  Character({
    required this.name,
    required this.image,
    required this.uniqueTraits,
  });

 factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name'] ?? "Unknown",
      image: (json['images'] as List<dynamic>).isNotEmpty
          ? json['images'][0] as String
          : "https://via.placeholder.com/150", // Default image if none found
      uniqueTraits: List<String>.from(json['uniqueTraits'] ?? []),
    );
  }
}
