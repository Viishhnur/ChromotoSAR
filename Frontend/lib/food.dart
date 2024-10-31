import 'package:flutter/material.dart';
import 'dart:developer' as developer;

void main(){
  runApp(App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Strawberry",
      debugShowCheckedModeBanner: false,
      home: HomePage(title: "Strawberry"), // this is a launcher screen / launcher page
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Strawberry',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300, // Set the height of the PageView (adjust as needed)
              child: PageView(
                scrollDirection: Axis.horizontal,
                children: [
                  InkWell(
                    onDoubleTap: () {
                      developer.log("This is strawberry image double tap");
                    },
                    onTap: () {
                      developer.log("This is strawberry image");
                    },
                    child: Image.asset(
                      "assets/images/strawberry.jpg",
                      fit: BoxFit.cover, // Ensures the image fits the entire screen
                    ),
                  ),
                  InkWell(
                    onDoubleTap: () {
                      developer.log("This is satelliate image double tap");
                    },
                    onTap: () {
                      developer.log("This is satelliate image");
                    },
                    child: Image.asset(
                      "assets/images/satellite.png",
                      fit: BoxFit.cover, // Ensures the image fits the entire screen
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Container(
              height: 20,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Center(
                child: Text("Strawberry Pavlova", style: TextStyle(fontSize: 12)),
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 200,
              width: 400,
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("This is strawberry"),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                developer.log("Button Clicked");
              },
              icon: Icon(Icons.thumb_up_sharp),
              label: Text("Like"),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 20,
                    width: 200,
                    color: Colors.amber,
                  ),
                  SizedBox(height: 100),
                  Container(
                    height: 20,
                    width: 200,
                    color: const Color.fromARGB(255, 255, 7, 127),
                  ),
                  SizedBox(height: 100),
                  Container(
                    height: 20,
                    width: 200,
                    color: const Color.fromARGB(255, 102, 7, 255),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
