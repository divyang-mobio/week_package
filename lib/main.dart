import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:time_range_picker/time_range_picker.dart';

void main() => runApp(_FlutterWeekViewDemoApp());

class _FlutterWeekViewDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Week View Demo',
        initialRoute: '/',
        routes: {
          '/': (context) => _DynamicDayView(),
        },
      );
}

class _DynamicDayView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DynamicDayViewState();
}

class _DynamicDayViewState extends State<_DynamicDayView> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _des = TextEditingController();
  List<FlutterWeekViewEvent> events = [];

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo dynamic day view'),
        actions: [
          IconButton(
            onPressed: () async {
              final data = await alert(context, _title, _des, events);
              if (data is FlutterWeekViewEvent) {
                events.add(data);
                setState(() {});
              }
              _title.clear();
              _des.clear();
            },
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: DayView(date: now, events: events),
    );
  }
}

alert(context, TextEditingController title, TextEditingController dec,
    List<FlutterWeekViewEvent> events) async {
  bool isAvailable = true;
  DateTime now = DateTime.now();
  TimeRange? result = await showTimeRangePicker(
      context: context,
      start: const TimeOfDay(hour: 9, minute: 0),
      end: const TimeOfDay(hour: 12, minute: 0),
      disabledTime: TimeRange(
          startTime: const TimeOfDay(hour: 24, minute: 0),
          endTime: const TimeOfDay(hour: 0, minute: 0)),
      disabledColor: Colors.red.withOpacity(0.5),
      strokeWidth: 4,
      ticks: 24,
      ticksOffset: -7,
      ticksLength: 15,
      ticksColor: Colors.grey,
      labels: ["12 am", "3 am", "6 am", "9 am", "12 pm", "3 pm", "6 pm", "9 pm"]
          .asMap()
          .entries
          .map((e) {
        return ClockLabel.fromIndex(idx: e.key, length: 8, text: e.value);
      }).toList(),
      labelOffset: 35,
      rotateLabels: false,
      padding: 60);

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Title'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              TextField(
                  controller: title,
                  decoration: const InputDecoration(hintText: "title")),
              const SizedBox(height: 10),
              TextField(
                  controller: dec,
                  decoration: const InputDecoration(hintText: "description"))
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
              child: const Text('ok'),
              onPressed: () => Navigator.of(context).pop()),
        ],
      );
    },
  );

  if (events.isNotEmpty && result != null) {
    for (var i in events) {
      if ((i.start.hour <= result.startTime.hour ||
              i.end.hour >= result.startTime.hour) &&
          (i.start.hour <= result.startTime.hour ||
              i.end.hour >= result.endTime.hour) &&
          (i.start.minute <= result.startTime.minute ||
              i.end.minute >= result.startTime.minute) &&
          (i.start.minute <= result.startTime.minute ||
              i.end.minute >= result.endTime.minute)) {
        isAvailable = false;
      }
    }
  }

  if (result != null && isAvailable) {
    return FlutterWeekViewEvent(
        title: title.text,
        start: DateTime(now.year, now.month, now.day, result.startTime.hour,
            result.startTime.minute),
        end: DateTime(now.year, now.month, now.day, result.endTime.hour,
            result.endTime.minute),
        description: dec.text);
  } else {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Other event is set on that time period"),
          actions: <Widget>[
            TextButton(
                child: const Text('Exit'),
                onPressed: () => Navigator.of(context).pop()),
          ],
        );
      },
    );
  }
}
