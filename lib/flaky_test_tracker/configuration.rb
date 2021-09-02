# frozen_string_literal: true

module FlakyTestTracker
  # rubocop:disable Metrics/ClassLength

  # Configuration.
  class Configuration
    attr_accessor :pretend, :verbose, :context, :reporter_classes

    attr_reader :source_class, :source_options, :storage_class, :storage_options

    def initialize
      @pretend = false
      @context = {}
      @verbose = true
      @reporters = []
      @source_class = nil # NullSource
      @source_options = {}
      @storage_class = nil # NullStorage
      @storage_options = {}
    end

    def source_class_name=(source_class_name)
      self.source_class = Object.const_get(source_class_name)
    end

    def source_type=(source_type)
      self.source_class =
        case source_type.to_s
        when "github"
          FlakyTestTracker::Sources::GitHubSource
        else
          raise ArgumentError, "Unkown source type #{source_type}"
        end
    end

    def source_class=(source_class)
      raise ArgumentError, "Expect source class to repond to build" unless source_class.respond_to?(:build)

      @source_class = source_class
    end

    def source_options=(source_options)
      raise ArgumentError, "Expect source options to be a Hash" unless source_options.is_a?(Hash)

      @source_options = source_options
    end

    def source=(source)
      source_methods = %i[file_source_location_uri source_uri]
      source_methods.each do |source_method|
        raise ArgumentError, "Expect source to respond to #{source_method}" unless source.respond_to?(source_method)
      end
      @source = source
    end

    def source
      self.source = source_class.build(**source_options) unless @source

      @source
    end

    def storage_class_name=(storage_class_name)
      self.storage_class = Object.const_get(storage_class_name)
    end

    def storage_type=(storage_type)
      self.storage_class =
        case storage_type.to_s
        when "github_issue"
          FlakyTestTracker::Storage::GitHubIssueStorage
        else
          raise ArgumentError, "Unkown storage type #{storage_type}"
        end
    end

    def storage_class=(storage_class)
      raise ArgumentError, "Expect storage class to repond to build" unless storage_class.respond_to?(:build)

      @storage_class = storage_class
    end

    def storage=(storage)
      storage_methods = %i[all create update delete]
      storage_methods.each do |storage_method|
        raise ArgumentError, "Expect storage to respond to #{storage_method}" unless storage.respond_to?(storage_method)
      end
      @storage = storage
    end

    def storage_options=(storage_options)
      raise ArgumentError, "Expect storage options to be a Hash" unless storage_options.is_a?(Hash)

      @storage_options = storage_options
    end

    def storage
      self.storage = storage_class.build(**storage_options) unless @storage

      @storage
    end

    # ===

    def reporter_class_names=(reporter_class_names)
      @reporter_classes = reporter_class_names.map do |reporters_class_name|
        Object.const_get(reporters_class_name)
      end
    end

    def reporters=(reporters)
      reporter_methods = %i[tracked_test tracked_tests resolved_test resolved_tests]
      reporters.each do |reporter|
        reporter_methods.each do |reporter_method|
          unless reporter.respond_to?(reporter_method)
            raise ArgumentError, "Expect reporter to respond to #{reporter_method}"
          end
        end
      end

      @reporters = reporters
    end

    def reporters
      self.reporters = reporter_classes.map(&:new) unless @reporters

      @reporters
    end

    def reporter
      FlakyTestTracker::Reporter.new(reporters: build_reporters)
    end

    private

    def build_reporters
      if verbose
        [FlakyTestTracker::Reporters::STDOUTReporter.new] + reporters
      else
        reporters
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
