# frozen_string_literal: true

module ImgproxyRails
  class Transformer
    MAP = {
      resize: proc do |p|
        width, height = p.split("x")
        {width: width, height: height}
      end,
      resize_to_limit: proc { |p| {width: p[0], height: p[1]} },
      resize_to_fit: proc { |p| {width: p[0], height: p[1]} },
      resize_to_fill: proc { |p| {width: p[0], height: p[1], resizing_type: :fill} },
      resize_and_pad: proc { |p, m| resize_and_pad(p, m) },
      convert: proc { |p| {format: p} },
      trim: proc { {trim: 0} },
      modulate: proc { |p| modulate(p) }
    }.freeze

    PASSTHROUGH_OPTIONS = Set.new([
      "rotate",
      "sharpen",
      "blur",
      "quality"
    ]).freeze

    class << self
      def call(transformations, meta)
        passed_options = transformations.delete(:imgproxy_options) || {}
        mapped_options = transformations.each_with_object({}) do |(t_key, t_value), memo|
          if PASSTHROUGH_OPTIONS.include?(t_key.to_s)
            memo[t_key] = t_value
            next
          end
          memo.merge!(MAP[t_key].call(t_value, meta)) if MAP.key?(t_key)
        end
        mapped_options.merge(passed_options)
      end

      private

      def convert_color(color)
        return unless color && color =~ /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/

        color.sub(/^#/, "")
      end

      def resize_and_pad(p, m)
        target_width, target_height, options = p
        options ||= {}

        result = {width: target_width, height: target_height}
        return result unless m["width"] && m["height"]

        aspect_ratio = m["width"].to_f / m["height"]
        if aspect_ratio > 1
          # add vertical padding
          final_height = target_width.to_f / aspect_ratio
          padding_length = ((target_height - final_height) / 2).round
          result[:padding] = [padding_length, 0]

          # setting min-width for correct upscaling
          result[:mw] = target_width
        elsif aspect_ratio < 1
          # add horizontal padding
          final_width = target_height.to_f * aspect_ratio
          padding_length = ((target_width - final_width) / 2).round
          result[:padding] = [0, padding_length]

          # setting min-height for correct upscaling
          result[:mh] = target_height
        end

        if (background = convert_color(options[:background]))
          result[:background] = background
        end

        result
      end

      def modulate(p)
        brightness, saturation, _ = p.split(",").map(&:to_i)

        result = {}
        result[:brightness] = brightness if brightness
        result[:saturation] = saturation if saturation

        result
      end
    end
  end
end
