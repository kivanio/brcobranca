# -*- encoding: utf-8 -*-

module Brcobranca
  module Boleto
    module Template
      module Base
        extend self

        def define_template(template)

          case template
          when :rghost
            return Brcobranca::Boleto::Template::Rghost
          when :rghost_carne
            return Brcobranca::Boleto::Template::RghostCarne
          else
            return Brcobranca::Boleto::Template::Rghost
          end

        end
      end
    end
  end
end
