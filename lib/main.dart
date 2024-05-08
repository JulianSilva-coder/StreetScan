import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'inicio.dart'; 

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Material App",
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 255, 255, 255),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "BIENVENIDO",
                  style: TextStyle(
                      color: Color.fromARGB(255, 252, 193, 1),
                      fontSize: 55,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "Ingresa tu número de Identificación",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                )
              ],
            ),
            Image.asset('assets/carretera.png'),
            Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: "Cedula",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    _obtenerUbicacionYIrAInicio(context);
                  },
                  child: Text("Registrar"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 187, 0),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 100, vertical: 20),
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _obtenerUbicacionYIrAInicio(BuildContext context) async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double latitud = position.latitude;
    double longitud = position.longitude;

    int latitud12Bits = ((latitud + 90) / 180 * 4095).round();
    int longitud12Bits = ((longitud + 180) / 360 * 4095).round();

    print("Ubicación en 12 bits:");
    print("Latitud: $latitud12Bits");
    print("Longitud: $longitud12Bits");

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Inicio(latitud: latitud, longitud: longitud)),
    );
  }
}