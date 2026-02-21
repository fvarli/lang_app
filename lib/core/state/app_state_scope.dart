import 'package:flutter/material.dart';

import '../data/content_repository.dart';
import '../persistence/progress_store.dart';
import 'app_state.dart';

class AppStateScope extends StatefulWidget {
  const AppStateScope({super.key, required this.child});

  final Widget child;

  static AppState of(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_AppStateInherited>();
    if (inherited == null) {
      throw StateError('AppStateScope not found in context');
    }
    return inherited.state;
  }

  @override
  State<AppStateScope> createState() => _AppStateScopeState();
}

class _AppStateScopeState extends State<AppStateScope> {
  late final AppState _state = AppState(
    contentRepository: ContentRepository(),
    progressStore: ProgressStore(),
  )..bootstrap();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AppStateInherited(state: _state, child: widget.child);
  }
}

class _AppStateInherited extends InheritedNotifier<AppState> {
  const _AppStateInherited({required AppState state, required super.child})
    : super(notifier: state);

  AppState get state => notifier!;
}
