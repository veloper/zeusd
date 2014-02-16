# Zeusd [![Gem Version](https://badge.fury.io/rb/zeusd.png)](http://badge.fury.io/rb/zeusd) [![Build Status](https://travis-ci.org/veloper/zeusd.png?branch=master)](https://travis-ci.org/veloper/zeusd) [![Code Climate](https://codeclimate.com/github/veloper/zeusd.png)](https://codeclimate.com/github/veloper/zeusd)

Zeusd a wraps around the Zeus Gem and turns it into a daemon.



## Installation

```
$ gem install zeusd
```

## Usage

### Main Commands

```
$ zeusd start   [--cwd=/path/to/rails/root]
                [--block | -b]
                [--verbose | -v]

$ zeusd restart [--cwd=/path/to/rails/root]
                [--block | -b]
                [--verbose | -v]

$ zeusd stop    [--cwd=/path/to/rails/root]
                [--verbose | -v]
```

### Utility Commands

```
$ zeusd tail    [--cwd=/path/to/rails/root]
                [--follow | -f]
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write passing specs that test your changes
3. Commit your changes and specs (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Author

[Daniel Doezema](http://dan.doezema.com)

## License

* Zeusd is released under the New BSD license. http://dan.doezema.com/licenses/new-bsd/