# Fadeable Date Time Pickers

A set of widgets related to date and time with centered selection and dynamic opacity, coloring, and text styling.

Built on [carousel_slider](pub.dev/packages/carousel_slider)

## Features

- Centered Horizontal Scrolling Date Picker with opacity fade
- Centered Vertical Spinner Time Picker with opacity fade

## Example Web Demo:

Preview Demo:
[https://jeffylo94.github.io/fadeable_date_time_pickers/#/](https://jeffylo94.github.io/fadeable_date_time_pickers/#/)

## Usage

Just create a widget and pass the required params. See example for more detailed usage.

``` dart
FadeableHorizontalDatePicker(
    startDate: DateTime.now().subtract(const Duration(days: 5)),
    endDate: DateTime.now().add(const Duration(days: 5)),
    initialSelectedDate: DateTime.now(),
    widgetWidth: 60,
    onDateSelected: (selectedDateTime) {
        print(selectedDateTime);
    },
);

FadeableSpinnerTimePicker(
    initialTime: DateTime.now(),
    onTimeChanged: (selectedDateTime){
        print('${selectedDateTime.hour}:${selectedDateTime.minute}');
    },
);
```

## License

MIT
