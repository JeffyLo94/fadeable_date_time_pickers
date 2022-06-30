
import 'package:flutter/material.dart';




class DateTimePickerController extends ValueNotifier<DateTime> {
  DateTimePickerController({required DateTime value}) : super(value);

  DateTime get currentDate => value;

  set currentDate(DateTime dt){
    value = dt;

    if(updateDateTime != null){
      updateDateTime!();
    }
  }

  void Function()? updateDateTime;
  

}