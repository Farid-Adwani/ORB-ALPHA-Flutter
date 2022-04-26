import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:alan_voice/alan_voice.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:roslibdart/roslibdart.dart';
import 'package:flutter_ripple/flutter_ripple.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ORB ALPHA',
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
  late Ros ros;
  late Topic display;
  late Topic order;

  _MyHomePageState() {
    AlanVoice.addButton(
        "4db70e7a40290c970f6bf03ce5bc092b2e956eca572e1d8b807a3e2338fdd0dc/prod",
        buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT);
    AlanVoice.setLogLevel("none");
  }

  ButtonState stateOnlyText = ButtonState.idle;
  ButtonState stateOnlyCustomIndicatorText = ButtonState.idle;
  ButtonState stateTextWithIcon = ButtonState.idle;
  ButtonState stateTextWithIconMinWidthState = ButtonState.idle;

  int compteurPutMeDown = 0;
  int compteurBehind = 0;
  int compteurFront = 0;

  int i = 0;
  int level = 0;
  int times = 0;
  int statecap = 11;
  bool Password = true;
  var dialog;
  late int ir1, ir2, ir3, sharp1, sharp2, gyrox, gyroy, gyroz;

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
  void checkIR(double code) {
    if (code == statecap) {
      switch (statecap) {
        case 11:
          statecap = 101;
          break;
        case 101:
          statecap = 110;
          break;
        case 110:
          statecap = 11;
          times = times + 1;
          break;
      }
    } else if (code == 11 && statecap == 101) {
      times = times;
    } else if (code == 101 && statecap == 110) {
      times = times;
    } else if (code == 110 && statecap == 11) {
      times = times;
    } else if (code != 111) {
      statecap = 11;
      times = 0;
    }

    // print(code.toString() +
    // " state is : " +
    // statecap.toString() +
    // "  times is : " +
    // times.toString());
    // print("eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee" + times.toString());
    if (times == 3) {
      times = 0;

      AlanVoice.activate();
      setState(() {
        i = 20;
      });
      AlanVoice.playText("yayyy this is very relaxing");
      //sleep(Duration(seconds: 2));
      setState(() {
        i = 11;
      });
    }
  }

  void checkSharp(double front, double back) {
    print("front =  " +
        front.toInt().toString() +
        " back = " +
        back.toInt().toString());
    if (front.toInt() > 11) {
      compteurFront++;
      if (compteurFront > 50) {
        AlanVoice.activate();
        AlanVoice.playText("i'm falling from front");
        compteurFront = 0;
      }
    }
    // if (back.toInt() > 15) {
    //   compteurBehind++;
    //   if (compteurBehind > 300) {
    //     AlanVoice.activate();
    //     AlanVoice.playText("i'm falling from behind");
    //     compteurBehind = 0;
    //   }
    // }
  }

  void checkGyro(double x, double y, double z) {
    // print("Roll =  " +
    //     x.toString() +
    //     "  Pitch = " +
    //     y.toString() +
    //     "  Yaw = " +
    //     z.toString());
    if (x.toInt() > 60 || x.toInt() < -60) {
      compteurPutMeDown++;
      if (compteurPutMeDown > 200) {
        setState(() {
          i = 0;
        });
        AlanVoice.activate();
        AlanVoice.playText("Hey put me down");
        compteurPutMeDown = 0;
        // setState(() {

        //       i=10;
        //     });
      }
    }
  }

  Future<void> subscribeHandler(Map<String, dynamic> msg) async {
    var sensors = json.encode(msg);

    double code = msg["ixx"] * 100 + msg["ixy"] * 10 + msg["ixz"];
    ir1 = msg["ixx"].toInt();
    ir2 = msg["ixy"].toInt();
    ir3 = msg["ixz"].toInt();
    sharp1 = msg["iyy"].toInt();
    sharp2 = msg["iyz"].toInt();
    gyrox = msg["com"]["x"].toInt();
    gyroy = msg["com"]["y"].toInt();
    gyroz = msg["com"]["z"].toInt();
    // print(code.toString());

    checkIR(code);
    checkSharp(msg["iyy"], msg["iyz"]);
    // checkGyro(msg["com"]["x"], msg["com"]["y"], msg["com"]["z"]);
  }

  _handleCommand(Map<String, dynamic> response) {
    // print("aaaaaaaaaaaaaaaaaaa");
    print(response);
    if (response["command"] == "password") {
      if (response["password"] == "open the door") {
        AlanVoice.playText("it's correct congratulations");
        dialog..dismiss();
      } else {
        AlanVoice.playText("but it's incorrect");
      }
    } else if (response["command"] == "order") {
      if (response["order"].toString() == "forward") {
        publishOrder(1);
        print("done forwarding");
      } else if (response["order"].toString() == "backward") {
        publishOrder(2);
        print("done backwarding");
      } else if (response["order"].toString() == "to the right") {
        publishOrder(3);
        print("done moving right");
      } else if (response["order"].toString() == "to the left") {
        publishOrder(4);
        print("done moving left");
      }
    } else if (response["command"] == "sensors") {
      if (response["sensors"].toString() == "the first laser") {
        AlanVoice.activate();
        AlanVoice.playText(ir1.toInt().toString());
      } else if (response["sensors"].toString() == "the second laser") {
        AlanVoice.activate();

        AlanVoice.playText(ir2.toInt().toString());
      } else if (response["sensors"].toString() == "the third laser") {
        AlanVoice.activate();

        AlanVoice.playText(ir3.toInt().toString());
      } else if (response["sensors"].toString() == "the first Sharp") {
        AlanVoice.activate();

        AlanVoice.playText(sharp1.toInt().toString());
      } else if (response["sensors"].toString() == "the second Sharp") {
        AlanVoice.activate();

        AlanVoice.playText(sharp2.toInt().toString());
      } else if (response["sensors"].toString() == "the gyro") {
        AlanVoice.activate();
        // AlanVoice.playText("gyrooo yes");
        String ch = "on x axis we have " +
            gyrox.toInt().toString() +
            "on y axis we have " +
            gyroy.toInt().toString() +
            "and on z axis we have " +
            gyroz.toInt().toString();
        AlanVoice.playText(ch.toString());
      } else {
        AlanVoice.activate();

        AlanVoice.playText("please select a sensor");
      }
    }
    // switch(response[“command”]){
    //   case “command_1”:
    //         //do something according to command_1
    //         break;
    //   case “command_2”:
    //         //do something according to command_2
    //         break;
    //   default:
    //         break;
  }

  @override
  void initState() {
    ros = Ros(url: 'ws://192.168.204.253:9090');
    display = Topic(
        ros: ros,
        name: '/sensors',
        type: "geometry_msgs/Inertia",
        reconnectOnClose: true,
        queueLength: 1000,
        queueSize: 1000);
    order = Topic(
        ros: ros,
        name: '/order',
        type: "std_msgd=s/Int32",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);
    ros.connect();
    initializeTopics();
    // dialog..show();
    AlanVoice.callbacks.add((command) => _handleCommand(command.data));

    super.initState();
  }

  Future<void> initializeTopics() async {
    await display.subscribe(subscribeHandler);
    await order.advertise();
  }

  void publishOrder(int x) async {
    var msg = {'data': x};
    await order.publish(msg);
    print('done publihsed');
  }

  void _incrementCounter() {
    AlanVoice.activate();

    AlanVoice.playText("Please say your Password");
    // setState(() {
    //   i = (i + 1) % faces.length;
    // });
    dialog..show();
  }

  void _decrementCounter() {
    publishOrder(i % 5);
    AlanVoice.activate();
    AlanVoice.playText("previous");
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

    dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.ERROR,
      borderSide: BorderSide(color: Colors.red, width: 5),
      // width: 280,
      buttonsBorderRadius: BorderRadius.all(Radius.circular(10)),
      animType: AnimType.SCALE,
      title: 'Authentification',
      desc: 'Voice Authentification',
      btnOk: Container(),
      dialogBackgroundColor: Colors.white,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,

      body: Center(
          child: Column(children: [
        Text(
          "Please Say your Secret Word :)",
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          child: FlutterRipple(
            radius: 70,
            child: IconButton(
                onPressed: () {
                  print("pressed");
                },
                icon: Icon(Icons.multitrack_audio_rounded)),
            rippleColor: Color.fromARGB(255, 164, 7, 7),
            duration: Duration(milliseconds: 1500),
            onTap: () {
              print("hello");
            },
          ),
          width: 200,
          height: 200,
        )
      ])),
    );

    return Scaffold(
      // appBar: AppBar(
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text(widget.title),
      // ),

      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: GestureDetector(
          child: RotatedBox(
            quarterTurns: 3,
            child: Image.asset(
              faces[i],
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
            ),
          ),
          onTap: _incrementCounter,
          onDoubleTap: _decrementCounter,
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: _incrementCounter,
        //   tooltip: 'Increment',
        //   child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}







// import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:flutter/material.dart';

// // import 'routes.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Fancy Dialog Example',
//       theme: ThemeData.dark(),
//       home: HomePage()
//       // initialRoute: '/',
//       // onGenerateRoute: RouteGenerator.generateRoute,
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   const HomePage({
//     Key? key,
//   }) : super(key: key);

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('Awesome Dialog Example'),
//         ),
//         body: Center(
//             child: Container(
//           padding: EdgeInsets.all(16),
//           child: SingleChildScrollView(
//             child: Column(
//               children: <Widget>[
//                 AnimatedButton(
//                   text: 'Info Dialog fixed width and sqare buttons',
//                   pressEvent: () {
//                     AwesomeDialog(
//                       context: context,
//                       dialogType: DialogType.INFO_REVERSED,
//                       borderSide: BorderSide(color: Colors.green, width: 2),
//                       width: 280,
//                       buttonsBorderRadius: BorderRadius.all(Radius.circular(2)),
//                       headerAnimationLoop: false,
//                       animType: AnimType.BOTTOMSLIDE,
//                       title: 'INFO',
//                       desc: 'Dialog description here...',
//                       showCloseIcon: true,
//                       btnCancelOnPress: () {},
//                       btnOkOnPress: () {},
//                     )..show();
//                   },
//                 ),
//                 SizedBox(
//                   height: 16,
//                 ),
//                 AnimatedButton(
//                   text: 'Question Dialog With Custom BTN Style',
//                   pressEvent: () {
//                     AwesomeDialog(
//                       context: context,
//                       dialogType: DialogType.QUESTION,
//                       headerAnimationLoop: false,
//                       animType: AnimType.BOTTOMSLIDE,
//                       title: 'Question',
//                       desc: 'Dialog description here...',
//                       buttonsTextStyle: TextStyle(color: Colors.black),
//                       showCloseIcon: true,
//                       btnCancelOnPress: () {},
//                       btnOkOnPress: () {},
//                     )..show();
//                   },
//                 ),
//                 SizedBox(
//                   height: 16,
//                 ),
//                 AnimatedButton(
//                   text: 'Info Dialog Without buttons',
//                   pressEvent: () {
//                     AwesomeDialog(
//                       context: context,
//                       headerAnimationLoop: true,
//                       animType: AnimType.BOTTOMSLIDE,
//                       title: 'INFO',
//                       desc:
//                           'Lorem ipsum dolor sit amet consectetur adipiscing elit eget ornare tempus, vestibulum sagittis rhoncus felis hendrerit lectus ultricies duis vel, id morbi cum ultrices tellus metus dis ut donec. Ut sagittis viverra venenatis eget euismod faucibus odio ligula phasellus,',
//                     )..show();
//                   },
//                 ),
//                 SizedBox(
//                   height: 16,
//                 ),
//                 AnimatedButton(
//                   text: 'Warning Dialog',
//                   color: Colors.orange,
//                   pressEvent: () {
//                     AwesomeDialog(
//                         context: context,
//                         dialogType: DialogType.WARNING,
//                         headerAnimationLoop: false,
//                         animType: AnimType.TOPSLIDE,
//                         showCloseIcon: true,
//                         closeIcon: Icon(Icons.close_fullscreen_outlined),
//                         title: 'Warning',
//                         desc:
//                             'Dialog description here..................................................',
//                         btnCancelOnPress: () {},
//                         onDissmissCallback: (type) {
//                           debugPrint('Dialog Dissmiss from callback $type');
//                         },
//                         btnOkOnPress: () {})
//                       ..show();
//                   },
//                 ),
//                 SizedBox(
//                   height: 16,
//                 ),
//                 AnimatedButton(
//                   text: 'Error Dialog',
//                   color: Colors.red,
//                   pressEvent: () {
//                     AwesomeDialog(
//                         context: context,
//                         dialogType: DialogType.ERROR,
//                         animType: AnimType.RIGHSLIDE,
//                         headerAnimationLoop: true,
//                         title: 'Error',
//                         desc:
//                             'Dialog description here..................................................',
//                         btnOkOnPress: () {},
//                         btnOkIcon: Icons.cancel,
//                         btnOkColor: Colors.red)
//                       ..show();
//                   },
//                 ),
//                 SizedBox(
//                   height: 16,
//                 ),
//                 AnimatedButton(
//                   text: 'Succes Dialog',
//                   color: Colors.green,
//                   pressEvent: () {
//                     AwesomeDialog(
//                         context: context,
//                         animType: AnimType.LEFTSLIDE,
//                         headerAnimationLoop: false,
//                         dialogType: DialogType.SUCCES,
//                         showCloseIcon: true,
//                         title: 'Succes',
//                         desc:
//                             'Dialog description here..................................................',
//                         btnOkOnPress: () {
//                           debugPrint('OnClcik');
//                         },
//                         btnOkIcon: Icons.check_circle,
//                         onDissmissCallback: (type) {
//                           debugPrint('Dialog Dissmiss from callback $type');
//                         })
//                       ..show();
//                   },
//                 ),
//                 SizedBox(
//                   height: 16,
//                 ),
//                 AnimatedButton(
//                   text: 'No Header Dialog',
//                   color: Colors.cyan,
//                   pressEvent: () {
//                     AwesomeDialog(
//                       context: context,
//                       headerAnimationLoop: false,
//                       dialogType: DialogType.NO_HEADER,
//                       title: 'No Header',
//                       desc:
//                           'Dialog description here..................................................',
//                       btnOkOnPress: () {
//                         debugPrint('OnClcik');
//                       },
//                       btnOkIcon: Icons.check_circle,
//                     )..show();
//                   },
//                 ),
//                 SizedBox(
//                   height: 16,
//                 ),
//                 AnimatedButton(
//                   text: 'Custom Body Dialog',
//                   color: Colors.blueGrey,
//                   pressEvent: () {
//                     AwesomeDialog(
//                       context: context,
//                       animType: AnimType.SCALE,
//                       dialogType: DialogType.INFO,
//                       body: Center(
//                         child: Text(
//                           'If the body is specified, then title and description will be ignored, this allows to further customize the dialogue.',
//                           style: TextStyle(fontStyle: FontStyle.italic),
//                         ),
//                       ),
//                       title: 'This is Ignored',
//                       desc: 'This is also Ignored',
//                     )..show();
//                   },
//                 ),
//                 SizedBox(
//                   height: 16,
//                 ),
//                 AnimatedButton(
//                   text: 'Auto Hide Dialog',
//                   color: Colors.purple,
//                   pressEvent: () {
//                     AwesomeDialog(
//                       context: context,
//                       dialogType: DialogType.INFO,
//                       animType: AnimType.SCALE,
//                       title: 'Auto Hide Dialog',
//                       desc: 'AutoHide after 2 seconds',
//                       autoHide: Duration(seconds: 2),
//                     )..show();
//                   },
//                 ),
//                 SizedBox(
//                   height: 16,
//                 ),
//                 AnimatedButton(
//                   text: 'Testing Dialog',
//                   color: Colors.orange,
//                   pressEvent: () {
//                     AwesomeDialog(
//                       context: context,
//                       keyboardAware: true,
//                       dismissOnBackKeyPress: false,
//                       dialogType: DialogType.WARNING,
//                       animType: AnimType.BOTTOMSLIDE,
//                       btnCancelText: "Cancel Order",
//                       btnOkText: "Yes, I will pay",
//                       title: 'Continue to pay?',
//                       // padding: const EdgeInsets.all(5.0),
//                       desc:
//                           'Please confirm that you will pay 3000 INR within 30 mins. Creating orders without paying will create penalty charges, and your account may be disabled.',
//                       btnCancelOnPress: () {},
//                       btnOkOnPress: () {},
//                     ).show();
//                   },
//                 ),
//                 SizedBox(
//                   height: 16,
//                 ),
//                 AnimatedButton(
//                   text: 'Body with Input',
//                   color: Colors.blueGrey,
//                   pressEvent: () {
//                     late AwesomeDialog dialog;
//                     dialog = AwesomeDialog(
//                       context: context,
//                       animType: AnimType.SCALE,
//                       dialogType: DialogType.INFO,
//                       keyboardAware: true,
//                       body: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           children: <Widget>[
//                             Text(
//                               'Form Data',
//                               style: Theme.of(context).textTheme.headline6,
//                             ),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             Material(
//                               elevation: 0,
//                               color: Colors.blueGrey.withAlpha(40),
//                               child: TextFormField(
//                                 autofocus: true,
//                                 minLines: 1,
//                                 decoration: InputDecoration(
//                                   border: InputBorder.none,
//                                   labelText: 'Title',
//                                   prefixIcon: Icon(Icons.text_fields),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             Material(
//                               elevation: 0,
//                               color: Colors.blueGrey.withAlpha(40),
//                               child: TextFormField(
//                                 autofocus: true,
//                                 keyboardType: TextInputType.multiline,
//                                 maxLengthEnforced: true,
//                                 minLines: 2,
//                                 maxLines: null,
//                                 decoration: InputDecoration(
//                                   border: InputBorder.none,
//                                   labelText: 'Description',
//                                   prefixIcon: Icon(Icons.text_fields),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             AnimatedButton(
//                                 isFixedHeight: false,
//                                 text: 'Close',
//                                 pressEvent: () {
//                                   dialog.dismiss();
//                                 })
//                           ],
//                         ),
//                       ),
//                     )..show();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         )));
//   }
// }
