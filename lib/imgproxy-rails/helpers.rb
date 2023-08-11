# frozen_string_literal: true

module ImgproxyRails
  module Helpers
    def self.image_variation?(model)
      model.respond_to?(:variation) &&
        model.try(:blob)&.content_type&.split("/")&.first == "image"
    end
  end
end
