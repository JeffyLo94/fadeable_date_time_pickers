import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'date_item_models.dart';

class DateItemWidget extends StatelessWidget {
  const DateItemWidget({
    Key? key,
    required this.dateTime,
    required this.dateItemState,
    required this.width,
    required this.height,
    required this.dateItemComponentList,
    this.locale,
    this.padding = 0.0,
    this.monthTextStyle,
    this.dayTextStyle,
    this.weekDayTextStyle,
    this.containerColor,
    this.textColor,
    this.textWeight,
    this.hideDisabled = true,
    this.fadeIntensity = 0.0,
    this.fadeScale = 0.2,
  }) : super(key: key);

  final bool hideDisabled;

  ///display [DateTime]
  final DateTime dateTime;

  ///State of the date
  final DateItemState dateItemState;

  /// if not provided, locale defaults to  system locale
  final String? locale;

  ///padding of the item widget
  final double padding;
  final double width;
  final double height;
  final TextStyle? monthTextStyle;
  final TextStyle? dayTextStyle;
  final TextStyle? weekDayTextStyle;
  final StateColor? containerColor;

  /// Overrides Text Style Color
  final StateColor? textColor;

  /// Overrides Text Font Weight
  final StateFontWeight? textWeight;

  final double fadeIntensity;
  final double fadeScale;

  /// Used to what [DateItem] components are shown.
  ///
  /// Items are displayed in order of list
  final List<DateItem> dateItemComponentList;

  @override
  Widget build(BuildContext context) {
    var locale = this.locale ?? Intl.getCurrentLocale();
    double opacity = hideDisabled ? 0.0 : 1.0;

    opacity = 1.0 - (fadeIntensity * fadeScale);
    opacity = opacity > 0.1 ? opacity : 0.1;

    // print('$dateTime -- 1-($fadeIntensity*$fadeScale) opacity value: $opacity');
    // print('$dateTime - hideDisabled=$hideDisabled -> showContainer $hideDisabled && ${dateItemState == DateItemState.disabled} - color: ${_getTextColorByState(dateItemState)?.withOpacity(opacity)}');

    return (hideDisabled && dateItemState == DateItemState.disabled)
        ? Container(
            width: width + padding,
            height: height,
            padding: EdgeInsets.only(left: padding / 2, right: padding / 2),
            color: _getContainerColorByState(dateItemState),
            alignment: Alignment.center,
          )
        : Container(
            width: width + padding,
            height: height,
            padding: EdgeInsets.only(left: padding / 2, right: padding / 2),
            color: _getContainerColorByState(dateItemState),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(
                dateItemComponentList.length,
                (index) {
                  switch (dateItemComponentList[index]) {
                    case DateItem.weekDay:
                      return Text(
                        DateFormat.E(locale).format(dateTime),
                        style: weekDayTextStyle != null
                            ? weekDayTextStyle!.copyWith(
                                color: _getTextColorByState(dateItemState)
                                    ?.withOpacity(opacity),
                                fontWeight:
                                    _getTextWeightByState(dateItemState),
                              )
                            : TextStyle(
                                color: _getTextColorByState(dateItemState)
                                    ?.withOpacity(opacity),
                                fontWeight:
                                    _getTextWeightByState(dateItemState),
                              ),
                      );
                    case DateItem.day:
                      return Text(
                        DateFormat.d(locale).format(dateTime),
                        style: dayTextStyle != null
                            ? dayTextStyle!.copyWith(
                                color: _getTextColorByState(dateItemState)
                                    ?.withOpacity(opacity),
                                fontWeight:
                                    _getTextWeightByState(dateItemState),
                              )
                            : TextStyle(
                                color: _getTextColorByState(dateItemState)
                                    ?.withOpacity(opacity),
                                fontWeight:
                                    _getTextWeightByState(dateItemState),
                              ),
                      );
                    case DateItem.month:
                      return Text(
                        DateFormat.MMM(locale).format(dateTime),
                        style: monthTextStyle != null
                            ? monthTextStyle!.copyWith(
                                color: _getTextColorByState(dateItemState)
                                    ?.withOpacity(opacity),
                                fontWeight:
                                    _getTextWeightByState(dateItemState),
                              )
                            : TextStyle(
                                color: _getTextColorByState(dateItemState)
                                    ?.withOpacity(opacity),
                                fontWeight:
                                    _getTextWeightByState(dateItemState),
                              ),
                      );
                    default:
                      return Container();
                  }
                },
              ),
            ),
          );
  }

  Color? _getContainerColorByState(DateItemState state) {
    switch (state) {
      case DateItemState.active:
        return containerColor?.normalColor;
      case DateItemState.selected:
        return containerColor?.selectedColor;
      case DateItemState.disabled:
      default:
        return containerColor?.disabledColor;
    }
  }

  Color? _getTextColorByState(DateItemState state) {
    switch (state) {
      case DateItemState.active:
        return textColor?.normalColor;
      case DateItemState.selected:
        return textColor?.selectedColor;
      case DateItemState.disabled:
      default:
        return textColor?.disabledColor;
    }
  }

  FontWeight? _getTextWeightByState(DateItemState state) {
    switch (state) {
      case DateItemState.active:
        return textWeight?.normalWeight;
      case DateItemState.selected:
        return textWeight?.selectedWeight;
      case DateItemState.disabled:
      default:
        return textWeight?.disabledWeight;
    }
  }
}
