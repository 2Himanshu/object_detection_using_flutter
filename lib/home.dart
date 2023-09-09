import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:object_detection/detect_screen.dart';
import 'package:alan_voice/alan_voice.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'test.dart';
import 'models.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<CameraDescription> cameras;
  late CameraController _cameraController;
  int clickCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    setUpAlan();
  }

  _initializeCamera() async {
    try {
      cameras = await availableCameras();
      _cameraController = CameraController(
        cameras[0], // Choose the desired camera
        ResolutionPreset.medium, // Adjust the resolution as needed
      );

      await _cameraController.initialize();

      // Start Alan AI voice interaction after the camera is initialized.
      setUpAlan();
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  @override
  void dispose() {
    // Dispose of the camera controller to release resources
    _cameraController.dispose();
    super.dispose();
  }

  setUpAlan() {
    AlanVoice.addButton(
      "34235777417ddd38c73b1d4793692d3f2e956eca572e1d8b807a3e2338fdd0dc/stage", // Replace with your Alan API key
      buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT,
    );
    AlanVoice.callbacks.add((command) => _handleCmd(command.data));
  }

  _handleCmd(Map<String, dynamic> res) {
    switch (res["command"]) {
      case "Tiny YOLOv2":
        onSelect("Tiny YOLOv2");
        break;

      case "SOS Alert":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TestWidget(),
          ),
        );
        break;

      default:
        break;
    }
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
    }
  }

  onSelect(model) {
    if (model == "SOS Alert") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TestWidget(),
        ),
      );
      return;
    }
    Fluttertoast.showToast(
      msg: model,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    loadModel(model);
    final route = MaterialPageRoute(builder: (context) {
      return DetectScreen(
        cameras: cameras,
        model: model,
        cameraController: _cameraController,
      );
    });
    Navigator.of(context).push(route);
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    await setupCameras();
  }

  setupCameras() async {
    try {
      cameras = await availableCameras();
    } on CameraException {
      // Handle camera error here
      Fluttertoast.showToast(
        msg: "Camera initialization failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Increment the click count when the screen is tapped
        setState(() {
          clickCount++;
          if (clickCount == 3) {
            // Reset the click count and navigate to the YOLO page
            clickCount = 0;
            onSelect(yolo);
          }
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'VisionMatee',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(70.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                    ),
                    itemCount: 2,
                    itemBuilder: (BuildContext context, int index) {
                      String modelName = '';
                      IconData modelIcon = Icons.camera;

                      switch (index) {
                        case 0:
                          modelName = yolo;
                          modelIcon = Icons.camera_alt;
                          break;
                        case 1:
                          modelName = posenet;
                          modelIcon = Icons.sos;
                          break;
                        // case 2:
                        //   modelName = mobilenet;
                        //   break;
                        // case 3:
                        //   modelName = posenet;
                        //   break;
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
      ),
    );
  }
}

class GridItem extends StatelessWidget {
  final String model;
  final IconData modelIcon;
  final Function onSelect;

  const GridItem({super.key, required this.model, required this.modelIcon, required this.onSelect});

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
