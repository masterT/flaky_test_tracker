# frozen_string_literal: true

module FlakyTestTracker
  # Configuration.
  class Configuration
    attr_accessor :pretend, :verbose, :context

    attr_reader :source_class, :source_options, :storage_class, :storage_options, :reporter_class, :reporter_options

    def initialize
      @pretend = false
      @context = {}
      @verbose = true
      @source_class = nil # NullSource
      @source_options = {}
      @storage_class = nil # NullStorage
      @storage_options = {}
      @reporter_class = nil # NullReporter
      @reporter_options = {}
    end

    def source_class_name=(source_class_name)
      self.source_class = Object.const_get(source_class_name)
    end

    def source_type=(source_type)
      self.source_class =
        case source_type.to_s
        when "github"
          FlakyTestTracker::Source::GitHubSource
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

    def reporter_class_name=(reporter_class_name)
      self.reporter_class = Object.const_get(reporter_class_name)
    end

    def reporter_class=(reporter_class)
      raise ArgumentError, "Expect report class to repond to build" unless reporter_class.respond_to?(:build)

      @reporter_class = reporter_class
    end

    def reporter_options=(reporter_options)
      raise ArgumentError, "Expect reporter options to be a Hash" unless reporter_options.is_a?(Hash)

      @reporter_options = reporter_options
    end

    def reporter=(reporter)
      reporter_methods = %i[tracked_tests resolved_tests]
      reporter_methods.each do |reporter_method|
        unless reporter.respond_to?(reporter_method)
          raise ArgumentError, "Expect reporter to respond to #{reporter_method}"
        end
      end

      @reporter = reporter
    end

    def reporter
      self.reporter = reporter_class.build(**reporter_options) unless @reporter

      @reporter
    end
  end
end
