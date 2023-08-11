# frozen_string_literal: true

Rails.application.routes.draw do
  direct :imgproxy_active_storage do |model, options|
    if ImgproxyRails::Helpers.image_variation?(model)
      url = route_for(:rails_storage_proxy, model.blob, options)
      transformations = model.variation.transformations
      Imgproxy.url_for(url, ImgproxyRails::Transformer.call(transformations, model.blob.metadata))
    else
      route_for(:rails_storage_proxy, model, options)
    end
  end
end
