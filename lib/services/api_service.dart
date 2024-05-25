import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/album.dart';
import '../models/photo.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String cacheKeyAlbums = 'cached_albums';
  static const String cacheKeyPhotos = 'cached_photos';
  static const String cacheKeyPosts = 'cached_posts';
  static const String cacheKeyComments = 'cached_comments';
  static const String cacheKeyUserProfile = 'cached_user_profile';

  Future<List<Album>> fetchAlbums(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(cacheKeyAlbums);

    if (cachedData != null) {
      Iterable jsonResponse = json.decode(cachedData);
      return jsonResponse.map((album) => Album.fromJson(album)).toList();
    } else {
      final response = await http.get(Uri.parse('$baseUrl/albums?userId=$userId'));
      if (response.statusCode == 200) {
        Iterable jsonResponse = json.decode(response.body);
        await prefs.setString(cacheKeyAlbums, response.body);
        return jsonResponse.map((album) => Album.fromJson(album)).toList();
      } else {
        throw Exception('Failed to load albums');
      }
    }
  }

  Future<List<Photo>> fetchPhotos(int albumId) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('$cacheKeyPhotos-$albumId');

    if (cachedData != null) {
      Iterable jsonResponse = json.decode(cachedData);
      return jsonResponse.map((photo) => Photo.fromJson(photo)).toList();
    } else {
      final response = await http.get(Uri.parse('$baseUrl/photos?albumId=$albumId'));
      if (response.statusCode == 200) {
        Iterable jsonResponse = json.decode(response.body);
        await prefs.setString('$cacheKeyPhotos-$albumId', response.body);
        return jsonResponse.map((photo) => Photo.fromJson(photo)).toList();
      } else {
        throw Exception('Failed to load photos');
      }
    }
  }

  Future<List<Post>> fetchPosts(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(cacheKeyPosts);

    if (cachedData != null) {
      Iterable jsonResponse = json.decode(cachedData);
      return jsonResponse.map((post) => Post.fromJson(post)).toList();
    } else {
      final response = await http.get(Uri.parse('$baseUrl/posts?userId=$userId'));
      if (response.statusCode == 200) {
        Iterable jsonResponse = json.decode(response.body);
        await prefs.setString(cacheKeyPosts, response.body);
        return jsonResponse.map((post) => Post.fromJson(post)).toList();
      } else {
        throw Exception('Failed to load posts');
      }
    }
  }

  Future<List<Comment>> fetchComments(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('$cacheKeyComments-$postId');

    if (cachedData != null) {
      Iterable jsonResponse = json.decode(cachedData);
      return jsonResponse.map((comment) => Comment.fromJson(comment)).toList();
    } else {
      final response = await http.get(Uri.parse('$baseUrl/comments?postId=$postId'));
      if (response.statusCode == 200) {
        Iterable jsonResponse = json.decode(response.body);
        await prefs.setString('$cacheKeyComments-$postId', response.body);
        return jsonResponse.map((comment) => Comment.fromJson(comment)).toList();
      } else {
        throw Exception('Failed to load comments');
      }
    }
  }

  Future<User> fetchUserProfile(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(cacheKeyUserProfile);

    if (cachedData != null) {
      return User.fromJson(json.decode(cachedData));
    } else {
      final response = await http.get(Uri.parse('$baseUrl/users?id=$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          await prefs.setString(cacheKeyUserProfile, response.body);
          return User.fromJson(jsonResponse[0]);
        } else {
          throw Exception('User not found');
        }
      } else {
        throw Exception('Failed to load user profile');
      }
    }
  }
}
