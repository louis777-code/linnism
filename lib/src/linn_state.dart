/// The state a Linn widget should display.
///
/// The application owns transitions between states. Components render the state
/// supplied to them; they never perform network requests or catch app errors.
enum LinnState {
  idle,
  loading,
  success,
  error,
  disabled;

  /// Whether an action or an edit is allowed in this state.
  bool get isInteractive => this != loading && this != disabled;

  /// A readable name for accessibility and component galleries.
  String get label => switch (this) {
    idle => 'Idle',
    loading => 'Loading',
    success => 'Success',
    error => 'Error',
    disabled => 'Disabled',
  };
}
