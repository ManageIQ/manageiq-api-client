# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

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

[Unreleased]: https://github.com/ManageIQ/manageiq-api-client/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/ManageIQ/manageiq-api-client/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/ManageIQ/manageiq-api-client/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/ManageIQ/manageiq-api-client/compare/v0.1.0...v0.1.1
