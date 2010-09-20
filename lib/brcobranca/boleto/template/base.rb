module Brcobranca
  module Boleto
    module Template
      module Base
        extend self

        def define_template(template)
          (template == :rghost) ? Brcobranca::Boleto::Template::Rghost : Brcobranca::Boleto::Template::Rghost
        end
      end
    end
  end
end