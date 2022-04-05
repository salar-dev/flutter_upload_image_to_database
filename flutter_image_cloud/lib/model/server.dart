import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'image.dart';

class Services {
  static var url = Uri.parse('************');

  static const _CREATE_TABLE_ACTION = 'CREATE_TABLE';
  static const _ADD_IMAGE_ACTION = 'ADD_IMAGE';
  static const _GET_ALL_IMAGES_ACTION = 'GET_ALL';

  //Method to create table
  static Future<String> createTable() async {
    try {
      var map = <String, dynamic>{};
      map['action'] = _CREATE_TABLE_ACTION;
      final response = await http.post(url, body: map);
      if (kDebugMode) {
        print('Create table response: ${response.body}');
      }
      if (200 == response.statusCode) {
        return response.body;
      } else {
        return 'error';
      }
    } catch (e) {
      return 'error';
    }
  }

  //Method to add Image
  static Future<String> addImage(String imageString) async {
    try {
      var map = <String, dynamic>{};
      map['action'] = _ADD_IMAGE_ACTION;
      map['image_code'] = imageString;
      final response = await http.post(url, body: map);
      print('ADD Post Response: ${response.body}');
      if (200 == response.statusCode) {
        return response.body;
      } else {
        return 'error';
      }
    } catch (e) {
      return 'error';
    }
  }

  // Method to show Images
  static Future<List<Images>> getAllPosts() async {
    try {
      var map = <String, dynamic>{};
      map['action'] = _GET_ALL_IMAGES_ACTION;
      final response = await http.post(url, body: map);
      if (kDebugMode) {
        // print('Get All Posts: ${response.body}');
      }
      if (200 == response.statusCode) {
        List<Images> list = parseResponse(response.body);
        return list;
      }
    } catch (e) {
      return <Images>[];
    }
    return getAllPosts();
  }

  static List<Images> parseResponse(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Images>((json) => Images.fromJson(json)).toList();
  }
}
