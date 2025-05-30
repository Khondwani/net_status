import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:net_status/net_status.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _netStatusPlugin = NetStatus();
  String _connectionStatus = 'Unknown connection status';
  String _streamedStatus = 'Unknown streamed status';
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _netStatusPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    try {
      // Listen to network status changes
      _netStatusPlugin.connectivityStream.listen((isConnected) {
        setState(() {
          _streamedStatus = isConnected ? 'Connected' : 'Not Connected';
        });
      });
    } catch (e) {
      print('Error listening to network status changes: $e');
    }

    try {
      // Attempt to start listening for network status changes
      await _netStatusPlugin.startListening();
    } catch (e) {
      print('Error starting listening: $e');
    }
    try {
      // Check if the device is connected to the network
      _isConnected = await _netStatusPlugin.isConnected();
      setState(() {
        _connectionStatus = _isConnected ? 'Connected' : 'Not Connected';
      });
    } catch (e) {
      print('Error checking connection status: $e');
    }

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Column(
          children: [
            Text('Running on: $_platformVersion\n'),
            const SizedBox(height: 20),
            Text('Connection status: $_connectionStatus'),
            ElevatedButton(
              child: const Text('Click to Check Status'),
              onPressed: () {
                _netStatusPlugin
                    .isConnected()
                    .then((isConnected) {
                      // print('Is connected: $isConnected');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Is connected: $isConnected')),
                      );
                    })
                    .catchError((error) {
                      // print('Error checking connection status: $error');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error checking connection status: $error',
                          ),
                        ),
                      );
                    });
              },
            ),
            Text('Streamed status: $_streamedStatus'),
          ],
        ),
      ),
    );
  }
}
