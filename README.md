# AtCoderFriends::Generator::PythonRef

Python source generator for [AtCoderFriends](https://github.com/nejiko96/at_coder_friends).  
(This is reference implementation)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'at_coder_friends-generator-python_ref'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install at_coder_friends-generator-python_ref

## Configuration

Add ```PythonRef``` to ```generators``` setting in ```.at_coder_friends.yml```:
  ```YAML
  generators:
    - PythonRef
  ```

## Generator Options

You can set following options to ```generator_settings/PythonRef``` setting  
in ```.at_coder_friends.yml```:

| Setting | Description | Default |
|---------|-------------|---------|
|default_template|Source template file path|[/templates/python_ref_default.py](/templates/python_ref_default.py)|
|interactive_template|Source template file path for interactive problems|[/templates/python_ref_interactive.py](/templates/python_ref_interactive.py)|

### Example
  ```YAML
  generator_settings:
    PythonRef:
      default_template: /path/to/template
  ```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/at_coder_friends-generator-python_ref. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the AtCoderFriends::Generator::PythonRef project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/at_coder_friends-generator-python_ref/blob/master/CODE_OF_CONDUCT.md).
