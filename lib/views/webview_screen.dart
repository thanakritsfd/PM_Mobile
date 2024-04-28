// ignore_for_file: use_super_parameters, avoid_single_cascade_in_expression_statements, avoid_print, prefer_const_constructors, use_build_context_synchronously, empty_catches

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:io';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({Key? key}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    FlutterDownloader.initialize();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..loadRequest(Uri.parse('https://pmstation.org/pm/'))
      ..addJavaScriptChannel(
        'exportUrl',
        onMessageReceived: (JavaScriptMessage message) async {
          final exportUrl = message.message;
          print('Received exportUrl: $exportUrl');
          String fileName = 'exported_data'; // ตั้งชื่อไฟล์เริ่มต้น
          int count = 1; // เลขลำดับเริ่มต้น
          // ตรวจสอบว่ามีไฟล์ที่มีชื่อซ้ำอยู่แล้วหรือไม่
          while (await File('/storage/emulated/0/Download/${fileName}_$count.xlsx').exists()) {
            count++; // เพิ่มเลขลำดับ
          }
          // สร้างชื่อไฟล์ใหม่โดยเพิ่มเลขลำดับลงไป
          String newFileName = '${fileName}_$count.xlsx';
          try {
            await FlutterDownloader.enqueue(
              url: exportUrl,
              savedDir: '/storage/emulated/0/Download/',
              fileName: newFileName,
              showNotification: true,
              openFileFromNotification: true,
            );
          } catch (error) {}
        },
      );

    _controller.clearCache(); // Clear WebView cache
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        child: Column(
          children: [
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}
