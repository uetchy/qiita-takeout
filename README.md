# Qiita::Takeout

This gem can takes your articles from Qiita to local storage.
It's assumed to use for backup.

## Installation

```ruby
gem install qiita-takeout
```

## Usage

```console
$ qiita-takeout dump [name] [password]
Dumped => qiita-takeout-20150125
$ tree qiita-takeout-20150125
qiita-takeout-20150125
├── articles.json
└── images
    ├── 163015
    │   └── ss3.png
    ├── 22393
    │   └── s1.png
    └── 31208
        └── s.png
```

## Contributing

1. Fork it ( https://github.com/uetchy/qiita-takeout/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
