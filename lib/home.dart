import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:object_detection/detect_screen.dart';

import 'models.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Roboto-Medium', fontSize: 18),
          titleLarge: TextStyle(fontFamily: 'Roboto-Bold', fontSize: 24),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final List<CameraDescription> cameras;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    await setupCameras();
  }

  loadModel(model) async {
    String? res;
    switch (model) {
      case yolo:
        res = await Tflite.loadModel(
          model: "assets/yolov2_tiny.tflite",
          labels: "assets/yolov2_tiny.txt",
        );
        break;

      case mobilenet:
        res = await Tflite.loadModel(
            model: "assets/mobilenet_v1_1.0_224.tflite",
            labels: "assets/mobilenet_v1_1.0_224.txt");
        break;

      case posenet:
        res = await Tflite.loadModel(
            model: "assets/posenet_mv1_075_float_from_checkpoints.tflite");
        break;

      default:
        res = await Tflite.loadModel(
            model: "assets/ssd_mobilenet.tflite",
            labels: "assets/ssd_mobilenet.txt");
    }
  }

  onSelect(model) {
    loadModel(model);
    final route = MaterialPageRoute(builder: (context) {
      return DetectScreen(cameras: cameras, model: model);
    });
    Navigator.of(context).push(route);
  }

  setupCameras() async {
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      // Handle camera error here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Object Detection App',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                  ),
                  itemCount: 4,
                  itemBuilder: (BuildContext context, int index) {
                    String modelName = '';
                    IconData modelIcon = Icons.camera;

                    switch (index) {
                      case 0:
                        modelName = ssd;
                        break;
                      case 1:
                        modelName = yolo;
                        modelIcon = Icons.camera_alt;
                        break;
                      case 2:
                        modelName = mobilenet;
                        break;
                      case 3:
                        modelName = posenet;
                        break;
                    }

                    return GridItem(
                      model: modelName,
                      modelIcon: modelIcon,
                      onSelect: () => onSelect(modelName),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class GridItem extends StatelessWidget {
  final String model;
  final IconData modelIcon;
  final Function onSelect;

  const GridItem(
      {Key? key,
      required this.model,
      required this.modelIcon,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    Color pastelColor = Colors.purple[100]!;

    return InkWell(
      onTap: () => onSelect(),
      child: Container(
        decoration: BoxDecoration(
          color: pastelColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              modelIcon,
              size: 36,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              model,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontFamily: 'Roboto-Medium',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
