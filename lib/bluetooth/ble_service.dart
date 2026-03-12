import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'models/orthese_data.dart';

class BleService {
  BleService._internal();

  static final BleService _instance = BleService._internal();

  factory BleService() => _instance;

  static const String targetDeviceName = 'ESP32_Orthese';

  static final Guid serviceUuid =
      Guid('4fafc208-1fb5-459d-8fcc-c5c9c331914b');

  static final Guid characteristicUuid =
      Guid('bed5483e-36e1-4688-b7f5-ea07361b26a8');

  BluetoothDevice? _device;
  BluetoothCharacteristic? _characteristic;
  StreamSubscription<List<int>>? _characteristicSubscription;

  final StreamController<OrtheseData> _dataController =
      StreamController<OrtheseData>.broadcast();

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<OrtheseData> get dataStream => _dataController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  BluetoothDevice? get device => _device;

  bool get isConnected => _device != null && _characteristic != null;

  String? get connectedDeviceName {
    if (_device == null) return null;
    if (_device!.platformName.isNotEmpty) return _device!.platformName;
    return _device!.remoteId.str;
  }

  Future<List<ScanResult>> scanDevices() async {
    final Map<String, ScanResult> uniqueResults = {};

    await FlutterBluePlus.stopScan();

    final subscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final id = result.device.remoteId.str;
        uniqueResults[id] = result;

        print(
          'BLE trouvé: ${result.device.platformName} / ${result.advertisementData.advName} / $id',
        );
      }
    });

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 6),
    );

    await Future.delayed(const Duration(seconds: 6));

    await FlutterBluePlus.stopScan();
    await subscription.cancel();

    return uniqueResults.values.toList();
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await disconnect();

      _device = device;

      await _device!.connect(
        license: License.free,
        timeout: const Duration(seconds: 10),
      );

      final services = await _device!.discoverServices();

      for (final service in services) {
        if (service.uuid == serviceUuid) {
          for (final characteristic in service.characteristics) {
            if (characteristic.uuid == characteristicUuid) {
              _characteristic = characteristic;

              await _characteristic!.setNotifyValue(true);

              await _characteristicSubscription?.cancel();

              _characteristicSubscription =
                  _characteristic!.lastValueStream.listen((value) {
                try {
                  if (value.isEmpty) return;

                  final raw = utf8.decode(value).trim();
                  final parsed = OrtheseData.fromBleString(raw);

                  _dataController.add(parsed);
                } catch (_) {}
              });

              _connectionController.add(true);
              return true;
            }
          }
        }
      }

      await disconnect();
      return false;
    } catch (e) {
      print('Erreur connexion BLE: $e');
      await disconnect();
      return false;
    }
  }

  Future<void> disconnect() async {
    await _characteristicSubscription?.cancel();
    _characteristicSubscription = null;
    _characteristic = null;

    if (_device != null) {
      try {
        await _device!.disconnect();
      } catch (_) {}
    }

    _device = null;
    _connectionController.add(false);
  }

  void dispose() {
    _characteristicSubscription?.cancel();
  }
}