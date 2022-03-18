import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:alan_voice/alan_voice.dart';

import 'dart:math';
import 'package:roslibdart/roslibdart.dart';
import 'package:json_annotation/json_annotation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // Try running your application with "flutter run". You'll see the
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late Ros ros;
  late Topic display;
  _MyHomePageState() {
    AlanVoice.addButton(
        "4db70e7a40290c970f6bf03ce5bc092b2e956eca572e1d8b807a3e2338fdd0dc/testing",
        buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT);
    AlanVoice.setLogLevel("all");
  }
  int i = 0;
  List<String> faces = [
  "assets/images/orb_afraid.gif",
  "assets/images/orb_dirty_face.gif",
  "assets/images/orb_sad.gif",
  "assets/images/orb_angry.gif",
  "assets/images/orb_dirty_face_sad.gif",
  "assets/images/orb_scream.gif",
  "assets/images/orb_blinking.gif",
  "assets/images/orb_dirty_face_wash.gif",
  "assets/images/orb_showing_smile.gif",
  "assets/images/orb_breathing.gif",  
  "assets/images/orb_dirty_teeth.gif",
  "assets/images/orb_shy.gif",
  "assets/images/orb_brushing_teeth.gif",
  "assets/images/orb_disgusted.gif",
  "assets/images/orb_sneezing.gif",
  "assets/images/orb_calmind_down.gif",
  "assets/images/orb_happy_blinking.gif",
  "assets/images/orb_surprise.gif",
  "assets/images/orb_cleaning_noise.gif",
  "assets/images/orb_kiss.gif",
  "assets/images/orb_talking_long.gif",
  "assets/images/orb_cold.gif",
  "assets/images/orb_normal.gif",
  "assets/images/orb_yawn.gif",
  "assets/images/orb_confused.gif",
  "assets/images/orb_one_eye.gif",
  "assets/images/orb_ykasha5.gif",
  "assets/images/orb_cry.gif",
  "assets/images/orb_puffing.gif",
  ];

  Future<void> subscribeHandler(Map<String, dynamic> msg) async {
    print(json.encode(msg));
    setState(() {});
  }

  @override
  void initState() {
    ros = Ros(url: 'ws://127.0.0.1:9090');
    display = Topic(
        ros: ros,
        name: '/display',
        type: "std_msgs/String",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);
    ros.connect();
    initializeTopics();
    super.initState();
  }

  Future<void> initializeTopics() async {
    await display.subscribe(subscribeHandler);
  }

  void _incrementCounter() {
    setState(() {
      i = (i + 1) % faces.length;
    });
  }

   void _decrementCounter() {
    setState(() {
      i = max((i - 1) % faces.length, 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      // appBar: AppBar(
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text(widget.title),
      // ),
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: GestureDetector(child: RotatedBox(
        quarterTurns: 1,
        child: Image.asset(
          faces[i],
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
        ),
      ),
        onTap: _incrementCounter,
        onDoubleTap:_decrementCounter,


      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
       ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
