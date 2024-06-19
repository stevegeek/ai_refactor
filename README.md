# AIRefactor for Ruby

__The goal for AIRefactor is to use LLMs to apply repetitive refactoring tasks to code.__

## The workflow

1) the human decides what refactoring is needed
2) the human selects an existing built-in refactoring command, and/or builds up a prompt to describe the task
3) the human selects some source files to act as context (eg examples of the code post-refactor, or related classes etc)
4) the human runs the tool with the command, source files and context files
5) the AI generates the refactored code and outputs it either to a file or stdout.
6) In some cases, the tool can then check the generated code by running tests and comparing test outputs.

AIRefactor can apply the refactoring to multiple files, allowing batch processing.

#### Notes

AI Refactor is an experimental tool and under active development as I explore the idea myself. It may not work as expected, or
change in ways that break existing functionality.

The focus of the tool is work with the **Ruby programming language ecosystem**, but it can be used with any language.

AI Refactor currently uses [OpenAI's ChatGPT](https://platform.openai.com/) or [Anthropic Claude](https://docs.anthropic.com/en/docs/about-claude/models) to generate code.

## Examples

See the [examples](examples/) directory for some examples of using the tool.

You can run the command files to run the example.

For example, the first example can be run with: (you can add options if desired, eg `-v` for verbose output and `-d` for debug output)

```shell
./exe/ai_refactor examples/ex1_convert_a_rspec_test_to_minitest.yml
```

You should see:
    
```
$ ./exe/ai_refactor examples/ex1_convert_a_rspec_test_to_minitest.yml
Loading refactor command file 'examples/ex1_convert_a_rspec_test_to_minitest.yml'...
AI Refactor 1 files(s)/dir(s) '["examples/ex1_input_spec.rb"]' with rails/minitest/rspec_to_minitest refactor
====================
Processing examples/ex1_input_spec.rb...

No differences found! Conversion worked!
Refactor succeeded on examples/ex1_input_spec.rb

All files processed successfully!
Done processing all files!
```

And find the file `examples/ex1_input_test.rb` has been created. Note the process above also ran the generated test file and compared the output to the original test file.

If you see an error, then try to run it again, or use a different GPT model.

## Available refactors & commands

Write your own prompt:

- `ruby/write_ruby`: provide your own prompt for the AI and expect to output Ruby code (no input files required)
- `ruby/refactor_ruby`: provide your own refactoring prompt for the AI and expect to output Ruby code
- `custom`: provide your own prompt for the AI and run against the input files. There is no expectation of the output.

Use a pre-built prompt:

- `minitest/write_test_for_class`: write a minitest test for a given class
- `rails/minitest/rspec_to_minitest`: convert RSpec specs to minitest tests in Rails apps

### User supplied prompts, eg `custom`, `ruby/write_ruby` and `ruby/refactor_ruby`

You can use these commands in conjunction with a user supplied prompt. 

You must supply a prompt file with the `-p` option.

The output is written to `stdout`, or to a file with the `--output` option.

User supplied prompts are best configured using a command file, see below.

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

### `minitest/write_test_for_class`

Writes a minitest test for a given class. The output will, by default, be put into a directory named `test` in the current directory,
in a path that matches the input file path, with a `_test.rb` suffix.

For example, if the input file is `app/stuff/my_thing.rb` the output will be written to `test/app/stuff/my_thing_test.rb`.

This refactor can benefit from being passed related files as context, for example, if the class under test inherits from another class,
then context can be used to provide the parent class.

### `quickdraw/0.1.0/convert_minitest`

Convert Minitest or Test::Unit test suite files to [Quickdraw](https://github.com/joeldrapper/quickdraw) test suite files.

Files, by default, are output to the same directory as the input file but with .test.rb extension (and _test removed).

Note: Quickdraw is still missing some features, so some minitest methods are not converted, for example, Quickdraw does not support setup/teardown just yet.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add ai_refactor

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install ai_refactor

## Usage

See `ai_refactor --help` for more information.

```
Usage: ai_refactor REFACTOR_TYPE_OR_COMMAND_FILE INPUT_FILE_OR_DIR [options]

Where REFACTOR_TYPE_OR_COMMAND_FILE is either the path to a command YML file, or one of the refactor types: ["custom" ... (run ai_refactor --help for full list of refactor types)]

    -o, --output [FILE]              Write output to given file instead of stdout. If no path provided will overwrite input file (will prompt to overwrite existing files). Some refactor tasks will write out to a new file by default. This option will override the tasks default behaviour.
    -O, --output-template TEMPLATE   Write outputs to files instead of stdout. The template is used to create the output name, where the it can have substitutions, '[FILE]', '[NAME]', '[DIR]', '[REFACTOR]' & '[EXT]'. Eg `[DIR]/[NAME]_[REFACTOR][EXT]` (will prompt to overwrite existing files)
    -c, --context CONTEXT_FILES      Specify one or more files to use as context for the AI. The contents of these files will be prepended to the prompt sent to the AI.
    -x, --extra CONTEXT_TEXT         Specify some text to be prepended to the prompt sent to the AI as extra information of note.
    -r, --review-prompt              Show the prompt that will be sent to ChatGPT but do not actually call ChatGPT or make changes to files.
    -p, --prompt PROMPT_FILE         Specify path to a text file that contains the ChatGPT 'system' prompt.
    -f, --diffs                      Request AI generate diffs of changes rather than writing out the whole file.
    -C, --continue [MAX_MESSAGES]    If ChatGPT stops generating due to the maximum token count being reached, continue to generate more messages, until a stop condition or MAX_MESSAGES. MAX_MESSAGES defaults to 3
    -m, --model MODEL_NAME           Specify a ChatGPT model to use (default gpt-4-turbo).
        --temperature TEMP           Specify the temperature parameter for ChatGPT (default 0.7).
        --max-tokens MAX_TOKENS      Specify the max number of tokens of output ChatGPT can generate. Max will depend on the size of the prompt (default 1500)
    -t, --timeout SECONDS            Specify the max wait time for ChatGPT response.
        --overwrite ANSWER           Always overwrite existing output files, 'y' for yes, 'n' for no, or 'a' for ask. Default to ask.
    -N, --no                         Never overwrite existing output files, same as --overwrite=n.
    -v, --verbose                    Show extra output and progress info
    -d, --debug                      Show debugging output to help diagnose issues
    -h, --help                       Prints this help
```

### Interactive mode

A basic interactive mode exists too, where you are prompted for options. 

Start interactive mode by not specifying anything for `REFACTOR_TYPE_OR_COMMAND_FILE` (ie no refactor type or command file)

### Command files and Custom prompts

Apart from invoking the tool with CLI options, the tool can also be invoked with a command file.

This makes it easier to build custom refactor prompts for projects, and run that custom refactor multiple times.

The command file is a YAML file that contains configuration options to pass to the tool.

The format of the YAML file is:

```yaml
# Required options:
refactor: refactor type name, eg 'ruby/write_ruby'
# Optional options:
input_file_paths: 
  - input files or directories
output_file_path: output file or directory
output_template_path: output file template (see docs)
prompt_file_path: path
prompt: |
  A custom prompt to send to AI if the command needs it (otherwise read from file)
context_file_paths: 
    - file1.rb
    - file2.rb
context_file_paths_from_gems:
  gem_name: 
    - path/from/gem_root/file1.rb
    - lib/gem_name/file2.rb
  gem_name2: 
    - lib/gem_name2/file1.rb
    - app/controllers/file2.rb
# Other configuration options:
context_text: |
    Some extra info to prepend to the prompt
diff: true/false (default false)
ai_max_attempts: max times to generate more if AI does not complete generating (default 3)
ai_model: AI model name, OpenAI GPT or Anthropic Claude (default gpt-4-turbo)
ai_temperature: AI temperature (default 0.7)
ai_max_tokens: AI max tokens (default 1500)
ai_timeout: AI timeout (default 60)
overwrite: y/n/a (default a)
verbose: true/false (default false)
debug: true/false (default false)
```

The command file can be invoked by passing it as the first argument to the tool:

```shell
ai_refactor my_command_file.yml
```

Other options can be passed on the command line and will override the options in the command file.

For example, if the command file contains:

```shell
ai_refactor my_command_file.yml my_input.rb -d --output foo.rb
```

### Prompt template substitutions

Prompt text can contain the following substitutions:

* `__{{input_file_path}}__`: the path to the input file
* `__{{output_file_path}}__`: the path to the output file
* `__{{prompt_header}}__`: the place the pre-build prompt will be injected, if used
* `__{{prompt_footer}}__`: prompt text that will be inserted after the prompt, eg the "make diffs" prompt if `--diffs` is used
* `__{{context}}__`: the contents of the context files, if any
* `__{{content}}__`: the contents of input file, if any

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

## Configuration

### `.ai_refactor` file

The tool can be configured using a `.ai_refactor` file in the current directory or in the user's home directory.

This file provides default CLI switches to add to any `ai_refactor` command.

## Command history

The tool keeps a history of commands run in the `.ai_refactor_history` file in the current working directory.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/stevegeek/ai_refactor.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
