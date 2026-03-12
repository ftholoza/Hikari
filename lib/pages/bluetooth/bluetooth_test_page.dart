import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../bluetooth/ble_service.dart';
import '../../bluetooth/models/orthese_data.dart';

class BluetoothTestPage extends StatefulWidget {
  const BluetoothTestPage({super.key});

  @override
  State<BluetoothTestPage> createState() => _BluetoothTestPageState();
}

class _BluetoothTestPageState extends State<BluetoothTestPage> {
  final BleService _bleService = BleService();

  StreamSubscription<OrtheseData>? _dataSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  bool _isScanning = false;
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isBluetoothOn = false;
  bool _isBleSupported = true;

  double _angle = 0.0;
  double _vitesse = 0.0;
  int _temps = 0;

  String _statusText = 'Déconnecté';

  List<ScanResult> _devices = [];

  @override
  void initState() {
    super.initState();
    debugPrint('BluetoothTestPage initState');

    _safeInitBluetooth();

    _dataSubscription = _bleService.dataStream.listen(
      (data) {
        if (!mounted) return;

        setState(() {
          _angle = data.angle;
          _vitesse = data.vitesse;
          _temps = data.temps;
        });
      },
      onError: (error, stackTrace) {
        debugPrint('Erreur dataStream: $error');
        debugPrint('$stackTrace');
      },
    );

    _connectionSubscription = _bleService.connectionStream.listen(
      (connected) {
        if (!mounted) return;

        setState(() {
          _isConnected = connected;
          _statusText = connected ? 'Connecté à l’orthèse' : 'Déconnecté';

          if (!connected) {
            _isConnecting = false;
          }
        });
      },
      onError: (error, stackTrace) {
        debugPrint('Erreur connectionStream: $error');
        debugPrint('$stackTrace');
      },
    );

    try {
      _adapterSubscription = FlutterBluePlus.adapterState.listen(
        (state) {
          if (!mounted) return;

          final bluetoothOn = state == BluetoothAdapterState.on;

          setState(() {
            _isBluetoothOn = bluetoothOn;

            if (!bluetoothOn && !_isConnected && !_isScanning) {
              _statusText = 'Bluetooth désactivé';
            }
          });
        },
        onError: (error, stackTrace) {
          debugPrint('Erreur adapterState.listen: $error');
          debugPrint('$stackTrace');

          if (!mounted) return;

          setState(() {
            _statusText = 'Erreur Bluetooth';
            _isBleSupported = false;
            _isBluetoothOn = false;
          });
        },
      );
    } catch (e, s) {
      debugPrint('Erreur abonnement adapterState: $e');
      debugPrint('$s');

      _isBleSupported = false;
      _isBluetoothOn = false;
      _statusText = 'Bluetooth indisponible';
    }
  }

  Future<void> _safeInitBluetooth() async {
    try {
      await _initBluetoothState();
    } catch (e, s) {
      debugPrint('Erreur _initBluetoothState: $e');
      debugPrint('$s');

      if (!mounted) return;

      setState(() {
        _isBleSupported = false;
        _isBluetoothOn = false;
        _statusText = 'Bluetooth indisponible sur cet appareil';
      });
    }
  }

  Future<void> _initBluetoothState() async {
    debugPrint('Init Bluetooth start');

    final supported = await FlutterBluePlus.isSupported;

    if (!mounted) return;

    if (!supported) {
      setState(() {
        _isBleSupported = false;
        _statusText = 'BLE non supporté sur cet appareil';
      });
      debugPrint('BLE non supporté');
      return;
    }

    final state = await FlutterBluePlus.adapterState.first;

    if (!mounted) return;

    setState(() {
      _isBleSupported = true;
      _isBluetoothOn = state == BluetoothAdapterState.on;
      _statusText = _isBluetoothOn ? 'Déconnecté' : 'Bluetooth désactivé';
    });

    debugPrint('Init Bluetooth ok - state: $state');
  }

  Future<void> _scanDevices() async {
    if (_isScanning || _isConnecting) return;

    if (!_isBleSupported) {
      setState(() {
        _statusText = 'BLE non supporté sur cet appareil';
      });
      return;
    }

    try {
      final state = await FlutterBluePlus.adapterState.first;

      if (state != BluetoothAdapterState.on) {
        setState(() {
          _isBluetoothOn = false;
          _statusText = 'Active le Bluetooth du téléphone avant de scanner';
          _devices = [];
        });
        return;
      }

      setState(() {
        _isScanning = true;
        _isBluetoothOn = true;
        _statusText = 'Scan en cours...';
        _devices = [];
      });

      final Map<String, ScanResult> uniqueResults = {};

      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();

      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          for (final result in results) {
            final id = result.device.remoteId.str;
            uniqueResults[id] = result;
          }

          final visibleDevices = uniqueResults.values.where((result) {
            final advName = result.advertisementData.advName.trim();
            final platformName = result.device.platformName.trim();

            return advName.isNotEmpty || platformName.isNotEmpty;
          }).toList();

          visibleDevices.sort((a, b) {
            final aIsTarget = _isTargetDevice(a);
            final bIsTarget = _isTargetDevice(b);

            if (aIsTarget && !bIsTarget) return -1;
            if (!aIsTarget && bIsTarget) return 1;

            final aName = _displayName(a).toLowerCase();
            final bName = _displayName(b).toLowerCase();

            return aName.compareTo(bName);
          });

          if (!mounted) return;

          setState(() {
            _devices = visibleDevices;
            _statusText = visibleDevices.isEmpty
                ? 'Scan en cours...'
                : '${visibleDevices.length} appareil(s) détecté(s)';
          });
        },
        onError: (error, stackTrace) {
          debugPrint('Erreur scanResults.listen: $error');
          debugPrint('$stackTrace');

          if (!mounted) return;

          setState(() {
            _isScanning = false;
            _statusText = 'Erreur pendant le scan';
          });
        },
      );

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 6),
      );

      await Future.delayed(const Duration(seconds: 6));
      await FlutterBluePlus.stopScan();

      if (!mounted) return;

      setState(() {
        _isScanning = false;
        if (_devices.isEmpty) {
          _statusText = 'Aucun appareil détecté';
        }
      });
    } catch (e, s) {
      debugPrint('Erreur scan BLE: $e');
      debugPrint('$s');

      if (!mounted) return;

      setState(() {
        _isScanning = false;
        _statusText = 'Erreur pendant le scan';
      });
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (_isConnecting) return;

    final deviceName = device.platformName.isNotEmpty
        ? device.platformName
        : device.remoteId.str;

    setState(() {
      _isConnecting = true;
      _statusText = 'Connexion à $deviceName...';
    });

    try {
      final success = await _bleService.connectToDevice(device);

      if (!mounted) return;

      setState(() {
        _isConnecting = false;
        _isConnected = success;
        _statusText = success
            ? 'Connecté à $deviceName'
            : 'Connexion impossible à $deviceName';
      });
    } catch (e, s) {
      debugPrint('Erreur connexion BLE: $e');
      debugPrint('$s');

      if (!mounted) return;

      setState(() {
        _isConnecting = false;
        _isConnected = false;
        _statusText = 'Erreur de connexion à $deviceName';
      });
    }
  }

  Future<void> _disconnect() async {
    try {
      await _bleService.disconnect();
    } catch (e, s) {
      debugPrint('Erreur déconnexion BLE: $e');
      debugPrint('$s');
    }

    if (!mounted) return;

    setState(() {
      _isConnected = false;
      _isConnecting = false;
      _statusText = _isBluetoothOn ? 'Déconnecté' : 'Bluetooth désactivé';
    });
  }

  bool _hasTargetService(ScanResult result) {
    final serviceUuids = result.advertisementData.serviceUuids
        .map((e) => e.toString().toLowerCase())
        .toList();

    return serviceUuids.contains(
      BleService.serviceUuid.toString().toLowerCase(),
    );
  }

  bool _isTargetDevice(ScanResult result) {
    final advName = result.advertisementData.advName.trim();
    final platformName = result.device.platformName.trim();

    return advName == BleService.targetDeviceName ||
        platformName == BleService.targetDeviceName ||
        _hasTargetService(result);
  }

  String _displayName(ScanResult result) {
    final advName = result.advertisementData.advName.trim();
    final platformName = result.device.platformName.trim();

    if (advName.isNotEmpty) return advName;
    if (platformName.isNotEmpty) return platformName;
    return 'Appareil BLE';
  }

  Widget _buildValueCard({
    required String title,
    required String value,
    required String unit,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTile(ScanResult result) {
    final name = _displayName(result);
    final id = result.device.remoteId.str;
    final isTarget = _isTargetDevice(result);

    final borderColor = isTarget
        ? Colors.blueAccent.withOpacity(0.5)
        : Colors.white10;

    final backgroundColor = isTarget
        ? const Color(0xFF1E1E1E)
        : const Color(0xFF161616);

    final iconColor = isTarget ? Colors.blueAccent : Colors.white38;
    final titleColor = isTarget ? Colors.white : Colors.white70;
    final subtitleColor = isTarget ? Colors.white54 : Colors.white38;

    return Opacity(
      opacity: isTarget ? 1.0 : 0.75,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(
              Icons.bluetooth,
              color: iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: titleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isTarget) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.4),
                            ),
                          ),
                          child: const Text(
                            'ORTHÈSE',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 110,
              height: 36,
              child: FilledButton(
                onPressed: (!_isConnecting && isTarget)
                    ? () => _connectToDevice(result.device)
                    : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  backgroundColor:
                      isTarget ? const Color(0xFF4A90E2) : Colors.white12,
                  foregroundColor: isTarget ? Colors.white : Colors.white38,
                  disabledBackgroundColor: Colors.white12,
                  disabledForegroundColor: Colors.white38,
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Connecter'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('BluetoothTestPage dispose');
    _dataSubscription?.cancel();
    _connectionSubscription?.cancel();
    _adapterSubscription?.cancel();
    _scanSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = !_isBleSupported
        ? Colors.redAccent
        : _isConnected
            ? Colors.greenAccent
            : _isConnecting
                ? Colors.orangeAccent
                : _isScanning
                    ? Colors.blueAccent
                    : _isBluetoothOn
                        ? Colors.redAccent
                        : Colors.orangeAccent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth'),
      ),
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isScanning || _isConnecting)
                          ? null
                          : _scanDevices,
                      child: Text(_isScanning ? 'Scan...' : 'Scanner'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isConnected ? _disconnect : null,
                      child: const Text('Se déconnecter'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    if (_devices.isNotEmpty) ...[
                      const Text(
                        'Appareils trouvés',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._devices.map(_buildDeviceTile),
                      const SizedBox(height: 16),
                    ],
                    _buildValueCard(
                      title: 'Angle',
                      value: _angle.toStringAsFixed(1),
                      unit: '°',
                    ),
                    _buildValueCard(
                      title: 'Vitesse',
                      value: _vitesse.toStringAsFixed(1),
                      unit: '°/s',
                    ),
                    _buildValueCard(
                      title: 'Temps écoulé',
                      value: _temps.toString(),
                      unit: 's',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}