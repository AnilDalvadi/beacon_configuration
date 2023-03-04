import 'dart:async';
import 'package:beacon/Home_Page.dart';
import 'package:beacon/Model/Scan_Device_Model.dart';
import 'package:beacon/Repository/Scan_Device_Repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue/gen/flutterblue.pb.dart' as ProtoBluetoothDevice;

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: Homepage());
  }
}

class AddDevice extends StatefulWidget {
  const AddDevice({Key? key}) : super(key: key);

  @override
  State<AddDevice> createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  @override
  void initState() {}

  late BluetoothCharacteristic Productmodel;
  late BluetoothCharacteristic Firmwareversion;
  late BluetoothCharacteristic Producttype;
  late BluetoothCharacteristic Softwareversion;
  late BluetoothCharacteristic Manufacturer;
  late BluetoothCharacteristic Password;
  late BluetoothCharacteristic Verification;

  String? word;
  var scandata;
  TextEditingController name = TextEditingController();
  TextEditingController password = TextEditingController(text: "Moko4321");
  Future<List<Device>> data = DeviceRepository.getData();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Scan Data'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: const [],
                builder: (c, snapshot) => Container(
                  child: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: snapshot.data!.map((result) {
                          var protoBt = ProtoBluetoothDevice.BluetoothDevice(
                            remoteId: result.device.id.toString(),
                          );
                          var connect = BluetoothDevice.fromProto(protoBt);

                          return ListTile(
                            minVerticalPadding: 10,
                            contentPadding: const EdgeInsets.all(0),
                            title: Text(result.device.name.toString()),
                            subtitle: Text(result.device.id.id.toString()),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                result.device != data
                                    ? ElevatedButton(
                                        onPressed: () async {},
                                        child: InkWell(
                                          onTap: () async {
                                            showDialog<String>(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  AlertDialog(
                                                title: TextFormField(
                                                  controller: name,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText:
                                                        'Enter your name',
                                                  ),
                                                ),
                                                content: TextFormField(
                                                  controller: password,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText:
                                                        'Enter your Password',
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () async {
                                                      await connect.connect();

                                                      List<BluetoothService>
                                                          services =
                                                          await connect
                                                              .discoverServices();
                                                      BluetoothService
                                                          servicedata = services
                                                              .firstWhere(
                                                                  (serv) {
                                                        if (serv.uuid
                                                                .toString() ==
                                                            '0000180a-0000-1000-8000-00805f9b34fb') {
                                                          return true;
                                                        } else {
                                                          return false;
                                                        }
                                                      });

                                                      Productmodel = servicedata
                                                          .characteristics
                                                          .firstWhere((ser) {
                                                        if (ser.uuid
                                                                .toString() ==
                                                            "00002a24-0000-1000-8000-00805f9b34fb") {
                                                          return true;
                                                        } else {
                                                          return false;
                                                        }
                                                      });
                                                      Firmwareversion =
                                                          servicedata
                                                              .characteristics
                                                              .firstWhere(
                                                                  (ser) {
                                                        if (ser.uuid
                                                                .toString() ==
                                                            "00002a26-0000-1000-8000-00805f9b34fb") {
                                                          return true;
                                                        } else {
                                                          return false;
                                                        }
                                                      });
                                                      Producttype = servicedata
                                                          .characteristics
                                                          .firstWhere((ser) {
                                                        if (ser.uuid
                                                                .toString() ==
                                                            "00002a27-0000-1000-8000-00805f9b34fb") {
                                                          return true;
                                                        } else {
                                                          return false;
                                                        }
                                                      });
                                                      Softwareversion =
                                                          servicedata
                                                              .characteristics
                                                              .firstWhere(
                                                                  (ser) {
                                                        if (ser.uuid
                                                                .toString() ==
                                                            "00002a28-0000-1000-8000-00805f9b34fb") {
                                                          return true;
                                                        } else {
                                                          return false;
                                                        }
                                                      });
                                                      Manufacturer = servicedata
                                                          .characteristics
                                                          .firstWhere((ser) {
                                                        if (ser.uuid
                                                                .toString() ==
                                                            "00002a29-0000-1000-8000-00805f9b34fb") {
                                                          return true;
                                                        } else {
                                                          return false;
                                                        }
                                                      });
                                                      BluetoothService service =
                                                          services.firstWhere(
                                                              (serv) {
                                                        if (serv.uuid
                                                                .toString() ==
                                                            '0000aa00-0000-1000-8000-00805f9b34fb') {
                                                          return true;
                                                        } else {
                                                          return false;
                                                        }
                                                      });
                                                      Verification = service
                                                          .characteristics
                                                          .firstWhere((ser) {
                                                        if (ser.uuid
                                                                .toString() ==
                                                            "0000aa00-0000-1000-8000-00805f9b34fb") {
                                                          return true;
                                                        } else {
                                                          return false;
                                                        }
                                                      });
                                                      List<int> data = [
                                                        0xED,
                                                        0x01,
                                                        0x01,
                                                        0x08
                                                      ];
                                                      List<int> finaldata =
                                                          data +
                                                              password.text
                                                                  .codeUnits;

                                                      await Verification.write(
                                                          finaldata);

                                                      var productmodel =
                                                          await Productmodel
                                                              .read();
                                                      var productmodeladd =
                                                          String.fromCharCodes(
                                                              productmodel);
                                                      var firmwareversion =
                                                          await Firmwareversion
                                                              .read();
                                                      var firmwareversionadd =
                                                          String.fromCharCodes(
                                                              firmwareversion);
                                                      var producttype =
                                                          await Producttype
                                                              .read();
                                                      var producttypeadd =
                                                          String.fromCharCodes(
                                                              producttype);
                                                      var softwareversion =
                                                          await Softwareversion
                                                              .read();
                                                      var softwareversionadd =
                                                          String.fromCharCodes(
                                                              softwareversion);
                                                      var manufacturer =
                                                          await Manufacturer
                                                              .read();
                                                      var manufactureradd =
                                                          String.fromCharCodes(
                                                              manufacturer);

                                                      await DeviceRepository.insert(Device(
                                                              name: result
                                                                  .device.name
                                                                  .toString(),
                                                              macaddress: result
                                                                  .device.id
                                                                  .toString(),
                                                              productmodel:
                                                                  productmodeladd
                                                                      .toString(),
                                                              manufacturer:
                                                                  manufactureradd
                                                                      .toString(),
                                                              firmwareversion:
                                                                  firmwareversionadd
                                                                      .toString(),
                                                              producttype:
                                                                  producttypeadd
                                                                      .toString(),
                                                              softwareversion:
                                                                  softwareversionadd
                                                                      .toString(),
                                                              password: password
                                                                  .text))
                                                          .then((value) =>
                                                              print("Added"));
                                                      await connect
                                                          .disconnect();
                                                      FlutterBlue.instance
                                                          .stopScan();

                                                      Navigator.of(context)
                                                          .pushReplacement(
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          const Homepage()));
                                                    },
                                                    child: const Text('Submit'),
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                          child: const Text('Add'),
                                        ),
                                      )
                                    : Container(),
                                const SizedBox(
                                  width: 15,
                                ),
                              ],
                            ),
                          );
                        }).toList()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
