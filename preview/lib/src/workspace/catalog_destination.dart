enum CatalogDestination {
  overview,
  actions,
  forms,
  navigation,
  settings,
  feedback,
  overlays,
  calendar,
}

extension CatalogDestinationContent on CatalogDestination {
  String get label => switch (this) {
    CatalogDestination.overview => 'Overview',
    CatalogDestination.actions => 'Actions',
    CatalogDestination.forms => 'Forms',
    CatalogDestination.navigation => 'Navigation',
    CatalogDestination.settings => 'Settings',
    CatalogDestination.feedback => 'Feedback',
    CatalogDestination.overlays => 'Overlays',
    CatalogDestination.calendar => 'Calendar',
  };

  String get description => switch (this) {
    CatalogDestination.overview => 'System and interaction',
    CatalogDestination.actions => 'Buttons and gestures',
    CatalogDestination.forms => 'Input and selection',
    CatalogDestination.navigation => 'Destinations and actions',
    CatalogDestination.settings => 'Rows and disclosure',
    CatalogDestination.feedback => 'Progress and recovery',
    CatalogDestination.overlays => 'Tooltip, dialog, sheet',
    CatalogDestination.calendar => 'Dates and day states',
  };
}
