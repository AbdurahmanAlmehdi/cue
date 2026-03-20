
import 'package:flutter/material.dart';

/// A ChangeNotifier that allows listeners to receive data when notified
class EventNotifier<T> {
  final List<void Function(T)> _eventListeners = [];

  bool _disposed = false;

  /// Add a listener that receives data when events are fired
  void addEventListener(void Function(T) listener) {
    assert(!_disposed, 'Cannot add event listener to a disposed EventNotifier');
    _eventListeners.add(listener);
  }

  /// Remove an event listener
  void removeEventListener(void Function(T) listener) {
    assert(!_disposed, 'Cannot remove event listener from a disposed EventNotifier');
    _eventListeners.remove(listener);
  }

  /// Fire an event with data to all event listeners
  void fireEvent(T data) {
    assert(!_disposed, 'Cannot fire event on a disposed EventNotifier');
    // Send event to all event listeners
    for (final listener in _eventListeners.toList()) {
      listener(data);
    }
  }

  @mustCallSuper
  void dispose() {
    _disposed = true;
    _eventListeners.clear();
  }
}
