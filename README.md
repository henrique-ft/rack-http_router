# rackr ![](https://img.shields.io/badge/version-0.0.2-blue.svg)

A complete, simple and easy to learn web micro-framework.

## Why??

- Rackr is designed to be what almost every one is expecting in a web micro-framework. Avoid brain gimnastics, too much magic, exotic way of doing things or hard documentations. Just ship value in a maintenable software using the language you love.

- 4x faster than Sinatra 7x from Rails. If you are looking for a bunch of performance.

- Lightweight and resourceful: With just 7 well tested .rb files and almost no dependences, Rackr is a “web glue” helping we organize requests and responses the better way we can.

- Rack first. Explicity receive Rack::Request objects and return Rack::Responses 

- Good documentation is one of the most important things here (in progress).

## Installation:

```bash
gem install rackr
```

## Quick Start
This is a pure Rack application:

```ruby
# config.ru
run do |env|
  [200, {'content-type' => 'text/html'}, ["<h1>Hello!</h1>"]]
end
```

This is a minimal Rackr application:
```ruby
# config.ru
require 'rackr'

run (Rackr.new.call do
  get do |req|
    [200, {'content-type' => 'text/html'}, ["<h1>Hello!</h1>"]]
  end
end)
```
As you can imagine, there are function defined for all http methods: `get`, `post`, `delete`, `put`, `trace`, `options`, `patch` and all work in the same way. The block receives a param that is just a instance of `Rack::Request` (`Rack::Request.new(env)`). But is not obrigatory if we will not use it.

This is the same Rackr application using the `html` helper:
```ruby
# config.ru
require 'rackr'

run (Rackr.new.call do
  get do |req|
    html("<h1>Hello!</h1>") # [200, {'content-type' => 'text/html'}, ["<h1>Hello!</h1>"]]
  end
end)
```
In addition to `html`, there are other helpers: `json`, `head`, `text` and also `view`.

Now lets scope our get endpoint to a `'v1/hello'` path:
```ruby
# config.ru
require 'rackr'

run (Rackr.new.call do
  scope 'v1' do
    scope 'hello' do
      get do |req|
        html("<h1>Hello!</h1>")
      end
    end
  end
end)
```

And say hello to specific name in `'v1/hello/somename'`
```ruby
# config.ru
require 'rackr'

run (Rackr.new.call do
  scope 'v1' do
    scope 'hello' do
      scope :name do
        get do |req|
          html("<h1>Hello #{req.params[:name]}!</h1>") # Rackr inject request params in the Rack::Request object
        end
      end
    end
  end
end)
```

Maybe we can do it with fewer lines:
```ruby
# config.ru
require 'rackr'

run (Rackr.new.call do
  get 'v1/hello/:name' do |req|
    html("<h1>Hello #{req.params[:name]}!</h1>")
  end
end)
```

If our app grows, we can create a *"rackr action"* including *Rackr::Action* module in a class and creating a `call` instance method:

```ruby
# config.ru
require 'rackr'

class HelloAction
  include Rackr::Action

  def call(req)
    html("<h1>Hello #{req.params[:name]}!</h1>")
  end
end

run (Rackr.new.call do
  get 'v1/hello/:name', HelloAction
end)
```

## Usefull resources

#### Rack Docs

- [Rack::Request](https://www.rubydoc.info/github/rack/rack/Rack/Request)
- [Rack::Session](https://www.rubydoc.info/github/rack/rack/Rack/Session)
- [Rack::Utils](https://www.rubydoc.info/github/rack/rack/Rack/Utils)

### How to

#### Serve static files:
```ruby
# config.ru
use Rack::Static, :urls => ["/public"] # Add paths for your public content
```
#### Work with sessions:

```ruby
# config.ru
use Rack::Session::Cookie,
    :key => 'rack.session', # Key for Rack 
    :expire_after => 2592000, # Expiration date
    :secret => ENV['MY_SECRET_KEY'] # Your secret key. 
```

#### Auto refresh the server for development:

use https://github.com/alexch/rerun

#### CRSF protection:

use https://github.com/baldowl/rack_csrf

#### HTTP Cache:

use https://github.com/rtomayko/rack-cache

## Feel free to get the idea, fork, contribute and do whatever you want!

Contact me if you have any issue:

hriqueft@gmail.com

I will be always open for tips, improvements, new ideas and new contributors! 

