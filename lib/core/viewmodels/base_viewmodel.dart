import 'package:flutter/foundation.dart';
import 'package:signals/signals_flutter.dart';

abstract class BaseViewModel {
  final _busy = signal(false);
  ReadonlySignal<bool> get busy => _busy;

  final _error = signal<String?>(null);
  ReadonlySignal<String?> get error => _error;

  @protected
  void setBusy(bool value) => _busy.value = value;

  @protected
  void setError(String? value) => _error.value = value;

  void dispose() {
    // Signals usually dispose themselves if linked to widgets, but good to have a hook
  }
}
