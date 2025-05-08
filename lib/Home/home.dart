import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import '../consts.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final WeatherFactory _wf = WeatherFactory(WEATHER_API_KEY);
  Weather? weather;
  final TextEditingController controller = TextEditingController();
  List<String> filteredCity = [];

  @override
  void initState() {
    super.initState();
    _getWeather('karachi');
  }

  void _getWeather(String city) async {
    try {
      final w = await _wf.currentWeatherByCityName(city);
      setState(() {
        weather = w;
      });
    } catch (e) {
      print('Weather fetch error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (weather == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    DateTime now = weather!.date!;
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80), // Space for the search bar
                Text(
                  weather?.areaName ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Center(
                  child: Image.network(
                    'https://openweathermap.org/img/wn/${weather?.weatherIcon}@4x.png',
                    height: 100,
                    width: 100,
                  ),
                ),
                Text(
                  'Temperature: ${weather?.temperature?.celsius?.toStringAsFixed(0)}°C',
                  style: TextStyle(fontSize: 25),
                ),
                const SizedBox(height: 20),
                Text('Time: ${DateFormat('h:mm a').format(now)}'),
                Text('Day: ${DateFormat('EEEE').format(now)}'),
                Text('Date: ${DateFormat('d-M-y').format(now)}'),
                Text('Max: ${weather?.tempMax?.celsius?.toStringAsFixed(0)}°C'),
                Text('Min: ${weather?.tempMin?.celsius?.toStringAsFixed(0)}°C'),
                Text(
                  'Wind Speed: ${weather?.windSpeed?.toStringAsFixed(0)} m/s',
                ),
                Text('Humidity: ${weather?.humidity?.toStringAsFixed(0)}%'),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 18,
            right: 18,
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  onChanged: (value) {
                    setState(() {
                      filteredCity =
                          cityList
                              .where(
                                (city) => city.toLowerCase().contains(
                                  value.toLowerCase(),
                                ),
                              )
                              .toList();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search City',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                if (filteredCity.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredCity.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: ListTile(
                          tileColor: Colors.red[100],
                          title: Text(filteredCity[index]),
                          onTap: () {
                            controller.text = filteredCity[index];
                            filteredCity.clear();
                            _getWeather(controller.text);
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
