import 'package:flutter/material.dart';

/// State of the date item
///
/// [active] = date within the start-end date range
///
/// [selected] = date that is currently selected
///
/// [disabled] = appended date at the beginning or end of picker (out of start-end rnage)
enum DateItemState { active, selected, disabled }

/// Date Items - used with the date item widget to specify what is shown
///
/// [month] - 3 Letter Month Abbreviation
///
/// [day] - The day value of date
///
/// [weekDay] - The string name of the day
enum DateItem { month, day, weekDay }

/// if selected and disabled are not specified, will default to normal color
class StateColor {
  const StateColor({
    this.normalColor = Colors.black,
    Color? selectedColor,
    Color? disabledColor,
  }) : selectedColor = selectedColor ?? normalColor,
  disabledColor = disabledColor ?? normalColor;

  final Color normalColor;
  final Color selectedColor;
  final Color disabledColor;
}

/// if selected and disabled are not specified, will default to normal color
class StateFontWeight {
  const StateFontWeight({
    this.normalWeight = FontWeight.normal,
    FontWeight? selectedWeight,
    FontWeight? disabledWeight,
  }) :
    selectedWeight = selectedWeight ?? normalWeight,
    disabledWeight = disabledWeight ?? normalWeight;

  final FontWeight normalWeight;
  final FontWeight selectedWeight;
  final FontWeight disabledWeight;
}