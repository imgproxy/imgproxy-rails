# frozen_string_literal: true

require "spec_helper"
require "imgproxy-rails/transformer"

describe ImgproxyRails::Transformer do
  describe ".call" do
    subject { described_class.call(transformations, {width: 1000, height: 1000}) }

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
    subject { described_class.send(:resize_and_pad, params, meta) }

    shared_examples "transforms to" do |expected|
      it { is_expected.to eq(expected) }
    end

    context "when landscape" do
      let(:params) { [1000, 1000] }
      let(:meta) { {"width" => 1664, "height" => 960} }

      it_behaves_like "transforms to",
        width: 1000,
        height: 1000,
        padding: [212, 0],
        mw: 1000

      context "when target height and width > original image" do
        let(:params) { [2000, 2000] }
        let(:meta) { {"width" => 1664, "height" => 960} }

        it_behaves_like "transforms to",
          width: 2000,
          height: 2000,
          padding: [423, 0],
          mw: 2000
      end

      context "when target height and width < original image" do
        let(:params) { [500, 500] }
        let(:meta) { {"width" => 1664, "height" => 960} }

        it_behaves_like "transforms to",
          width: 500,
          height: 500,
          padding: [106, 0],
          mw: 500
      end
    end

    context "when vertical" do
      let(:params) { [1000, 1000] }
      let(:meta) { {"width" => 799, "height" => 1280} }

      it_behaves_like "transforms to",
        width: 1000,
        height: 1000,
        padding: [0, 188],
        mh: 1000

      context "when target height and width > original image" do
        let(:params) { [2000, 2000] }
        let(:meta) { {"width" => 799, "height" => 1280} }

        it_behaves_like "transforms to",
          width: 2000,
          height: 2000,
          padding: [0, 376],
          mh: 2000
      end

      context "when target height and width < original image" do
        let(:params) { [500, 500] }
        let(:meta) { {"width" => 799, "height" => 1280} }

        it_behaves_like "transforms to",
          width: 500,
          height: 500,
          padding: [0, 94],
          mh: 500
      end
    end

    context "when square" do
      let(:params) { [1000, 1000] }
      let(:meta) { {"width" => 500, "height" => 500} }

      it_behaves_like "transforms to", width: 1000, height: 1000
    end

    describe "background option" do
      context "when background is not present" do
        let(:params) { [1000, 1000, {background: "#bbbbc4"}] }
        let(:meta) { {"width" => 100, "height" => 100} }

        it { is_expected.to include(background: "bbbbc4") }

        context "when invalid" do
          let(:params) { [1000, 1000, {background: "invalid"}] }

          it { is_expected.to_not have_key(:background) }
        end
      end
    end
  end
end
