import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'camera.dart';
import 'bndbox.dart';

const String ssd = "SSD MobileNet";
const String yolo = "Tiny YOLOv2";
const String monumenti = "Monumenti Cagliari";

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomePage(this.cameras);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  CameraController _cameraController;
  String _model = "";

  @override
  void initState() {
    super.initState();
  }

  closeModel() {

    _cameraController?.dispose();
    setState(() {
      _model == '';
    });
  }

  loadModel() async {
    String res;
    switch (_model) {
      case monumenti:
        res = await Tflite.loadModel(
          model: "assets/monumenti.tflite",
          labels: "assets/monumenti.txt",
        );
        break;
      case yolo:
        res = await Tflite.loadModel(
          model: "assets/yolov2_tiny.tflite",
          labels: "assets/yolov2_tiny.txt",
        );
        break;
      default:
        res = await Tflite.loadModel(
            model: "assets/ssd_mobilenet.tflite",
            labels: "assets/ssd_mobilenet.txt");
        break;
    }
    print(res);
  }

  onSelect(model) {
    setState(() {
      _model = model;
    });
    loadModel();
  }

  setRecognitions(recognitions, imageHeight, imageWidth, cameraController) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
      _cameraController = cameraController;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(_model != null ? _model : ''),
        actions: <Widget>[
          FlatButton(
              child: Text('Chiudi'),
              onPressed: () {
                closeModel();

              }),
        ],
      ),
      body: _model == ""
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: const Text(ssd),
                    onPressed: () => onSelect(ssd),
                  ),
                  RaisedButton(
                    child: const Text(yolo),
                    onPressed: () => onSelect(yolo),
                  ),
                  RaisedButton(
                    child: const Text(monumenti),
                    onPressed: () => onSelect(monumenti),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                Camera(
                  widget.cameras,
                  _model,
                  setRecognitions,
                ),
                buildResults(screen),
              ],
            ),
    );
  }

  Widget buildResults(Size screen) {
    return _model == monumenti
        ? Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              child: Text(
                _recognitions != null && _recognitions.isNotEmpty
                    ? _recognitions.first['label']
                    : 'analisi in corso...',
                textAlign: TextAlign.center,
              ),
              height: 30,
              width: 200,
              color: Colors.blueAccent,
            ),
          )
        : BndBox(
            _recognitions == null ? [] : _recognitions,
            math.max(_imageHeight, _imageWidth),
            math.min(_imageHeight, _imageWidth),
            screen.height,
            screen.width,
          );
  }
}
