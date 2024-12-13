import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:excel/excel.dart';

void main() {
  runApp(MyClassApp());
}

class MyClassApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Class Attendance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class Student {
  String name;
  String status; // حاضر, غیبت غیر موجه, غیبت موجه

  Student({required this.name, this.status = 'حاضر'});
}

class AttendanceRecord {
  String title;
  String date;
  List<Student> students;

  AttendanceRecord({
    required this.title,
    required this.date,
    required this.students,
  });
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Student> students = [];
  List<AttendanceRecord> records = [];
  String selectedTitle = "اسمعونی";
  DateTime selectedDate = DateTime.now();

  final List<String> titles = [
    "اسمعونی",
    "داستان ما",
    "من یک نوجوانم",
    "مباحثه",
    "ریاضی",
    "انگلیسی",
    "خوشنویسی",
    "بایدها و نبایدها",
    "برنامه ویژه",
  ];

  void addStudent(String name) {
    setState(() {
      students.add(Student(name: name));
    });
  }

  void updateStatus(int index, String status) {
    setState(() {
      students[index].status = status;
    });
  }

  void saveRecord() {
    String date = getShamsiDate(selectedDate);
    AttendanceRecord record = AttendanceRecord(
      title: selectedTitle,
      date: date,
      students: List.from(students),
    );
    setState(() {
      records.add(record);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Record saved successfully!")),
    );
  }

  String getShamsiDate(DateTime date) {
    HijriCalendar shamsiDate = HijriCalendar.fromDate(date);
    return shamsiDate.toFormat("dd MMM yyyy");
  }

  String generateAttendanceText(AttendanceRecord record) {
    String text = "💠 لیست حضور غیاب کلاس ${record.title}\n";
    text += "🔸 ${record.date}\n\n";

    for (var student in record.students) {
      String emoji = student.status == "حاضر"
          ? "✅"
          : student.status == "غیبت غیر موجه"
              ? "❌"
              : "❌✔️";
      text += "${student.name} $emoji\n";
    }

    text += "\n#حضوروغیاب";
    return text;
  }

  void exportToExcel() {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Attendance'];

    // Header row
    sheet.appendRow(['Name'] + records.map((r) => '${r.title} (${r.date})').toList());

    // Data rows
    for (var student in records[0].students) {
      List<String> row = [student.name];
      for (var record in records) {
        var found = record.students.firstWhere((s) => s.name == student.name, orElse: () => Student(name: ''));
        row.add(found.status);
      }
      sheet.appendRow(row);
    }

    // Save file (simulate export)
    excel.save(fileName: "attendance.xlsx");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Excel exported successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Class Attendance"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedTitle,
              items: titles.map((title) {
                return DropdownMenuItem(value: title, child: Text(title));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTitle = value!;
                });
              },
            ),
            ListTile(
              title: Text("Select Date"),
              subtitle: Text(getShamsiDate(selectedDate)),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(students[index].name),
                    trailing: DropdownButton<String>(
                      value: students[index].status,
                      items: ['حاضر', 'غیبت غیر موجه', 'غیبت موجه'].map((status) {
                        return DropdownMenuItem(value: status, child: Text(status));
                      }).toList(),
                      onChanged: (value) {
                        updateStatus(index, value!);
                      },
                    ),
                  );
                },
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: "Add Student Name",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  addStudent(value);
                }
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: saveRecord,
                  child: Text("Save Record"),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: exportToExcel,
                  child: Text("Export to Excel"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
