package main

import (
	"github.com/go-flutter-desktop/go-flutter"
	"github.com/go-flutter-desktop/plugins/path_provider"
)

var options = []flutter.Option{
	flutter.WindowInitialDimensions(360, 620),
	flutter.WindowTransparentBackground(true),
	flutter.WindowDimensionLimits(360, 620, 360, 620),
	// flutter.WindowMode(flutter.WindowModeBorderless),
	flutter.AddPlugin(&path_provider.PathProviderPlugin{
		VendorName:      "Tadjaur",
		ApplicationName: "get_music_player",
	}),
}
