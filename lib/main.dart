import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/country_info': (context) => const CountryDataDisplayer(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Country Info App',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
      ),
      body: const AppBody(),
    );
  }
}

class AppBody extends StatefulWidget {
  const AppBody({super.key});

  @override
  State<AppBody> createState() => _AppBodyState();
}

class _AppBodyState extends State<AppBody> {
  var myController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    myController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 250.0,
            child: TextField(
              controller: myController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Enter a country name"),
              ),
              style: const TextStyle(
                fontSize: 20.0,
              ),
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          SizedBox(
            width: 250.0,
            height: 50.0,
            child: ElevatedButton(
              onPressed: () {
                String inputValue = myController.text;
                fetchCountryData(inputValue);
                myController.clear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
              ),
              child: const Text(
                'Get Country Info',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchCountryData(String country) async {
    try {
      final response = await http
          .get(Uri.parse('https://restcountries.com/v3.1/name/$country'));

      if (response.statusCode == 200) {
        final List<dynamic> countryList = json.decode(response.body);

        if (countryList.isEmpty) {
          showErrorSnackBar("Country not found");
          return;
        }

        final data = countryList[0];
        String flagUrl = data['flags']['png'];
        String name = data['name']['common'];
        String continent = data['continents'][0];
        double population = data['population'] / 1000000;
        String languages = data['languages'].values.join(', ');

        // Navigate to the second page with the data
        Navigator.pushNamed(
          context,
          '/country_info',
          arguments: CountryData(
            flagUrl: flagUrl,
            name: name,
            continent: continent,
            population: population.toStringAsFixed(1),
            languages: languages,
          ),
        );
      } else {
        showErrorSnackBar("Error fetching country data");
      }
    } catch (e) {
      showErrorSnackBar(
          "Failed to fetch data. Please check your internet connection.");
    }
  }

  void showErrorSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class CountryData {
  final String flagUrl;
  final String name;
  final String continent;
  final String population;
  final String languages;

  CountryData({
    required this.flagUrl,
    required this.name,
    required this.continent,
    required this.population,
    required this.languages,
  });
}

class CountryDataDisplayer extends StatelessWidget {
  const CountryDataDisplayer({super.key});

  @override
  Widget build(BuildContext context) {
    final CountryData countryData =
        ModalRoute.of(context)!.settings.arguments as CountryData;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Country Info App',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(countryData.flagUrl),
              const SizedBox(height: 20),
              Text(
                'Country: ${countryData.name}',
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                'Continent: ${countryData.continent}',
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                'Population: ${countryData.population} million',
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                'Languages: ${countryData.languages}',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
