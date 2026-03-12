import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
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
    StreamSubscription<List<ScanResult>>? subscription;

    try {
      debugPrint('BleService.scanDevices start');

      await FlutterBluePlus.stopScan();

      subscription = FlutterBluePlus.scanResults.listen(
        (results) {
          for (final result in results) {
            final id = result.device.remoteId.str;
            uniqueResults[id] = result;

            debugPrint(
              'BLE trouvé: ${result.device.platformName} / '
              '${result.advertisementData.advName} / $id',
            );
          }
        },
        onError: (error, stackTrace) {
          debugPrint('Erreur scanResults.listen: $error');
          debugPrint('$stackTrace');
        },
      );

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 6),
      );

      await Future.delayed(const Duration(seconds: 6));
      await FlutterBluePlus.stopScan();

      debugPrint(
        'BleService.scanDevices done - ${uniqueResults.length} appareil(s)',
      );

      return uniqueResults.values.toList();
    } catch (e, s) {
      debugPrint('Erreur scanDevices: $e');
      debugPrint('$s');
      return [];
    } finally {
      await subscription?.cancel();
    }
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      debugPrint('BleService.connectToDevice start: ${device.remoteId.str}');

      await disconnect();

      _device = device;

      await _device!.connect(
        license: License.free,
        timeout: const Duration(seconds: 10),
      );

      debugPrint('BLE connecté au device, découverte des services...');

      final services = await _device!.discoverServices();

      for (final service in services) {
        debugPrint('Service détecté: ${service.uuid}');

        if (service.uuid == serviceUuid) {
          debugPrint('Service cible trouvé');

          for (final characteristic in service.characteristics) {
            debugPrint('Characteristic détectée: ${characteristic.uuid}');

            if (characteristic.uuid == characteristicUuid) {
              debugPrint('Characteristic cible trouvée');

              _characteristic = characteristic;

              await _characteristic!.setNotifyValue(true);

              await _characteristicSubscription?.cancel();

              _characteristicSubscription =
                  _characteristic!.lastValueStream.listen(
                (value) {
                  try {
                    if (value.isEmpty) return;

                    final raw = utf8.decode(value).trim();
                    debugPrint('BLE raw: $raw');

                    final parsed = OrtheseData.fromBleString(raw);
                    _dataController.add(parsed);
                  } catch (e, s) {
                    debugPrint('Erreur parsing BLE: $e');
                    debugPrint('$s');
                  }
                },
                onError: (error, stackTrace) {
                  debugPrint('Erreur characteristic stream: $error');
                  debugPrint('$stackTrace');
                },
              );

              _connectionController.add(true);
              debugPrint('BleService.connectToDevice success');
              return true;
            }
          }
        }
      }

      debugPrint('Service ou characteristic cible introuvable');
      await disconnect();
      return false;
    } catch (e, s) {
      debugPrint('Erreur connexion BLE: $e');
      debugPrint('$s');
      await disconnect();
      return false;
    }
  }

  Future<void> disconnect() async {
    debugPrint('BleService.disconnect start');

    try {
      await _characteristicSubscription?.cancel();
    } catch (e, s) {
      debugPrint('Erreur cancel characteristicSubscription: $e');
      debugPrint('$s');
    }

    _characteristicSubscription = null;
    _characteristic = null;

    if (_device != null) {
      try {
        await _device!.disconnect();
        debugPrint('Device déconnecté: ${_device!.remoteId.str}');
      } catch (e, s) {
        debugPrint('Erreur device.disconnect: $e');
        debugPrint('$s');
      }
    }

    _device = null;

    if (!_connectionController.isClosed) {
      _connectionController.add(false);
    }

    debugPrint('BleService.disconnect done');
  }

  Future<void> dispose() async {
    debugPrint('BleService.dispose');

    await disconnect();

    if (!_dataController.isClosed) {
      await _dataController.close();
    }

    if (!_connectionController.isClosed) {
      await _connectionController.close();
    }
  }
}