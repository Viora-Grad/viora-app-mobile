const Map<String, String> _displayToBackend = {
  'Orthopedics': 'Orthopedic Surgery',
  'Cardiology': 'Cardiology',
  'Dermatology': 'Dermatology',
  'Psychiatry': 'Psychiatry & Behavioral Health',
};

String mapServiceType(String displayName) {
  return _displayToBackend[displayName] ?? displayName;
}
