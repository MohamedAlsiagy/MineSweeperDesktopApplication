import 'package:flutter/material.dart';

class KeyPreview extends StatelessWidget {
  final List<dynamic> keys;
  final Function coloringFunction;
  dynamic Function(dynamic) decodingFunction = (e) => "$e";
  late List<dynamic> decodedKeys;

  KeyPreview({
    Key? key,
    required this.keys,
    required this.coloringFunction,
    required this.decodingFunction,
  }) : super(key: key);

  Widget itemBuilder(index) {
    return Container(
      margin: EdgeInsets.only(bottom: index != keys.length - 1 ? 10 : 0),
      height: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 20,
            width: 20,
            color: coloringFunction(keys[index]),
          ),
          const SizedBox(width: 10),
          Text(decodedKeys[index], style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    decodedKeys = keys.map(decodingFunction).toList();
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(keys.length, itemBuilder));
  }
}
