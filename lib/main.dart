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
