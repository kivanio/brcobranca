module Brcobranca
  module Util
    class Errors

      include Enumerable

      CALLBACKS_OPTIONS = [:if, :unless, :on, :allow_nil, :allow_blank, :strict]
      MESSAGE_OPTIONS = [:message]

      attr_reader :messages, :details

      def initialize(base)
        @base     = base
        @messages = apply_default_array({})
        @details = apply_default_array({})
      end

      def add(attribute, message = :invalid, options = {})
        message = message.call if message.respond_to?(:call)
        detail  = normalize_detail(message, options)
        message = normalize_message(attribute, message, options)
        details[attribute.to_sym]  << detail
        messages[attribute.to_sym] << message
      end

      def size
        @messages.values.flatten.size
      end
      alias :count :size

      def generate_message(attribute, type = :invalid, options = {})
        :"errors.attributes.#{attribute}.#{type}"
      end

      def full_messages
        @messages.values.flatten
      end
      alias :to_a :full_messages

      private

        def apply_default_array(hash)
          hash.default_proc = proc { |h, key| h[key] = [] }
          hash
        end

        def normalize_message(attribute, message, options)
          case message
          when Symbol
            generate_message(attribute, message, except(options, *CALLBACKS_OPTIONS))
          else
            if message.start_with?(variable_name(attribute))
              message
            else
              "#{variable_name(attribute)} #{message}"
            end
          end
        end

        def normalize_detail(message, options)
          { error: message }.merge(except(options, *CALLBACKS_OPTIONS + MESSAGE_OPTIONS))
        end

        def except(hash, *keys)
          dup = hash.dup
          keys.each { |key| dup.delete(key) }
          dup
        end

        def variable_name(symbol)
          symbol.to_s.tr("_", " ").capitalize
        end

    end
  end
end
