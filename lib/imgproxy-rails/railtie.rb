# frozen_string_literal: true

require "imgproxy"
require "imgproxy-rails/transformer"

module ImgproxyRails
  module UrlHelpers
    VARIANT_CLASSES = [
      "ActiveStorage::Variant",
      "ActiveStorage::VariantWithRecord"
    ].freeze

    def imgproxy_active_storage_url(*args)
      record = args[0]

      if VARIANT_CLASSES.any? { |klass| record.is_a?(klass.constantize) }
        imgproxy_url(record)
      else
        rails_storage_proxy_url(*args)
      end
    end

    def imgproxy_active_storage_path(*args)
      rails_storage_proxy_path(*args)
    end

    private

    def imgproxy_url(record)
      transformations = record.variation.transformations
      url = rails_storage_proxy_url(record.blob)
      ::Imgproxy.url_for(url, Transformer.call(transformations))
    end
  end

  class RailtieHelpers < ::Rails::Railtie
    initializer "imgproxy-rails.include_url_helpers" do
      ActionDispatch::Routing::UrlFor.include UrlHelpers
    end
  end
end
