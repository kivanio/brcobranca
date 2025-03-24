# frozen_string_literal: true

module Brcobranca
  module Remessa
    module Cnab400
      class SantanderPix < Brcobranca::Remessa::Cnab400::Santander
        # @see Brcobranca::Remessa::PagamentoPix::TIPOS_CHAVE_DICT
        TIPOS_CHAVE_DICT = {
          cpf: '1',
          cnpj: '2',
          telefone: '3',
          email: '4',
          chave_aleatoria: '5'
        }.freeze

        # Monta Registro Tipo de Pagamento e Dados Qr Code
        #
        # @param pagamento [PagamentoPix]
        #   objeto contendo as informacoes referentes ao pagamento via PIX
        # @param sequencial
        #   num. sequencial do registro no arquivo
        #
        # @return [String]
        def monta_detalhe_pix(pagamento, sequencial)
          raise Brcobranca::RemessaInvalida, pagamento if pagamento.invalid?

          detalhe = '8'                                                        # Codigo do Registro                  9[001]
          detalhe += tipo_pagamento_pix(pagamento.tipo_pagamento_pix)          # Tipo de Pagamento                   9[002]
          detalhe << pagamento.quantidade_pagamentos_pix.to_s.rjust(2, '0')    # Quantidade de Pagamentos possiveis  9[002]
          detalhe << pagamento.tipo_valor_pix.to_s.rjust(1, '0')               # Tipo do Valor Informado             9[001]
          detalhe << pagamento.formata_valor_maximo_pix                        # Valor Maximo                        9[013]
          detalhe << pagamento.formata_percentual_maximo_pix                   # Percentual Maximo                   9[005]
          detalhe << pagamento.formata_valor_minimo_pix                        # Valor Minimo                        9[013]
          detalhe << pagamento.formata_percentual_minimo_pix                   # Percentual Minimo                   9[005]
          detalhe << tipo_chave_dict(pagamento.tipo_chave_dict)                # Tipo de Chave DICT                  X[001]
          detalhe << pagamento.codigo_chave_dict.ljust(77, ' ')                # Codigo Chave DICT                   X[077]
          detalhe << pagamento.txid.to_s.ljust(35, ' ')                        # Codigo de Identificacao do Qr Code  X[035]
          detalhe << ''.rjust(239, ' ')                                        # Reservado (uso banco)               X[239]
          detalhe << sequencial.to_s.rjust(6, '0')                             # numero do registro no arquivo       9[006]
          detalhe
        end

        private

        # Identificacao do tipo de pagamento
        # 00 - Conforme Perfil do Beneficiario
        # 01 - Aceita qualquer valor
        # 02 - Entre o minimo e o maximo
        # 03 - Nao aceita pagamento com o valor divergente
        def tipo_pagamento_pix(tipo_pagamento_pix)
          tipo_pagamento_pix.to_i.to_s.rjust(2, '0')
        end

        def tipo_chave_dict(tipo_chave_dict)
          TIPOS_CHAVE_DICT[tipo_chave_dict.to_sym]
        end
      end
    end
  end
end
