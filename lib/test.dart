import 'package:flutter/material.dart';

class TestWidget extends StatelessWidget {
  const TestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 235, 88, 78),
          title: Text('SOS'
         ),
        ),
        body: Center(
          child: SOSbutton(),
        ),
      ),
    );
  }
}

class SOSbutton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      onTap: ()  {
        // Handle button tap here
      
      },
      child: Container(
        width: 300, // Set the width of the button
        height: 300, // Set the height of the button
        decoration: BoxDecoration(
         
         // Make it a circle
        ),
        child: Center(
          child: Image.asset(
            'assets/sos.jpg', // Replace with your image asset
            width: 200, // Set the width of the image
            height: 200, // Set the height of the image
          ),
        ),
      ),
    );
  }
}
