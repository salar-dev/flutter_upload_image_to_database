import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'model/server.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? image;
  bool _isLoading = false;
  Uint8List? decodedBytes;

  List _images = [];

  Future<void> _getPosts() async {
    setState(() {
      _isLoading = true;
    });
    await Services.getAllPosts().then((posts) {
      setState(() {
        _images = posts;
        _isLoading = false;
      });
    });
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemporary = File(image.path);
      setState(() {
        this.image = imageTemporary;
        ConvertImage(imageTemporary);
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future ConvertImage(File image) async {
    Uint8List imageBytes = await image.readAsBytes(); //convert to bytes
    String base64string =
        base64.encode(imageBytes); //convert bytes to base64 string
    _addPost(base64string);
  }

  _createTable() {
    Services.createTable().then((result) {
      if ('success' == result) {
        print('success to create table');
      } else {
        print('failed to create table');
      }
    });
  }

  _addPost(String imageCode) async {
    setState(() {
      _isLoading = true;
    });
    await Services.addImage(
      imageCode,
    ).then((result) {
      if ('success' == result) {
        _getPosts();
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Row(
              children: const [
                Icon(Icons.thumb_up, color: Colors.white),
                Text(
                  'تم اضافة الصورة',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _createTable();
    _getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          pickImage();
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text('Image Cloud'),
        actions: [
          _isLoading
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : Container(),
        ],
      ),
      body: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5.0,
            mainAxisSpacing: 5.0,
          ),
          itemCount: _images.length,
          itemBuilder: (context, index) {
            return Container(
                child: Image.memory(
              base64Decode(_images[index].imageString),
                  fit: BoxFit.cover,
            ));
          }),
    );
  }
}
