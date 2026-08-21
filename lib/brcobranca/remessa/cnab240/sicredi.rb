# frozen_string_literal: true

module Brcobranca
  module Remessa
    module Cnab240
      class Sicredi < Brcobranca::Remessa::Cnab240::Base
        attr_accessor :modalidade_carteira, :parcela, :byte_idt, :posto

        #       Parcela - 02 posições (11 a 12) - "01" se parcela única

        validates_presence_of :byte_idt, :modalidade_carteira, :parcela, :posto, :digito_conta,
                              message: 'não pode estar em branco.'

        # Remessa 240 - 12 digitos
        validates_length_of :conta_corrente, maximum: 5, message: 'deve ter 5 dígitos.'
        validates_length_of :agencia, is: 4, message: 'deve ter 4 dígitos.'
        validates_length_of :modalidade_carteira, is: 2, message: 'deve ter 2 dígitos.'
        validates_length_of :digito_conta, is: 1, message: 'deve ter 1 dígito.'
        validates_length_of :posto, maximum: 2, message: 'deve ter 2 dígitos.'
        validates_length_of :byte_idt, is: 1,
                                       message: 'deve ser 1 se o numero foi gerado pela agencia ou 2-9 se foi gerado pelo beneficiário'

        def initialize(campos = {})
          campos = { emissao_boleto: '2',
                     distribuicao_boleto: '2',
                     especie_titulo: '03',
                     parcela: '01',
                     modalidade_carteira: '01',
                     forma_cadastramento: '1',
                     tipo_documento: '1' }.merge!(campos)
          super(campos)
        end

        def cod_banco
          '748'
        end

        def nome_banco
          'SICREDI'.ljust(30, ' ')
        end

        def versao_layout_arquivo
          '081'
        end

        def versao_layout_lote
          '040'
        end

        def densidade_gravacao
          '01600'
        end

        def digito_agencia
          ' '
        end

        def dv_agencia_cobradora
          ' '
        end

        def uso_exclusivo_banco
          ''.rjust(20, ' ')
        end

        def uso_exclusivo_empresa
          ''.rjust(20, ' ')
        end

        def codigo_convenio
          # CAMPO                TAMANHO
          # num. convenio        20 BRANCOS
          ''.rjust(20, ' ')
        end

        alias convenio_lote codigo_convenio

        def info_conta
          # CAMPO                  TAMANHO
          # agencia                5
          # digito agencia         1
          # conta corrente         12
          # digito conta           1
          # digito agencia/conta   1
          "#{agencia.rjust(5, '0')}#{digito_agencia}#{conta_corrente.rjust(12, '0')}#{digito_conta} "
        end

        def complemento_header
          ''.rjust(29, ' ')
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
          total_cobranca_simples    = ''.rjust(23, '0')
          total_cobranca_vinculada  = ''.rjust(23, '0')
          total_cobranca_caucionada = ''.rjust(23, '0')
          total_cobranca_descontada = ''.rjust(23, '0')

          "#{total_cobranca_simples}#{total_cobranca_vinculada}#{total_cobranca_caucionada}" \
          "#{total_cobranca_descontada}".ljust(217, ' ')
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
          # codigo banco              3
          # lote de servico           4
          # tipo de registro          1
          # uso FEBRABAN              9
          # nro de lotes              6
          # nro de registros(linhas)  6
          # uso FEBRABAN              211
          "#{cod_banco}99999#{''.rjust(9,
                                       ' ')}#{nro_lotes.to_s.rjust(6,
                                                                   '0')}#{sequencial.to_s.rjust(6,
                                                                                                '0')}#{''.rjust(6,
                                                                                                                '0')}#{''.rjust(
                                                                                                                  205, ' '
                                                                                                                )}"
        end

        def complemento_p(pagamento)
          # CAMPO                   TAMANHO
          # conta corrente          12
          # digito conta            1
          # digito agencia/conta    1
          # ident. titulo no banco  20
          "#{conta_corrente.rjust(12, '0')}#{digito_conta} #{formata_nosso_numero(pagamento.nosso_numero)}"
        end

        # Retorna o nosso numero
        #
        # @return [String]
        def formata_nosso_numero(nosso_numero)
          nosso_numero.somente_numeros.ljust(20, ' ')
        end

        # Campo 30.3P - Codigo do desconto 1.
        # Manual Sicredi: '0' - Sem desconto | '1' - Valor fixo ate a data
        # informada | '2' - Percentual ate a data informada.
        # Para o codigo '0' o valor e a data do desconto devem ser zerados.
        # Deve respeitar o valor informado pelo beneficiario.
        def codigo_desconto(pagamento)
          if pagamento.cod_desconto == '0'
            pagamento.data_desconto = nil
            pagamento.valor_desconto = 0.0
          end
          pagamento.cod_desconto
        end

        def codigo_baixa(_pagamento)
          '1'
        end

        # Campo 39.3P - No de dias para baixa/devolucao.
        # Manual Sicredi: o Sicredi nao utiliza esse campo, preencher com zeros.
        def dias_baixa(_pagamento)
          '000'
        end

        # Campo 19.3P - Seu Numero (posicoes 63-77).
        # Manual Sicredi: "Embora no layout constem 15 posicoes, o Sicredi
        # apenas validara as 10 primeiras (campos 63-72), ou seja, da esquerda
        # para a direita. Nao pode conter espaco."
        # O numero deve entao ser alinhado a esquerda e o restante preenchido
        # com zeros (o campo nao pode conter espaco).
        def numero(pagamento)
          pagamento.documento_ou_numero.to_s.gsub(/[^0-9A-Za-z]/, '').ljust(15, '0')[0...15]
        end

        # Campos 17.3Q, 18.3Q e 19.3Q - Beneficiario Final.
        # Manual Sicredi: nao havendo Beneficiario Final o tipo deve ser "0"
        # e o campo CPF/CNPJ (posicoes 155-169) deve ficar em branco.
        # O BRCobranca preenche o CPF/CNPJ com zeros quando nao informado.
        def monta_segmento_q(pagamento, nro_lote, sequencial)
          segmento_q = super
          return segmento_q unless pagamento.documento_avalista.to_s.strip.empty?

          segmento_q[153, 16] = "0#{''.rjust(15, ' ')}"
          segmento_q
        end

        def data_mora(pagamento)
          return ''.rjust(8, '0') unless %w[1 2].include? pagamento.tipo_mora

          pagamento.data_vencimento.next_day.strftime('%d%m%Y')
        end

        private

        def mapeamento_para_modulo_11
          {
            10 => 0,
            11 => 0
          }
        end
      end
    end
  end
end
