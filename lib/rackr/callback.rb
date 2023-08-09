class Rackr
  module Callback
    def self.included(base)
      base.class_eval do
        include Rackr::Action
      end
    end

    def assign(obj, hash)
      Rackr::Callback.assign(obj, hash)
    end

    def self.assign(obj, hash)
      hash.each do |k, v|
        obj.define_singleton_method(k) { v }
      end

      obj
    end
  end
end
