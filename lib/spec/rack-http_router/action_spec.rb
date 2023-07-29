# frozen_string_literal: true

require_relative '../../rack-http_router/action'
require 'byebug'

class SomeClass
  include Rack::HttpRouter::Action
end

class SomeClass2
end

RSpec.describe Rack::HttpRouter::Action do
  context 'rendering content' do
    context 'text' do
      it 'can render from string with success' do
        result = Rack::HttpRouter::Action.text('test')
        expect(result).to eq(
          [
            200,
            { 'Content-Type' => 'text/plain' },
            %w[test]
          ]
        )
      end

      it 'can render text with other status' do
        result = Rack::HttpRouter::Action.text('test', status: 201)
        expect(result).to eq(
          [
            201,
            { 'Content-Type' => 'text/plain' },
            %w[test]
          ]
        )
      end
    end

    context 'assign' do
      it 'can assign methods to objects' do
        x = SomeClass2.new
        Rack::HttpRouter::Action.assign(x, { method1: 1, method2: 2 })

        expect(x.method1).to eq(1)
        expect(x.method2).to eq(2)
      end
    end

    context 'html_response' do
      it 'can render from string with success' do
        response = Rack::HttpRouter::Action.text_response('test')
        expect(response.finish).to eq(
          [
            200,
            { 'content-type' => 'text/plain' },
            %w[test]
          ]
        )
      end

      it 'can render text with other status' do
        response = Rack::HttpRouter::Action.text_response('test', status: 201)
        expect(response.finish).to eq(
          [
            201,
            { 'content-type' => 'text/plain' },
            %w[test]
          ]
        )
      end
    end

    context 'html' do
      it 'can render from string with success' do
        result = Rack::HttpRouter::Action.html('test')
        expect(result).to eq(
          [
            200,
            { 'Content-Type' => 'text/html' },
            %w[test]
          ]
        )
      end

      it 'can render html with other status' do
        result = Rack::HttpRouter::Action.html('test', status: 201)
        expect(result).to eq(
          [
            201,
            { 'Content-Type' => 'text/html' },
            %w[test]
          ]
        )
      end
    end

    context 'html_response' do
      it 'can render from string with success' do
        response = Rack::HttpRouter::Action.html_response('test')
        expect(response.finish).to eq(
          [
            200,
            { 'content-type' => 'text/html' },
            %w[test]
          ]
        )
      end

      it 'can render html with other status' do
        response = Rack::HttpRouter::Action.html_response('test', status: 201)
        expect(response.finish).to eq(
          [
            201,
            { 'content-type' => 'text/html' },
            %w[test]
          ]
        )
      end
    end

    context 'view' do
      before do
        allow(::File).to receive(:read).and_return('hey')
      end

      it 'can render with success' do
        path = 'test'

        result = Rack::HttpRouter::Action.view path

        expect(result).to eq([200, { 'Content-Type' => 'text/html' }, %w[hey]])
      end

      it 'can render with success with response_instance' do
        path = 'test'

        response = Rack::HttpRouter::Action.view path, response_instance: true

        expect(response.finish).to eq([200, { 'content-type' => 'text/html' }, %w[hey]])
      end

      it 'reads the views/* folder' do
        path = 'test'

        Rack::HttpRouter::Action.view path

        expect(::File).to have_received(:read).with('views/test.html.erb')
      end

      it 'reads the config views folder' do
        path = 'test'

        Rack::HttpRouter::Action.view path, config: { views: { path: 'some/path' }}

        expect(::File).to have_received(:read).with('some/path/test.html.erb')
      end

      it 'can render with different status' do
        path = 'test'

        result = Rack::HttpRouter::Action.view path, status: 404

        expect(result).to eq([404, { 'Content-Type' => 'text/html' }, %w[hey]])
      end

      it 'can render multiple erbs' do
        path = 'test'

        result = Rack::HttpRouter::Action.view [path, path, path], status: 404

        expect(result).to eq(
          [404, { 'Content-Type' => 'text/html' }, %w[heyheyhey]]
        )
      end
    end

    context 'view_response' do
      before do
        allow(::File).to receive(:read).and_return('hey')
      end

      it 'can render with success with response_instance' do
        path = 'test'

        response = Rack::HttpRouter::Action.view_response path
        expect(response.finish).to eq([200, { 'content-type' => 'text/html' }, %w[hey]])
      end
    end

    context 'json' do
      it 'can render from hash with success' do
        result = Rack::HttpRouter::Action.json({ test: 'value' })
        expect(result).to eq(
          [
            200,
            { 'Content-Type' => 'application/json' },
            %w[{"test":"value"}]
          ]
        )
      end

      it 'can render json with other status' do
        result = Rack::HttpRouter::Action.json({ test: 'value' }, status: 201)
        expect(result).to eq(
          [
            201,
            { 'Content-Type' => 'application/json' },
            %w[{"test":"value"}]
          ]
        )
      end
    end

    context 'json_response' do
      it 'can render from hash with success' do
        response = Rack::HttpRouter::Action.json_response({ test: 'value' })
        expect(response.finish).to eq(
          [
            200,
            { 'content-type' => 'application/json' },
            %w[{"test":"value"}]
          ]
        )
      end

      it 'can render json with other status' do
        response = Rack::HttpRouter::Action.json_response({ test: 'value' }, status: 201)
        expect(response.finish).to eq(
          [
            201,
            { 'content-type' => 'application/json' },
            %w[{"test":"value"}]
          ]
        )
      end
    end
  end

  context 'response' do
    it 'can build a rack response' do
      response = Rack::HttpRouter::Action.response

      expect(response).to be_a(Rack::Response)
      expect(response.status).to eq(200)
      expect(response.body).to eq([])
      expect(response.headers).to eq({})
    end
  end

  context 'redirecting' do
    it 'can redirect' do
      result = Rack::HttpRouter::Action.redirect_to('/hey')
      expect(result).to eq([302, { 'Location' => '/hey' }, []])
    end

    it 'can redirect with rack response' do
      res = Rack::HttpRouter::Action.redirect_response('/hey')
      expect(res.finish).to eq([302, { 'location' => '/hey' }, []])
    end
  end

  context 'including' do
    let(:route) { 'route' }
    let(:config) { { some_config: 'a', db: 'db' } }
    let(:included) { SomeClass.new(route: route, config: config)}

    it { expect(included.route).to eq(route) }
    it { expect(included.config).to eq(config) }
    it { expect(included.db).to eq(config[:db]) }
  end
end
