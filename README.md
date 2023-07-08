# AI Refactor

AI Refactor is an experimental tool to see how AI (specifically [OpenAI's ChatGPT](https://platform.openai.com/)) can be used to help apply refactoring to code.

The goal is **not** that the AI decides what refactoring to do, but rather, given refactoring tasks specified by the human user,
the AI can help identify which code to change and apply the relevant refactor.

This is based on the assumption that the LLM AIs are pretty good at identifying patterns.

## Available refactors

Currently available:

- `rails/minitest/rspec_to_minitest`: convert RSpec specs to minitest tests in Rails apps
- `generic`: provide your own prompt for the AI and run against the input files

### `rails/minitest/rspec_to_minitest`

Converts RSpec tests to minitest tests for Rails test suites (ie generated minitest tests are actually `ActiveSupport::TestCase`s).

The tool first runs the original RSpec spec file and then runs the generated minitest test file, and compares the output of both.

The comparison is simply the count of successful and failed tests but this is probably enough to determine if the conversion worked.

```shellq
stephen$ OPENAI_API_KEY=my-key ai_refactor rails/minitest/rspec_to_minitest spec/models/my_thing_spec.rb
AI Refactor 1 files(s)/dir(s) '["spec/models/my_thing_spec.rb"]' with rails/minitest/rspec_to_minitest refactor
====================
Processing spec/models/my_thing_spec.rb...

Original test run results:
>> Examples: 41, Failures: 0, Pendings: 0

Translated test file results:
>> Runs: 41, Failures: 0, Skips: 0

No differences found! Conversion worked!
Refactor succeeded on spec/models/my_thing_spec.rb

Done processing all files!
```

### `generic` (user supplied prompt)

Applies the refactor specified by prompting the AI with the user supplied prompt. You must supply a prompt file with the `-p` option.

The output is written to `stdout`, or to a file with the `--output` option. 

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add ai_refactor

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install ai_refactor

## Usage

See `ai_refactor --help` for more information.

```
Usage: ai_refactor REFACTOR_TYPE INPUT_FILE_OR_DIR [options]

Where REFACTOR_TYPE is one of: ["generic" ... (run ai_refactor --help for full list of refactor types)]

    -o, --output [FILE]              Write output to given file instead of stdout. If no path provided will overwrite input file (will prompt to overwrite existing files). Some refactor tasks will write out to a new file by default. This option will override the tasks default behaviour.
    -O, --output-template TEMPLATE   Write outputs to files instead of stdout. The template is used to create the output name, where the it can have substitutions, '[FILE]', '[NAME]', '[DIR]', '[REFACTOR]' & '[EXT]'. Eg `[DIR]/[NAME]_[REFACTOR][EXT]` (will prompt to overwrite existing files)
    -c, --context CONTEXT_FILES      Specify one or more files to use as context for the AI. The contents of these files will be prepended to the prompt sent to the AI.
    -r, --review-prompt              Show the prompt that will be sent to ChatGPT but do not actually call ChatGPT or make changes to files.
    -p, --prompt PROMPT_FILE         Specify path to a text file that contains the ChatGPT 'system' prompt.
    -f, --diffs                      Request AI generate diffs of changes rather than writing out the whole file.
    -C, --continue [MAX_MESSAGES]    If ChatGPT stops generating due to the maximum token count being reached, continue to generate more messages, until a stop condition or MAX_MESSAGES. MAX_MESSAGES defaults to 3
    -m, --model MODEL_NAME           Specify a ChatGPT model to use (default gpt-4).
        --temperature TEMP           Specify the temperature parameter for ChatGPT (default 0.7).
        --max-tokens MAX_TOKENS      Specify the max number of tokens of output ChatGPT can generate. Max will depend on the size of the prompt (default 1500)
    -t, --timeout SECONDS            Specify the max wait time for ChatGPT response.
        --overwrite ANSWER           Always overwrite existing output files, 'y' for yes, 'n' for no, or 'a' for ask. Default to ask.
    -v, --verbose                    Show extra output and progress info
    -d, --debug                      Show debugging output to help diagnose issues
    -h, --help                       Prints this help
```

## Outputs

Some refactor tasks will write out to a new file by default, others to stdout.

The `--output` lets you specify a file to write to instead of the Refactors default behaviour.

If `--output` is used without a value it overwrites the input with a prompt to overwrite existing files.

You can also output to a file using a template, `--output-template` to determine the output file name given a template string:

The template is used to create the output name, where the it can have substitutions, '[FILE]', '[NAME]', '[DIR]', '[REFACTOR]' & '[EXT]'.

Eg `--output-template "[DIR]/[NAME]_[REFACTOR][EXT]"`

eg for the input `my_dir/my_class.rb`
- `[FILE]`: `my_class.rb`
- `[NAME]`: `my_class`
- `[DIR]`: `my_dir`
- `[REFACTOR]`: `generic`
- `[EXT]`: `.rb`


## Note on performance and ChatGPT version

_The quality of results depend very much on the version of ChatGPT being used._

I have tested with both 3.5 and 4 and see **significantly** better performance with version 4.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/stevegeek/ai_refactor.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
