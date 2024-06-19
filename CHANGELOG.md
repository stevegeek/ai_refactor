# AI Refactor Changelog

## [Unreleased]

### Changes


## [0.6.0] - 2024-06-19

### Added

- Now supports Anthropic AI models. Eg pass `-m claude-3-opus-20240229` to use the current Claude Opus model.

### Changes
- Default openAI model is now `gpt-4-turbo`

### Fixed

- example test run should use `bundle exec` to ensure the correct version of the gem is used.

## [0.5.4] - 2024-02-07

### Added
- Support for built-in command YML files to make it easy to add new refactors
- Support for specifying context files from gems with `context_file_paths_from_gems:` key in command templates
- Command to convert Minitest tests to Quickdraw tests

### Changes
- Default openAI model is now `gpt-4-turbo-preview`

## [0.5.3] - 2024-02-06

### Added
- Add runner to run steep on inputs after generating RBS
- Add refactor to write RBS

### Fixed
- Removed dependency on `dotenv` gems
- Update openai dependency
- Improve prompt handling to allow having custom text prompts from commands that can append to build in prompt templates
- Custom refactor should allow prompt to come from prompt text option

## [0.5.2] - 2023-09-21

### Added

### Fixed
- Removed `puts`

## [0.5.1] - 2023-09-21

### Added

- Support for substitutions in path templates.

### Fixed

- Fixes issue with refactor type specified on command line not being picked up.


## [0.5.0] - 2023-09-21

### Added

- Support for new command files, which are YAML files that can be used to define options for a refactor. This makes it
  simpler to create configurations for refactors that will be used repeatedly. They can be committed to source control
  of your project and shared with other developers.
- Support for configuring the run commands for the test runners
- Adding real life examples

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
