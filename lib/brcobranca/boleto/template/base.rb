# -*- encoding: utf-8 -*-
#

module Brcobranca
  module Boleto
    module Template
      module Base
        extend self

        def define_template(template)
          case template
          when :rghost
            [Brcobranca::Boleto::Template::Rghost]
          when :rghost_carne
            [Brcobranca::Boleto::Template::RghostCarne]
          when :both
            [Brcobranca::Boleto::Template::Rghost, Brcobranca::Boleto::Template::RghostCarne]
          else
            [Brcobranca::Boleto::Template::Rghost]
          end
        end
      end
    end
  end
end
