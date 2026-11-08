import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

/// Геолокацияны сұрап, permission/қызмет күйін UI-ға жариялайды.
class LocationController extends ChangeNotifier {
  Position? position;
  String? message;
  bool loading = false;

  Future<void> locate() async {
    loading = true;
    message = null;
    notifyListeners();
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        message = 'Құрылғы баптауынан геолокацияны қосыңыз.';
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        message = 'Орналасуға рұқсат берілмеді. Қайта сұрауға болады.';
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        message = 'Рұқсат бұғатталған. Құрылғы баптауынан рұқсат беріңіз.';
        return;
      }
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } catch (_) {
      message = 'Орналасуды алу мүмкін болмады. Қайталап көріңіз.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => LocationController(),
        child: const _LocationView(),
      );
}

class _LocationView extends StatelessWidget {
  const _LocationView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LocationController>();
    final position = state.position;
    return Scaffold(
      appBar: AppBar(title: const Text('Оқу орнының орналасуы')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              const Text(
                'Ағымдағы орналасуыңызды тапсырмаларыңызбен байланыстыру үшін құрылғының геолокациясын қолданыңыз.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (state.loading) const CircularProgressIndicator(),
              if (position != null) ...[
                Text('Ендік: ${position.latitude.toStringAsFixed(5)}'),
                Text('Бойлық: ${position.longitude.toStringAsFixed(5)}'),
                Text('Дәлдігі: ${position.accuracy.toStringAsFixed(0)} м'),
              ],
              if (state.message != null) ...[
                const SizedBox(height: 12),
                Text(state.message!, textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: state.loading ? null : state.locate,
                icon: const Icon(Icons.my_location),
                label: const Text('Орналасуды анықтау'),
              ),
              if (state.message?.contains('бұғатталған') ?? false)
                const TextButton(
                  onPressed: Geolocator.openAppSettings,
                  child: Text('Қолданба баптауларын ашу'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
