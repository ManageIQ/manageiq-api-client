# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [0.4.1] - 2024-03-06
### Added
- Drop active_support and more_core_extensions dependency [[#115]](https://github.com/ManageIQ/manageiq-api-client/pull/115)
- Add rails 7 support [[#114]](https://github.com/ManageIQ/manageiq-api-client/pull/114)

## [0.4.0] - 2023-10-16
### Added
- Add Bearer token support [[#113]](https://github.com/ManageIQ/manageiq-api-client/pull/113)

## [0.3.7] - 2023-05-19
### Changed
- Loosen faraday to 1.x. [[#108]](https://github.com/ManageIQ/manageiq-api-client/pull/108)

## [0.3.6] - 2022-05-30
### Changed
- Added support to ActiveSupport 6.1 [[#100]](https://github.com/ManageIQ/manageiq-api-client/pull/100)
- Changed faraday to v1.0. [[#90]](https://github.com/ManageIQ/manageiq-api-client/pull/90)

## [0.3.5] - 2020-05-07
### Changed
- Loosen dependency and update the json gem to v2.3 [[#92](https://github.com/ManageIQ/manageiq-api-client/pull/92)]

## [0.3.4] - 2020-04-30
### Changed
- Relax requirement as ActiveSupport::Concern is stable. [[#88](https://github.com/ManageIQ/manageiq-api-client/pull/88)]
- Allow ActiveSupport 5.2 [[#87](https://github.com/ManageIQ/manageiq-api-client/pull/87)]

## [0.3.3] - 2019-02-25
### Fixed
- Raise an error if not found when filtering by a single ID [[#85](https://github.com/ManageIQ/manageiq-api-client/pull/85)]

## [0.3.2] - 2018-11-08
### Fixed
- Raise a ResourceNotFound error when response is a 404 [[#84](https://github.com/ManageIQ/manageiq-api-client/pull/84)]

## [0.3.1] - 2018-08-06
### Fixed
- Raise a more specific error class [[#82](https://github.com/ManageIQ/manageiq-api-client/pull/82)]

## [0.3.0] - 2018-03-14
### Changed
- Adding support for Faraday's open_timeout and timeout options [[#78](https://github.com/ManageIQ/manageiq-api-client/pull/78)]
- Loosen dependency on activesupport [[#74](https://github.com/ManageIQ/manageiq-api-client/pull/74)]
- Updated JSON gem to 2.1.0 [[#73](https://github.com/ManageIQ/manageiq-api-client/pull/73)]
- Loosen dependency on faraday to allow for upgrades [[#71](https://github.com/ManageIQ/manageiq-api-client/pull/71)]
- Enhanced ServerInfo to support the new \_href entries [[#66](https://github.com/ManageIQ/manageiq-api-client/pull/66)]

### Fixed
- Improve query used when fetching collection actions [[#77](https://github.com/ManageIQ/manageiq-api-client/pull/77)]

## [0.2.0] - 2017-02-24
### Changed
- **BREAKING** Client's `settings` is renamed to `user_settings` to avoid collision with API's `settings` collection [[#57](https://github.com/ManageIQ/manageiq-api-client/pull/57)]
- Loosen ActiveSupport dependency [[#64](https://github.com/ManageIQ/manageiq-api-client/pull/64)]

### Fixed
- Fix Client::Error to support Rails errors (routing, etc) [[#58](https://github.com/ManageIQ/manageiq-api-client/pull/58)]
- When fetching the entrypoint a / is appended to the URL [[#59](https://github.com/ManageIQ/manageiq-api-client/pull/59)]

## [0.1.1]
### Added
- Add CHANGELOG.md
- Update README with simple instructions reflecting the query interface.

[Unreleased]: https://github.com/ManageIQ/manageiq-api-client/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/ManageIQ/manageiq-api-client/compare/v0.3.7...v0.4.0
[0.3.7]: https://github.com/ManageIQ/manageiq-api-client/compare/v0.3.6...v0.3.7
[0.3.6]: https://github.com/ManageIQ/manageiq-api-client/compare/v0.3.5...v0.3.6
[0.3.5]: https://github.com/ManageIQ/manageiq-api-client/compare/v0.3.4...v0.3.5
[0.3.4]: https://github.com/ManageIQ/manageiq-api-client/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/ManageIQ/manageiq-api-client/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/ManageIQ/manageiq-api-client/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/ManageIQ/manageiq-api-client/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/ManageIQ/manageiq-api-client/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/ManageIQ/manageiq-api-client/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/ManageIQ/manageiq-api-client/compare/v0.1.0...v0.1.1
