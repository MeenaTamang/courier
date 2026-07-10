import 'package:courier/app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DocumentsView extends StatefulWidget {
  final String? licenseImagePath;
  final String? nidImagePath;
  final String? vehicleImagePath;
  final String? authToken; // Pass in your JWT/auth token here

  const DocumentsView({
    super.key,
    this.licenseImagePath,
    this.nidImagePath,
    this.vehicleImagePath,
    this.authToken,
  });

  // Root of your server, NOT the API route.
  // Static files (images/uploads/...) are served relative to this.
  static const String baseUrl = 'https://barley-chimp-girdle.ngrok-free.dev/';

  @override
  State<DocumentsView> createState() => _DocumentsViewState();
}

class _DocumentsViewState extends State<DocumentsView> {
  late String? licensePath;
  late String? nidPath;
  late String? vehiclePath;

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    licensePath = widget.licenseImagePath;
    nidPath = widget.nidImagePath;
    vehiclePath = widget.vehicleImagePath;
  }

  Future<void> _onRefresh() async {
    // Since this screen is populated via navigation arguments,
    // You'd normally re-fetch data here if API was available.
    // For now, we'll just simulate a state refresh.

    await Future.delayed(const Duration(seconds: 1)); // simulate network delay

    setState(() {
      // In real usage, refetch or update state here.
      licensePath = widget.licenseImagePath;
      nidPath = widget.nidImagePath;
      vehiclePath = widget.vehicleImagePath;
    });

    _refreshController.refreshCompleted();
  }

  // Builds the headers sent with every image request.
  Map<String, String> get _imageHeaders {
    final headers = <String, String>{
      'ngrok-skip-browser-warning': 'Meena',
    };
    if (widget.authToken != null && widget.authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${widget.authToken}';
    }
    return headers;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasLicense = licensePath != null && licensePath!.isNotEmpty;
    final bool hasNid = nidPath != null && nidPath!.isNotEmpty;
    final bool hasVehicle = vehiclePath != null && vehiclePath!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MaterialTheme.blueColorScheme().secondary,
        title: const Text('Documents'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/firstLayer.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("License Image:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildImageWidget(hasLicense ? '${DocumentsView.baseUrl}$licensePath' : null),

                  const SizedBox(height: 24),
                  const Text("National ID Image:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildImageWidget(hasNid ? '${DocumentsView.baseUrl}$nidPath' : null),

                  const SizedBox(height: 24),
                  const Text("Vehicle Registration Image:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildImageWidget(hasVehicle ? '${DocumentsView.baseUrl}$vehiclePath' : null),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String? imageUrl) {
    if (imageUrl == null) {
      return const Text("No Image Found", style: TextStyle(color: Colors.red));
    }

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: Image.network(
        imageUrl,
        headers: _imageHeaders,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // TEMP: remove this print once things are working,
          // but keep it for now to see the real cause of failure
          // (404, 401, CORS, malformed URL, etc.)
          debugPrint('Image load error for $imageUrl: $error');
          return const Center(
            child: Text("Failed to load image", style: TextStyle(color: Colors.red)),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}