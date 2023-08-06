# frozen_string_literal: true

module ImgproxyRails
  class Transformer
    class << self
      MAP = {
        resize: ->(p) do
          width, height = p.split("x")
          {width: width, height: height}
        end,
        resize_to_limit: ->(p) { {width: p[0], height: p[1], type: :fit} },
        resize_to_fit: ->(p) { {width: p[0], height: p[1], type: :fit} },
        resize_to_fill: ->(p) { {width: p[0], height: p[1], type: :fill} },
        resize_and_pad: ->(p) { false },
        crop: ->(p) { false },
        rotate: ->(p) { p },
        convert: ->(p) { {format: p} },
        define: ->(p) { false },
        monochrome: ->(p) { false },
        flip: ->(p) { false },
        sharpen: ->(p) { p }
      }

      def call(transformations)
        passed_options = transformations.delete(:imgproxy_options) || {}
        mapped_options = transformations.each_with_object({}) do |(key, value), memo|
          next unless MAP.key?(key)

          value = MAP[key].call(value)
          next if value.is_a?(FalseClass)

          if value.is_a?(Hash)
            memo.merge!(value)
          else
            memo[key] = value
          end
        end
        mapped_options.merge(passed_options)
      end
    end
  end
end
