# Implementação feita por Nando Vieira do http://simplesideias.com.br
# post http://simplesideias.com.br/usando-number_to_currency-em-modelos-no-rails
module Brcobranca #:nodoc:[all]
  module Currency #:nodoc:[all]
    BRL = {:delimiter => ".", :separator => ",", :unit => "R$", :precision => 2, :position => "before"}
    USD = {:delimiter => ',', :separator => ".", :unit => "US$", :precision => 2, :position => "before"}
    DEFAULT = BRL.merge(:unit => "")

    module String #:nodoc:[all]
      def to_number(options={})
        return self.gsub(/,/, '.').to_f if self.numeric?
        nil
      end

      def numeric?
        self =~ /^(\+|-)?[0-9]+((\.|,)[0-9]+)?$/ ? true : false
      end
    end

    module Number #:nodoc:[all]
      def to_currency(options = {})
        number = self
        default   = Brcobranca::Currency::DEFAULT.stringify_keys
        options   = default.merge(options.stringify_keys)
        precision = options["precision"] || default["precision"]
        unit      = options["unit"] || default["unit"]
        position  = options["position"] || default["position"]
        separator = precision > 0 ? options["separator"] || default["separator"] : ""
        delimiter = options["delimiter"] || default["delimiter"]

        begin
          parts = number.with_precision(precision).split('.')
          number = parts[0].to_i.with_delimiter(delimiter) + separator + parts[1].to_s
          position == "before" ? unit + number : number + unit
        rescue
          number
        end
      end

      def with_delimiter(delimiter=",", separator=".")
        number = self
        begin
          parts = number.to_s.split(separator)
          parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
          parts.join separator
        rescue
          self
        end
      end

      def with_precision(precision=3)
        number = self
        "%01.#{precision}f" % number
      end
    end
  end
end

class Fixnum #:nodoc:[all]
  include Brcobranca::Currency::Number
end
class Bignum #:nodoc:[all]
  include Brcobranca::Currency::Number
end
class Float #:nodoc:[all]
  include Brcobranca::Currency::Number
end
class String #:nodoc:[all]
  include Brcobranca::Currency::String
end