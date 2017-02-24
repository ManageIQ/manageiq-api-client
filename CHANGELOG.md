# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

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

[Unreleased]: https://github.com/ManageIQ/manageiq-api-client/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/ManageIQ/manageiq-api-client/compare/v0.1.0...v0.1.1
[0.2.0]: https://github.com/ManageIQ/manageiq-api-client/compare/v0.1.1...v0.2.0
