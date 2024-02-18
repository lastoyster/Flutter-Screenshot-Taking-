import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:screenshot_example/widget/button_widget.dart';
import 'package:share_plus/share_plus.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final String title = 'Take Screenshots';

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MainPage(),
      );
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final controller = ScreenshotController();

  @override
  Widget build(BuildContext context) => Screenshot(
        controller: controller,
        child: Scaffold(
          appBar: AppBar(
            title: Text(MyApp.title),
            centerTitle: true,
          ),
          body: Column(
            children: [
              buildImage(),
              const SizedBox(height: 32),
              ButtonWidget(
                text: 'Capture Screen',
                onClicked: () async {
                  final image = await controller.capture();
                  if (image == null) return;

                  await saveImage(image);

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'Screenshot Saved In Gallery...',
                      style: TextStyle(fontSize: 20),
                    ),
                    backgroundColor: Colors.blue,
                  ));
                },
              ),
              const SizedBox(height: 16),
              ButtonWidget(
                text: 'Capture Widget',
                onClicked: () async {
                  final image =
                      await controller.captureFromWidget(buildImage());

                  saveAndShare(image);
                },
              ),
            ],
          ),
        ),
      );

  Future saveAndShare(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final image = File('${directory.path}/flutter.png');
    image.writeAsBytesSync(bytes);

    final text = 'Shared From Facebook';
    await Share.shareFiles([image.path], text: text);
  }

  Future<String> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();

    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-');
    final name = 'screenshot_$time';
    final result = await ImageGallerySaver.saveImage(bytes, name: name);

    return result['filePath'];
  }

  Widget buildImage() => Stack(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              'https://images.unsplash.com/photo-1469334031218-e382a71b716b?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1500&q=80',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 16,
            right: 0,
            left: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                color: Colors.black,
                child: Text(
                  'Summer 🌞⚓',
                  style: TextStyle(color: Colors.white, fontSize: 32),
                ),
              ),
            ),
          )
        ],
      );
}
