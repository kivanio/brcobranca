# -*- encoding: utf-8 -*-
module Brcobranca
  module Remessa
    module Cnab240
      class SicoobBancoBrasil < Brcobranca::Remessa::Cnab240::BaseCorrespondente
        attr_accessor :codigo_cobranca

        validates_length_of :agencia, is: 4, message: 'deve ter 4 dígitos.'
        validates_length_of :convenio, maximum: 10, message: 'deve ter 10 dígitos.'
        validates_length_of :conta_corrente, maximum: 10, message: 'deve ter 10 dígitos.'
        validates_length_of :codigo_cobranca, maximum: 7, message: 'deve ter 7 dígitos.'
        validates_length_of :sequencial_remessa, maximum: 8, message: 'deve ter 8 dígitos.'
        validates_presence_of :sequencial_remessa, message: 'não pode estar em branco.'

        def initialize(campos = {})
          campos = {
            emissao_boleto: '2',
            distribuicao_boleto: '2',
            codigo_carteira: '9',
            tipo_documento: '02'
          }.merge!(campos)
          super(campos)
        end

        def cod_banco
          '756'
        end

        def digito_conta
          conta_corrente.modulo11(mapeamento: { 10 => 'X' }).to_s
        end

        def info_conta
          # CAMPO                  TAMANHO
          # agencia                4
          # codigo cobranca        7
          # conta corrente         11
          "#{agencia.rjust(4, '0')}#{codigo_cobranca.rjust(7, '0')}#{conta_corrente.rjust(10, '0')}#{digito_conta}"
        end

        def complemento_header
          "#{''.rjust(11, '0')}#{''.rjust(33, ' ')}"
        end

        def complemento_p(pagamento)
          # CAMPO                   TAMANHO
          # num. doc. de corbanca   15
          "#{pagamento.nosso_numero.to_s.rjust(15, '0')}"
        end

        def codigo_convenio
          # CAMPO                TAMANHO
          # num. convenio        20 BRANCOS
          ''.rjust(20, ' ')
        end

        alias_method :convenio_lote, :codigo_convenio

        def totaliza_valor_titulos
          pagamentos.inject(0) { |sum, pag| sum += pag.valor.to_f }
        end

        def valor_titulos_carteira
          total = sprintf "%.2f", totaliza_valor_titulos
          total.somente_numeros.rjust(17, "0")
        end

        def complemento_trailer
          ''.rjust(217, ' ')
        end

        # Monta o registro trailer do arquivo
        #
        # @param nro_lotes [Integer]
        #   numero de lotes no arquivo
        # @param sequencial [Integer]
        #   numero de registros(linhas) no arquivo
        #
        # @return [String]
        #
        def monta_trailer_arquivo(nro_lotes, sequencial)
          # CAMPO                     TAMANHO
          # zeros                     7
          # registro trailer lote     1
          # uso FEBRABAN              9
          # nro de lotes              6
          # nro de registros(linhas)  6
          # uso FEBRABAN              211
          "#{''.rjust(7, '0')}5#{''.rjust(9, ' ')}#{nro_lotes.to_s.rjust(6, '0')}#{valor_titulos_carteira}#{''.rjust(6, '0')}#{''.rjust(194, ' ')}"
        end
      end
    end
  end
end
