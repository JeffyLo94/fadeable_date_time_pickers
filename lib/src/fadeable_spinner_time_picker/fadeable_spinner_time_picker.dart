// library fadeable_spinner_time_picker;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:fadeable_date_time_pickers/src/utils/date_time_picker_controller.dart';
import 'package:fadeable_date_time_pickers/src/utils/time_utils.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum _TimeSpinnerType {
  hours,
  minutes,
  seconds,
  ampm,
}

class FadeableSpinnerTimePicker extends StatefulWidget {
  FadeableSpinnerTimePicker({
    Key? key,
    required this.initialTime,
    required this.onTimeChanged,
    DateTimePickerController? dtController,
    this.maxTime,
    this.minTime,
    this.is24HourMode = false,
    this.showSeconds = false,
    this.minutesInterval = 1,
    this.secondsInterval = 1,
    this.horizontalAlignment = MainAxisAlignment.center,
    this.spacerWidth = 40,
    this.apSpacerWidth = 30,
    this.itemSize = const Size(40, 40),
    this.itemSpacing = 20,
    this.isForceHour2Digits = false,
    this.isForce2Digits = true,
    this.itemAlignment = Alignment.center,
    this.itemsToShow = 4.5,
    this.selectedTextStyle,
    this.normalTextStyle,
    this.spacerTextStyle,
    this.timeSpacerWidget,
    this.amPmSpacerWidget,
    this.selectedItemColor = Colors.blue,
    this.unselectedItemColor = Colors.grey,
    this.disabledItemColor = const Color(0xFFE0E0E0),
    this.enableDistanceFade = true,
    this.maximumFadeItems = 3,
  })  : controller =
            dtController ?? DateTimePickerController(value: initialTime),
        super(key: key);

  final DateTimePickerController controller;

  /// Required initial time picker shows
  final DateTime initialTime;

  /// determines if picker is in a 24 hour style
  /// if false, shows AM PM
  final bool is24HourMode;

  /// determines whether picker shows seconds
  final bool showSeconds;

  final DateTime? maxTime;
  final DateTime? minTime;

  /// determines minutes interval
  final int minutesInterval;

  /// determines seconds interval
  final int secondsInterval;
  final Size itemSize;
  final bool isForceHour2Digits;
  final bool isForce2Digits;
  final Alignment itemAlignment;
  final double itemSpacing;
  final double itemsToShow;
  final double spacerWidth;
  final double apSpacerWidth;

  final Color selectedItemColor;
  final Color unselectedItemColor;
  final Color disabledItemColor;
  final bool enableDistanceFade;

  /// Overrides the default fade calculations to instead be at maximum fade by the specified [maximumFadeItems] around the selected date
  final double maximumFadeItems;

  final MainAxisAlignment horizontalAlignment;
  final Widget? timeSpacerWidget;
  final Widget? amPmSpacerWidget;
  final TextStyle? selectedTextStyle;
  final TextStyle? normalTextStyle;
  final TextStyle? spacerTextStyle;

  final Function(DateTime) onTimeChanged;

  @override
  State<FadeableSpinnerTimePicker> createState() =>
      _FadeableSpinnerTimePickerState();
}

class _FadeableSpinnerTimePickerState extends State<FadeableSpinnerTimePicker> {
  TextStyle defaultHighlightTextStyle =
      const TextStyle(fontSize: 24, color: Colors.blue);
  TextStyle defaultSpacerTextStyle =
      const TextStyle(fontSize: 24, color: Colors.blue);
  TextStyle defaultNormalTextStyle =
      const TextStyle(fontSize: 24, color: Colors.black54);
  TextStyle defaultDisabledTextStyle =
      const TextStyle(fontSize: 24, color: Colors.grey);

  int selectedHour = 0;
  int selectedMinute = 0;
  int selectedSecond = 0;
  int selectedAmPm = -1;

  DateTime time = DateTime.now();

  List<Widget> hourItems = [];
  List<Widget> minuteItems = [];
  List<Widget> secondItems = [];
  List<Widget> amPmItems = [];

  CarouselController hourCtrl = CarouselController();
  CarouselController minuteCtrl = CarouselController();
  CarouselController secondCtrl = CarouselController();
  CarouselController amPmCtrl = CarouselController();

  @override
  void initState() {
    super.initState();

    hourCtrl = CarouselController();
    minuteCtrl = CarouselController();
    secondCtrl = CarouselController();
    amPmCtrl = CarouselController();

    time = widget.initialTime.roundNearestMinute(Duration(
        minutes: widget.minutesInterval, seconds: widget.secondsInterval));
    // print('time is: $time');
    _initTimeItems();
    _initTime();
    // _initTimeListItemWidgets();
    _setSelected(type: _TimeSpinnerType.hours, selectedIndex: selectedHour);
    // print('calling set selected minutes');
    _setSelected(
        type: _TimeSpinnerType.minutes, selectedIndex: _selectedMinuteIndex);
    // print('calling set selected seconds');
    _setSelected(
        type: _TimeSpinnerType.seconds, selectedIndex: _selectedSecondIndex);
    _setSelected(type: _TimeSpinnerType.ampm, selectedIndex: selectedAmPm);

    widget.controller.updateDateTime = _setDateTime;
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  _setDateTime() {
    if (mounted) {
    //   print(
    //       '-------------------------- UPDATING DATE TIME -------------------------');
      setState(() {
        time = widget.controller.value.roundNearestMinute(Duration(
            minutes: widget.minutesInterval, seconds: widget.secondsInterval));
        if (_isInvalidTime(time)) {
          time = (widget.minTime?.isAfter(time) ?? false)
              ? widget.minTime!
                  .roundNearestMinute(Duration(minutes: widget.minutesInterval))
              : (widget.maxTime?.isBefore(time) ?? false)
                  ? widget.maxTime!.roundNearestMinute(
                      Duration(minutes: widget.minutesInterval))
                  : time;
          if (hourCtrl.ready) {
            hourCtrl.jumpToPage(time.hour);
          }
          if (minuteCtrl.ready) {
            minuteCtrl.jumpToPage(time.minute ~/ widget.minutesInterval);
          }
        }
        selectedHour = time.hour;
        selectedMinute = time.minute;
        selectedSecond = time.second;
        selectedAmPm = time.hour >= 12 ? 1 : 0;
      });

      _setSelected(type: _TimeSpinnerType.hours, selectedIndex: selectedHour);
      _setSelected(
          type: _TimeSpinnerType.minutes, selectedIndex: _selectedMinuteIndex);
      _setSelected(
          type: _TimeSpinnerType.seconds, selectedIndex: _selectedSecondIndex);
      _setSelected(type: _TimeSpinnerType.ampm, selectedIndex: selectedAmPm);

      widget.onTimeChanged(time);
    }
  }

  void _initTime() {
    DateTime initTime = widget.initialTime.roundNearestMinute(Duration(
        minutes: widget.minutesInterval, seconds: widget.secondsInterval));
    setState(() {
      selectedHour = initTime.hour;
      selectedMinute = initTime.minute;
      selectedSecond = initTime.second;
      selectedAmPm = initTime.hour >= 12 ? 1 : 0;
    });
    // print('time inited to: $selectedHour:$selectedMinute:$selectedSecond');
  }

  void _initTimeItems() {
    setState(() {
      hourItems = _generateTimeItems(
        max: _getHourCount(),
        interval: 1,
        type: _TimeSpinnerType.hours,
        ctrl: hourCtrl,
      );
      minuteItems = _generateTimeItems(
          max: _getMinuteCount(),
          interval: widget.minutesInterval,
          type: _TimeSpinnerType.minutes,
          ctrl: minuteCtrl);
      secondItems = _generateTimeItems(
        max: _getSecondCount(),
        interval: widget.secondsInterval,
        type: _TimeSpinnerType.seconds,
        ctrl: secondCtrl,
      );
    });
  }

  bool _isInvalidTime(DateTime checkTime) {
    return (widget.minTime?.isAfter(checkTime) ?? false) ||
        (widget.maxTime?.isBefore(checkTime) ?? false);
  }

  int get _selectedMinuteIndex {
    final calculatedIndex = (selectedMinute / widget.minutesInterval).round();
    // print(
    //     'selected minutes index = ($selectedMinute / ${widget.minutesInterval}) = ${calculatedIndex} => ${calculatedIndex >= minuteItems.length ? 0 : calculatedIndex}');
    return calculatedIndex >= minuteItems.length ? 0 : calculatedIndex;
  }

  int get _selectedSecondIndex {
    final calculatedIndex = (selectedSecond / widget.secondsInterval).round();
    return calculatedIndex >= secondItems.length ? 0 : calculatedIndex;
  }

  void _setSelected(
      {required _TimeSpinnerType type, required int selectedIndex}) {
    // print('time range: ${widget.minTime} - ${widget.maxTime}');
    setState(() {
      switch (type) {
        case _TimeSpinnerType.hours:
          int value = selectedIndex;
          hourItems = _generateTimeItems(
            max: _getHourCount(),
            interval: 1,
            type: type,
            ctrl: hourCtrl,
          );
          if (value >= 12 && !widget.is24HourMode) {
            value = selectedIndex % 12;
          }
          selectedHour = selectedIndex;

          final DateTime selectedTime = DateTime(
            widget.controller.value.year,
            widget.controller.value.month,
            widget.controller.value.day,
            selectedHour,
            selectedMinute,
            selectedSecond,
          );

          if (_isInvalidTime(selectedTime)) {
            // print(
            //     'INVALID HOUR ${selectedHour}: ${selectedTime} should be between ${widget.minTime} and ${widget.maxTime}');
            if (widget.maxTime?.isBefore(selectedTime) ?? false) {
              DateTime maxHourTime = DateTime(
                  selectedTime.year,
                  selectedTime.month,
                  selectedTime.day,
                  widget.maxTime!.hour,
                  selectedTime.minute,
                  selectedTime.second);
              if (widget.maxTime!.isBefore(maxHourTime)) {
                //print('hour ${selectedHour} is invalid, should jump to max');
                int targetHour = widget.maxTime!.hour - 1;
                hourCtrl.animateToPage(targetHour);
                var maxValue = (targetHour >= 12 && !widget.is24HourMode)
                    ? targetHour % 12
                    : targetHour;
                hourItems[selectedIndex] = _generateTimeWidget(
                  maxValue,
                  isHours: true,
                  isSelected: true,
                  type: type,
                  ctrl: hourCtrl,
                  index: targetHour,
                );
              } else {
                //print('hour ${selectedHour} is invalid, should jump to max');
                hourCtrl.animateToPage(widget.maxTime!.hour);
                var maxValue =
                    (widget.maxTime!.hour >= 12 && !widget.is24HourMode)
                        ? widget.maxTime!.hour % 12
                        : widget.maxTime!.hour;
                hourItems[selectedIndex] = _generateTimeWidget(
                  maxValue,
                  isHours: true,
                  isSelected: true,
                  type: type,
                  ctrl: hourCtrl,
                  index: widget.maxTime!.hour,
                );
              }
            } else if (widget.minTime?.isAfter(selectedTime) ?? false) {
              // print('hour ${selectedHour} is invalid, should jump to min');
              hourCtrl.animateToPage(widget.minTime!.hour);

              // if the hour is changed, we should also update the AM/PM indicartor
              //Animate AMPM
              if (widget.minTime!.hour >= 12 && selectedAmPm == 0) {
                // set to PM
                amPmCtrl.animateToPage(1);
              } else if (widget.minTime!.hour < 12 && selectedAmPm == 1) {
                // set to AM
                amPmCtrl.animateToPage(0);
              }
            }
          } else {
            // print('VALID HOUR - $selectedHour');

            //Animate AMPM
            if (selectedHour >= 12 && selectedAmPm == 0) {
              // set to PM
              amPmCtrl.animateToPage(1);
            } else if (selectedHour < 12 && selectedAmPm == 1) {
              // set to AM
              amPmCtrl.animateToPage(0);
            }

            hourItems[selectedIndex] = _generateTimeWidget(
              value,
              isHours: true,
              isSelected: true,
              type: type,
              ctrl: hourCtrl,
              index: selectedIndex,
            );
            _setSurrounding(
              selectedIndex,
              hourItems,
              hourCtrl,
              type,
            );
            amPmItems = _generateAmPmItems(selectedIndex: selectedAmPm);

            // refresh minute items
            // print(
            //     'hour changed -> minutes valid ? ${(selectedMinute ~/ widget.minutesInterval)} <= ${minuteItems.length} .... ${(selectedMinute ~/ widget.minutesInterval) <= minuteItems.length}');
            if (minuteCtrl.ready) {
              if (minuteItems.isNotEmpty &&
                  (selectedMinute ~/ widget.minutesInterval) <=
                      minuteItems.length) {
                _setSelected(
                    type: _TimeSpinnerType.minutes,
                    selectedIndex: selectedMinute ~/ widget.minutesInterval);
              }
            } else {
              //print('----UNABLE TO CHANGE MINUTES--------');
            }
          }

          break;
        case _TimeSpinnerType.minutes:
          minuteItems = _generateTimeItems(
              max: _getMinuteCount(),
              interval: widget.minutesInterval,
              type: type,
              ctrl: minuteCtrl);
          selectedMinute = selectedIndex * widget.minutesInterval;

          final DateTime selectedTime = DateTime(
            widget.controller.value.year,
            widget.controller.value.month,
            widget.controller.value.day,
            selectedHour,
            selectedMinute,
            selectedSecond,
          );

          if (_isInvalidTime(selectedTime)) {
            // print(
            //     'INVALID MINUTE: ${selectedTime} should be between ${widget.minTime} and ${widget.maxTime}');
            if (widget.maxTime?.isBefore(selectedTime) ?? false) {
              // print('minute ${selectedMinute} is invalid, should jump to max');
              minuteCtrl.animateToPage(widget.maxTime!
                      .roundNearestMinute(
                          Duration(minutes: widget.minutesInterval))
                      .minute ~/
                  widget.minutesInterval);
              // print(
              //     'animate jump to index: ${widget.maxTime!.roundNearestMinute(Duration(minutes: widget.minutesInterval)).minute ~/ widget.minutesInterval}');
              minuteItems[selectedIndex] = _generateTimeWidget(
                widget.maxTime!
                    .roundNearestMinute(
                        Duration(minutes: widget.minutesInterval))
                    .minute,
                isHours: false,
                isSelected: true,
                type: type,
                ctrl: minuteCtrl,
                index: widget.maxTime!
                        .roundNearestMinute(
                            Duration(minutes: widget.minutesInterval))
                        .minute ~/
                    widget.minutesInterval,
              );
            } else if (widget.minTime?.isAfter(selectedTime) ?? false) {
              // print('minute ${selectedMinute} is invalid, should jump to min');
              minuteCtrl.animateToPage(widget.minTime!
                      .roundNearestMinute(
                          Duration(minutes: widget.minutesInterval))
                      .minute ~/
                  widget.minutesInterval);
              // print(
              //     'animate jump to index: ${widget.minTime!.roundNearestMinute(Duration(minutes: widget.minutesInterval)).minute ~/ widget.minutesInterval}');
            }
          } else {
            // print('VALID MINUTE - $selectedMinute');
            minuteItems[selectedIndex] = _generateTimeWidget(
              // selectedIndex,
              selectedMinute,
              isHours: false,
              isSelected: true,
              type: type,
              ctrl: minuteCtrl,
              index: selectedIndex,
            );
            _setSurrounding(
              selectedIndex,
              minuteItems,
              minuteCtrl,
              type,
            );

            // refresh hour items
            // print(
            //     'minute changed -> hours valid ? ${(selectedHour)} <= ${hourItems.length} .... ${(selectedHour) <= hourItems.length}');
            // if (hourCtrl.ready) {
            //   if (hourItems.isNotEmpty && (selectedHour) <= hourItems.length) {
            //     _setSelected(
            //         type: _TimeSpinnerType.hours, selectedIndex: selectedHour);
            //   }
            // } else {
            //   print('----UNABLE TO CHANGE hours--------');
            // }
          }

          break;
        case _TimeSpinnerType.seconds:
          secondItems = _generateTimeItems(
            max: _getSecondCount(),
            interval: widget.secondsInterval,
            type: type,
            ctrl: secondCtrl,
          );
          selectedSecond = selectedIndex * widget.secondsInterval;

          final DateTime selectedTime = DateTime(
            widget.controller.value.year,
            widget.controller.value.month,
            widget.controller.value.day,
            selectedHour,
            selectedMinute,
            selectedSecond,
          );

          if (_isInvalidTime(selectedTime)) {
            // print(
            //     'INVALID SECOND: ${selectedTime} should be between ${widget.minTime} and ${widget.maxTime}');
            if (widget.maxTime?.isBefore(selectedTime) ?? false) {
              // print('second ${selectedSecond} is invalid, should jump to max');
              secondCtrl.animateToPage(widget.maxTime!
                      .roundNearestMinute(
                          Duration(seconds: widget.secondsInterval))
                      .second ~/
                  widget.secondsInterval);
              secondItems[selectedIndex] = _generateTimeWidget(
                widget.maxTime!
                    .roundNearestMinute(
                        Duration(seconds: widget.secondsInterval))
                    .second,
                isHours: false,
                isSelected: true,
                type: type,
                ctrl: secondCtrl,
                index: widget.maxTime!
                        .roundNearestMinute(
                            Duration(seconds: widget.secondsInterval))
                        .second ~/
                    widget.secondsInterval,
              );
            } else if (widget.minTime?.isAfter(selectedTime) ?? false) {
              // print('second ${selectedSecond} is invalid, should jump to min');
              secondCtrl.animateToPage(widget.minTime!
                      .roundNearestMinute(
                          Duration(seconds: widget.secondsInterval))
                      .second ~/
                  widget.secondsInterval);
            }
          } else {
            // print('VALID SECOND - $selectedSecond');

            secondItems[selectedIndex] = _generateTimeWidget(
              selectedSecond,
              isHours: false,
              isSelected: true,
              type: type,
              ctrl: secondCtrl,
              index: selectedIndex,
            );
            _setSurrounding(
              selectedIndex,
              secondItems,
              secondCtrl,
              type,
            );
          }
          break;
        case _TimeSpinnerType.ampm:
          // var previousAmPmIndex = selectedAmPm;
          selectedAmPm = selectedIndex;
          // print(
          //     'previous was ${previousAmPmIndex == 0 ? 'AM' : 'PM'} -> Now is ${selectedAmPm == 0 ? 'AM' : 'PM'}');
          if (selectedAmPm == 0) {
            // is now am
            if (selectedHour >= 12) {
              // current hour is in PM range -> should be AM range
              final DateTime possibleHourChange = DateTime(
                widget.controller.value.year,
                widget.controller.value.month,
                widget.controller.value.day,
                selectedHour - 12,
                selectedMinute,
                selectedSecond,
              );
              if (widget.minTime?.isAfter(possibleHourChange) ?? false) {
                // Invalid time change -> bounce back to PM
                // print('bouncing back to PM');
                selectedAmPm = 1;
                amPmCtrl.animateToPage(1);
              } else {
                // valid -> bounce hour index to AM range
                selectedHour = possibleHourChange.hour;
                hourCtrl.jumpToPage(selectedHour);
              }
            }
          } else if (selectedAmPm == 1) {
            // is now pm
            if (selectedHour < 12) {
              // current hour is in AM range -> should be PM range
              final DateTime possibleHourChange = DateTime(
                widget.controller.value.year,
                widget.controller.value.month,
                widget.controller.value.day,
                selectedHour + 12,
                selectedMinute,
                selectedSecond,
              );
              if (widget.maxTime?.isBefore(possibleHourChange) ?? false) {
                // Invalid time change -> bounce back to PM
                // print('bouncing back to AM');
                selectedAmPm = 0;
                amPmCtrl.animateToPage(0);
              } else {
                // valid -> bounce hour index to PM range
                selectedHour = possibleHourChange.hour;
                hourCtrl.jumpToPage(selectedHour);
              }
            }
          } else {
            // invalid am/pm index
            assert(selectedAmPm >= 0 && selectedAmPm <= 1);
          }

          amPmItems = _generateAmPmItems(selectedIndex: selectedAmPm);
          break;
      }
    });
  }

  bool isIndexInvalidTime(
      {required _TimeSpinnerType type, required int index}) {
    final DateTime selectedTime = DateTime(
      widget.controller.value.year,
      widget.controller.value.month,
      widget.controller.value.day,
      type == _TimeSpinnerType.hours ? index : selectedHour,
      type == _TimeSpinnerType.minutes
          ? index * widget.minutesInterval
          : selectedMinute,
      type == _TimeSpinnerType.seconds
          ? index * widget.secondsInterval
          : selectedSecond,
    );
    // print('isIndexValidTime? $selectedTime');
    return _isInvalidTime(selectedTime);
  }

  void _setSurrounding(
    int selectedIndex,
    List<Widget> items,
    CarouselController ctrl,
    _TimeSpinnerType type,
  ) {
    var maxIndexesAboveBelow = (widget.itemsToShow / 2.0).floor();
    int value = selectedIndex;
    //below
    for (int i = selectedIndex - 1;
        i >= (selectedIndex - maxIndexesAboveBelow);
        i--) {
      int index = i;
      if (i < 0) {
        // break;
        index = i % items.length;
      }
      value = index;
      if (type == _TimeSpinnerType.hours &&
          value >= 12 &&
          !widget.is24HourMode) {
        value = i % 12;
      }
      if (type == _TimeSpinnerType.minutes) {
        value = value * widget.minutesInterval;
      }
      if (type == _TimeSpinnerType.seconds) {
        value = value * widget.secondsInterval;
      }
      var diff = (selectedIndex - i).abs();
      items[index] = _generateTimeWidget(
        value,
        isHours: type == _TimeSpinnerType.hours,
        isSelected: false,
        ctrl: ctrl,
        index: index,
        type: type,
        distanceFromSelected: diff,
      );
    }
    //above
    for (int i = selectedIndex + 1;
        i <= (selectedIndex + maxIndexesAboveBelow);
        i++) {
      int index = i;
      if (i >= items.length) {
        // break;
        index = i % items.length;
      }

      value = index;
      if (type == _TimeSpinnerType.hours &&
          value >= 12 &&
          !widget.is24HourMode) {
        value = i % 12;
      }
      if (type == _TimeSpinnerType.minutes) {
        value = value * widget.minutesInterval;
      }
      if (type == _TimeSpinnerType.seconds) {
        value = value * widget.secondsInterval;
      }
      var diff = (selectedIndex - i).abs();
      items[index] = _generateTimeWidget(
        value,
        isHours: type == _TimeSpinnerType.hours,
        isSelected: false,
        ctrl: ctrl,
        index: index,
        type: type,
        distanceFromSelected: diff,
      );
    }
  }

  int _getHourCount() {
    // return widget.is24HourMode ? 24 : 12;
    return 24;
  }

  int _getMinuteCount() {
    return (60 / widget.minutesInterval).floor();
  }

  int _getSecondCount() {
    return (60 / widget.secondsInterval).floor();
  }

  List<Widget> _generateAmPmItems({int selectedIndex = -1}) {
    List<Widget> widgets = [];
    for (int i = 0; i < 2; i++) {
      var fadeScale = 1 / widget.maximumFadeItems;
      var opacity = 1.0;
      opacity = 1.0 - (1 * fadeScale);
      opacity = opacity > 0.1 ? opacity : 0.1;

      // check if pm/am is invalid
      var isDisabled = selectedHour < 12
          ? (widget.maxTime?.isBefore(DateTime(
                widget.controller.value.year,
                widget.controller.value.month,
                widget.controller.value.day,
                selectedHour + 12,
                0,
                0,
              )) ??
              false)
          : (widget.minTime?.isAfter(DateTime(
                widget.controller.value.year,
                widget.controller.value.month,
                widget.controller.value.day,
                selectedHour - 12,
                0,
                0,
              )) ??
              false);

      // print(
      //     'isDisabled ${widget.maxTime} < ${DateTime(widget.initialTime.year, widget.initialTime.month, widget.initialTime.day, 12, 0, 0)} = $isDisabled');
      // isDisabled ? print('pm is disabled') : print('pm not disabled');

      widgets.add(GestureDetector(
        onTap: () {
          // print('tap detected $i');
          amPmCtrl.jumpToPage(i);
          _setSelected(type: _TimeSpinnerType.ampm, selectedIndex: i);
        },
        child: Container(
          height: widget.itemSize.height,
          width: widget.itemSize.width,
          alignment: widget.itemAlignment,
          // color: Colors.green,
          child: Text(
            i == 0 ? 'AM' : 'PM',
            style: selectedIndex == i
                ? _getHighlightedTextStyle()
                : i == 1 && isDisabled
                    ? _getDisabledTextStyle(opacity: 0.25)
                    : _getNormalTextStyle(opacity: opacity),
          ),
        ),
      ));
    }
    return widgets;
  }

  List<Widget> _generateTimeItems({
    required int max,
    required int interval,
    required _TimeSpinnerType type,
    required CarouselController ctrl,
  }) {
    List<Widget> widgets = [];
    for (int i = 0; i < max; i++) {
      int value = i;
      if (type == _TimeSpinnerType.minutes ||
          type == _TimeSpinnerType.seconds) {
        value = i * interval;
        // print('value: ${value}');
      } else if (type == _TimeSpinnerType.hours &&
          value >= 12 &&
          !widget.is24HourMode) {
        value = value % 12;
      }
      widgets.add(_generateTimeWidget(
        value,
        isHours: (type == _TimeSpinnerType.hours),
        ctrl: ctrl,
        index: i,
        type: type,
      ));
    }
    return widgets;
  }

  Widget _generateTimeWidget(
    int value, {
    bool isHours = false,
    bool isSelected = false,
    required CarouselController ctrl,
    required int index,
    required _TimeSpinnerType type,
    // double opacity = 1,
    int? distanceFromSelected,
  }) {
    String text;
    text = value.toString();
    if (isHours) {
      if (!widget.is24HourMode && value == 0) {
        text = '12';
      }
      if (widget.isForceHour2Digits && text != '') {
        text = text.padLeft(2, '0');
        //print('padding text -> $text');
      }
    } else {
      if (widget.isForce2Digits && text != '') {
        text = text.padLeft(2, '0');
      }
    }

    //opacity
    var fadeScale = 1 / widget.maximumFadeItems;
    var fadeIntensity = distanceFromSelected ?? widget.maximumFadeItems;
    var opacity = 1.0;
    opacity = 1.0 - (fadeIntensity * fadeScale);
    opacity = opacity > 0.1 ? opacity : 0.1;
    // print(opacity);

    final DateTime selectedTime = DateTime(
      widget.controller.value.year,
      widget.controller.value.month,
      widget.controller.value.day,
      type == _TimeSpinnerType.hours ? index : selectedHour,
      type == _TimeSpinnerType.minutes
          ? index * widget.minutesInterval
          : selectedMinute,
      type == _TimeSpinnerType.seconds
          ? index * widget.secondsInterval
          : selectedSecond,
    );

    final bool isInvalidTime = _isInvalidTime(selectedTime);
    // final bool isInvalidTime = isIndexValidTime(index: index, type: type);

    // if (isInvalidTime && type != _TimeSpinnerType.seconds)
    // print('time ${type} - $value - $selectedTime at $index is invalid');

    return GestureDetector(
      onTap: () {
        // print(
        //     '--------------------------------------------tap detected - $index');
        //Check if valid index to jump to, otherwise do nothing
        if (!isIndexInvalidTime(type: type, index: index)) {
          // print('valid index $index tapped, jumping');
          ctrl.jumpToPage(index);
          _setSelected(type: type, selectedIndex: index);
        } else {
          // print('invalid index $index tapped');
        }
      },
      child: Container(
        height: widget.itemSize.height,
        width: widget.itemSize.width,
        alignment: widget.itemAlignment,
        // color: Colors.green,
        child: Text(
          text,
          style: isSelected
              ? _getHighlightedTextStyle()
              : isInvalidTime
                  ? _getDisabledTextStyle(opacity: 0.25)
                  : _getNormalTextStyle(opacity: opacity),
        ),
      ),
    );
  }

  Widget _timeSpinner({
    required int selectedIndex,
    required _TimeSpinnerType spinnerType,
  }) {
    List<Widget> items;
    CarouselController ctrl;

    switch (spinnerType) {
      case _TimeSpinnerType.hours:
        items = hourItems;
        ctrl = hourCtrl;
        break;
      case _TimeSpinnerType.minutes:
        items = minuteItems;
        ctrl = minuteCtrl;
        break;
      case _TimeSpinnerType.seconds:
        items = secondItems;
        ctrl = secondCtrl;
        break;
      case _TimeSpinnerType.ampm:
        items = amPmItems;
        ctrl = amPmCtrl;
        break;
    }

    // print('initial page = $selectedIndex');
    return Container(
      height: widget.itemsToShow * widget.itemSize.height,
      width: widget.itemSize.width,
      child: CarouselSlider(
        items: items,
        carouselController: ctrl,
        options: CarouselOptions(
          scrollDirection: Axis.vertical,
          height: widget.itemSize.height,
          enableInfiniteScroll: spinnerType != _TimeSpinnerType.ampm,
          viewportFraction: 1 / (widget.itemsToShow),
          onPageChanged: (index, reason) {
            // print('page changed - $index, $reason');
            _setSelected(type: spinnerType, selectedIndex: index);
            _updateDateTime(spinnerType, index);
          },
          initialPage: selectedIndex,
        ),
      ),
    );
  }

  Widget _timeSpacer({bool isAmPm = false}) {
    return Container(
      width: isAmPm ? widget.apSpacerWidth : widget.spacerWidth,
      // height: _getItemHeight()! * defaultShownIndexes,
      alignment: Alignment.center,
      // color: Colors.purple,
      child: (isAmPm ? widget.amPmSpacerWidget : widget.timeSpacerWidget) ??
          Text(
            isAmPm ? '' : ':',
            style: _getSpacerTextStyle(),
          ),
    );
  }

  TextStyle? _getSpacerTextStyle() {
    return widget.spacerTextStyle?.copyWith(color: widget.selectedItemColor) ??
        defaultSpacerTextStyle;
  }

  TextStyle? _getHighlightedTextStyle() {
    return widget.selectedTextStyle
            ?.copyWith(color: widget.selectedItemColor) ??
        defaultHighlightTextStyle;
  }

  TextStyle? _getNormalTextStyle({double opacity = 1.0}) {
    return widget.normalTextStyle != null
        ? widget.normalTextStyle!
            .copyWith(color: widget.unselectedItemColor.withOpacity(opacity))
        : defaultNormalTextStyle.copyWith(
            color: widget.unselectedItemColor.withOpacity(opacity));
  }

  TextStyle? _getDisabledTextStyle({double opacity = 1.0}) {
    return widget.normalTextStyle != null
        ? widget.normalTextStyle!
            .copyWith(color: widget.disabledItemColor.withOpacity(opacity))
        : defaultNormalTextStyle.copyWith(
            color: widget.disabledItemColor.withOpacity(opacity));
  }

  void _updateDateTime(_TimeSpinnerType type, int index) {
    switch (type) {
      case _TimeSpinnerType.hours:
        int value = index;
        if (!widget.is24HourMode) {
          // print('hour changed, is ampm: ${selectedAmPm == 0 ? 'am' : 'pm'}');
          if (selectedAmPm == 0) {
            // is am -> hour should be between 0 and 11
            value = value % 12;
          } else {
            // is pm -> hour value should be between 12 and 23
            if (value < 12) {
              value = value + 12;
            }
          }
        }
        var potentialNewTime = DateTime.utc(
            time.year, time.month, time.day, value, time.minute, time.second);
        if (potentialNewTime.isBefore(widget.maxTime!)) {
          //print('TIME BUMP VALID, changing time to $potentialNewTime');
          time = potentialNewTime;
        } else {
          // DO NOTHING - timebump is invalid
          //print('TIME BUMP INVALID, DOING NOTHING');
        }
        // time = DateTime.utc(
        //     time.year, time.month, time.day, value, time.minute, time.second);
        // print('hours updated to $index');
        break;
      case _TimeSpinnerType.minutes:
        time = DateTime.utc(time.year, time.month, time.day, time.hour,
            index * widget.minutesInterval, time.second);
        // print('minutes updated to $index');
        break;
      case _TimeSpinnerType.seconds:
        time = DateTime.utc(time.year, time.month, time.day, time.hour,
            time.minute, index * widget.secondsInterval);
        // print('second updated to $index');
        break;
      case _TimeSpinnerType.ampm:
        int amPmValue = index;
        // print('ampm changed to: ${amPmValue == 0 ? 'am' : 'pm'}');
        int hourValue = time.hour;
        if (amPmValue == 0) {
          // is am -> hour should be between 0 and 11
          hourValue = hourValue % 12;
        } else {
          // is pm -> hour value should be between 12 and 23
          if (hourValue < 12) {
            hourValue = hourValue + 12;
          }
        }
        time = DateTime.utc(time.year, time.month, time.day, hourValue,
            time.minute, time.second);
        break;
    }
    widget.onTimeChanged(time);
  }

  @override
  Widget build(BuildContext context) {
    // print('building with time: $selectedHour:$selectedMinute:$selectedSecond');
    // print('minute index: ${selectedMinute ~/ widget.minutesInterval}');
    return Row(
      mainAxisAlignment: widget.horizontalAlignment,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _timeSpinner(
          spinnerType: _TimeSpinnerType.hours,
          selectedIndex: selectedHour,
        ),
        _timeSpacer(),
        _timeSpinner(
          spinnerType: _TimeSpinnerType.minutes,
          selectedIndex: selectedMinute ~/ widget.minutesInterval,
        ),
        widget.showSeconds ? _timeSpacer() : Container(),
        widget.showSeconds
            ? _timeSpinner(
                spinnerType: _TimeSpinnerType.seconds,
                selectedIndex: selectedSecond ~/ widget.secondsInterval,
              )
            : Container(),
        !widget.is24HourMode ? _timeSpacer(isAmPm: true) : Container(),
        !widget.is24HourMode
            ? _timeSpinner(
                selectedIndex: selectedAmPm,
                spinnerType: _TimeSpinnerType.ampm,
              )
            : Container(),
      ],
    );
  }
}
