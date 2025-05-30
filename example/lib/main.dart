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

    platformVersion =
        await _netStatusPlugin.getPlatformVersion() ??
        'Unknown platform version';
    setState(() {
      _platformVersion = platformVersion;
    });

    _netStatusPlugin.connectivityStream.listen((isConnected) {
      setState(() {
        _streamedStatus = isConnected ? 'Connected' : 'Not Connected';
      });
    });

    _isConnected = await _netStatusPlugin.isConnected();
    setState(() {
      _connectionStatus = _isConnected ? 'Connected' : 'Not Connected';
    });
    await _netStatusPlugin.startListening();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Net Status App')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Running on: $_platformVersion'),
              const SizedBox(height: 20),
              Text('Connection status: $_connectionStatus'),
              ElevatedButton(
                child: const Text('Click to Check Status'),
                onPressed: () async {
                  _isConnected = await _netStatusPlugin.isConnected();
                  setState(() {
                    _connectionStatus =
                        _isConnected ? 'Connected' : 'Not Connected';
                  });
                },
              ),
              Text('Streamed status: $_streamedStatus'),
            ],
          ),
        ),
      ),
    );
  }
}
