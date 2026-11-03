import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';

//Partners with Evan Gonzalez



void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}


class WeatherService {
  Future<Map<String, dynamic>> fetchWeather(String city) async {
    final apiKey = dotenv.env['API_KEY'];


    final response = await http.get(
      Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric',
      ),
    );


    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to load data, make sure you typed the name correctly',
      );
    }
  }
}


class MyApp extends StatefulWidget {
  MyApp({super.key});


  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  final TextEditingController cityController = TextEditingController();
  final WeatherService weatherService = WeatherService();


  Future<Map<String, dynamic>>? futureWeather;


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('Weather App')),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: cityController,
                decoration: InputDecoration(labelText: 'Enter City'),
              ),


              ElevatedButton(
                onPressed: () {
                  setState(() {
                    futureWeather = weatherService.fetchWeather(
                      cityController.text,
                    );
                  });
                },
                child: Text('Get Weather'),
              ),


              FutureBuilder<Map<String, dynamic>>(
                future: futureWeather,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading...');
                  }


                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }


                  if (snapshot.hasData) {
                    final weather = snapshot.data!;


                    return Column(
                      children: [
                        Image.network(
                          'https://openweathermap.org/img/wn/${weather['weather'][0]['icon']}@2x.png',
                          width: 100,
                          height: 100,
                        ),


                        Text('City: ${weather['name']}'),


                        Text('Temperature: ${weather['main']['temp']} °C'),


                        Text(
                          'Conditions: ${weather['weather'][0]['description']}',
                        ),
                      ],
                    );
                  }


                  return Text('Enter a city to get weather.');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}



