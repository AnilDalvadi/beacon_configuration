// ignore_for_file: deprecated_member_use, avoid_print, non_constant_identifier_name, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DeviceH1 extends StatefulWidget {
  DeviceH1({key, required this.device}) : super(key: key);
  var device;

  @override
  State<DeviceH1> createState() => _DeviceH1State();
}

class _DeviceH1State extends State<DeviceH1> {
  @override
  void initState() {
    super.initState();
    setState(() {
      widget.device.state.listen((s) async {
        if (s == BluetoothDeviceState.connected) {
          print('Device is already connected');
        } else {
          await widget.device.connect();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[]),
      ),
    );
  }
}
