// ignore_for_file: must_be_immutable, avoid_print, non_constant_identifier_names, library_prefixes, prefer_typing_uninitialized_variables
import 'package:beacon/Add_Device.dart';
import 'package:beacon/Device_H1.dart';
import 'package:beacon/Model/Scan_Device_Model.dart';
import 'package:beacon/Repository/Scan_Device_Repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue/gen/flutterblue.pb.dart' as ProtoBluetoothDevice;
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:permission_handler/permission_handler.dart';

class Homepage extends StatefulWidget {
  const Homepage({
    key,
  }) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late BluetoothCharacteristic Poweron;
  late BluetoothCharacteristic Password;
  late BluetoothCharacteristic Verification;
  bool _switchValue = false;
  late MqttServerClient client;
  List datalist = [];
  var macadd;
  var voltage;
  var connect;
  var current;
  var activePower;
  var powerFactor;
  var currentFrequency;
  var historicalTotalEnergy;
  var bleTxPower;
  List<int> switchstatus = [];
  var Id;
  @override
  void initState() {
    super.initState();

    setState(() {
      DeviceRepository.getData();
      test();
    });
  }

  test() {
    FlutterBlue.instance.startScan(allowDuplicates: true);
    FlutterBlue.instance.scanResults.listen((event) {
      event.forEach(
        (var test) {
          var ManufacturerDataList = [];
          test.advertisementData.manufacturerData
              .forEach((k, v) => ManufacturerDataList = v);
          setState(() {
            datalist = ManufacturerDataList.map((num) => num.toRadixString(16))
                .toList();

            if (test.device.name == "117B-4D44") {
              macadd = datalist
                  .sublist(0, 6)
                  .map((byte) => byte.padLeft(2, '0'))
                  .join(':');

              voltage = int.parse(datalist[6] + datalist[7], radix: 16) * 0.1;

              current = int.parse(datalist[8] + datalist[9], radix: 16) * 0.1;
              activePower = int.parse(
                      datalist[10] + datalist[11] + datalist[12] + datalist[13],
                      radix: 16) *
                  0.1;
              powerFactor = int.parse(datalist[14], radix: 16) * 1;
              currentFrequency =
                  int.parse(datalist[15] + datalist[16], radix: 16) * 0.01;
              historicalTotalEnergy = int.parse(
                      datalist[17] + datalist[18] + datalist[19] + datalist[20],
                      radix: 16) *
                  0.01;
              bleTxPower = datalist[21];

              List<int> byteToBits(int byte) {
                List<int> bits = [];
                for (int i = 7; i >= 0; i--) {
                  bits.add((byte & (1 << i)) >> i);
                }
                return bits;
              }

              var data = int.parse(datalist[22], radix: 16);

              switchstatus = byteToBits(data);
              if (switchstatus[0] == 1) {
                setState(() {
                  _switchValue = true;
                });
              } else {
                setState(() {
                  _switchValue = false;
                });
              }
            }
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: _switchValue == true
              ? const Text("Connected")
              : const Text("Disconnected"),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SingleChildScrollView(
                  child: SizedBox(
                height: 450,
                width: 500,
                child: FutureBuilder(
                  future: DeviceRepository.getData(),
                  builder: (context, AsyncSnapshot<List<Device>> snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                          itemCount: snapshot.data!.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            var protoBt = ProtoBluetoothDevice.BluetoothDevice(
                              remoteId:
                                  snapshot.data![index].macaddress.toString(),
                            );
                            connect = BluetoothDevice.fromProto(protoBt);
                            Id = snapshot.data![index].name;
                            return Card(
                              child: ListTile(
                                minVerticalPadding: 10,
                                contentPadding: const EdgeInsets.all(0),
                                leading: Padding(
                                    padding: const EdgeInsets.all(
                                        15), //apply padding to all four sides
                                    child: Text('${index + 1}')),
                                title:
                                    Text(snapshot.data![index].name.toString()),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('MAC address: $macadd'),
                                    Text(
                                        'Voltage: ${voltage != null ? double.parse(voltage.toStringAsFixed(5)) : "0"} V'),
                                    Text(
                                        'Current: ${current != null ? double.parse(current.toStringAsFixed(2)) : "0"} mA'),
                                    Text(
                                        'Active power: ${activePower != null ? double.parse(activePower.toStringAsFixed(2)) : "0"} W'),
                                    Text(
                                        'Power factor: ${powerFactor ?? "0"} %'),
                                    Text(
                                        'Current frequency: ${currentFrequency != null ? double.parse(currentFrequency.toStringAsFixed(3)) : "0"} Hz'),
                                    Text(
                                        'Historical total energy: ${historicalTotalEnergy ?? "0"} KWh'),
                                    Text('BLE TX power: ${bleTxPower ?? "0"}'),
                                    Text(
                                        "Switch Status:${switchstatus.isNotEmpty ? switchstatus[0] == 1 ? "On" : "Off" : "Off"}"),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (snapshot.data![index].productmodel ==
                                            "MK117B" ||
                                        snapshot.data![index].productmodel ==
                                            "MK117NB")
                                      Switch(
                                        value: _switchValue,
                                        onChanged: (bool newValue) async {
                                          setState(() {
                                            _switchValue = newValue;
                                          });

                                          await connect.connect();

                                          connect.state.listen((event) async {
                                            if (event ==
                                                BluetoothDeviceState
                                                    .connected) {
                                              List<BluetoothService> services =
                                                  await connect
                                                      .discoverServices();

                                              BluetoothService service =
                                                  services.firstWhere((serv) {
                                                if (serv.uuid.toString() ==
                                                    '0000aa00-0000-1000-8000-00805f9b34fb') {
                                                  return true;
                                                } else {
                                                  return false;
                                                }
                                              });

                                              Password = service.characteristics
                                                  .firstWhere((ser) {
                                                if (ser.uuid.toString() ==
                                                    "0000aa03-0000-1000-8000-00805f9b34fb") {
                                                  return true;
                                                } else {
                                                  return false;
                                                }
                                              });

                                              Verification = service
                                                  .characteristics
                                                  .firstWhere((ser) {
                                                if (ser.uuid.toString() ==
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
                                              await Verification.write(
                                                  data +
                                                      snapshot.data![index]
                                                          .password!.codeUnits,
                                                  withoutResponse: true);

                                              if (_switchValue == true) {
                                                List<int> switchstatuson = [
                                                  0xED,
                                                  0x01,
                                                  0x51,
                                                  0x01,
                                                  0x01
                                                ];
                                                await Password.write(
                                                    switchstatuson);
                                                await Password.setNotifyValue(
                                                    true);
                                                await connect.disconnect();
                                              } else {
                                                List<int> switchstatusoff = [
                                                  0xED,
                                                  0x01,
                                                  0x51,
                                                  0x01,
                                                  0x00
                                                ];
                                                await Password.write(
                                                    switchstatusoff);
                                                await Password.setNotifyValue(
                                                    true);
                                                await connect.disconnect();
                                              }
                                            }
                                          });
                                        },
                                      ),
                                    InkWell(
                                      onTap: () async {
                                        if (snapshot
                                                .data![index].productmodel ==
                                            "MK117B") {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DeviceH1(
                                                          device: connect)));
                                        }
                                        if (snapshot
                                                .data![index].productmodel ==
                                            "MK117NB") {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const AddDevice()));
                                        }
                                      },
                                      child: const Icon(
                                        Icons.settings,
                                        color: Colors.black,
                                        size: 35,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 25,
                                    ),
                                    InkWell(
                                      onTap: () => showDialog<String>(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          title: const Text('Please Confirm'),
                                          content: const Text(
                                              'Are you sure to remove this Beacon'),
                                          actions: [
                                            TextButton(
                                              onPressed: () async {
                                                setState(() {
                                                  DeviceRepository.delete(
                                                      snapshot.data![index].id);
                                                });
                                                await connect.disconnect();
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Yes'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('No'),
                                            )
                                          ],
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.delete_forever,
                                        color: Colors.red,
                                        size: 35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              )),
              ElevatedButton(
                  onPressed: () async {
                    if (await Permission.location.request().isGranted == true &&
                        await Permission.bluetoothScan.request().isGranted ==
                            true &&
                        await Permission.bluetooth.request().isGranted ==
                            true &&
                        await Permission.bluetoothAdvertise
                                .request()
                                .isGranted ==
                            true &&
                        await Permission.bluetoothConnect.request().isGranted ==
                            true) {
                      FlutterBlue.instance.stopScan();
                      // FlutterBlue.instance
                      //     .startScan(timeout: const Duration(seconds: 2));
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const AddDevice()));
                    }
                  },
                  child: const Text('Add Device')),
            ],
          ),
        ),
      ),
    );
  }
}
