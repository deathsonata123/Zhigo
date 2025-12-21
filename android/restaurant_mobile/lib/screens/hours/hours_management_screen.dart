import 'package:flutter/material.dart';

class HoursManagementScreen extends StatefulWidget {
  const HoursManagementScreen({super.key});

  @override
  State<HoursManagementScreen> createState() => _HoursManagementScreenState();
}

class _HoursManagementScreenState extends State<HoursManagementScreen> {
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final Map<String, Map<String, dynamic>> _hours = {
    'Monday': {'open': true, 'openTime': '09:00', 'closeTime': '22:00'},
    'Tuesday': {'open': true, 'openTime': '09:00', 'closeTime': '22:00'},
    'Wednesday': {'open': true, 'openTime': '09:00', 'closeTime': '22:00'},
    'Thursday': {'open': true, 'openTime': '09:00', 'closeTime': '22:00'},
    'Friday': {'open': true, 'openTime': '09:00', 'closeTime': '23:00'},
    'Saturday': {'open': true, 'openTime': '10:00', 'closeTime': '23:00'},
    'Sunday': {'open': true, 'openTime': '10:00', 'closeTime': '21:00'},
  };

  Future<void> _selectTime(BuildContext context, String day, bool isOpenTime) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        if (isOpenTime) {
          _hours[day]!['openTime'] = timeString;
        } else {
          _hours[day]!['closeTime'] = timeString;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operating Hours'),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hours saved successfully')),
              );
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final day = _days[index];
          final dayHours = _hours[day]!;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Switch(
                        value: dayHours['open'],
                        onChanged: (value) {
                          setState(() {
                            _hours[day]!['open'] = value;
                          });
                        },
                      ),
                    ],
                  ),
                  if (dayHours['open']) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _selectTime(context, day, true),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.access_time, size: 18),
                                const SizedBox(width: 8),
                                Text('Open: ${dayHours['openTime']}'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('to'),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _selectTime(context, day, false),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.access_time, size: 18),
                                const SizedBox(width: 8),
                                Text('Close: ${dayHours['closeTime']}'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else
                    const SizedBox(height: 8),
                  if (!dayHours['open'])
                    const Text(
                      'Closed',
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
