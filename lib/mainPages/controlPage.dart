// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:libserialport/libserialport.dart';
import 'package:minesweeper/auxiliaryWidgets/keyPreview.dart';
import 'package:minesweeper/utilities/mathematical_model.dart';
import 'package:minesweeper/utilities/robotSpacialData.dart';

import '../utilities/color.dart';
import '../utilities/constants.dart';
import '../utilities/incData.dart';
import '../utilities/robot.dart';
import '../utilities/tile.dart';

class ControlPage extends StatefulWidget {
  final String port;
  final SerialPortConfig config;

  const ControlPage({Key? key, required this.port, required this.config})
      : super(key: key);

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  //Setup variables - Serial related
  late SerialPort port;
  late Stream<String> upcommingData;
  late SerialPortReader reader;
  late bool isReaderClosed;
  late bool isConnected;

  //visual related variables
  late double height;
  late double width;
  final double allScreenPadding = 10;
  final double robotSizeComparedToCell = 1;
  late ScrollController _scrollController;
  late SpacialData pastRobotSpacialData;
  late double smallestSize;
  late double visualRobotSize;

  //data variables
  List<String> dataReceived = [];
  int threshold = 5;

  //map details consts
  final int numberOfGrids = 19;

  //TODO : leave one one number of grids only here or the tile folder
  //TODO : leave one one number of grids only here or the tile folder
  // final double tileLength = 10; //is found as tile const static attribute
  final double gridSpacing = 2;

  //mapping details variables
  late List<Tile> grid; //map
  late Postion onGridPostion;

  // late double tileEquivalentLengthOfPixels; // TODO: Is modified in the initializer.
  Robot robot = Robot(
    name: "3anter",
    spacialData: SpacialData(
      postion: Postion(x: 0.0, y: 0.0), // TODO: Is modified in the initializer.
      angle: pi / 2,
    ),
  ); // starting at (0,0) - angle 90

  //TODO : Adding delays in control the robot for better tracking and accounting for reversing direction issue
  //TODO : Adding delays in control the robot for better tracking and accounting for reversing direction issue
  //TODO : Adding delays in control the robot for better tracking and accounting for reversing direction issue
  //TODO : Adding delays in control the robot for better tracking and accounting for reversing direction issue
  //TODO : Adding delays in control the robot for better tracking and accounting for reversing direction issue
  //TODO : Adding delays in control the robot for better tracking and accounting for reversing direction issue
  //TODO : Adding delays in control the robot for better tracking and accounting for reversing direction issue

  Uint8List _stringToUint8List(String data) {
    List<int> codeUnits = data.codeUnits;
    Uint8List uint8List = Uint8List.fromList(codeUnits);
    return uint8List;
  }

  // Serial related Methods
  void portWrite(String string) {
    try {
      int count = port.write(_stringToUint8List(string));
      print("Written bytes :$count");
      if (count == string.length) dataReceived.add("Sent : $string");
    } on SerialPortError catch (err, _) {
      print("Error Happened : ${SerialPort.lastError}");
    }
  }

  void startListener() {
    try {
      reader = SerialPortReader(port);
      isReaderClosed = false;
      upcommingData = reader.stream.map((data) => String.fromCharCodes(data));
      upcommingData.listen((data) {
        print(data);
        dataReceived.add(data);
        setState(() {});
      });
    } on SerialPortError catch (err, _) {
      print("Error Happened : ${SerialPort.lastError}");
    }
  }

  void startPort() {
    port = SerialPort(widget.port);
    port.config = widget.config;
    port.openReadWrite();
    isConnected = true;
  }

  // _scrollListener() {
  //   setState(() {
  //     _scrollPosition = _scrollController.position.pixels;
  //   });
  // }

  @override
  void initState() {
    startPort();
    Tile.numberOfGrids = numberOfGrids;
    grid = List.generate(
        pow(numberOfGrids, 2).toInt(),
        (index) => Tile.fromIndex(
              index: index,
              mineType: MineTypes.safe,
              numberOfGrids: numberOfGrids,
            ));

    for (int i = 0; i < 10; i++) {
      grid[Random().nextInt(pow(numberOfGrids, 2).toInt())]
          .setMineType(MineTypes.values[Random().nextInt(2) + 1]);
    }
    print(Tile.minePlaces);
    //set the intial postion of the single child scroll widget
    // _scrollController.position
    //     .setPixels(200);
    //TODO
    _scrollController = ScrollController();
    // _scrollController.addListener(_scrollListener);
    startListener();
    super.initState();
    // // TODO : PLAY and TESTING
    // robot.spacialData =
    //     SpacialData(postion: Postion(x: 1, y: 4), angle: pi / 2);
    // setState(() {});
    // Timer.periodic(const Duration(milliseconds: 50), (timer) {
    //   setRobotSpacialData(
    //       spacialData: analyzingIncomingData(IncomingData(
    //     n1: 7,
    //     n2: 8,
    //     isRightDirectionPositive: true,
    //     isLeftDirectionPositive: true,
    //   )));
    //   setState(() {});
    // });
    // dataReceived = ["adf", "afs ", 'afdpm'];
  }

  // Mapping related methods
  Color colorOfMine(MineTypes mineType) {
    switch (mineType) {
      case MineTypes.surfaceMine:
        {
          return Colors.red.shade800;
        }
      case MineTypes.underGroundMine:
        {
          return Colors.brown.shade600;
        }
      default:
        {
          return Colors.green.shade600;
        }
    }
  }

  Color getTileColor(Tile tile) {
    if (tile.isRobotHere) return Colors.yellow.shade800;
    return colorOfMine(tile.getMineType());
  }

  Widget makeTile(Tile tile) {
    return Container(
      padding: EdgeInsets.all(gridSpacing / 2),
      color: Colors.green.shade900,
      child: Container(
        color: getTileColor(tile),
        child: Center(
          child: Text(
            // "(${tile.postion.x},${tile.postion.y})",
            "${fromIndexToAlphabet(index: tile.postion.y as int)}${tile.postion.x + 1}",
            style: const TextStyle(color: Colors.white60),
          ),
        ),
      ),
    );
  }

  Widget generateMap() {
    return GridView(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: numberOfGrids,
          childAspectRatio: 1,
        ),
        children: grid.map((Tile tile) {
          return makeTile(tile);
        }).toList());
  }

  // double postionRelativeToRobotCenter();
  Widget postionMask() {
    return AnimatedPositioned(
      curve: Curves.linear,
      duration: const Duration(milliseconds: 300),
      left: (robot.spacialData.postion.x as double),
      // 0 --> smallestSize ---EXTREMES
      bottom: (robot.spacialData.postion.y as double),
      // 0 --> smallestSize ---EXTREMES
      child: AnimatedRotation(
        curve: Curves.linear,
        duration: const Duration(milliseconds: 300),
        turns: -robot.spacialData.angle / (2 * pi),
        child: Container(
          height: visualRobotSize,
          width: visualRobotSize,
          decoration: const BoxDecoration(
            // color: Colors.cyan,
            image: DecorationImage(
              image: AssetImage(
                "assets/images/robot2.png",
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget indexPanel(Postion tilePostion) {
    MineTypes tileMineType =
        grid[Tile.fromGridPostionToIndex(onGridPostion)].getMineType();
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      color: Colors.black54,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text(
          "Current Cell:",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${fromIndexToAlphabet(index: tilePostion.y as int)}${tilePostion.x + 1}",
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.all(3),
              child: Icon(
                tileMineType == MineTypes.safe
                    ? Icons.verified_user_rounded
                    : Icons.dangerous,
                color: colorOfMine(tileMineType),
              ),
            )
          ],
        )
      ]),
    );
  }

  void adaptToScreenSize() {
    height = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).padding.top + kToolbarHeight);
    width = MediaQuery.of(context).size.width;
    smallestSize = width - allScreenPadding * 2;
    visualRobotSize =
        (smallestSize / (numberOfGrids + 2 * robotSizeComparedToCell)) *
            robotSizeComparedToCell;
    // smallestSize = (height > width ? width : height) -
    //     2 * visualRobotSize - 40 - allScreenPadding * 2; // the last 40 is responsible for the DataRow
    //TODO : remove dataRow
    //TODO : remove dataRow
    //TODO : remove dataRow
    //TODO : remove dataRow
    //TODO : remove dataRow
    //TODO : remove dataRow
    //TODO : remove dataRow
    //TODO : remove dataRow
    //TODO : remove dataRow
    //TODO : remove dataRow

    Tile.tileEquivalentLengthOfPixels =
        (smallestSize - 2 * visualRobotSize) / numberOfGrids;
    if (IncomingData.startMapping) {
      setRobotSpacialData(
          spacialData: analyzingIncomingData(IncomingData(
        n1: 0,
        n2: 0,
        isRightDirectionPositive: true,
        isLeftDirectionPositive: true,
      )));
    }
  }

  void limitRecivedData(threshold) {
    while (dataReceived.length > threshold) {
      dataReceived.removeAt(0);
    } //reduce the data Recived
  }

  SpacialData analyzingIncomingData(IncomingData incomingData) {
    MathematicalModel mathematicalModel = MathematicalModel(
      n1: incomingData.n1,
      n2: incomingData.n2,
      isLeftDirectionPositive: incomingData.isLeftDirectionPositive,
      isRightDirectionPositive: incomingData.isRightDirectionPositive,
    );
    SpacialData cmSpacialData = mathematicalModel.calculateFinalSpacialData();
    SpacialData pixelsSpacialData = SpacialData(
        postion: cmSpacialData.postion.convertFromCmsToPixels(),
        angle: cmSpacialData.angle);

    return pixelsSpacialData;
  }

  void setRobotPostionOnGrid(Postion postion) {
    onGridPostion = Tile.decodeActualPosToGridPos(
      actualPostion: postion,
      robotSize: visualRobotSize,
      relativeReferenceOnTheRobot: Postion(x: 0.5, y: 0.5),
    );
    Tile.setRobotPostionOnGrid(robotPostion: onGridPostion)
        .forEach((key, value) {
      grid[value].isRobotHere = !grid[value].isRobotHere;
    });
  }

  void setRobotSpacialData({required SpacialData spacialData}) {
    // pastRobotSpacialData = robot.spacialData;
    robot.spacialData = spacialData;
    setRobotPostionOnGrid(robot.spacialData.postion);
    //TODO : I was here last
    //TODO : I was here last
    //TODO : I was here last
    //TODO : I was here last
    //TODO : I was here last
    //TODO : I was here last
    //TODO : I was here last
    //TODO : I was here last

    // print((robot.spacialData.postion.y - pastRobotSpacialData.postion.y));
    // if (IncomingData.startMapping) {
    //   _scrollController.position.animateTo(
    //       _scrollController.offset +
    //           (robot.spacialData.postion.y - pastRobotSpacialData.postion.y),
    //       duration: const Duration(milliseconds: 300),
    //       curve: Curves.linear);
    // }
  }

  void initializeMapping() {
    setRobotSpacialData(
      spacialData: SpacialData(
          postion: Tile.specifyActualPostionOnTile(
            tilePostionOnGrid: Postion(x: 0, y: 0),
            //intial postion
            //TODO : converted during testing and playing but i think it doesn't matter
            //TODO : it matters as in setting state before sending orders provides actual postion
            // instead of relative postion
            relativePostionInsideTile: Postion(x: 0.5, y: 0),
            relativeReferenceOnTheRobot: Postion(x: 0.5, y: 0),
            robotSize: visualRobotSize,
          ),
          angle: robot.spacialData.angle),
    ); //initial Start at middle of first cell);
    MathematicalModel.initialSpacialData = SpacialData(
      postion: robot.spacialData.postion.convertFromPixelsToCms(),
      angle: robot.spacialData.angle,
    );
  }

  Widget makeATableOfTiles(
      {required String title, required List<Tile> tileList}) {
    List<TableRow> tableRows = tileList
        .map((tile) => TableRow(children: <Widget>[
              Center(
                  child:
                      Text(fromIndexToAlphabet(index: tile.postion.y as int))),
              Center(child: Text("${tile.postion.x + 1}")),
            ]))
        .toList();
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
                border: Border(
              top: BorderSide(),
              right: BorderSide(),
              left: BorderSide(),
            )),
            child: Center(child: Text(title)),
          ),
          Table(
            border: TableBorder.all(),
            children: tableRows,
          ),
        ],
      ),
    );
  }

  void showTableDialog(BuildContext context, width) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("Done"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Mines Detected"),
      content: SizedBox(
        width: width / 2,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            makeATableOfTiles(
                title: "Surface Mines",
                tileList: Tile.minePlaces["${MineTypes.surfaceMine}"]!),
            const SizedBox(width: 30),
            makeATableOfTiles(
                title: "Buried Mines",
                tileList: Tile.minePlaces["${MineTypes.underGroundMine}"]!),
          ],
        ),
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    limitRecivedData(threshold);
    adaptToScreenSize(); //Initialize map Size && Screen adaptation of mapping elements
    if (!IncomingData.startMapping) {
      initializeMapping();
    } //initiate Robot postion and other properties --Comes After Screen Adaptation
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor.shade800,
        leading: Container(),
        title: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.white, fontSize: 20),
            children: <TextSpan>[
              const TextSpan(
                  text: 'Map ',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500)),
              TextSpan(text: '- ${widget.port}'),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showTableDialog(context, width);
            },
            icon: const Icon(
              Icons.table_view,
              size: 28,
            ),
          ),
          const SizedBox(width: 20)
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(allScreenPadding),
                  child: Center(
                    child: SingleChildScrollView(
                      reverse: true,
                      controller: _scrollController,
                      child: Stack(
                        children: [
                          // NotificationListener<ScrollUpdateNotification>(
                          //   onNotification: (notification) {
                          //     print(notification);
                          //     return true;
                          //   },
                          Container(
                            color: Colors.green.shade200,
                            width: smallestSize,
                            height: smallestSize,
                            padding: EdgeInsets.all(visualRobotSize),
                            child: generateMap(),
                          ),
                          postionMask(),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              //TODO: DATABAR DATA DATAROW
              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.symmetric(vertical: 10),
              //   color: primaryColor.shade200,
              //   child: Center(
              //     child: SingleChildScrollView(
              //         scrollDirection: Axis.horizontal,
              //         child: DataBar(
              //           dataReceived: dataReceived,
              //         )),
              //   ),
              // ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: isConnected
                ? isConnectedFloatingActionButtons()
                : FloatingActionButton(
                    tooltip: "connect port",
                    onPressed: () {
                      port.close();
                      startPort();
                      isReaderClosed = true;
                      setState(() {});
                    },
                    heroTag: "Random#001",
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.connect_without_contact),
                  ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              color: Colors.black26,
              child: KeyPreview(
                keys: MineTypes.values,
                decodingFunction: (mineType) =>
                    "$mineType".replaceFirst("MineTypes.", ""),
                coloringFunction: colorOfMine,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              color: Colors.black54,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            setRobotSpacialData(
                                spacialData: analyzingIncomingData(IncomingData(
                              n1: 30,
                              n2: 20,
                              isRightDirectionPositive: true,
                              isLeftDirectionPositive: true,
                            )));
                            setState(() {});
                          },
                          child: const Icon(Icons.arrow_back_ios_new)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                          onPressed: () {
                            setRobotSpacialData(
                                spacialData: analyzingIncomingData(IncomingData(
                              n1: 10,
                              n2: 10,
                              isRightDirectionPositive: true,
                              isLeftDirectionPositive: false,
                            )));
                            setState(() {});
                          },
                          child: const Icon(Icons.rotate_left)),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setRobotSpacialData(
                              spacialData: analyzingIncomingData(IncomingData(
                            n1: 30,
                            n2: 30,
                            isRightDirectionPositive: true,
                            isLeftDirectionPositive: true,
                          )));

                          setState(() {});
                        },
                        child: Transform.rotate(
                            angle: -pi / 2,
                            child: const Icon(Icons.arrow_forward_ios)),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          setRobotSpacialData(
                              spacialData: analyzingIncomingData(IncomingData(
                            n1: 30,
                            n2: 30,
                            isRightDirectionPositive: false,
                            isLeftDirectionPositive: false,
                          )));
                          setState(() {});
                        },
                        child: Transform.rotate(
                            angle: pi / 2,
                            child: const Icon(Icons.arrow_forward_ios)),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            setRobotSpacialData(
                                spacialData: analyzingIncomingData(IncomingData(
                              n1: 20,
                              n2: 30,
                              isRightDirectionPositive: true,
                              isLeftDirectionPositive: true,
                            )));
                            setState(() {});
                          },
                          child: const Icon(Icons.arrow_forward_ios)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                          onPressed: () {
                            setRobotSpacialData(
                                spacialData: analyzingIncomingData(IncomingData(
                              n1: 10,
                              n2: 10,
                              isRightDirectionPositive: false,
                              isLeftDirectionPositive: true,
                            )));
                            setState(() {});
                          },
                          child: const Icon(Icons.rotate_right)),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: () {
                            grid[Tile.fromGridPostionToIndex(onGridPostion)]
                                .setMineType(MineTypes.surfaceMine);
                            setState(() {});
                          },
                          child: const Icon(Icons.dangerous)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown),
                          onPressed: () {
                            grid[Tile.fromGridPostionToIndex(onGridPostion)]
                                .setMineType(MineTypes.underGroundMine);
                            setState(() {});
                          },
                          child: const Icon(Icons.dangerous)),
                    ],
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: indexPanel(onGridPostion),
          ),
        ],
      ),
    );
  }

  Widget isConnectedFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          tooltip: "pause / play Serial read",
          onPressed: () {
            if (isReaderClosed) {
              print("---------------------\nStarting Reader");
              port.close();
              startPort();
              startListener();
            } else {
              print("Ending Reader\n----------------------");
              reader.close();
              isReaderClosed = true;
            }
            setState(() {});
          },
          heroTag: "Random#-001",
          backgroundColor: isReaderClosed ? Colors.red : Colors.green,
          child: isReaderClosed
              ? const Icon(Icons.pause)
              : const Icon(Icons.play_arrow),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          tooltip: "Send data",
          onPressed: () {
            portWrite("test");
            setState(() {});
          },
          heroTag: "Random#000",
          backgroundColor: primaryColor.shade800,
          child: const Icon(Icons.send),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          tooltip: "Disconnect port",
          onPressed: () {
            reader.close();
            isReaderClosed = true;
            port.close();
            isConnected = false;
            setState(() {});
          },
          heroTag: "Random#002",
          backgroundColor: Colors.red,
          child: const Icon(Icons.close),
        ),
      ],
    );
  }

  @override
  void dispose() {
    port.close();
    port.dispose();
    super.dispose();
  }
}

class DataBar extends StatefulWidget {
  final List<String> dataReceived;

  const DataBar({Key? key, required this.dataReceived}) : super(key: key);

  @override
  State<DataBar> createState() => _DataBarState();
}

class _DataBarState extends State<DataBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
        children: widget.dataReceived
            .map((string) => Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  height: 40,
                  width: 100,
                  decoration: BoxDecoration(
                      color: string.startsWith("Sent")
                          ? Colors.blue
                          : primaryColor,
                      borderRadius: BorderRadius.circular(30)),
                  child: Center(
                    child: Text(
                      string,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ))
            .toList());
  }
}
