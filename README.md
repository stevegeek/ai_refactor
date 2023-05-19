# AI Refactor

Uses ChatGPT to convert RSpec tests to minitest tests.

Convert one file at a time, or whole directories.

See `ai_refactor --help` for more information.

```shell
stephen$ OPENAI_API_KEY=my-key ai_refactor -i spec/models/my_thing_spec.rb -p prompts/rspec_to_minitest.md -v
Convert all specs in 'spec/models/my_thing_spec.rb' to minitest tests (with prompt in file prompts/rspec_to_minitest.md)...
====================
Processing spec/models/my_thing_spec.rb...
[Run spec spec/models/my_thing_spec.rb... (bundle exec rspec spec/models/my_thing_spec.rb)]
Original test run results:
>> Examples: 3, Failures: 0, Pendings: 0
Do you wish to overwrite test/models/company_buyer_test.rb? (y/n)
y
[Converting spec/models/my_thing_spec.rb...]
[OpenAI finished, with reason 'stop'...]
Used tokens: 1867
[Converted spec/models/my_thing_spec.rb to test/models/company_buyer_test.rb...]
[Run generated test file test/models/company_buyer_test.rb (bundle exec rails test test/models/company_buyer_test.rb)...]
Translated test file results:
>> Runs: 3, Failures: 0, Skips: 0
[Done converting spec/models/my_thing_spec.rb to test/models/company_buyer_test.rb...]
No differences found! Conversion worked!
====================
Done processing all files!
```


## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add ai_refactor

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install ai_refactor

## Usage

```
Usage: ai_refactor [options]
    -p, --prompt PROMPT_FILE         [Required] Specify the path to the ChatGPT 'system' prompt.
    -i, --input FILE_OR_DIR          [Required] Specify the path to the input(s).
    -w, --working DIR                Specify the working directory to run commands (eg 'rspec') in.
    -c, --continue [MAX_MESSAGES]    If ChatGPT stops generating due to the maximum token count being reached, continue to generate more messages, until a stop condition or MAX_MESSAGES. MAX_MESSAGES defaults to 3
    -m, --model MODEL_NAME           Specify a ChatGPT model to use (default gpt-3.5-turbo).
        --temperature TEMP           Specify the temperature parameter for ChatGPT (default 0.7).
        --max-tokens MAX_TOKENS      Specify the max number of tokens of output ChatGPT can generate. Max will depend on the size of the prompt (default 1500)
    -t, --timeout SECONDS            Specify the max wait time for ChatGPT response.
    -v, --verbose                    Show extra output and progress info
    -h, --help                       Prints this help
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/stevegeek/ai_refactor.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
