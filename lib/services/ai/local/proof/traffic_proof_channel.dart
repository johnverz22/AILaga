import 'package:flutter/services.dart';

/// Proof channel for the "On my phone" privacy panel (C10).
///
/// Wraps Android `TrafficStats.getUidRxBytes/getUidTxBytes` via a
/// MethodChannel so the UI can show real bytes sent/received by this app
/// during an AI session. Returns null on non-Android or if the channel is
/// missing — the caller must show "unavailable", never a fabricated number
/// (spike S5 decides whether this ships).
class TrafficProofChannel {
  static const MethodChannel _channel =
      MethodChannel('com.ailaga.ailaga/traffic');

  /// Bytes received by this app's UID since boot, or null if unavailable.
  static Future<int?> getUidRxBytes() async {
    try {
      final v = await _channel.invokeMethod<int>('getUidRxBytes');
      return (v != null && v >= 0) ? v : null;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Bytes transmitted by this app's UID since boot, or null if unavailable.
  static Future<int?> getUidTxBytes() async {
    try {
      final v = await _channel.invokeMethod<int>('getUidTxBytes');
      return (v != null && v >= 0) ? v : null;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}

/// Snapshot of the UID counters at a point in time.
class TrafficSnapshot {
  final int rxBytes;
  final int txBytes;
  const TrafficSnapshot({required this.rxBytes, required this.txBytes});
}

/// Diffs two snapshots — bytes attributable to this app between them.
/// Construct only from real channel reads.
class TrafficSession {
  final TrafficSnapshot start;
  const TrafficSession(this.start);

  static Future<TrafficSession?> begin() async {
    final rx = await TrafficProofChannel.getUidRxBytes();
    final tx = await TrafficProofChannel.getUidTxBytes();
    if (rx == null || tx == null) return null;
    return TrafficSession(TrafficSnapshot(rxBytes: rx, txBytes: tx));
  }

  /// Bytes moved since [begin], or null if counters became unavailable.
  Future<TrafficSnapshot?> delta() async {
    final rx = await TrafficProofChannel.getUidRxBytes();
    final tx = await TrafficProofChannel.getUidTxBytes();
    if (rx == null || tx == null) return null;
    return TrafficSnapshot(rxBytes: rx - start.rxBytes, txBytes: tx - start.txBytes);
  }
}
