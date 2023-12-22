# frozen_string_literal: true

module ImgproxyRails
  module Helpers
    def self.applicable_variation?(model)
      return false if !model.respond_to?(:variation)

      content_type = model.try(:blob)&.content_type
      content_type&.start_with?("image/") ||
        content_type&.start_with?("video/") ||
        content_type == "application/pdf"
    end
  end
end
