# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dummy app", type: :request do
  let(:option) { record }
  let(:record) { user.avatar.variant(resize_to_limit: [500, 500]) }
  let(:user) do
    User.create.tap do |user|
      user.avatar.attach(
        io: File.open("spec/avatar.png"),
        filename: "avatar.png",
        content_type: "image/png"
      )
    end
  end
  let(:user_with_previewable_image) do
    User.create.tap do |user|
      user.avatar.attach(
        io: File.open("spec/previewable.pdf"),
        filename: "avatar.pdf",
        content_type: "application/pdf"
      )
    end
  end

  before do
    Rails.application.routes.default_url_options[:host] = "http://example.com"
    Imgproxy.configure { |config| config.endpoint = "http://imgproxy.io" }
  end

  describe "image_tag" do
    include ActionView::Helpers::AssetTagHelper

    subject { image_tag(option) }

    describe "with resolve_model_to_route == :rails_storage_proxy" do
      before { ActiveStorage.resolve_model_to_route = :rails_storage_proxy }

      it { is_expected.to include('<img src="http://example.com', "representations") }
    end

    describe "with resolve_model_to_route = :imgproxy_active_storage" do
      before { ActiveStorage.resolve_model_to_route = :imgproxy_active_storage }

      it { is_expected.to include('<img src="http://imgproxy.io', "blobs") }

      context "when tracking the variants" do
        before { ActiveStorage.track_variants = true }

        it { is_expected.to include('<img src="http://imgproxy.io', "blobs") }
      end

      context "when record is not variant" do
        let(:record) { user.avatar }

        it { is_expected.to include('<img src="http://example.com', "blobs") }
      end

      context "when record is previewable" do
        let(:record) { user_with_previewable_image.avatar.preview(resize_to_limit: [500, 500]) }

        it { is_expected.to include('<img src="http://example.com', "representations") }
      end
    end
  end

  describe "url helpers" do
    describe "#imgproxy_active_storage_url" do
      subject { imgproxy_active_storage_url(option) }

      it { is_expected.to start_with("http://imgproxy.io/unsafe").and include("rails/active_storage") }
    end

    describe "#imgproxy_active_storage_path" do
      subject { imgproxy_active_storage_path(option) }

      it { is_expected.to start_with("/unsafe").and include("rails/active_storage") }
    end
  end
end
