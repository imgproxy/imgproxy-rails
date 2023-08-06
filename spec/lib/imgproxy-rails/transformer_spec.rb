require "spec_helper"
require "imgproxy-rails/transformer"

describe ImgproxyRails::Transformer do
  describe ".call" do
    subject { described_class.call(transformations) }

    let(:transformations) do
      {
        resize: "100x100",
        resize_to_limit: [101, 101],
        resize_to_fit: [102, 102],
        resize_to_fill: [103, 103],
        resize_and_pad: [104, 104],
        crop: [20, 50, 300, 300],
        rotate: 90,
        convert: :jpg,
        define: "webp:method=6",
        monochrome: true,
        flip: true,
        sharpen: 4,
        lol: 5,
        imgproxy_options: {
          width: 500,
          height: 500,
          type: :fit,
          lol: 6
        }
      }
    end

    let(:expected_transformations) do
      {
        width: 500,
        height: 500,
        type: :fit,
        rotate: 90,
        format: :jpg,
        sharpen: 4,
        lol: 6
      }
    end

    it { is_expected.to eq(expected_transformations) }
  end
end
