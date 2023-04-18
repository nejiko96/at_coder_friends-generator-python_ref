[![Gem Version](https://badge.fury.io/rb/at_coder_friends-generator-python_ref.svg)](https://badge.fury.io/rb/at_coder_friends-generator-python_ref)
![Gem](https://img.shields.io/gem/dt/at_coder_friends-generator-python_ref)
[![Ruby](https://github.com/nejiko96/at_coder_friends-generator-python_ref/actions/workflows/ruby.yml/badge.svg)](https://github.com/nejiko96/at_coder_friends-generator-python_ref/actions/workflows/ruby.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/0775ef9da0798b73beb4/maintainability)](https://codeclimate.com/github/nejiko96/at_coder_friends-generator-python_ref/maintainability)
![GitHub](https://img.shields.io/github/license/nejiko96/at_coder_friends-generator-python_ref)

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

Add ```PythonRef``` to ```generators``` setting in ```.at_coder_friends.yml```

## Generator Options

Following options are available  
in ```generator_settings/PythonRef``` section of ```.at_coder_friends.yml```:

| Setting | Description  | Default |
|---------|--------------|---------|
|file_ext |File extension|py       |
|default_template|Source template file path|[/templates/python_ref.py.erb](/templates/python_ref.py.erb)|

## ```.at_coder_friends.yml``` example for Python
  ```YAML
  generators:
    - PythonRef
  generator_settings:
    PythonRef:
      default_template: /path/to/template
  ext_settings:
    'py':
      test_cmd:
        default: 'python "{dir}/{base}.py"'
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
