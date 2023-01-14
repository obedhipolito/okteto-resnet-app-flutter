import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedImagePath='';
  final URL_API = Uri.parse("https://linear-model-service-lixbeth34.cloud.okteto.net/v1/models/resnet:predict");
  final HEADERS_API = {"Content-Type": "application/json;charset=UTF-8"};


  Future<void> _upload() async {
    showDialog(
        context:  context,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        }
    );

    File file = File(selectedImagePath);
    List<int> fileInByte = file.readAsBytesSync();
    String base64 = base64Encode(fileInByte);


    try {
      final body_data = {
        "instances" : [
          {
            "b64": "$base64"
          }
        ]
      };

      final res = await http.post(URL_API, headers: HEADERS_API, body: jsonEncode(body_data));


      if (res.statusCode == 200) {
        Navigator.pop(this.context);
        final response = jsonDecode(res.body);
        String clases_prediction = response['predictions'][0]['classes'].toString();
        log("Clase: $clases_prediction");


        final value = await rootBundle.loadString('assets/json_data/imagenet_class_index.json');
        var datos = json.decode(value);
        var clase_prediccion_json = datos[clases_prediction.toString()][1];
        var result_prediction = datos[clases_prediction.toString()];

        mostrarResultados(
            "Predicción con ID: $clases_prediction",
            "El ID pertenece a la clase:\n $clase_prediccion_json"
        );

      }

    } catch (e) {
      Navigator.pop(this.context);
      log("Ocurrió un error: ${e.toString()}");
    }
  }


  mostrarResultados(titulo, submensaje) {
    showDialog(
      context:  this.context,
      builder: (context) {
        Future.delayed(
          Duration(seconds: 8),
              () {
            Navigator.of(context).pop(true);
          },
        );

        return AlertDialog(
          title: Text(titulo),
          content: Text(submensaje),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 25, 153, 13),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            selectedImagePath == ''
                ? Image.asset('assets/images/image_placeholder.png', height: 200, width: 200, fit: BoxFit.fill,)
                : Image.file(File(selectedImagePath), height: 200, width: 200, fit: BoxFit.fill,),
            Text(
              'Seleccionar imagen',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            SizedBox(
              height: 20.0,
            ),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(20)),
                    textStyle: MaterialStateProperty.all(
                        const TextStyle(fontSize: 14, color: Colors.white))),
                onPressed: () async {
                  selectImage();
                  setState(() {});
                },
                child: const Text('Seleccionar')),
            const SizedBox(height: 10),

            Visibility(
              visible:  selectedImagePath != '',
              child:
              ElevatedButton.icon(
                onPressed: (){
                  _upload();
                },
                icon: Icon(Icons.near_me_rounded),
                label: Text('Enviar'),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                    padding:
                    MaterialStateProperty.all(const EdgeInsets.all(20)),
                    textStyle: MaterialStateProperty.all(
                        const TextStyle(fontSize: 14, color: Colors.white))),
                ),
              ),

          ],
        ),
      ),
    );
  }

  Future selectImage() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 150,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      'Seleccionar imagen de:',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            selectedImagePath = await selectImageFromGallery();
                            print('Image_Path:-');
                            print(selectedImagePath);
                            if (selectedImagePath != '') {
                              Navigator.pop(context);
                              setState(() {});
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("No se seleciono imagen!"),
                              ));
                            }
                          },
                          child: Card(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/gallery.png',
                                      height: 60,
                                      width: 60,
                                    ),
                                    Text('Galeria'),
                                  ],
                                ),
                              )),
                        ),
                        GestureDetector(
                          onTap: () async {
                            selectedImagePath = await selectImageFromCamera();
                            print('Image_Path:-');
                            print(selectedImagePath);

                            if (selectedImagePath != '') {
                              Navigator.pop(context);
                              setState(() {});
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("No se capturo imagen!"),
                              ));
                            }
                          },
                          child: Card(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/camera.png',
                                      height: 60,
                                      width: 60,
                                    ),
                                    Text('Camara'),
                                  ],
                                ),
                              )),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  selectImageFromGallery() async {
    XFile? file = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 10);
    if (file != null) {
      return file.path;
    } else {
      return '';
    }
  }

  //
  selectImageFromCamera() async {
    XFile? file = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 10);
    if (file != null) {
      return file.path;
    } else {
      return '';
    }
  }
}