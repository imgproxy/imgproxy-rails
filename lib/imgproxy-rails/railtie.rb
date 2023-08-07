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
              url = route_for(:rails_storage_proxy, model.blob, options)
              transformations = model.variation.transformations
              ::Imgproxy.url_for(url, Transformer.call(transformations))
            else
              route_for(:rails_storage_proxy, model, options)
            end
          end
        end
      end
    end
  end
end
