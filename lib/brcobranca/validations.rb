# coding: utf-8
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

      attr_reader :presences
      attr_reader :lengths
      attr_reader :numericals
      attr_reader :inclusions
      attr_reader :eachs

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

      def validates_each(*attr_names, &block)
        @eachs ||= {}
        attr_names.each do |attr_name|
          @eachs[attr_name] = block
        end
      end

      def with_options(options, &block)
      end

    end

    def errors
      @errors ||= Brcobranca::Util::Errors.new(self)
    end

    def valid?
      #puts "** #{self.class}"
      #puts "** #{self.class.superclass}"
      all_valid = true
      all_valid = false if !check_eachs
      all_valid = false if !check_presences
      all_valid = false if !check_numericals
      all_valid = false if !check_lengths
      all_valid = false if !check_inclusions
      return all_valid
    end

    def invalid?
      !valid?
    end

    private

      def check_eachs
        eachs = {}
        if self.class.superclass.superclass.respond_to?(:eachs)
          eachs.merge!(self.class.superclass.superclass.eachs || {})
        end
        if self.class.superclass.respond_to?(:eachs)
          eachs.merge!(self.class.superclass.eachs || {})
        end
        if self.class.eachs
          eachs.merge!(self.class.eachs)
        end
        return true if eachs.keys.size == 0
        eachs.each do |attr_name, block|
          value = ''
          begin
          value = self.send(attr_name)
          rescue
          end
          block.call(self, attr_name, value)
        end
        return errors.size == 0
      end

      def check_presences
        presences = []
        if self.class.superclass.superclass.respond_to?(:presences)
          presences = self.class.superclass.superclass.presences || []
        end
        if self.class.superclass.respond_to?(:presences)
          presences += self.class.superclass.presences || []
        end
        if self.class.presences
          presences += self.class.presences
        end
        all_present = true
        presences.each do |presence|
          presence.select { |p| p.is_a? Symbol}.each do |variable|
            if blank?(self.send(variable))
              all_present = false
              errors.add variable, presence[-1][:message]
            end
          end
        end
        return all_present
      end

      def check_numericals
        numericals = []
        if self.class.superclass.respond_to?(:numericals)
          numericals = self.class.superclass.numericals || []
        end
        if self.class.numericals
          numericals += self.class.numericals
        end
        return true if !numericals
        all_numerical = true
        numericals.each do |numerical|
          numerical.select { |p| p.is_a? Symbol}.each do |variable|
            if self.respond_to?(variable) && self.send(variable) && (self.send(variable).to_s =~ /\A[+-]?\d+\z/).nil?
              all_numerical = false
              errors.add variable, numerical[-1][:message]
            end
          end
        end
        return all_numerical
      end

      def check_lengths
        lengths = []
        if self.class.superclass.superclass.respond_to?(:lengths)
          lengths = self.class.superclass.superclass.lengths || []
        end
        if self.class.superclass.respond_to?(:lengths)
          lengths += self.class.superclass.lengths || []
        end
        if self.class.lengths
          lengths += self.class.lengths
        end
        return true if !lengths
        all_checked = true
        lengths.each do |rule|
          variable = rule[0]
          next if !self.respond_to?(variable)
          value = self.send(variable)
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
        return all_checked
      end

      def check_inclusions
        inclusions = []
        if self.class.superclass.superclass.respond_to?(:inclusions)
          inclusions = self.class.superclass.superclass.inclusions || []
        end
        if self.class.superclass.respond_to?(:inclusions)
          inclusions += self.class.superclass.inclusions || []
        end
        if self.class.inclusions
          inclusions += self.class.inclusions
        end
        return true if !inclusions
        all_checked = true
        inclusions.each do |rule|
          variable = rule[0]
          next if !self.respond_to?(variable)
          value = self.send(variable)
          next if !value
          if rule[-1][:in]
            if !rule[-1][:in].include?(value)
              all_checked = false
              errors.add variable, rule[-1][:message]
            end
          end
        end
        return all_checked
      end

      def variable_name(symbol)
        symbol.to_s.tr("_", " ").capitalize
      end

      def blank?(obj)
        return obj !~ /\S/ if obj.is_a? String
        obj.respond_to?(:empty?) ? obj.empty? : !obj
      end
  end
end
