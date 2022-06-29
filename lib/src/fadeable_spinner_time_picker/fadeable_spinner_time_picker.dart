// library fadeable_spinner_time_picker;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

enum _TimeSpinnerType {
  hours,
  minutes,
  seconds,
  ampm,
}

class FadeableSpinnerTimePicker extends StatefulWidget {
  const FadeableSpinnerTimePicker({
    Key? key,
    required this.initialTime,
    required this.onTimeChanged,
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
    this.enableDistanceFade = true,
    this.maximumFadeItems = 3,
  }) : super(key: key);

  /// Required initial time picker shows
  final DateTime initialTime;

  /// determines if picker is in a 24 hour style
  /// if false, shows AM PM
  final bool is24HourMode;

  /// determines whether picker shows seconds
  final bool showSeconds;

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
    DateTime time = widget.initialTime;

    _initTime();
    // _initTimeListItemWidgets();
    _setSelected(type: _TimeSpinnerType.hours, selectedIndex: selectedHour);
    _setSelected(
        type: _TimeSpinnerType.minutes, selectedIndex: _selectedMinuteIndex);
    _setSelected(
        type: _TimeSpinnerType.seconds, selectedIndex: _selectedSecondIndex);
    _setSelected(type: _TimeSpinnerType.ampm, selectedIndex: selectedAmPm);
    super.initState();
  }

  int get _selectedMinuteIndex {
    // print(
    // 'selected minutes index = ($selectedMinute / ${widget.minutesInterval}) = ${(selectedMinute / widget.minutesInterval).round()}');
    final calculatedIndex = (selectedMinute / widget.minutesInterval).round();
    return calculatedIndex >= minuteItems.length ? 0 : calculatedIndex;
  }

  int get _selectedSecondIndex {
    final calculatedIndex = (selectedSecond / widget.secondsInterval).round();
    return calculatedIndex >= secondItems.length ? 0 : calculatedIndex;
  }

  void _setSelected(
      {required _TimeSpinnerType type, required int selectedIndex}) {
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
          hourItems[selectedIndex] = _generateTimeWidget(
            value,
            isHours: true,
            isSelected: true,
            ctrl: hourCtrl,
            index: selectedIndex,
          );
          _setSurrounding(
            selectedIndex,
            hourItems,
            hourCtrl,
            type,
          );
          break;
        case _TimeSpinnerType.minutes:
          minuteItems = _generateTimeItems(
              max: _getMinuteCount(),
              interval: widget.minutesInterval,
              type: type,
              ctrl: minuteCtrl);
          selectedMinute = selectedIndex * widget.minutesInterval;
          minuteItems[selectedIndex] = _generateTimeWidget(
            selectedMinute,
            isHours: false,
            isSelected: true,
            ctrl: minuteCtrl,
            index: selectedIndex,
          );
          _setSurrounding(
            selectedIndex,
            minuteItems,
            minuteCtrl,
            type,
          );
          break;
        case _TimeSpinnerType.seconds:
          secondItems = _generateTimeItems(
            max: _getSecondCount(),
            interval: widget.secondsInterval,
            type: type,
            ctrl: secondCtrl,
          );
          selectedSecond = selectedIndex * widget.secondsInterval;
          secondItems[selectedIndex] = _generateTimeWidget(
            selectedSecond,
            isHours: false,
            isSelected: true,
            ctrl: secondCtrl,
            index: selectedIndex,
          );
          _setSurrounding(
            selectedIndex,
            secondItems,
            secondCtrl,
            type,
          );
          break;
        case _TimeSpinnerType.ampm:
          selectedAmPm = selectedIndex;
          amPmItems = _generateAmPmItems(selectedIndex: selectedIndex);
          break;
      }
    });
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
        distanceFromSelected: diff,
      );
    }
  }

  List<Widget> _generateAmPmItems({int selectedIndex = -1}) {
    List<Widget> widgets = [];
    for (int i = 0; i < 2; i++) {
      var fadeScale = 1 / widget.maximumFadeItems;
      var opacity = 1.0;
      opacity = 1.0 - (1 * fadeScale);
      opacity = opacity > 0.1 ? opacity : 0.1;
      widgets.add(GestureDetector(
        onTap: () {
          // print('tap detected $i');
          amPmCtrl.jumpToPage(i);
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
                : _getNormalTextStyle(opacity: opacity),
          ),
        ),
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

    return GestureDetector(
      onTap: () {
        // print('tap detected - $index');
        ctrl.jumpToPage(index);
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
              : _getNormalTextStyle(opacity: opacity),
        ),
      ),
    );
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
      ));
    }
    return widgets;
  }

  void _initTime() {
    setState(() {
      selectedHour = widget.initialTime.hour;
      selectedMinute = widget.initialTime.minute;
      selectedSecond = widget.initialTime.second;
      selectedAmPm = widget.initialTime.hour >= 12 ? 1 : 0;
    });
    // print('time inited to: ${selectedHour}:$selectedMinute:$selectedSecond');
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
        time = DateTime.utc(
            time.year, time.month, time.day, value, time.minute, time.second);
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

  @override
  Widget build(BuildContext context) {
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
          selectedIndex: _selectedMinuteIndex,
        ),
        widget.showSeconds ? _timeSpacer() : Container(),
        widget.showSeconds
            ? _timeSpinner(
                spinnerType: _TimeSpinnerType.seconds,
                selectedIndex: _selectedSecondIndex,
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
            _setSelected(type: spinnerType, selectedIndex: index);
            _updateDateTime(spinnerType, index);
          },
          initialPage: selectedIndex,
        ),
      ),
    );
  }
}
