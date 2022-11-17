import 'package:fadeable_date_time_pickers/fadeable_date_time_pickers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Fadeable Date Time Pickers Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _dateSelection2 = DateTime.now();
  final int _maxDayRange = 5;

  final DateTime _initialTime = DateTime.now();
  // DateTime createdOn = DateTime(2022, 6, 30, 10, 30, 10);
  DateTime createdOn = DateTime.now();

  DateTime _timeSelection = DateTime.now();
  // DateTime _initialTime = DateTime(2022, 6, 29, 13, 35);
  // DateTime _timeSelection = DateTime(2022, 6, 29, 13, 35);
  DateTimePickerController dtController =
      DateTimePickerController(value: DateTime(2022, 6, 29, 13, 35));

  @override
  void initState() {
    dtController = DateTimePickerController(
        value: DateTime(
            _dateSelection2.year,
            _dateSelection2.month,
            _dateSelection2.day,
            _timeSelection.hour,
            _timeSelection.minute,
            _timeSelection.second));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              const Text('Today is:'),
              DateItemWidget(
                dateTime: DateTime.now(),
                dateItemState: DateItemState.active,
                width: 100,
                height: 80,
                dateItemComponentList: const [
                  DateItem.weekDay,
                  DateItem.day,
                  DateItem.month
                ],
              ),
              const SizedBox(
                height: 20,
              ),

              /// 5 DAYS BEFORE
              Text('picker w/ $_maxDayRange days before'),
              FadeableHorizontalDatePicker(
                key: const Key('dp1'),
                startDate: createdOn.subtract(Duration(
                    days: _maxDayRange,
                    hours: createdOn.hour,
                    minutes: createdOn.minute,
                    seconds: createdOn.second)),
                endDate: DateTime.now(),
                initialSelectedDate: _initialTime.roundNearestMinute(
                    const Duration(minutes: 15), true),
                dateItemTextColor: const StateColor(
                  normalColor: Colors.black,
                  disabledColor: Color.fromRGBO(142, 142, 142, 0.1),
                  selectedColor: Colors.lightGreen,
                ),
                dateItemTextWeight: const StateFontWeight(
                  normalWeight: FontWeight.w400,
                  selectedWeight: FontWeight.w500,
                  disabledWeight: FontWeight.w100,
                ),
                dateItemContainerWidth: 50,
                dayTextStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                monthTextStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                weekDayTextStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                dateItemComponentList: const [
                  DateItem.weekDay,
                  DateItem.day,
                  DateItem.month,
                ],
                enableDistanceFade: true,
                maximumFadeDays: 3,
                widgetWidth: MediaQuery.of(context).size.width * 0.7,
                daysInViewport: 15,
                onDateSelected: (selectedDate) {
                  setState(() {
                    _dateSelection2 = selectedDate;
                    var updatedDate = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      _timeSelection.hour,
                      _timeSelection.minute,
                      _timeSelection.second,
                    );
                    dtController.currentDate = updatedDate;
                  });
                },
              ),
              Text(DateFormat.yMMMd().format(_dateSelection2)),
              const SizedBox(
                height: 40,
              ),

              const Text('TIME PICKER'),
              // Container(
              //   width: MediaQuery.of(context).size.width * 0.7,
              //   child: FadeableSpinnerTimePicker(
              //     key: const Key('tp1'),
              //     // initialTime: DateTime.now(),
              //     initialTime: DateTime(2022, 6, 27, 12, 55),
              //     enableMaxTime: true,
              //     onTimeChanged: (dt) {
              //       print('date changed to : $dt');
              //       setState(() {
              //         _timeSelection = dt;
              //       });
              //     },
              //     minutesInterval: 15,
              //     secondsInterval: 15,
              //     itemSize: const Size(60, 40),
              //     amPmSpacerWidget: Container(),
              //     // unselectedItemColor: Color.fromARGB(255, 54, 54, 54),
              //     spacerTextStyle: const TextStyle(
              //       fontWeight: FontWeight.w400,
              //       fontSize: 25,
              //     ),
              //     selectedItemColor: Colors.lightGreen,
              //     selectedTextStyle: const TextStyle(
              //       fontWeight: FontWeight.w400,
              //       fontSize: 25,
              //     ),
              //     // spacerWidth: MediaQuery.of(context).size.width * (0.7/5),
              //   ),
              // ),
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 200,
                child: FadeableSpinnerTimePicker(
                  initialTime: _timeSelection,
                  dtController: dtController,
                  maxTime: _initialTime.roundNearestMinute(
                      const Duration(minutes: 15), true),
                  // minTime: _initialTime.subtract(Duration(
                  //     days: _maxDayRange,
                  //     hours: _initialTime.hour,
                  //     minutes: _initialTime.minute,
                  //     seconds: _initialTime.second)),
                  minutesInterval: 15,
                  showSeconds: false,
                  onTimeChanged: (DateTime dt) {
                    print('time changed $dt');
                    setState(() {
                      _timeSelection = dt;
                    });
                  },
                ),
              ),
              Text(DateFormat.yMMMd().add_jms().format(_timeSelection)),

              // FadeableHorizontalDatePicker(
              //     startDate: DateTime.now().subtract(const Duration(days: 5)),
              //     endDate: DateTime.now().add(const Duration(days: 5)),
              //     initialSelectedDate: DateTime.now(),
              //     widgetWidth: MediaQuery.of(context).size.width * 0.5,
              //     // dateItemContainerWidth: 100,
              //     // daysInViewport: 5,
              //     // dateItemContainerColor: StateColor(normalColor: Colors.orange),
              //     onDateSelected: (selectedDateTime) {
              //       print(selectedDateTime);
              //     },
              //   ),

              // FadeableSpinnerTimePicker(
              //   initialTime: DateTime.now(),
              //   minutesInterval: 5,
              //   onTimeChanged: (selectedDateTime) {
              //     print(DateFormat.Hm().format(selectedDateTime));
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
