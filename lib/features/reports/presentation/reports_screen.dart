import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import '../../../core/utils/date_formatter.dart';
import '../../care_recipient/data/care_recipient_providers.dart';
import '../data/report_providers.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

final reportDateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  return DateTimeRange(
    start: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7)),
    end: DateTime(now.year, now.month, now.day, 23, 59, 59),
  );
});

final reportProvider = FutureProvider.autoDispose<Uint8List?>((ref) async {
  final recipient = ref.watch(primaryCareRecipientProvider).value;
  if (recipient == null) return null;
  
  final range = ref.watch(reportDateRangeProvider);
  
  final service = ref.watch(reportServiceProvider);
  final report = await service.generateReport(
    recipientId: recipient.id,
    periodStart: range.start,
    periodEnd: range.end,
  );
  
  return report.pdfBytes;
});

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(reportDateRangeProvider);
    final reportAsync = ref.watch(reportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Reports'),
      ),
      body: Column(
        children: [
          _DateRangeSelector(range: range),
          Expanded(
            child: reportAsync.when(
              data: (pdfBytes) {
                if (pdfBytes == null) {
                  return const Center(child: Text('No care recipient found.'));
                }
                
                return PdfPreview(
                  build: (format) => pdfBytes,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  allowSharing: true,
                  allowPrinting: true,
                  initialPageFormat: PdfPageFormat.a4,
                  pdfFileName: 'AILaga_Report_${DateFormatter.formatDate(range.start)}_to_${DateFormatter.formatDate(range.end)}.pdf',
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Something went wrong.')),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRangeSelector extends ConsumerWidget {
  final DateTimeRange range;
  
  const _DateRangeSelector({required this.range});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Expanded: long date ranges wrap to a second line instead of
          // overflowing the row on narrow screens or large text.
          Expanded(
            child: Text(
              '${DateFormatter.formatDate(range.start)} - ${DateFormatter.formatDate(range.end)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newRange = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDateRange: range,
              );
              
              if (newRange != null) {
                ref.read(reportDateRangeProvider.notifier).state = DateTimeRange(
                  start: newRange.start,
                  end: DateTime(newRange.end.year, newRange.end.month, newRange.end.day, 23, 59, 59),
                );
              }
            },
            child: const Text('Custom Range'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Symbols.calendar_today_rounded),
            onSelected: (value) {
              final now = DateTime.now();
              DateTime start = now;
              DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

              if (value == 'Today') {
                start = DateTime(now.year, now.month, now.day);
              } else if (value == 'Last 7 days') {
                start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
              } else if (value == 'Last 30 days') {
                start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));
              }

              ref.read(reportDateRangeProvider.notifier).state = DateTimeRange(start: start, end: end);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Today', child: Text('Today')),
              const PopupMenuItem(value: 'Last 7 days', child: Text('Last 7 days')),
              const PopupMenuItem(value: 'Last 30 days', child: Text('Last 30 days')),
            ],
          ),
        ],
      ),
    );
  }
}
