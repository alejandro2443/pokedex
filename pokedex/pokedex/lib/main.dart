import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const PokedexApp());
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home: const PokemonListScreen(),
    );
  }
}

class Pokemon {
  final String name;
  final String imageUrl;
  final int id;

  Pokemon({
    required this.name,
    required this.imageUrl,
    required this.id,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    int id = int.parse(json['url'].split('/')[6]);
    return Pokemon(
      name: json['name'],
      imageUrl:
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
      id: id,
    );
  }
}

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  List<Pokemon> pokemonList = [];
  List<Pokemon> filteredList = [];
  bool isLoading = true;
  String nextUrl = 'https://pokeapi.co/api/v2/pokemon?limit=50';
  TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchPokemon();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        fetchPokemon();
      }
    });
  }

  Future<void> fetchPokemon() async {
    if (nextUrl.isEmpty) return; // Asegúrate de que nextUrl no sea null

    try {
      final response = await http.get(Uri.parse(nextUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Pokemon> tempList = (data['results'] as List)
            .map((json) => Pokemon.fromJson(json))
            .toList();

        setState(() {
          pokemonList.addAll(tempList);
          filteredList = pokemonList;
          nextUrl = data['next'] ?? ''; // Asegúrate de que nextUrl no sea null
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterPokemon(String query) {
    setState(() {
      filteredList = pokemonList
          .where((pokemon) =>
          pokemon.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent, // Color de fondo similar
      appBar: AppBar(
        backgroundColor: Colors.blue, // Barra superior azul
        title: const Text(
          'Pokedex',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: filterPokemon,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final pokemon = filteredList[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8.0),
                    leading: Image.network(
                      pokemon.imageUrl,
                      height: 50,
                      width: 50,
                    ),
                    title: Text(
                      '#${pokemon.id.toString().padLeft(3, '0')}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      pokemon.name.capitalize(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
