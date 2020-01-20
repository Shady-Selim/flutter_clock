// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:video_player/video_player.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'container_hand.dart';
import 'drawn_hand.dart';


final radiansPerTick = radians(360 / 60);
final radiansPerHour = radians(360 / 12);

class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _temperature = '';
  var _date = '';
  var _weekday = '';
  Timer _timer;
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature =
          '${widget.model.temperatureString}\n${widget.model.weatherString}';
      // Todo: Instead of String text for Weather we can add SVG image
    });
    _controller = VideoPlayerController.asset(
        'assets/foggy.mp4') // free video from https://www.videezy.com/nature/4057-foggy-landscape-over-the-lake
      ..initialize().then((_) {
        _controller.play();
        _controller.setLooping(true);
        setState(() {});
      });
     // Todo: Add free video loops for all possible Weather status
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      _date = DateFormat("d\nMMM").format(_now).toString();
      _weekday = DateFormat(DateFormat.ABBR_WEEKDAY).format(_now).toString();
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            primaryColor: Color(0x99FFFFFF),
            highlightColor: Color(0xFF8AB4F8),
            accentColor: Color(0x99669DF6),
            backgroundColor: Color(0x223C4043),
          )
        : Theme.of(context).copyWith(
            primaryColor: Color(0x993C4043),
            highlightColor: Color(0xFF4285F4),
            accentColor: Color(0x998AB4F8),
            backgroundColor: Color(0x22FFFFFF),
          );

    final time = DateFormat.Hms().format(DateTime.now());

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        child: Stack(
          children: [
        SizedBox.expand(
        child: FittedBox(
        fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size?.width ?? 0,
            height: _controller.value.size?.height ?? 0,
            child: VideoPlayer(_controller),
          ),
        ),
      ),
            Container(
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: customTheme.backgroundColor)),
            Positioned(
                left: 250,
                top: 80,
                child: Container(
                  width: 150,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: customTheme.primaryColor,
                  ),
                  child: Center(
                      child: Text(
                    time,
                    textAlign: TextAlign.center,
                    textScaleFactor: 2,
                  )),
                )),
            Positioned(
                left: 200,
                bottom: 80,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: customTheme.primaryColor,
                  ),
                  child: Center(
                      child: Text(
                        _weekday,
                        textAlign: TextAlign.center,
                        textScaleFactor: 2,
                      )),
                )),

            Positioned(
                right: 200,
                bottom: 80,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: customTheme.primaryColor,
                  ),
                  child: Center(
                      child: Text(
                    _date,
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.5,
                  )),
                )),
            Positioned(
                right: 280,
                bottom: 40,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: customTheme.primaryColor,
                  ),
                  child: Center(
                      child: Text(
                    _temperature,
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.5,
                  )),
                )),
            // Example of a hand drawn with [CustomPainter].

            // Example of a hand drawn with [Container].
            ContainerHand(
              color: Colors.transparent,
              size: 0.5,
              angleRadians: _now.hour * radiansPerHour +
                  (_now.minute / 60) * radiansPerHour,
              child: Transform.translate(
                offset: Offset(0.0, -60.0),
                child: Container(
                  width: 16,
                  height: 150,
                  decoration: BoxDecoration(
                    color: customTheme.accentColor,
                  ),
                ),
              ),
            ),
            DrawnHand(
              color: customTheme.accentColor,
              thickness: 5,
              size: 0.7,
              angleRadians: _now.minute * radiansPerTick,
            ),
            DrawnHand(
              color: customTheme.primaryColor,
              thickness: 4,
              size: 0.9,
              angleRadians: _now.second * radiansPerTick,
            ),
      Center(
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: customTheme.highlightColor,
          )
        )
      )
          ]
        )
      ),
    );
  }
}
