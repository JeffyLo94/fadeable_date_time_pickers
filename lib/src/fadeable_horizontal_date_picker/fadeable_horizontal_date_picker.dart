// library fadeable_horizontal_date_picker;

// export 'date_item_models.dart';
// export 'date_item_widget.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:fadeable_date_time_pickers/src/utils/time_utils.dart';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'date_item_models.dart';
import 'date_item_widget.dart';

class FadeableHorizontalDatePicker extends StatefulWidget {
  const FadeableHorizontalDatePicker({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.initialSelectedDate,
    required this.widgetWidth,
    required this.onDateSelected,
    this.dateItemComponentList = const <DateItem>[
      DateItem.month,
      DateItem.day,
      DateItem.weekDay
    ],
    this.locale,
    this.dateItemContainerWidth = 60,
    this.widgetHeight = 80,
    this.dateItemContainerColor,
    this.dateItemTextColor = const StateColor(
      normalColor: Colors.black,
      disabledColor: Colors.grey,
      selectedColor: Colors.blue,
    ),
    this.dateItemTextWeight =
        const StateFontWeight(normalWeight: FontWeight.normal),
    this.dayTextStyle = const TextStyle(fontSize: 18),
    this.monthTextStyle = const TextStyle(fontSize: 12),
    this.weekDayTextStyle = const TextStyle(fontSize: 12),
    this.enableDistanceFade = true,
    this.maximumFadeDays,
    this.daysInViewport = 6.5,
    this.hideDisabled = true,
  }) : super(key: key);

  ///picker start date
  final DateTime startDate;

  ///picker end date
  final DateTime endDate;

  ///default selected date
  final DateTime initialSelectedDate;

  /// if null, the locale will use the system default one
  /// locale String like "de", can be found via
  /// https://api.flutter.dev/flutter/date_symbol_data_http_request/availableLocalesForDateFormatting.html
  /// or use locale.toString()
  final String? locale;

  /// each date item container's width
  /// the [daysInViewport] property adjusts the distance between items
  final double dateItemContainerWidth;

  ///whole widget's width
  final double widgetWidth;

  ///whole widget's height
  final double widgetHeight;

  ///callback when a new date selected
  final void Function(DateTime value) onDateSelected;

  ///controller controls the visible position of the picker
  ///this controller will share both internal and external use
  ///this is required
  // final CenterScrolledDatePickerController datePickerController;

  /// state based background color of [DateItemWidget]
  final StateColor? dateItemContainerColor;

  /// state based text color of [DateItemWidget]
  final StateColor dateItemTextColor;

  /// state based font weight of [DateItemWidget]
  final StateFontWeight dateItemTextWeight;

  /// TextStyle of the month label in the [DateItemWidget]
  ///
  /// Color and Weight are overridden by [dateItemTextColor] and [dateItemTextWeight]
  final TextStyle monthTextStyle;

  /// TextStyle of the day label in the [DateItemWidget]
  ///
  /// Color and Weight are overridden by [dateItemTextColor] and [dateItemTextWeight]
  final TextStyle dayTextStyle;

  /// TextStyle of the weekday label in the [DateItemWidget]
  ///
  /// Color and Weight are overridden by [dateItemTextColor] and [dateItemTextWeight]
  final TextStyle weekDayTextStyle;

  /// Enable color of date items futher from - true by default
  final bool enableDistanceFade;

  /// Overrides the default fade calculations to instead be at maximum fade by the specified [maximumFadeDays] around the selected date
  final double? maximumFadeDays;

  /// Specify the [daysInViewport] to adjust days shown in widget - for best look use an odd number
  final double daysInViewport;

  /// Hide Disabled Dates - True by default
  final bool hideDisabled;

  /// Date item display setting
  /// default set as month, day, day of week, from top to bottom
  /// at least one info must be in the list
  final List<DateItem> dateItemComponentList;

  @override
  FadeableHorizontalDatePickerState createState() =>
      FadeableHorizontalDatePickerState();
}

class FadeableHorizontalDatePickerState
    extends State<FadeableHorizontalDatePicker> {
  double _padding = 0.0;

  final CarouselSliderController _carouselController =
      CarouselSliderController();
  DateTime selectedDate = DateTime.now().toUtc();
  DateTime startDate = DateTime.now().toUtc();
  DateTime endDate = DateTime.now().toUtc();
  int selectedIndex = 0;

  List<DateTime> possibleDates = [];

  @override
void initState() {
    _init(
      widget.widgetWidth,
      widget.dateItemContainerWidth,
      widget.initialSelectedDate,
    );

    // Converting all start/end dates to 2am Locale
    startDate = DateTime.utc(
        widget.startDate.year, widget.startDate.month, widget.startDate.day, 2);
    endDate = DateTime.utc(
        widget.endDate.year, widget.endDate.month, widget.endDate.day, 2);

    if (!startDate.isUtc) {
      // print('START DATE IS NOT UTC)');
      startDate = startDate.toUtc();
    } else {
      startDate = startDate;
    }
    if (!endDate.isUtc) {
      endDate = endDate.toUtc();
    } else {
      endDate = endDate;
    }
    // print('start date: $startDate');
    // print('end date: $endDate');
    var numDates = endDate.daysBetween(startDate).abs();
    // var numDates = endDate.difference(startDate).inDays;
    // print('Total Possible days: $numDates');
    setState(() {
      for (int i = 0; i <= numDates; i++) {
        if (i != numDates) {
          // print(
          //     'Adding Possible Dates: ${startDate.addDate(days: i)}} is utc? ${startDate.addDate(days: i).isUtc}');
          possibleDates.add(startDate.addDate(days: i));
        } else {
          //  print(
          //     'Adding End Date: ${endDate}');
          possibleDates.add(endDate);
        }

        if (_isSelectedDate(startDate.addDate(days: i))) {
          // print('SELECTED DATE: ${startDate.addDate(days: i)}');
          selectedIndex = i;
          // print('Selected Index: $selectedIndex');
        } else {
        //   print('NOT SELECTED DATE: ${startDate.addDate(days: i)}, initialSelectedDate: ${DateTime.utc(widget.initialSelectedDate.year, widget.initialSelectedDate.month,
        // widget.initialSelectedDate.day, 2)}');
        }
      }
      // possibleDates.forEach(print);
    });

    super.initState();
    initializeDateFormatting(widget.locale, null);
  }

  @override
  Widget build(BuildContext context) {
    final int totalDays = endDate.difference(startDate).inDays.abs();
    double fadeScaleValue = 0;
    if (widget.enableDistanceFade) {
      if (widget.maximumFadeDays != null) {
        // use maximum fade days
        fadeScaleValue = (1 / (widget.maximumFadeDays!.abs()));
      } else {
        // use relative fading
        fadeScaleValue = (1 / totalDays);
      }
    }

    // print('viewport: 1/${widget.daysInViewport}');
    // print('possible dates: ${possibleDates.length}');
    // print('fadeScaleValue: $fadeScaleValue');
    return SizedBox(
      height: widget.widgetHeight,
      width: widget.widgetWidth,
      child: CarouselSlider.builder(
        options: CarouselOptions(
          scrollDirection: Axis.horizontal,
          height: widget.widgetHeight,
          viewportFraction: 1 / (widget.daysInViewport),
          enableInfiniteScroll: false,
          initialPage: selectedIndex,
          onPageChanged: (index, reason) {
            setState(() {
              selectedDate = possibleDates[index];
              widget.onDateSelected(possibleDates[index]);
              selectedIndex = index;
            });
          },
        ),
        carouselController: _carouselController,
        itemCount: possibleDates.length,
        itemBuilder: (context, index, realIndex) {
          if (index >= possibleDates.length) {
            return Container();
          }
          var dateTime = possibleDates[index];

          double distanceFromSelected =
              selectedDate.daysBetween(dateTime).abs().toDouble();

          DateItemState dateItemState = _getDateTimeState(dateTime);
          // print('isDateTime in UTC? ${dateTime.isUtc}');
          // print(
          //     'UTC Date Time: $dateTime vs LOCAL Date Time: ${dateTime.toLocal()}');

          return GestureDetector(
            onTap: () {
              if (dateItemState != DateItemState.disabled) {
                setState(() {
                  selectedDate = dateTime;
                  widget.onDateSelected(dateTime);
                  selectedIndex = index;
                  _carouselController.jumpToPage(index);
                  distanceFromSelected =
                      selectedDate.daysBetween(dateTime).abs().toDouble();
                });
              }
            },
            child: DateItemWidget(
              locale: widget.locale,
              dateTime: dateTime.toLocal(),
              padding: _padding,
              width: widget.dateItemContainerWidth,
              height: widget.widgetHeight,
              dateItemState: dateItemState,
              dayTextStyle: widget.dayTextStyle,
              monthTextStyle: widget.monthTextStyle,
              weekDayTextStyle: widget.weekDayTextStyle,
              textColor: widget.dateItemTextColor,
              textWeight: widget.dateItemTextWeight,
              containerColor: widget.dateItemContainerColor,
              dateItemComponentList: widget.dateItemComponentList,
              fadeIntensity: distanceFromSelected,
              fadeScale: fadeScaleValue,
              hideDisabled: widget.hideDisabled,
            ),
          );
        },
      ),
    );
  }

  // double _getDayDifference(DateTime first, DateTime second) {
  //   return second.difference(first).inDays.abs().toDouble();
  // }

  DateItemState _getDateTimeState(DateTime dateTime) {
    if (_isSelectedDate(dateTime)) {
      return DateItemState.selected;
    } else {
      if (_isWithinRange(dateTime)) {
        return DateItemState.active;
      } else {
        return DateItemState.disabled;
      }
    }
  }

  bool _isSelectedDate(DateTime dateTime) {
    return dateTime.toUtc().year == selectedDate.toUtc().year &&
        dateTime.toUtc().month == selectedDate.toUtc().month &&
        dateTime.toUtc().day == selectedDate.toUtc().day;
  }

  void _init(
    // CenterScrolledDatePickerController controller,
    double ttlWidth,
    double width,
    DateTime initialSelectedDate,
  ) {
    int maxRowChild = 0;
    double widgetWidth = ttlWidth;

    maxRowChild = (widgetWidth / width).floor();

    //calc padding(L+R)
    _padding = (widgetWidth - (maxRowChild * width)) / maxRowChild;

    selectedDate = DateTime.utc(initialSelectedDate.year, initialSelectedDate.month,
        initialSelectedDate.day, 2);
  }

  bool _isWithinRange(DateTime dateTime) {
    // print('RANGE dateTime: $dateTime, startDate: $startDate, endDate: $endDate');
    // print(
    //     'RANGE: ${dateTime.compareTo(startDate)} >= 0 && ${dateTime.compareTo(endDate)} <= 0');

    return dateTime.compareTo(startDate) >= 0 &&
        dateTime.compareTo(endDate) <= 0;
  }
}
