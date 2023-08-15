# AI Refactor Changelog

## [0.4.0] - 2023-08-15

### Added

- Support for providing files as context for prompt.
- Output path configuration made available to all refactors.
- New refactor to write minitest tests for classes
- New refactor to write changelog entries.
- 'review' prompt CLI switch without invoking AI.
- CLI switch to control output overwrite behaviour.
- Extra text context for prompts via command line with -x
- Support for .ai_refactor config file which can provide default options/switches for prompts.

### Changed

- Moved to using zeitwerk for loading and dotenv.
- Simple registry for refactors and change in naming convention.
- Updated diff prompt option and fixes for new structure.
- Reorganised refactors.
- Tweaked rspec to minitest prompt.
- Fixed check for custom prompt path.
- Updated docs.

### Fixed

- Fixed reference to built in prompt paths.

## [0.3.1] - 2023-05-25

### Added

- Added support for outputting to file from generic refactor.

## [0.2.0] - 2023-05-24

### Added

- Introduced a generic refactor type which uses the user supplied prompt and outputs to stdout.
- Added support for outputting to file from generic refactor.
- Added a prompt for rspec_to_minitest.

### Fixed

- Fixed example.

## [0.1.0] - 2023-05-19

### Added

- First version of CLI.

### Changed

- Gem dependencies are not open-ended.
- Renamed to clean up intention.
- Updated docs.
