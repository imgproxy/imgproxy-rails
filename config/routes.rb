# frozen_string_literal: true

Rails.application.routes.draw do
  direct :imgproxy_active_storage do |model, options|
    if ImgproxyRails::Helpers.image_variation?(model)
      transformations = model.variation.transformations
      Imgproxy.url_for(model.blob, ImgproxyRails::Transformer.call(transformations, model.blob.metadata))
    else
      route_for(:rails_storage_proxy, model, options)
    end
  end
end
