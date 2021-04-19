import 'dart:async';
import 'dart:convert' show utf8;
import 'package:control_pad/models/pad_button_item.dart';
import 'package:control_pad/control_pad.dart';
import 'package:control_pad/models/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_joypad_ble/page1.dart';
import 'package:flutter_app_joypad_ble/page2.dart';
import 'package:flutter_blue/flutter_blue.dart';

Future<void> main() async {
 WidgetsFlutterBinding.ensureInitialized();
  runApp(MainScreen());
}

class MainScreen extends StatelessWidget {
 
  @override
  
  
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motor Control',
      debugShowCheckedModeBanner: false,
      home: JoyPad(),
      theme: ThemeData.light(),
    );
    
  }
}

class JoyPad extends StatefulWidget {
  @override
  _JoyPadState createState() => _JoyPadState();
}


class _JoyPadState extends State<JoyPad> {
  final String SERVICE_UUID = "eb36d2c8-e3da-41f7-8120-2664c83fa432";
  final String CHARACTERISTIC_UUID = "433d109a-a336-4479-bfa5-7c29097d65ca";
  final String TARGET_DEVICE_NAME = "Kutar bilisim";

  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription<ScanResult> scanSubScription;

  BluetoothDevice targetDevice;
  BluetoothCharacteristic targetCharacteristic;
  BluetoothDescriptor descriptor;
  String connectionText = "";

  @override
  void initState() {
    super.initState();
    startScan();
  }

  startScan() {
    setState(() {
      connectionText = "Tarama yapılıyor";
    });

    scanSubScription = flutterBlue.scan().listen((scanResult) {
      if (scanResult.device.name == TARGET_DEVICE_NAME) {
        print('Cihazlar bulundu');
        stopScan();
        setState(() {
          connectionText = "Hedef cihaz bulundu";
        });

        targetDevice = scanResult.device;
        connectToDevice();
      }
    }, onDone: () => stopScan());
  }

  stopScan() {
    scanSubScription?.cancel();
    scanSubScription = null;
  }

  connectToDevice() async {
    if (targetDevice == null) return;

    setState(() {
      connectionText = "Cihaz Bağlanılıyor...";
    });

    await targetDevice.connect();
    print('Cihaz Bağlandı');
    setState(() {
      connectionText = "Cihaz Bağlandı";
    });

    discoverServices();
  }

  disconnectFromDevice() {
    if (targetDevice == null) return;

    targetDevice.disconnect();

    setState(() {
      connectionText = "Cihaz bağlantısı koptu..";
    });
  }

  discoverServices() async {
    if (targetDevice == null) return;

    List<BluetoothService> services = await targetDevice.discoverServices();
    services.forEach((service) {
      // do something with service
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
            targetCharacteristic = characteristic;
            writeData(" ESP32!!");
            setState(() {
              connectionText = "Bağlı olan cihazlar: ${targetDevice.name}";
            });
          }
        });
      }
    });
  }
  
  writeData(String data) {
    if (targetCharacteristic == null) return;

    List<int> bytes = utf8.encode(data);
    targetCharacteristic.write(bytes);
  }
 
  @override
  Widget build(BuildContext context) {
    JoystickDirectionCallback onDirectionChanged(
        double degrees, double distance) {
      String data =
          "Derece: ${degrees.toStringAsFixed(2)}, Uzaklık : ${distance.toStringAsFixed(2)}";
      print(data);
      writeData(data);
    }

    PadButtonPressedCallback padBUttonPressedCallback(
        int buttonIndex, Gestures gesture) {
      String data = "Button : ${buttonIndex}";
      print(data);
      writeData(data);
    }
 
    return Scaffold(
      appBar: AppBar(
        title: Text(connectionText),
        actions:<Widget> [
          PopupMenuButton(itemBuilder: (content)=>[
            PopupMenuItem(
value: 1,
child: Text("Sensorler"),
            ),
                        PopupMenuItem(
value: 2,
child: Text("Komut"),

            ), 
          ],
          onSelected: (int menu){
            if(menu ==1){
           Navigator.push((context), MaterialPageRoute(
             builder: (context)=>Page1()));
            }
            else if(menu ==2){
           Navigator.push((context), MaterialPageRoute(
             builder: (context)=>page2()));
            }
          },
          ),
        ],
      ),
        
  
  
      body: Container(
        
        child: targetCharacteristic == null
            ? Center(
                child: Text(
                  "Bekleniyor...",
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
              )
              
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
  ElevatedButton(
	
    child: Text('fmobey.com'),
	
    onPressed: () {
	
      print('Pressed');
	
    },
	
  ),

	
                  JoystickView(
                    
                    onDirectionChanged: onDirectionChanged,
                  ),
                  
                  PadButtonsView(
                    
                       buttons: [ 
      PadButtonItem(index: 361, buttonText: "180",pressedColor: Colors.black45),
      PadButtonItem(index: 362, buttonText: "60", pressedColor: Colors.black45),
      PadButtonItem(index: 363, buttonText: "30", pressedColor: Colors.black45),
      PadButtonItem(index: 364, buttonText: "15", pressedColor: Colors.black45),
    ],
                  
                    padButtonPressedCallback: padBUttonPressedCallback,
                  ),
                 
                    PadButtonsView(
                    
                    
       buttons: [ 
      PadButtonItem(index: 365, buttonText: "RIGHT",pressedColor: Colors.black45),
      PadButtonItem(index: 366, buttonText: "-", pressedColor: Colors.black45),
      PadButtonItem(index: 367, buttonText: "LEFT", pressedColor: Colors.black45),
      PadButtonItem(index: 368, buttonText: "+", pressedColor: Colors.black45),
    ],
    
                    
                    padButtonPressedCallback: padBUttonPressedCallback,
                  ),
                  	

                ],
                
              ),
              
              
              
      ),
      
    );
    
  }
}
