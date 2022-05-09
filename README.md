# NautilusTelemetry

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FeBay%2FNautilusTelemetry%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/eBay/NautilusTelemetry) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FeBay%2FNautilusTelemetry%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/eBay/NautilusTelemetry) [![Swift](https://github.com/eBay/NautilusTelemetry/actions/workflows/swift.yml/badge.svg)](https://github.com/eBay/NautilusTelemetry/actions/workflows/swift.yml)

NautilusTelemetry is an iOS-oriented Swift package to collect [OpenTelemetry](https://github.com/open-telemetry) data and submit it in [OTLP-JSON](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/protocol/otlp.md) format to an [OpenTelemetry Collector](https://github.com/open-telemetry/opentelemetry-collector) instance. gRPC is not currently supported in order to keep the package size as small as possible. Not all features of OpenTelemetry are supported, and this package should be considered experimental.

Additional utilities include an Swift wrapper for [os_unfair_lock](https://developer.apple.com/documentation/os/1646466-os_unfair_lock_lock), and a wrapper for [mach_continuous_time](https://developer.apple.com/documentation/kernel/1646199-mach_continuous_time) to provide precision timing.

## Usage

```swift

import NautilusTelemetry

InstrumentationSystem.bootstrap(reporter: ExampleReporter())

	func logResponseComplete() {
		let tracer = InstrumentationSystem.tracer
		tracer.withSpan(name: #function) {
			self.populateLogContext()
			self.loggers.forEach { logger in
				logger.logResponseComplete()
			}
		}
	}

```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)
