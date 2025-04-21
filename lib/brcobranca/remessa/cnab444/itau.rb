# frozen_string_literal: true

module Brcobranca
  module Remessa
    module Cnab444
      class Itau < Brcobranca::Remessa::Cnab400::Itau

        # Detalhe do arquivo
        #
        # @param pagamento [PagamentoCnab444]
        #   objeto contendo as informacoes referentes ao boleto (valor, vencimento, cliente)
        # @param sequencial
        #   num. sequencial do registro no arquivo
        #
        # @return [String]
        #
        def monta_detalhe(pagamento, sequencial)
          detalhe = super(pagamento, sequencial)
  
          detalhe + pagamento.chave_nfe.to_s.ljust(44, ' ')                 # chave da nota fiscal (NFe)            X[44]
        end
      end
    end
  end
end
