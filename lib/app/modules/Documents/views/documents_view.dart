import 'package:courier/app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/documents_controller.dart';

class DocumentsView extends GetView<DocumentsController> {
  const DocumentsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaterialTheme.blueColorScheme().primary,
      appBar: AppBar(
        backgroundColor: MaterialTheme.blueColorScheme().secondary,
        title: const Text('Documents'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'All documents images',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
