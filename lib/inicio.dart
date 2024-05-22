import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Inicio extends StatefulWidget {
  final String numeroCedula; // Agregar el campo para almacenar el número de cédula

  const Inicio({Key? key, required this.numeroCedula}) : super(key: key);

  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  Position? _position;
  XFile? _image;
  String? _mensaje;
  int _numeroNotificacion = 1;

  set numeroNotificacion(int value) {
    _numeroNotificacion = value;
  }

  int get numeroNotificacion => _numeroNotificacion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de craters'),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/carretera.gif'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Ingrese su mensaje',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _mensaje = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _registrarUbicacion(context);
                        },
                        child: Text("Registrar Ubicación"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          _tomarFotoYGuardar(context);
                        },
                        child: Text("Tomar Fotografía"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _enviarNotificacion(context);
                    },
                    child: Text("Enviar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _registrarUbicacion(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Los servicios de localización están deshabilitados.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permisos de localización denegados.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permisos de localización permanentemente denegados.')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _position = position;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ubicación: ${position.latitude}, ${position.longitude}')),
    );
  }

  void _tomarFotoYGuardar(BuildContext context) async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    final fotoCapturada = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(camera: firstCamera),
      ),
    );

    if (fotoCapturada != null) {
      await GallerySaver.saveImage(fotoCapturada.path);
      setState(() {
        _image = fotoCapturada;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Foto guardada en la galería'),
        ),
      );
    }
  }

  void _enviarNotificacion(BuildContext context) async {
  if (_position == null || _image == null || _mensaje == null || _mensaje!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Debe registrar ubicación, tomar foto y escribir un mensaje')),
    );
    return;
  }

  final url = Uri.parse('http://192.168.1.6:5000/notificacion');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'numero_notificacion': numeroNotificacion,
      'numero_cedula': widget.numeroCedula, // Accediendo al valor de numeroCedula desde el widget Inicio
      'comentarios': _mensaje,
      'ruta_fotografia': _image!.path,
      'coordenadas': '${_position!.latitude},${_position!.longitude}',
    }),
  );

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notificación enviada correctamente')),
    );
    numeroNotificacion++;
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al enviar la notificación')),
    );
  }
}
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

@override
void initState() {
  super.initState();
  _controller = CameraController(
    widget.camera,
    ResolutionPreset.medium,
  );
  _initializeControllerFuture = _controller.initialize();
}

@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Tomar Fotografía')),
    body: FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CameraPreview(_controller);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () async {
        try {
          await _initializeControllerFuture;
          final image = await _controller.takePicture();
          Navigator.pop(context, image);
        } catch (e) {
          print(e);
        }
      },
      child: Icon(Icons.camera),
    ),
  );
}
}
