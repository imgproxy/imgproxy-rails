# frozen_string_literal: true

require "imgproxy"
require "imgproxy-rails/transformer"

module ImgproxyRails
  class Railtie < ::Rails::Railtie
    VARIANT_CLASSES = [
      "ActiveStorage::Variant",
      "ActiveStorage::VariantWithRecord"
    ].freeze

    initializer "imgproxy-rails.routes" do
      config.after_initialize do |app|
        app.routes.prepend do
          direct :imgproxy_active_storage do |model, options|
            if VARIANT_CLASSES.any? { |klass| model.is_a?(klass.constantize) }
              url = rails_storage_proxy_url(model.blob)
              transformations = model.variation.transformations
              ::Imgproxy.url_for(url, Transformer.call(transformations))
            else
              rails_storage_proxy_url(model, options)
            end
          end
        end
      end
    end
  end
end
