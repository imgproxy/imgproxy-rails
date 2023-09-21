[![Gem Version](https://badge.fury.io/rb/imgproxy-rails.svg)](https://rubygems.org/gems/imgproxy-rails) [![Build](https://github.com/palkan/imgproxy-rails/workflows/Build/badge.svg)](https://github.com/palkan/imgproxy-rails/actions)

# imgproxy-rails

Integration of [imgproxy.rb](https://github.com/imgproxy/imgproxy.rb) with [ActiveStorage::Variant API](https://edgeapi.rubyonrails.org/classes/ActiveStorage/Variant.htmlasses/ActiveStorage/Variant.html).

## Installation

Add to your project:

```ruby
# Gemfile
gem "imgproxy-rails"
```

### Supported Ruby versions

- Ruby (MRI) >= 2.7.0
- JRuby >= 9.2.9

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

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/palkan/imgproxy-rails](https://github.com/palkan/imgproxy-rails).

## Credits

This gem is generated via [new-gem-generator](https://github.com/palkan/new-gem-generator).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
