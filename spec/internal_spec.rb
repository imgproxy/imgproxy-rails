# frozen_string_literal: true

require "rails_helper"
require "ostruct"

describe "Dummy app" do
  let(:option) { record }
  let(:record) { user.avatar.variant(variant_options) }
  let(:variant_options) { {resize_to_limit: [500, 500]} }
  let(:user) do
    User.create.tap do |user|
      user.avatar.attach(
        io: File.open("spec/avatar.png"),
        filename: "avatar.png",
        content_type: "image/png"
      )
    end
  end
  let(:user_with_video) do
    User.create.tap do |user|
      user.avatar.attach(
        io: File.open("spec/avatar.mp4"),
        filename: "avatar.png",
        content_type: "video/mp4"
      )
    end
  end
  let(:user_with_pdf) do
    User.create.tap do |user|
      user.avatar.attach(
        io: File.open("spec/avatar.pdf"),
        filename: "avatar.pdf",
        content_type: "application/pdf"
      )
    end
  end

  describe "image_tag" do
    include ActionView::Helpers::AssetTagHelper

    subject { image_tag(option) }

    describe "with resolve_model_to_route == :rails_storage_proxy" do
      before { ActiveStorage.resolve_model_to_route = :rails_storage_proxy }

      it { is_expected.to include('<img src="http://example.com', "representations") }

      context "when imgproxy_options are passed" do
        let(:variant_options) { {imgproxy_options: {width: 100}} }

        it { is_expected.to include('<img src="http://example.com', "representations") }
      end
    end

    describe "with resolve_model_to_route = :imgproxy_active_storage" do
      before { ActiveStorage.resolve_model_to_route = :imgproxy_active_storage }

      it { is_expected.to include('<img src="http://imgproxy.io', "rails/active_storage/blobs/proxy") }

      context "when imgproxy_options are passed" do
        let(:variant_options) { {imgproxy_options: {width: 100}} }

        it { is_expected.to include('<img src="http://imgproxy.io', "w:100", "blobs") }
      end

      context "when tracking the variants" do
        before { ActiveStorage.track_variants = true }

        it { is_expected.to include('<img src="http://imgproxy.io', "blobs") }
      end

      context "when record is not variant" do
        let(:record) { user.avatar }

        it { is_expected.to include('<img src="http://example.com', "blobs") }
      end

      context "when record is video" do
        before { ActiveStorage.variable_content_types << "video/mp4" }
        let(:record) { user_with_video.avatar.variant(resize_to_limit: [500, 500]) }

        it { is_expected.to include('<img src="http://imgproxy.io', "blobs") }
      end

      context "when record is PDF" do
        before { ActiveStorage.variable_content_types << "application/pdf" }
        let(:record) { user_with_pdf.avatar.variant(resize_to_limit: [500, 500]) }

        it { is_expected.to include('<img src="http://imgproxy.io', "blobs") }
      end

      context "when using short S3 urls with imgproxy", skip: ActiveStorage::VERSION::MAJOR < 7 do
        let(:s3_service_class) do
          stub_const("ActiveStorage::Service::S3Service", Class.new(SimpleDelegator) do
            def name
              "fake_cloud"
            end

            def bucket
              OpenStruct.new(name: "test-bucket")
            end
          end)
        end

        let(:services) { ActiveStorage::Blob.services.instance_variable_get(:@services) }

        before do
          fake_cloud_service = s3_service_class.new(ActiveStorage::Blob.service)
          services[:fake_cloud] = fake_cloud_service
          ActiveStorage::Blob.service = :fake_cloud
          Imgproxy.config.use_s3_urls = true
        end

        after do
          services.delete(:fake_cloud)
          ActiveStorage::Blob.service = :test
          Imgproxy.config.use_s3_urls = false
        end

        it { is_expected.to include('<img src="http://imgproxy.io', "s3://test-bucket", record.blob.key) }
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
