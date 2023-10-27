# frozen_string_literal: true

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
        rotate: 90,
        convert: :jpg,
        sharpen: 4,
        blur: 40,
        quality: 80,
        trim: true,
        modulate: "150,151,152",
        lol: 5,
        imgproxy_options: {
          width: 500,
          height: 500,
          resizing_type: :fit,
          lol: 6
        }
      }
    end

    let(:expected_transformations) do
      {
        width: 500,
        height: 500,
        enlarge: true,
        extend: true,
        resizing_type: :fit,
        rotate: 90,
        format: :jpg,
        sharpen: 4,
        blur: 40,
        brightness: 150,
        quality: 80,
        saturation: 151,
        trim: 0,
        lol: 6
      }
    end

    it { is_expected.to eq(expected_transformations) }
  end

  describe ".resize_and_pad" do
    subject { described_class.send(:resize_and_pad, params) }

    shared_examples "transforms to" do |expected|
      it { is_expected.to eq(expected) }
    end

    let(:params) { [1000, 1000] }

    specify do
      is_expected.to eq(
        width: 1000,
        height: 1000,
        extend: true
      )
    end

    context "when background is present" do
      let(:params) { [1000, 1000, {background: "#bbbbc4"}] }

      it { is_expected.to include(background: "bbbbc4") }

      context "when invalid" do
        let(:params) { [1000, 1000, {background: "invalid"}] }

        it { is_expected.to_not have_key(:background) }
      end
    end

    context "when gravity is present" do
      let(:params) { [1000, 1000, {gravity: :"north-east"}] }

      it { expect(subject.fetch(:extend)).to eq(extend: true, gravity: "noea") }
    end
  end
end
