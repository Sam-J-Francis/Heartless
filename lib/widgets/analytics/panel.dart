import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:heartless/shared/constants.dart';
import 'package:heartless/widgets/analytics/graphs.dart';
import 'package:intl/intl.dart';

class Panel extends StatefulWidget {
  final String title;

  const Panel({super.key, required this.title});

  @override
  State<Panel> createState() => _PanelState();
}

class _PanelState extends State<Panel> {
  final String month = DateFormat('MMMM').format(DateTime.now());
  final int year = DateTime.now().year;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        // backgroundColor: Colors.transparent,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            letterSpacing: 3,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: const GraphsWidget(),
    );
  }
}
