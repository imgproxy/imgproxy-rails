# frozen_string_literal: true

Rails.application.routes.draw do
  direct :imgproxy_active_storage do |model, options|
    if model.respond_to?(:variation) && model.try(:blob)&.content_type&.split("/")&.first == "image"
      url = route_for(:rails_storage_proxy, model.blob, options)
      transformations = model.variation.transformations
      Imgproxy.url_for(url, ImgproxyRails::Transformer.call(transformations, model.blob.metadata))
    else
      route_for(:rails_storage_proxy, model, options)
    end
  end
end
