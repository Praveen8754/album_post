import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import 'album_screen.dart';
import 'posts_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  User? _user;
  String? _location;
  String? _error;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchLocation();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      User user = await apiService.fetchUserProfile(1);
      setState(() {
        _user = user;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch user profile';
      });
      print('Error fetching user profile: $e');
    }
  }

  Future<void> _fetchLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _location = 'Location services are disabled.';
        });
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _location = 'Location permissions are denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _location = 'Location permissions are permanently denied, we cannot request permissions.';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Translate coordinates to address
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];

      setState(() {
        _location = '${place.locality}, ${place.postalCode}, ${place.country}';
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch location';
      });
      print('Error fetching location: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: _user == null && _error == null
          ? Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _image == null ? null : FileImage(_image!),
                  child: _image == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_user!.name!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(_user!.username!),
                      Text(_user!.email!),
                      Text(_user!.address!.city. toString()),
                      Text(_user!.address!.geo!.lat . toString()),
                      Text(_user!.address!.geo!.lng . toString()),
                      Text(_user!.address!.zipcode. toString()),
                      Text(_user!.phone!),
                      Text(_user!.website!),
                      Text(_user!.company!.bs. toString()),
                      Text(_user!.company!.catchPhrase. toString()),
                      Text(_user!.company!.name. toString()),
                      Text(_location ?? 'Fetching location...'),
                    ],
                  ),
                ),
                PopupMenuButton<ImageSource>(
                  onSelected: (ImageSource source) {
                    _pickImage(source);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: ImageSource.camera,
                      child: Text("Capture Photo"),
                    ),
                    const PopupMenuItem(
                      value: ImageSource.gallery,
                      child: Text("Select from Gallery"),
                    ),
                  ],
                  icon: const Icon(Icons.camera_alt),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlbumsScreen()),
                );
              },
              child: const Text('My Albums'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostsScreen()),
                );
              },
              child: const Text('My Posts'),
            ),
          ],
        ),
      ),
    );
  }
}
