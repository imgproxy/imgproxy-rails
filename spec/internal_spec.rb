require "rails_helper"

RSpec.describe "Dummy app", type: :request do
  include ActionView::Helpers::AssetTagHelper

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

  before { Rails.application.routes.default_url_options[:host] = "http://example.com" }

  describe "image_tag" do
    subject { image_tag(option) }

    shared_context "handles string correctly" do
      let(:option) { "http://image1.png" }

      it { is_expected.to include(option) }
    end

    describe "with resolve_model_to_route == :rails_storage_proxy" do
      before { ActiveStorage.resolve_model_to_route = :rails_storage_proxy }

      it { is_expected.to include('<img src="http://example.com', "representations") }
      it_behaves_like "handles string correctly"
    end

    describe "with resolve_model_to_route = :imgproxy_active_storage" do
      before do
        ActiveStorage.resolve_model_to_route = :imgproxy_active_storage
        Imgproxy.configure do |config|
          config.endpoint = "http://imgproxy.io"
        end
      end

      it { is_expected.to include('<img src="http://imgproxy.io', "blobs") }

      it_behaves_like "handles string correctly"

      context "when tracking the variants" do
        before { ActiveStorage.track_variants = true }

        it { is_expected.to include('<img src="http://imgproxy.io', "blobs") }

        it_behaves_like "handles string correctly"
      end

      context "when record is not variant" do
        let(:record) { user.avatar }

        it { is_expected.to include('<img src="http://example.com', "blobs") }

        it_behaves_like "handles string correctly"
      end
    end
  end

  describe "url helpers" do
    describe "#imgproxy_active_storage_path" do
      subject { imgproxy_active_storage_path(option) }

      describe "with resolve_model_to_route == :imgproxy_active_storage" do
        before { ActiveStorage.resolve_model_to_route = :imgproxy_active_storage }

        it { is_expected.to start_with("/rails/active_storage") }
      end

      describe "with resolve_model_to_route == :rails_storage_proxy" do
        before { ActiveStorage.resolve_model_to_route = :rails_storage_proxy }

        it { is_expected.to start_with("/rails/active_storage") }
      end
    end
  end
end
