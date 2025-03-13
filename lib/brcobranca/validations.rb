# frozen_string_literal: true

# @author Eduardo Reboucas
require 'brcobranca/util/errors'

module Brcobranca
  # Métodos auxiliares de validação para evitar ActiveSupport e ActiveModel com
  # mínimo de impacto nas definições das validações existentes

  module Validations
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      attr_reader :presences, :lengths, :numericals, :inclusions, :eachs, :with_formats

      def validates_presence_of(*attr_names)
        @presences ||= []
        @presences = @presences << attr_names
      end

      def validates_length_of(*attr_names)
        @lengths ||= []
        @lengths = @lengths << attr_names
      end

      def validates_numericality_of(*attr_names)
        @numericals ||= []
        @numericals = @numericals << attr_names
      end

      def validates_inclusion_of(*attr_names)
        @inclusions ||= []
        @inclusions = @inclusions << attr_names
      end

      def validates_format_of(*attr_names)
        @with_formats ||= []
        @with_formats = @with_formats << attr_names
      end

      def validates_each(*attr_names, &block)
        @eachs ||= {}
        attr_names.each do |attr_name|
          @eachs[attr_name] = block
        end
      end

      def with_options(options, &block); end
    end

    def errors
      @errors ||= Brcobranca::Util::Errors.new(self)
    end

    def valid?
      # puts "** #{self.class}"
      # puts "** #{self.class.superclass}"
      all_valid = true
      all_valid = false unless check_eachs
      all_valid = false unless check_presences
      all_valid = false unless check_numericals
      all_valid = false unless check_lengths
      all_valid = false unless check_inclusions
      all_valid = false unless check_with_formats
      all_valid
    end

    def invalid?
      !valid?
    end

    private

    def check_eachs
      eachs = {}
      eachs.merge!(self.class.superclass.superclass.eachs || {}) if self.class.superclass.superclass.respond_to?(:eachs)
      eachs.merge!(self.class.superclass.eachs || {}) if self.class.superclass.respond_to?(:eachs)
      eachs.merge!(self.class.eachs) if self.class.eachs
      return true if eachs.keys.size.zero?

      eachs.each do |attr_name, block|
        value = ''
        begin
          value = send(attr_name)
        rescue StandardError
        end
        block.call(self, attr_name, value)
      end
      errors.size.zero?
    end

    def check_presences
      presences = []
      if self.class.superclass.superclass.respond_to?(:presences)
        presences = self.class.superclass.superclass.presences || []
      end
      presences += self.class.superclass.presences || [] if self.class.superclass.respond_to?(:presences)
      presences += self.class.presences if self.class.presences
      all_present = true
      presences.each do |presence|
        presence.select { |p| p.is_a? Symbol }.each do |variable|
          next unless valid_condition?(presence[-1])

          if blank?(send(variable))
            all_present = false
            errors.add variable, presence[-1][:message]
          end
        end
      end
      all_present
    end

    def check_numericals
      numericals = []
      numericals = self.class.superclass.numericals || [] if self.class.superclass.respond_to?(:numericals)
      numericals += self.class.numericals if self.class.numericals
      return true unless numericals

      all_numerical = true
      numericals.each do |numerical|
        numerical.select { |p| p.is_a? Symbol }.each do |variable|
          next unless valid_condition?(numerical[-1])

          if respond_to?(variable) && send(variable) && (send(variable).to_s =~ /\A[+-]?\d+\z/).nil?
            all_numerical = false
            errors.add variable, numerical[-1][:message]
          end
        end
      end
      all_numerical
    end

    def check_lengths
      lengths = []
      lengths = self.class.superclass.superclass.lengths || [] if self.class.superclass.superclass.respond_to?(:lengths)
      lengths += self.class.superclass.lengths || [] if self.class.superclass.respond_to?(:lengths)
      lengths += self.class.lengths if self.class.lengths
      return true unless lengths

      all_checked = true
      lengths.each do |rule|
        variable = rule[0]
        next unless respond_to?(variable)
        next unless valid_condition?(rule[-1])

        value = send(variable)
        if rule[-1][:in]
          if !value
            all_checked = false
            errors.add variable, rule[-1][:message]
          elsif value.size < rule[-1][:in].first || value.size > rule[-1][:in].last
            all_checked = false
            errors.add variable, rule[-1][:message]
          end
        end
        if rule[-1][:is]
          if !value
            all_checked = false
            errors.add variable, rule[-1][:message]
          elsif value.to_s.size != rule[-1][:is]
            all_checked = false
            errors.add variable, rule[-1][:message]
          end
        end
        if rule[-1][:minimum] && rule[-1][:maximum]
          if !value || value.size < rule[-1][:minimum] || value.size > rule[-1][:maximum]
            all_checked = false
            errors.add variable, rule[-1][:message]
          end
        elsif rule[-1][:maximum]
          if value && value.size > rule[-1][:maximum]
            all_checked = false
            errors.add variable, rule[-1][:message]
          end
        end
      end
      all_checked
    end

    def check_inclusions
      inclusions = []
      if self.class.superclass.superclass.respond_to?(:inclusions)
        inclusions = self.class.superclass.superclass.inclusions || []
      end
      inclusions += self.class.superclass.inclusions || [] if self.class.superclass.respond_to?(:inclusions)
      inclusions += self.class.inclusions if self.class.inclusions
      return true unless inclusions

      all_checked = true
      inclusions.each do |rule|
        variable = rule[0]
        next unless respond_to?(variable)

        value = send(variable)
        next unless value

        next unless rule[-1][:in]
        next unless valid_condition?(rule[-1])

        unless rule[-1][:in].include?(value)
          all_checked = false
          errors.add variable, rule[-1][:message]
        end
      end
      all_checked
    end

    def check_with_formats
      with_formats = []
      if self.class.superclass.superclass.respond_to?(:with_formats)
        with_formats = self.class.superclass.superclass.with_formats || []
      end
      with_formats += self.class.superclass.with_formats || [] if self.class.superclass.respond_to?(:with_formats)
      with_formats += self.class.with_formats if self.class.with_formats
      return true unless with_formats

      all_checked = true
      with_formats.each do |rule|
        variable = rule[0]
        next unless respond_to?(variable)

        value = send(variable)
        next unless value

        next unless rule[-1][:with]
        next unless valid_condition?(rule[-1])

        unless value&.match?(rule[-1][:with])
          all_checked = false
          errors.add variable, rule[-1][:message]
        end
      end
      all_checked
    end

    def variable_name(symbol)
      symbol.to_s.tr('_', ' ').capitalize
    end

    def blank?(obj)
      return obj !~ /\S/ if obj.is_a? String

      obj.respond_to?(:empty?) ? obj.empty? : !obj
    end

    def valid_condition?(rule)
      return true unless rule[:if]

      if rule[:if].is_a?(Symbol)
        send(rule[:if])
      elsif rule[:if].is_a?(Proc)
        rule[:if].call(self)
      else
        raise ArgumentError, 'Condition must be a symbol or a proc'
      end
    end
  end
end
