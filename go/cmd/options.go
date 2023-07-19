package main

import (
	"github.com/go-flutter-desktop/go-flutter"
	"github.com/go-flutter-desktop/plugins/path_provider"
)

var options = []flutter.Option{
	flutter.WindowInitialDimensions(800, 1280),
	flutter.AddPlugin(&path_provider.PathProviderPlugin{
		VendorName:      "taurAppSolution",
		ApplicationName: "gtmusicplayer",
	}),
}
