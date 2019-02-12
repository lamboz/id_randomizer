module IdRandomizer
  module ActsAsIdRandomizer
    DEFAULT_OPTIONS = {
      column: :randomized_id
    }.freeze
    SequencedColumnExists = Class.new(StandardError)

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Public: Defines ActiveRecord callbacks to set a sequential ID scoped
      # on a specific class.
      #
      # Can be called multiple times to add hooks for different column names.
      #
      # options - The Hash of options for configuration:
      #           :scope    - The Symbol representing the columm on which the
      #                       sequential ID should be scoped (default: nil)
      #           :column   - The Symbol representing the column that stores the
      #                       sequential ID (default: :sequential_id)
      #
      # Examples
      #
      #   class Answer < ActiveRecord::Base
      #     belongs_to :question
      #     randomize_id column: :randomized_id
      #   end
      #
      # Returns nothing.
      def randomize_id(options = {})
        unless defined?(sequenced_options)
          include IdRandomizer::ActsAsRandomId::InstanceMethods

          mattr_accessor :sequenced_options, instance_accessor: false
          self.sequenced_options = []

          before_save :set_sequential_ids
        end

        options = DEFAULT_OPTIONS.merge(options)
        column_name = options[:column]

        if sequenced_options.any? {|options| options[:column] == column_name}
          raise(SequencedColumnExists, <<-MSG.squish)
            Tried to set #{column_name} as sequenced but there was already a
            definition here. Did you accidentally call acts_as_sequenced
            multiple times on the same column?
          MSG
        else
          sequenced_options << options
        end
      end
    end

    module InstanceMethods
      def set_sequential_ids
        self.class.base_class.sequenced_options.each do |options|
          IdRandomizer::Generator.new(self, options).set
        end
      end
    end
  end
end
