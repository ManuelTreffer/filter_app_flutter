import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:save_in_gallery/save_in_gallery.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:dio/dio.dart';
import 'package:photos_saver/photos_saver.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Color Filter Flutter',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.orange,
      ),
      home: MyHomePage(title: 'Color Filter Flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class CellData {
  double value;
  final int index;
  TextEditingController controller;

  CellData(this.value, this.index);
}

Map<String, List<double>> predefinedFilters = {
  'Normal': [
    //R  G   B    A  Const
    1, 0, 0, 0, 0, //
    0, 1, 0, 0, 0, //
    0, 0, 1, 0, 0, //
    0, 0, 0, 1, 0, //
  ],
  'Grey Scale': [
    //R  G   B    A  Const
    0.33, 0.59, 0.11, 0, 0, //
    0.33, 0.59, 0.11, 0, 0, //
    0.33, 0.59, 0.11, 0, 0, //
    0, 0, 0, 1, 0, //
  ],
  'Invers': [
    //R  G   B    A  Const
    -1, 0, 0, 0, 255, //
    0, -1, 0, 0, 255, //
    0, 0, -1, 0, 255, //
    0, 0, 0, 1, 0, //
  ],
  'Sepia': [
    //R  G   B    A  Const
    0.393, 0.769, 0.189, 0, 0, //
    0.349, 0.686, 0.168, 0, 0, //
    0.272, 0.534, 0.131, 0, 0, //
    0, 0, 0, 1, 0, //
  ],
};

class _MyHomePageState extends State<MyHomePage> {

  Future<String> get _localPath async{
    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    var timestamp = new DateTime.now().millisecondsSinceEpoch;
    return File('$path/$timestamp.jpg');
  }

  File imageFile;
  List<CellData> matrixValues =
  List<CellData>.generate(20, (index) => CellData(0.0, index));

  _MyHomePageState() {
    updateMatrixValues(predefinedFilters['Normal']);
  }

  void pickImage() async {
    imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 700,
      // maxHeight: 800
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 16,
              ),
              FractionallySizedBox(
                widthFactor: 0.75,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    //decoration: BoxDecoration(
                    // border: Border.all(color: Colors.grey),
                    // ),
                    child: GestureDetector(
                      onTap: pickImage,
                      child: imageFile != null
                          ? ColorFiltered(
                        colorFilter: ColorFilter.matrix(matrixValues
                            .map<double>((entry) => entry.value)
                            .toList()),
                        child: Image.file(
                          imageFile,
                          //fit: BoxFit.cover,
                        ),
                      )
                          : Center(
                          child:
                          Text('Klicke hier, um ein Bild auszuwählen',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 28,
                              ))),
                    ),
                  ),
                ),
              ),

              PopupMenuButton<String>(
                child: Container(
                  color: Colors.orange,
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(8),
                  child: Text('Vordefinierte Filter',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
                itemBuilder: (context) => predefinedFilters.keys
                    .map<PopupMenuItem<String>>(
                      (filterName) => PopupMenuItem<String>(
                    value: filterName,
                    child: Text(filterName),
                  ),
                )
                    .toList(),
                onSelected: (entry) => setState(() {
                  updateMatrixValues(predefinedFilters[entry]);
                }),
              ),
              FlatButton(
                child: Container(
                  color: Colors.orange,
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(8),
                  child: Text('Bild speichern',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
                onPressed: writeContent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateMatrixValues(List<double> values) {
    assert(values.length == 20);
    assert(matrixValues != null);
    for (int i = 0; i < values.length; i++) {
      matrixValues[i].value = values[i];
    }
  }

  void writeContent(){
    final _imageSaver = ImageSaver();
    Future<void> saveAssetImage() async {
      final urls = [
        "assets/images/Flutter_icon.png",
      ];

      List<Uint8List> bytesList = [];
      for (final url in urls){
        final bytes = await rootBundle.load(url);
        bytesList.add(bytes.buffer.asUint8List());
      }

      final res = await _imageSaver.saveImages(imageBytes: bytesList);
    }
  }
}
