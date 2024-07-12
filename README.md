<p align="center">
  <a href="https://imgproxy.net">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/imgproxy/imgproxy/master/assets/logo-dark.svg?sanitize=true">
      <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/imgproxy/imgproxy/master/assets/logo-light.svg?sanitize=true">
      <img alt="imgproxy logo" src="https://raw.githubusercontent.com/imgproxy/imgproxy/master/assets/logo-light.svg?sanitize=true">
    </picture>
  </a>
</p>

<p align="center">
<a href="https://github.com/imgproxy/imgproxy-rails/actions"><img alt="GH Test" src="https://img.shields.io/github/actions/workflow/status/imgproxy/imgproxy-rails/rspec.yml?branch=master&label=Test&style=for-the-badge"/></a>
<a href="https://github.com/imgproxy/imgproxy-rails/actions"><img alt="GH Test Jruby" src="https://img.shields.io/github/actions/workflow/status/imgproxy/imgproxy-rails/rspec-jruby.yml?branch=master&label=Test%20JRuby&style=for-the-badge"/></a>
<a href="https://github.com/imgproxy/imgproxy-rails/actions"><img alt="GH Lint" src="https://img.shields.io/github/actions/workflow/status/imgproxy/imgproxy-rails/rubocop.yml?branch=master&label=Lint&style=for-the-badge"/></a>
<a href="https://rubygems.org/gems/imgproxy-rails"><img alt="Gem" src="https://img.shields.io/gem/v/imgproxy-rails.svg?style=for-the-badge"/></a>
<a href="https://www.rubydoc.info/gems/imgproxy-rails"><img alt="rubydoc.org" src="https://img.shields.io/badge/rubydoc-reference-blue.svg?style=for-the-badge"/></a>
</p>

---

Seamless integration of [imgproxy](https://imgproxy.net)–a fast and secure standalone server for resizing and converting remote images–to your Rails app with zero changes to your codebase required.

While [imgproxy.rb](https://github.com/imgproxy/imgproxy.rb) being a framework-agnostic Ruby gem includes proper support for Rails' most popular image attachment options: [Active Storage](https://edgeguides.rubyonrails.org/active_storage_overview.html) and [Shrine](https://github.com/shrinerb/shrine), it requires user to use imgproxy specific API:

```ruby
user.avatar.imgproxy_url(width: 250, height: 250)
```

But wouldn't that be awesome to keep using existing variant syntax? For example, to use vips/ImageMagick in dev and imgproxy in production?

And `imgproxy-rails` gem provides just that, thanks to [ActiveStorage::Variant API](https://api.rubyonrails.org/v7.1.3/classes/ActiveStorage/Variant.html) and [Proxy mode](https://guides.rubyonrails.org/active_storage_overview.html#proxy-mode).

## Installation

Add to your project:

```ruby
# Gemfile
gem "imgproxy-rails"
```

### Supported Ruby versions

- Ruby (MRI) >= 2.7.0
- JRuby >= 9.3.0

### Supported Rails versions

- Rails >= 6.0.0

## Usage

Given the following configuration:

```ruby
# development.rb
config.active_storage.resolve_model_to_route = :rails_storage_proxy

# production.rb
config.active_storage.resolve_model_to_route = :imgproxy_active_storage
```

The following HTML snippet will generate different URLs in dev and prod:

```erb
# show.erb.html
<%= image_tag Current.user.avatar.variant(resize: "100x100") %>
```

In dev, it will generate a URL like this:

```html
<img src="http://localhost:3000/rails/active_storage/blobs/proxy/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBWHc9IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--0c35e9a616c29da2dfa10a385bae7172526e7961/me.png">
```

In prod, it will generate a URL like this:

```html
<img src="https://imgproxy.example.com/8uVB2dYrZVOdG-1tekFjNJZ7s7VHDViXJbu9TcQavQ8/fn:me.png/aHR0cDovL2xvY2Fs/aG9zdDozMDAwL3Jh/aWxzL2FjdGl2ZV9z/dG9yYWdlL2Jsb2Jz/L3Byb3h5L2V5SmZj/bUZwYkhNaU9uc2li/V1Z6YzJGblpTSTZJ/a0pCYUhCQldIYzlJ/aXdpWlhod0lqcHVk/V3hzTENKd2RYSWlP/aUppYkc5aVgybGtJ/bjE5LS0wYzM1ZTlh/NjE2YzI5ZGEyZGZh/MTBhMzg1YmFlNzE3/MjUyNmU3OTYxL21l/LnBuZw">
```

You can also specify imgproxy-specific parameters in `imgproxy_options` attribute. Imgproxy-specific params will take precedence over ones from original API:

```ruby
# height=50 and width=50 will be applied
Current.user.avatar.variant(resize: "100x100", imgproxy_options: {height: 50, width: 50})
```

### Generating video and PDF previews

If you are an imgproxy Pro user and you want to use it to generate previews for your videos and PDFs, just add their content types to the `variable_content_types` list:

```ruby
config.active_storage.variable_content_types << "application/pdf"
config.active_storage.variable_content_types << "video/mp4"
config.active_storage.variable_content_types << "video/mov"
# ...etc
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/imgproxy/imgproxy-rails](https://github.com/imgproxy/imgproxy-rails).

## Credits

This gem is generated via [new-gem-generator](https://github.com/palkan/new-gem-generator).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
