# Zeusd

Run the Zeud Gem as a daemon

[![Build Status](https://travis-ci.org/veloper/zeusd.png?branch=master)](https://travis-ci.org/veloper/zeusd) [![Code Climate](https://codeclimate.com/github/veloper/zeusd.png)](https://codeclimate.com/github/veloper/zeusd)


## Installation

Add this line to your application's Gemfile:

    gem 'zeusd'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zeusd

## Usage

### Commands

```
zeusd start [--block]
zeusd stop
zeusd restart
```

### Global Flags
* `--cwd=current/work/directory/of/rails/app` or alias `-d`
* `--verbose` or `-v`


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write and test your changes
3. Commit your changes and specs (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

* Zeusd is released under the New BSD license. http://dan.doezema.com/licenses/new-bsd/