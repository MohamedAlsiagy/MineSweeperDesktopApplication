import 'package:flutter/material.dart';
import 'package:libserialport/libserialport.dart';
import 'package:minesweeper/mainPages/controlPage.dart';
import 'package:minesweeper/utilities/color.dart';

class mainPage extends StatefulWidget {
  const mainPage({Key? key}) : super(key: key);

  @override
  State<mainPage> createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  late List<String> availablePorts;

  List<Widget> generateAvailablePortsList() {
    isPressed(String comName) {
      final config = SerialPortConfig();
      config.baudRate = 2000000;
      config.bits = 8;
      config.parity = 0;
      config.stopBits = 255;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return ControlPage(port: comName, config: config);
        },
      ));
    }

    return availablePorts
        .map(
          (com) => Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor.shade300,
                  foregroundColor: Colors.black),
              onPressed: () {
                isPressed(com);
              },
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(com),
                      // Text(
                      //     ('Manufacturer : ${SerialPort(com).manufacturer}')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  Widget listIsEmpty() => const Center(
        child: Text(
          "No Available ports",
          style: TextStyle(fontSize: 20),
        ),
      );

  Widget listIsNotEmpty() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: primaryColor.shade600,
            padding: const EdgeInsets.all(10),
            child: const Text(
              "Available Ports : ",
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: primaryColor,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: generateAvailablePortsList(),
                ),
              ),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    // availablePorts = SerialPort.availablePorts;
    availablePorts = ["COM4"];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor.shade800,
        title: const Text("Mine Sweeper"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: availablePorts.isEmpty ? listIsEmpty() : listIsNotEmpty(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor.shade800,
        child: const Icon(Icons.undo),
        onPressed: () {
          availablePorts.clear();
          setState(() {});
        },
      ),
    );
  }
}
