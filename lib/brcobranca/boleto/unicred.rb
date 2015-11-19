module Brcobranca
  module Boleto
    class Unicred < Brcobranca::Boleto::Sicredi

      # Nova instancia do Bradesco
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos = {})
        campos = {
          carteira: '03',
          especie_documento: 'A',
          local_pagamento: "PAGÁVEL PREFERENCIALMENTE NAS AGÊNCIAS DA UNICRED"
        }.merge!(campos)

        super(campos)
      end
    end
  end
end
