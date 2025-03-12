import 'package:flutter_test/flutter_test.dart';

import 'package:fadeable_date_time_pickers/fadeable_date_time_pickers.dart';

void main() {
  // test('adds one to input values', () {
  //   final calculator = Calculator();
  //   expect(calculator.addOne(2), 3);
  //   expect(calculator.addOne(-7), -6);
  //   expect(calculator.addOne(0), 1);
  // });

  test('create horizontal date picker', () {
    final FadeableHorizontalDatePicker picker = FadeableHorizontalDatePicker(
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 5)),
      initialSelectedDate: DateTime.now(),
      widgetWidth: 60,
      onDateSelected: (selectedDateTime) {
        // print(selectedDateTime);
      },
    );
  });

  test('create spinner time picker', () {
    final FadeableSpinnerTimePicker timePicker = FadeableSpinnerTimePicker(
      initialTime: DateTime.now(),
      onTimeChanged: (selectedDateTime){
        // print('${selectedDateTime.hour}:${selectedDateTime.minute}');
      },
    );
  });
}
