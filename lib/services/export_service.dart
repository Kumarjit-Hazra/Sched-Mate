import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../models/class_schedule.dart';

class ExportService {
  Future<String> exportToPDF(List<ClassSchedule> schedules) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Class Schedule',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: context,
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              headerHeight: 25,
              cellHeight: 40,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.centerLeft,
              },
              headerStyle: pw.TextStyle(
                color: PdfColors.black,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: const pw.TextStyle(fontSize: 10),
              headers: ['Day', 'Subject', 'Time', 'Teacher'],
              data:
                  schedules
                      .map(
                        (schedule) => [
                          schedule.day,
                          schedule.subject,
                          '${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
                          schedule.teacher,
                        ],
                      )
                      .toList(),
            ),
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/schedule.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  Future<String> exportToExcel(List<ClassSchedule> schedules) async {
    final excel = Excel.createExcel();
    final sheet = excel['Schedule'];

    // Add headers with styling
    final headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Left,
    );

    final headers = ['Day', 'Subject', 'Time', 'Teacher'];
    final defaultColumnWidth = 15.0;

    // Set column widths and add headers
    for (var i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, defaultColumnWidth);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = headerStyle;
    }

    // Add data
    var row = 1;
    for (final schedule in schedules) {
      final data = [
        schedule.day,
        schedule.subject,
        '${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}',
        schedule.teacher,
      ];

      for (var i = 0; i < data.length; i++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row))
          ..value = TextCellValue(data[i]);
      }
      row++;
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/schedule.xlsx');
    await file.writeAsBytes(excel.encode()!);
    return file.path;
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
