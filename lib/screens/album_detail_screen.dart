import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/photo.dart';

class AlbumDetailsScreen extends StatelessWidget {
  final int albumId;

  AlbumDetailsScreen({required this.albumId});

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final Future<List<Photo>> photos = apiService.fetchPhotos(albumId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Album Details'),
      ),
      body: FutureBuilder<List<Photo>>(
        future: photos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No photos found'));
          } else {
            return GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final photo = snapshot.data![index];
                return PhotoCard(photo: photo);
              },
            );
          }
        },
      ),
    );
  }
}

class PhotoCard extends StatelessWidget {
  final Photo photo;

  PhotoCard({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 150.0, // Fixed height for the image
            child: Image.network(
              photo.url,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Text(
              photo.title,
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
