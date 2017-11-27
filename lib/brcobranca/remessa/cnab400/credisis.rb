# -*- encoding: utf-8 -*-
module Brcobranca
  module Remessa
    module Cnab400
      class Credisis < Brcobranca::Remessa::Cnab400::Base
        attr_accessor :codigo_cedente, :documento_cedente, :convenio

        validates_presence_of :agencia, :conta_corrente, :codigo_cedente, :digito_conta, message: 'não pode estar em branco.'
        validates_length_of :agencia, maximum: 4, message: 'deve ter 4 dígitos.'
        validates_length_of :codigo_cedente, maximum: 4, message: 'deve ter 4 dígitos.'
        validates_length_of :conta_corrente, maximum: 8, message: 'deve ter 8 dígitos.'
        validates_length_of :carteira, maximum: 2, message: 'deve ter 2 dígitos.'
        validates_length_of :digito_conta, maximum: 1, message: 'deve ter 1 dígito.'
        validates_length_of :sequencial_remessa, :convenio, maximum: 7, message: 'deve ter 7 dígitos.'

        # Nova instancia do CrediSIS
        def initialize(campos = {})
          campos = { aceite: 'N' }.merge!(campos)
          super(campos)
        end

        def agencia=(valor)
          @agencia = valor.to_s.rjust(4, '0') if valor
        end

        def conta_corrente=(valor)
          @conta_corrente = valor.to_s.rjust(8, '0') if valor
        end

        def carteira=(valor)
          @carteira = valor.to_s.rjust(2, '0') if valor
        end

        def sequencial_remessa=(valor)
          @sequencial_remessa = valor.to_s.rjust(7, '0') if valor
        end

        def codigo_cedente=(valor)
          @codigo_cedente = valor.to_s.rjust(4, '0') if valor
        end

        def cod_banco
          '097'
        end

        def nome_banco
          'CENTRALCRED'.ljust(15, ' ')
        end

        # Informacoes da conta corrente do cedente
        #
        # @return [String]
        #
        def info_conta
          # CAMPO            TAMANHO
          # agencia          4
          # complemento      1
          # conta corrente   8
          # digito da conta  1
          # complemento      6
          "#{agencia} #{conta_corrente}#{digito_conta}#{''.rjust(6, ' ')}"
        end

        # Complemento do header
        #
        # @return [String]
        #
        def complemento
          sequencial_remessa.to_s.ljust(294, ' ')
        end

        def formata_nosso_numero(nosso_numero)
          "0#{codigo_cedente}#{nosso_numero.rjust(6, '0')}"
        end

        # Detalhe do arquivo
        #
        # @param pagamento [PagamentoCnab400]
        #   objeto contendo as informacoes referentes ao boleto (valor, vencimento, cliente)
        # @param sequencial
        #   num. sequencial do registro no arquivo
        #
        # @return [String]
        #
        def monta_detalhe(pagamento, sequencial)
          raise Brcobranca::RemessaInvalida, pagamento if pagamento.invalid?

          detalhe = '1'                                                     # identificacao transacao               9[01]
          detalhe << Brcobranca::Util::Empresa.new(documento_cedente).tipo  # tipo de identificacao da empresa      9[02]
          detalhe << documento_cedente.to_s.rjust(14, '0')                  # cpf/cnpj da empresa                   9[14]
          detalhe << agencia                                                # agencia                               9[04]
          detalhe << ''.rjust(1, ' ')                                       # brancos                               X[01]
          detalhe << conta_corrente                                         # conta corrente                        9[08]
          detalhe << digito_conta                                           # dac                                   9[01]
          detalhe << ''.rjust(6, ' ')                                       # complemento do registro (brancos)     X[06]
          detalhe << pagamento.documento_ou_numero.to_s.ljust(25)                                      # identificacao do tit. na empresa      X[25]
          detalhe << formata_nosso_numero(pagamento.nosso_numero.to_s)      # nosso numero                          9[11]
          detalhe << ''.rjust(37, ' ')                                      # brancos                               X[37]
          detalhe << pagamento.numero.to_s.rjust(10, '0')         # numero do documento                   X[10]
          detalhe << pagamento.data_vencimento.strftime('%d%m%y')           # data do vencimento                    A[06]
          detalhe << pagamento.formata_valor                                # valor do documento                    9[13]
          detalhe << ''.rjust(11, ' ')                                      # brancos                               X[11]
          detalhe << pagamento.data_emissao.strftime('%d%m%y')              # data de emissao                       9[06]
          detalhe << ''.rjust(4, ' ')                                       # brancos                               X[04]
          detalhe << pagamento.formata_valor_mora(4).ljust(6, '0')          # valor mora ao dia                     9[06]
          detalhe << pagamento.formata_percentual_multa.ljust(6, '0')       # valor multa                           9[06]
          detalhe << ''.rjust(33, ' ')                                      # brancos                               X[33]
          detalhe << pagamento.formata_valor_desconto                       # valor do desconto                     9[13]
          detalhe << pagamento.identificacao_sacado                         # identificacao do pagador              9[02]
          detalhe << pagamento.documento_sacado.to_s.rjust(14, '0')         # documento do pagador                  9[14]
          detalhe << pagamento.nome_sacado.format_size(40)                  # nome do pagador                       A[40]
          detalhe << pagamento.endereco_sacado.format_size(37)              # endereco do pagador                   A[37]
          detalhe << pagamento.bairro_sacado.format_size(15)                # bairro do pagador                     X[15]
          detalhe << pagamento.cep_sacado                                   # cep do pagador                        9[08]
          detalhe << pagamento.cidade_sacado.format_size(15)                # cidade do pagador                     A[15]
          detalhe << pagamento.uf_sacado                                    # uf do pagador                         A[02]
          detalhe << pagamento.nome_avalista.format_size(25)                # nome do sacador/avalista              X[25]
          detalhe << ''.rjust(1, ' ')                                       # complemento do registro               X[01]
          detalhe << ''.rjust(14, ' ')                                      # documento avalista                    X[14] *
          detalhe << pagamento.dias_protesto.rjust(2, '0')                  # quantidade de dias do prazo           9[02]
          detalhe << ''.rjust(1, ' ')                                       # complemento do registro (brancos)     X[01]
          detalhe << sequencial.to_s.rjust(6, '0')                          # numero do registro no arquivo         9[06]
          detalhe
        end
      end
    end
  end
end
