# frozen_string_literal: true

require "base64"
require "json"

RSpec.describe ActiveModel::Serializers::HTMLComment do
  let(:test_active_model_class) do
    Class.new do
      include ActiveModel::Serializers::HTMLComment

      attr_accessor :foo

      def attributes=(hash)
        hash.each do |key, value|
          send("#{key}=", value)
        end
      end

      def attributes
        instance_values
      end
    end
  end

  before do
    stub_const("TestActiveModelClass", test_active_model_class)
  end

  describe "#as_html_comment" do
    let(:instance) do
      instance = test_active_model_class.new
      instance.foo = "bar"
      instance
    end

    it "returns Nokogiri::XML::Comment" do
      expect(instance.as_html_comment).to be_a(Nokogiri::XML::Comment)
    end

    it "returns Nokogiri::XML::Comment with content base64 encoded of the JSON representation" do
      html_comment = instance.as_html_comment

      expect(html_comment.content).to eq(Base64.encode64(instance.to_json))
    end
  end

  describe "#from_html_comment" do
    let(:instance) do
      instance = test_active_model_class.new
      instance.foo = "bar"
      instance
    end

    it "returns instance" do
      html_comment = instance.as_html_comment
      result = test_active_model_class.new.from_html_comment(html_comment.to_html)

      expect(result).to have_attributes(
        instance.attributes
      )
    end
  end
end
