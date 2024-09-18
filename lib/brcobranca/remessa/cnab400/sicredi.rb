# frozen_string_literal: true

module Brcobranca
  module Remessa
    module Cnab400
      class Sicredi < Brcobranca::Remessa::Cnab400::Base
        # Código de Transmissão ou código do beneficiário
        # Consulte o manual para obter esse código
        attr_accessor :codigo_beneficiario

        # Código da carteira
        attr_accessor :codigo_carteira

        validates_presence_of :documento_cedente, :codigo_beneficiario, message: 'não pode estar em branco.'
        validates_presence_of :digito_conta, message: 'não pode estar em branco.', if: :conta_padrao_novo?
        validates_length_of :documento_cedente, minimum: 11, maximum: 14, message: 'deve ter entre 11 e 14 dígitos.'
        validates_length_of :codigo_carteira, maximum: 2, message: 'deve ter no máximo 2 dígitos.'
        validates_length_of :codigo_beneficiario, maximum: 20, message: 'deve ter no máximo 20 dígitos.'

        def initialize(campos = {})
          campos = { aceite: 'N', carteira: '1', codigo_carteira: '01' }.merge!(campos)
          super(campos)
        end

        def cod_banco
          '748'
        end

        def nome_banco
          'SICREDI'.format_size(15)
        end

        def codigo_beneficiario=(valor)
          @codigo_beneficiario = valor.to_s.strip.rjust(20, '0') if valor
        end

        # Informações do Código do Beneficiário
        #
        # @return [String]
        #
        def info_conta
          # CAMPO                     TAMANHO
          # codigo_beneficiario       20
          codigo_beneficiario
        end

        # Zeros do header
        #
        # @return [String]
        #
        def zeros
          ''.ljust(16, '0')
        end

        # Complemento do header
        #
        # @return [String]
        #
        def complemento
          ''.ljust(275, ' ')
        end

        # Numero da versão da remessa
        #
        # @return [String]
        #
        def versao
          '082'
        end

        def monta_header
          # CAMPO                 TAMANHO    VALOR
          # tipo do registro      [1]        0
          # operacao              [1]        1
          # literal remessa       [7]        REMESSA
          # Código do serviço     [2]        01
          # cod. servico          [15]       COBRANCA
          # info. conta           [20]
          # empresa mae           [30]
          # cod. banco            [3]
          # nome banco            [15]
          # data geracao          [6]        formato DDMMAA
          # zeros                 [16]
          # complemento registro  [275]
          # versao                [3]
          # num. sequencial       [6]        000001
          "01REMESSA01COBRANCA       #{info_conta}#{empresa_mae[0..29].to_s.ljust(30,
                                                                                  ' ')}#{cod_banco}#{nome_banco}#{data_geracao}#{zeros}#{complemento}#{versao}000001"
        end

        # Detalhe do arquivo
        #
        # @param pagamento [PagamentoCnab400]
        #   objeto contendo as informações referentes ao boleto (valor, vencimento, cliente)
        # @param sequencial
        #   número sequencial do registro no arquivo
        #
        # @return [String]
        #
        def monta_detalhe(pagamento, sequencial)
          raise Brcobranca::RemessaInvalida, pagamento if pagamento.invalid?

          detalhe = '1'                                                     # identificação transação               9[01]
          detalhe += Brcobranca::Util::Empresa.new(documento_cedente).tipo  # tipo de identificação da empresa      9[02]
          detalhe << documento_cedente.to_s.rjust(14, '0')                  # cpf/cnpj da empresa                   9[14]
          detalhe << codigo_beneficiario                                     # Código do Beneficiário                9[20]
          detalhe << pagamento.documento_ou_numero.to_s.ljust(25, ' ')       # identificação do título na empresa    X[25]
          detalhe << pagamento.nosso_numero.to_s.rjust(8, '0')              # nosso número                          9[8]
          detalhe << pagamento.formata_data_segundo_desconto                # data limite para o segundo desconto   9[06]
          detalhe << ''.rjust(1, ' ')                                       # brancos                               X[1]
          detalhe << pagamento.codigo_multa                                 # Com multa = 2, Sem multa = 0          9[1]
          detalhe << pagamento.formata_percentual_multa                     # Percentual multa por atraso %         9[6]
          detalhe << '00'                                                   # Unidade de valor moeda corrente = 00  9[2]
          detalhe << '0'.rjust(13, '0')                                     # Valor do título em outra unidade      9[15]
          detalhe << ''.rjust(4, ' ')                                       # brancos                               X[4]
          detalhe << pagamento.formata_data_multa                           # Data para cobrança de multa           9[6]
          detalhe << codigo_carteira                                        # código da carteira                    9[2]
          detalhe << pagamento.identificacao_ocorrencia                     # código da ocorrência                  9[02]
          detalhe << pagamento.numero.to_s.rjust(10, '0')                   # número do documento                   X[10]
          detalhe << pagamento.data_vencimento.strftime('%d%m%y')           # data do vencimento                    9[06]
          detalhe << pagamento.formata_valor                                # valor do documento                    9[13]
          detalhe << cod_banco                                              # código banco                          9[03]
          detalhe << ''.rjust(5, '0')                                       # agência cobradora - deixar zero       9[05]
          detalhe << pagamento.especie_titulo                               # Espécie de documento                  9[02]
          detalhe << aceite                                                 # aceite (A/N)                          X[01]
          detalhe << pagamento.data_emissao.strftime('%d%m%y')              # data de emissão                       9[06]
          detalhe << pagamento.cod_primeira_instrucao                       # primeira instrução                    9[02]
          detalhe << pagamento.cod_segunda_instrucao                        # segunda instrução                     9[02]
          detalhe << pagamento.formata_valor_mora                           # valor mora ao dia                     9[13]
          detalhe << pagamento.formata_data_desconto                        # data limite para desconto             9[06]
          detalhe << pagamento.formata_valor_desconto                       # valor do desconto                     9[13]
          detalhe << pagamento.formata_valor_iof                            # valor do iof                          9[13]
          detalhe << pagamento.formata_valor_abatimento                     # valor do abatimento                   9[13]
          detalhe << pagamento.identificacao_sacado                         # identificação do pagador              9[02]
          detalhe << pagamento.documento_sacado.to_s.rjust(14, '0')         # documento do pagador                  9[14]
          detalhe << pagamento.nome_sacado.format_size(40)                  # nome do pagador                       X[40]
          detalhe << pagamento.endereco_sacado.format_size(40)              # endereço do pagador                   X[40]
          detalhe << pagamento.bairro_sacado.format_size(12)                # bairro do pagador                     X[12]
          detalhe << pagamento.cep_sacado                                   # cep do pagador                        9[08]
          detalhe << pagamento.cidade_sacado.format_size(15)                # cidade do pagador                     X[15]
          detalhe << pagamento.uf_sacado                                    # uf do pagador                         X[02]
          detalhe << pagamento.nome_avalista.format_size(30)                # Sacador/Mensagens                     X[30]
          detalhe << ''.rjust(1, ' ')                                       # Brancos                               X[1]
          detalhe << ''.rjust(2, ' ')                                       # Complemento                           9[2]
          detalhe << ''.rjust(6, ' ')                                       # Brancos                               X[06]
          detalhe << pagamento.dias_protesto.rjust(2, '0')                  # Número de dias para protesto          9[02]
          detalhe << ''.rjust(1, ' ')                                       # Brancos                               X[1]
          detalhe << sequencial.to_s.rjust(6, '0')                          # número do registro no arquivo         9[06]
          detalhe
        end

        # Trailer do arquivo remessa
        #
        # @param sequencial
        #   número sequencial do registro no arquivo
        #
        # @return [String]
        #
        def monta_trailer(sequencial)
          # tipo do registro -> 9
          # complemento do trailer -> ' '
          # número sequencial do registro no arquivo
          "9#{''.ljust(393, ' ')}#{sequencial.to_s.rjust(6, '0')}"
        end
      end
    end
  end
end
