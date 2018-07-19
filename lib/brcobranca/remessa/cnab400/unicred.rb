# -*- encoding: utf-8 -*-
module Brcobranca
  module Remessa
    module Cnab400
      class Unicred < Brcobranca::Remessa::Cnab400::Base
        attr_accessor :posto, :byte_idt

        # Codigo de transmissao fornecido pelo banco
        attr_accessor :codigo_transmissao

        validates_presence_of :agencia, :conta_corrente, :documento_cedente,
                              :digito_conta, :codigo_transmissao, message: 'não pode estar em branco.'

        validates_length_of :agencia, maximum: 4, message: 'deve ter 4 dígitos.'
        validates_length_of :conta_corrente, maximum: 5, message: 'deve ter 5 dígitos.'
        validates_length_of :documento_cedente, minimum: 11, maximum: 14, message: 'deve ter entre 11 e 14 dígitos.'
        validates_length_of :carteira, maximum: 2, message: 'deve ter 2 dígitos.'
        validates_length_of :digito_conta, maximum: 1, message: 'deve ter 1 dígito.'
        validates_length_of :codigo_transmissao, maximum: 20, message: 'deve ter 20 dígitos.'

        validates_inclusion_of :carteira, in: %w(01 03 04 05 06 07), message: 'não existente para este banco.'

        # Nova instancia do Unicred
        def initialize(campos = {})
          campos = {
            aceite: 'N'
          }.merge!(campos)

          super(campos)
        end

        def agencia=(valor)
          @agencia = valor.to_s.rjust(4, '0') if valor
        end

        def conta_corrente=(valor)
          @conta_corrente = valor.to_s.rjust(5, '0') if valor
        end

        def carteira=(valor)
          @carteira = valor.to_s.rjust(2, '0') if valor
        end

        def cod_banco
          '748'
        end

        def nome_banco
          'UNICRED'.ljust(15, ' ')
        end

        # Informacoes da conta corrente do cedente
        #
        # @return [String]
        #
        def info_conta
          # CAMPO                    TAMANHO
          # codigo da transmissao         20
          "#{codigo_transmissao}"
        end

        # Complemento do header
        # (no caso do Unicred, sao apenas espacos em branco)
        #
        # @return [String]
        #
        def complemento
          ''.rjust(294, ' ')
        end

        # Codigo da carteira de acordo com a documentacao do Unicred
        #
        # @return [String]
        #
        def codigo_carteira
          codigo_carteira = carteira[1]
        end

        def identificador_complemento
          " "
        end

        # Retorna o nosso numero
        #
        # @return [String]
        def formata_nosso_numero(nosso_numero)
          nosso_numero.somente_numeros.rjust(20, ' ')
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
          detalhe << codigo_transmissao                                     # código da transmissao                 9[20]
          detalhe << pagamento.documento_ou_numero.to_s.ljust(25)                                      # numero de controle do participante    X[25]
          detalhe << formata_nosso_numero(pagamento.nosso_numero)           # nosso numero                          X[20]
          detalhe << ''.rjust(25, ' ')                                      # brancos                               X[25]
          detalhe << codigo_carteira                                        # codigo da carteira                    X[01]
          detalhe << pagamento.identificacao_ocorrencia                     # identificacao ocorrencia              9[02]
          detalhe << pagamento.numero.to_s.rjust(10, '0')         # numero do documento                   X[10]
          detalhe << pagamento.data_vencimento.strftime('%d%m%y')           # data do vencimento                    9[06]
          detalhe << pagamento.formata_valor                                # valor do documento                    9[13]
          detalhe << cod_banco                                              # codigo banco                          9[03]
          detalhe << ''.rjust(5, '0')                                       # agencia cobradora - deixar zero       9[05]
          detalhe << '01'                                                   # especie  do titulo                    X[02]
          detalhe << aceite                                                 # aceite (A/N)                          X[01]
          detalhe << pagamento.data_emissao.strftime('%d%m%y')              # data de emissao                       9[06]
          detalhe << "".rjust(4, "0")                                       # instrucao                             9[04]
          detalhe << "0"                                                    # zero                                  9[01]
          detalhe << pagamento.formata_valor_mora(12)                       # valor mora ao dia                     9[12]
          detalhe << pagamento.formata_data_desconto                        # data limite para desconto             9[06]
          detalhe << pagamento.formata_valor_desconto                       # valor do desconto                     9[13]
          detalhe << pagamento.formata_valor_iof                            # valor do iof                          9[13]
          detalhe << pagamento.formata_valor_abatimento                     # valor do abatimento                   9[13]
          detalhe << pagamento.identificacao_sacado                         # identificacao do pagador              9[02]
          detalhe << pagamento.documento_sacado.to_s.rjust(14, '0')         # documento do pagador                  9[14]
          detalhe << pagamento.nome_sacado.format_size(40)                  # nome do pagador                       X[40]
          detalhe << pagamento.endereco_sacado.format_size(40)              # endereco do pagador                   X[40]
          detalhe << pagamento.bairro_sacado.format_size(12)                # bairro do pagador                     X[12]
          detalhe << pagamento.cep_sacado                                   # cep do pagador                        9[08]
          detalhe << pagamento.cidade_sacado.format_size(15)                # cidade do pagador                     X[15]
          detalhe << pagamento.uf_sacado                                    # uf do pagador                         X[02]
          detalhe << pagamento.nome_avalista.format_size(40)                # nome do sacador/avalista              X[40]
          detalhe << pagamento.dias_protesto.rjust(2, '0')                  # numero de dias para proteste          9[02]
          detalhe << "9"                                                    # moeda                                 9[01]
          detalhe << sequencial.to_s.rjust(6, '0')                          # numero do registro no arquivo         9[06]
          detalhe
        end
      end
    end
  end
end
