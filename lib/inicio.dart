import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Inicio extends StatelessWidget {
  final double latitud;
  final double longitud;

  const Inicio({Key? key, required this.latitud, required this.longitud}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de craters'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(latitud, longitud),
              zoom: 12,
            ),
            onMapCreated: (GoogleMapController controller) {
              // Aquí puedes agregar lógica adicional cuando se crea el mapa, si es necesario
            },
            // Puedes agregar más opciones del mapa aquí según tus necesidades
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Color.fromARGB(255, 223, 223, 223),
                            title: Text(
                              "Mensaje de Registro",
                              style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                            ),
                            content: Text(
                              "¡Hola! Este es un mensaje de registro. Latitud: $latitud, Longitud: $longitud",
                              style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "Cerrar",
                                  style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text("Registrar Ubicacion"),
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
                    child: Text("Tomar Fotografia"),
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
            ),
          ),
        ],
      ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Foto guardada en la galería'),
        ),
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
      appBar: AppBar(title: Text('Tomar Fotografia')),
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
