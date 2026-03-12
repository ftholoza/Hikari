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

  bool _isScanning = false;
  bool _isConnecting = false;
  bool _isConnected = false;

  double _angle = 0.0;
  double _vitesse = 0.0;
  int _temps = 0;

  String _statusText = 'Déconnecté';

  List<ScanResult> _devices = [];

  @override
  void initState() {
    super.initState();

    _dataSubscription = _bleService.dataStream.listen((data) {
      if (!mounted) return;

      setState(() {
        _angle = data.angle;
        _vitesse = data.vitesse;
        _temps = data.temps;
      });
    });

    _connectionSubscription = _bleService.connectionStream.listen((connected) {
      if (!mounted) return;

      setState(() {
        _isConnected = connected;
        _statusText = connected ? 'Connecté à l’orthèse' : 'Déconnecté';
        if (!connected) {
          _isConnecting = false;
        }
      });
    });
  }

  Future<void> _scanDevices() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _statusText = 'Scan en cours...';
      _devices = [];
    });

    final results = await _bleService.scanDevices();

    if (!mounted) return;

    setState(() {
      _isScanning = false;
      _devices = results;
      _statusText =
          results.isEmpty ? 'Aucun appareil trouvé' : 'Appareils trouvés';
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (_isConnecting) return;

    final deviceName =
        device.platformName.isNotEmpty ? device.platformName : device.remoteId.str;

    setState(() {
      _isConnecting = true;
      _statusText = 'Connexion à $deviceName...';
    });

    final success = await _bleService.connectToDevice(device);

    if (!mounted) return;

    setState(() {
      _isConnecting = false;
      _isConnected = success;
      _statusText = success
          ? 'Connecté à $deviceName'
          : 'Connexion impossible à $deviceName';
    });
  }

  Future<void> _disconnect() async {
    await _bleService.disconnect();

    if (!mounted) return;

    setState(() {
      _isConnected = false;
      _isConnecting = false;
      _statusText = 'Déconnecté';
    });
  }

  String _displayName(ScanResult result) {
    final advName = result.advertisementData.advName;
    final platformName = result.device.platformName;

    if (advName.isNotEmpty) return advName;
    if (platformName.isNotEmpty) return platformName;
    return 'Appareil inconnu';
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
    final isTarget = name == BleService.targetDeviceName;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isTarget ? Colors.blueAccent.withOpacity(0.5) : Colors.white12,
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.bluetooth,
          color: isTarget ? Colors.blueAccent : Colors.white70,
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          id,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: _isConnecting ? null : () => _connectToDevice(result.device),
          child: const Text('Connecter'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _connectionSubscription?.cancel();
    _bleService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _isConnected
        ? Colors.greenAccent
        : _isConnecting
            ? Colors.orangeAccent
            : _isScanning
                ? Colors.blueAccent
                : Colors.redAccent;

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
                      onPressed: (_isScanning || _isConnecting) ? null : _scanDevices,
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