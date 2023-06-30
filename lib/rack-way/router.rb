require_relative 'router/route.rb'
require_relative 'router/build_request.rb'

module Rack
  class Way
    class Router
      attr_writer :not_found

      def initialize
        @routes = {}

        %w[GET POST DELETE PUT TRACE OPTIONS PATCH].each do |method|
          @routes[method] = { indexes: [], route_objects: [] }
        end

        @namespaces = []

        @not_found = proc { [404, {}, ['Not found']] }
      end

      def call(env)
        route = match_route(env)
        request_builder = BuildRequest.new(env)

        return render_not_found(request_builder.call) if route.nil?

        if route.endpoint.respond_to?(:call)
          return route.endpoint.call(request_builder.call(route))
        end

        route.endpoint.new.call(request_builder.call(route))
      end

      def add(method, path, endpoint)
        route =
          Route.new(
            '/' + @namespaces.join('/') + put_path_slash(path),
            endpoint
          )

        @routes[method.to_s.upcase][:indexes].push(path)
        @routes[method.to_s.upcase][:route_objects].push(route)
      end

      def add_not_found(endpoint)
        @not_found = endpoint
      end

      def append_namespace(name)
        @namespaces.push(name)
      end

      def clear_last_namespace
        @namespaces = @namespaces.first(@namespaces.size - 1)
      end

      private

      def put_path_slash(path)
        return '' if (path == '/' || path == '') && @namespaces != []
        return '/' + path if @namespaces != []
        path
      end

      def render_not_found(env)
        return @not_found.call(env) if @not_found.respond_to?(:call)

        @not_found.new.call(env)
      end

      def match_route(env)
        index = @routes[env['REQUEST_METHOD']][:indexes].index(env['REQUEST_PATH'])
        return @routes[env['REQUEST_METHOD']][:route_objects][index] if index != nil

        @routes[env['REQUEST_METHOD']][:route_objects].detect { |route| route.match?(env) }
      end
    end
  end
end
