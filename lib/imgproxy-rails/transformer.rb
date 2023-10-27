# frozen_string_literal: true

module ImgproxyRails
  class Transformer
    MAP = {
      resize: proc do |p|
        width, height = p.split("x")
        {width: width, height: height}
      end,
      resize_to_limit: proc { |p| {width: p[0], height: p[1]} },
      resize_to_fit: proc { |p| {width: p[0], height: p[1], enlarge: true} },
      resize_to_fill: proc { |p| {width: p[0], height: p[1], resizing_type: :fill, enlarge: true} },
      resize_and_pad: proc { |p| resize_and_pad(p) },
      convert: proc { |p| {format: p} },
      trim: proc { {trim: 0} },
      modulate: proc { |p| modulate(p) }
    }.freeze

    GRAVITY = {
      "north" => "no",
      "north-east" => "noea",
      "east" => "ea",
      "south-east" => "soea",
      "south" => "so",
      "south-west" => "sowe",
      "west" => "we",
      "north-west" => "nowe",
      "centre" => "ce"
    }.freeze

    PASSTHROUGH_OPTIONS = Set.new([
      "rotate",
      "sharpen",
      "blur",
      "quality"
    ]).freeze

    class << self
      def call(transformations)
        passed_options = transformations.delete(:imgproxy_options) || {}
        mapped_options = transformations.each_with_object({}) do |(t_key, t_value), memo|
          if PASSTHROUGH_OPTIONS.include?(t_key.to_s)
            memo[t_key] = t_value
            next
          end
          memo.merge!(MAP[t_key].call(t_value)) if MAP.key?(t_key)
        end
        mapped_options.merge(passed_options)
      end

      private

      def convert_color(color)
        return unless color && color =~ /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/

        color.sub(/^#/, "")
      end

      def resize_and_pad(p)
        target_width, target_height, options = p
        options ||= {}

        result = {width: target_width, height: target_height, extend: true}

        if (background = convert_color(options[:background]))
          result[:background] = background
        end

        if (gravity = GRAVITY[options[:gravity].to_s])
          result[:extend] = {extend: true, gravity: gravity}
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
