# -*- encoding: utf-8 -*-
module Brcobranca
  module Remessa
    module Cnab240
      class Cecred < Brcobranca::Remessa::Cnab240::Base
        # digito da agencia
        attr_accessor :digito_agencia

        validates_presence_of :digito_agencia, :convenio, :conta_corrente, message: 'não pode estar em branco.'
        validates_length_of :convenio, maximum: 6, message: 'deve ter 6 dígitos.'
        validates_length_of :conta_corrente, maximum: 7, message: 'deve ter 7 dígitos.'
        validates_length_of :digito_agencia, is: 1, message: 'deve ter 1 dígito.'

        def initialize(campos = {})
          campos = { emissao_boleto: '2',
                     forma_cadastramento: '0',
                     distribuicao_boleto: '2',
                     especie_titulo: '02' }.merge!(campos)
          super(campos)
        end

        def convenio=(valor)
          @convenio = valor.to_s.rjust(6, '0') if valor
        end

        def conta_corrente=(valor)
          @conta_corrente = valor.to_s.rjust(7, '0') if valor
        end

        def cod_banco
          '085'
        end

        def nome_banco
          'CECRED'.ljust(30, ' ')
        end

        def versao_layout_arquivo
          '087'
        end

        def versao_layout_lote
          '045'
        end

        def codigo_convenio
          convenio.ljust(20, ' ')
        end

        def uso_exclusivo_banco
          ''.rjust(20, ' ')
        end

        def uso_exclusivo_empresa
          ''.ljust(20, ' ')
        end

        def convenio_lote
          codigo_convenio
        end

        def info_conta
          # CAMPO            # TAMANHO
          # agencia          5
          # digito agencia   1
          # conta corrente   12
          # dv da conta      1
          # dv agencia/conta 1
          "#{agencia_conta_corrente}#{agencia_conta_corrente_dv}"
        end

        def agencia_conta_corrente
          "#{agencia.to_s.rjust(5, '0')}#{digito_agencia}#{conta_corrente.rjust(12, '0')}#{conta_corrente_dv}"
        end

        def conta_corrente_dv
          conta_corrente.modulo11(mapeamento: { 10 => 0 })
        end

        def agencia_conta_corrente_dv
          " "
        end

        def complemento_header
          "#{''.rjust(29, ' ')}"
        end

        def complemento_trailer
          "#{''.rjust(69, '0')}#{''.rjust(148, ' ')}"
        end

        def tipo_documento
          "1"
        end

        def complemento_p(pagamento)
          # CAMPO                 TAMANHO
          # conta_corrente        12
          # dv conta corrente     1
          # dv agencia/conta      1
          # ident. titulo         20
          "#{conta_corrente.rjust(12, '0')}#{conta_corrente_dv}#{agencia_conta_corrente_dv}#{ajusta_nosso_numero(pagamento)}"
        end

        def ajusta_nosso_numero(pagamento)
          "#{conta_corrente}#{conta_corrente_dv}#{pagamento.nosso_numero.to_s.rjust(9, '0')}".ljust(20, ' ')
        end

        def identificacao_titulo_empresa(pagamento)
          pagamento.documento_ou_numero.to_s.ljust(25, " ")
        end

        def complemento_trailer
          # CAMPO                               TAMANHO
          # Qt. Títulos em Cobrança Simples     6
          # Vl. Títulos em Carteira Simples     15 + 2 decimais
          # Qt. Títulos em Cobrança Vinculada   6
          # Vl. Títulos em Carteira Vinculada   15 + 2 decimais
          # Qt. Títulos em Cobrança Caucionada  6
          # Vl. Títulos em Carteira Caucionada  15 + 2 decimais
          # Qt. Títulos em Cobrança Descontada  6
          # Vl. Títulos em Carteira Descontada  15 + 2 decimais
          total_cobranca_simples    = "#{quantidade_titulos_cobranca}#{valor_titulos_carteira}"
          total_cobranca_vinculada  = "".rjust(23, "0")
          total_cobranca_caucionada = "".rjust(23, "0")
          total_cobranca_descontada = "".rjust(23, "0")

          "#{total_cobranca_simples}#{total_cobranca_vinculada}#{total_cobranca_caucionada}"\
            "#{total_cobranca_descontada}".ljust(217, ' ')
        end

        def total_segmentos(pagamentos)
          pagamentos.inject(0) { |total, pagamento| total += pagamento.codigo_multa != '0' ? 3 : 2 }
        end

        def monta_segmento_r(pagamento, nro_lote, contador)
          return nil if pagamento.codigo_multa == '0'
          super(pagamento, nro_lote, contador)
        end

        def codigo_baixa(pagamento)
          '2'
        end

        def dias_baixa(pagamento)
          ''.rjust(3, ' ')
        end
      end
    end
  end
end
