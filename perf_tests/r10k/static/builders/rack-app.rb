rack_app_routes = lambda do |f, level, prefix|
  base = BASE_ROUTE.dup
  ROUTES_PER_LEVEL.times do
    if level == 1
      f.puts "  get '#{prefix}#{base}' do"
      f.puts "    '#{RESULT.call(prefix[1..-1] + base)}'"
      f.puts "  end"
    else
      rack_app_routes.call(f, level-1, "#{prefix}#{base}/")
    end
    base.succ!
  end
end

File.open("#{File.dirname(__FILE__)}/../apps/rack-app_#{LEVELS}_#{ROUTES_PER_LEVEL}.rb", 'wb') do |f|
  f.puts "# frozen-string-literal: true"
  f.puts "require 'rack/app'"
  f.puts "class App < Rack::App"
  f.puts "  use Rack::App::Middlewares::HeaderSetter, 'Content-Type'=>'text/html'"
  rack_app_routes.call(f, LEVELS, '/')
  f.puts "end"
end
