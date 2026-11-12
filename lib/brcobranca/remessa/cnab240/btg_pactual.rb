# frozen_string_literal: true

module Brcobranca
  module Remessa
    module Cnab240
      # Remessa CNAB 240 do BTG Pactual (208).
      #
      # O BTG segue o layout FEBRABAN 240 v10.9 sem particularidades de posição
      # (docs/BtgPactual). Suporta os segmentos P, Q e R na remessa; o Y-04
      # (Bolepix) é apenas de retorno.
      class BtgPactual < Brcobranca::Remessa::Cnab240::Base
        # digito verificador da agencia (opcional, o BTG trabalha sem DV de agencia)
        attr_writer :digito_agencia
        # versao do layout do arquivo (G019); padrao FEBRABAN 10.9
        attr_writer :versao_layout_arquivo
        # versao do layout do lote de cobranca (G030); padrao FEBRABAN 10.9
        attr_writer :versao_layout_lote

        validates_presence_of :digito_conta, message: 'não pode estar em branco.'
        validates_length_of :agencia, maximum: 4, message: 'deve ser menor ou igual a 4 dígitos.'
        validates_length_of :conta_corrente, maximum: 7, message: 'deve ser menor ou igual a 7 dígitos.'
        validates_length_of :digito_conta, is: 1, message: 'deve ter 1 dígito.'
        # O leitor devolve sempre 1 caractere (branco quando não informado).
        validates_format_of :digito_agencia, with: /\A[0-9A-Za-z ]\z/,
                                             message: 'deve ter no máximo 1 caractere alfanumérico.'
        validates_length_of :convenio, maximum: 20, message: 'deve ser menor ou igual a 20 caracteres.'
        validates_format_of :versao_layout_arquivo, with: /\A\d{3}\z/, message: 'deve ter 3 dígitos.'
        validates_format_of :versao_layout_lote, with: /\A\d{3}\z/, message: 'deve ter 3 dígitos.'

        # Quebras de linha ou outros caracteres de controle dividiriam os
        # registros de posição fixa do arquivo.
        validates_each :campos_sem_caracteres_de_controle do |record, _attr, _value|
          %i[digito_conta convenio].each do |campo|
            next unless record.send(campo).to_s.match?(/[[:cntrl:]]/)

            record.errors.add(campo, 'não pode conter caracteres de controle.')
          end
        end

        # O nosso número do BTG tem 11 posições (seção 4.4.4 do manual); um valor
        # maior é rejeitado em vez de truncado, para não registrar outro título.
        validates_each :nosso_numero_pagamentos do |record, _attr, _value|
          Array(record.pagamentos).each do |pagamento|
            next unless pagamento.respond_to?(:nosso_numero)
            next if pagamento.nosso_numero.to_s.size <= 11

            record.errors.add(:nosso_numero, "#{pagamento.nosso_numero} deve ser menor ou igual a 11 dígitos.")
          end
        end

        def initialize(campos = {})
          campos = { emissao_boleto: '2',
                     distribuicao_boleto: '2',
                     especie_titulo: '02',
                     tipo_documento: '1',
                     versao_layout_arquivo: '103',
                     versao_layout_lote: '060' }.merge!(campos)
          super(campos)
        end

        def cod_banco
          '208'
        end

        def nome_banco
          'BANCO BTG PACTUAL S.A.'.ljust(30, ' ')
        end

        def digito_agencia
          @digito_agencia.to_s.empty? ? ' ' : @digito_agencia.to_s
        end

        # Sempre String, para que um valor numérico (ex.: 103) não seja
        # concatenado como caractere no header.
        def versao_layout_arquivo
          @versao_layout_arquivo.to_s
        end

        def versao_layout_lote
          @versao_layout_lote.to_s
        end

        def codigo_convenio
          convenio.to_s.ljust(20, ' ')
        end

        def convenio_lote
          codigo_convenio
        end

        def uso_exclusivo_banco
          ''.rjust(20, ' ')
        end

        def uso_exclusivo_empresa
          ''.rjust(20, ' ')
        end

        def info_conta
          # CAMPO            TAMANHO
          # agencia          5
          # digito agencia   1
          # conta corrente   12
          # dv da conta      1
          # dv agencia/conta 1
          "#{agencia.to_s.rjust(5, '0')}#{digito_agencia}#{conta_corrente.to_s.rjust(12, '0')}#{digito_conta} "
        end

        def complemento_header
          ''.rjust(29, ' ')
        end

        def complemento_p(pagamento)
          # CAMPO                 TAMANHO
          # conta corrente        12
          # dv conta corrente     1
          # dv agencia/conta      1
          # nosso numero          20
          "#{conta_corrente.to_s.rjust(12, '0')}#{digito_conta} #{formata_nosso_numero(pagamento)}"
        end

        # Nosso número sem o DV (seção 4.4.4 do manual: "certifique-se de não enviar
        # o dígito verificador"), alinhado à direita. O tamanho máximo de 11
        # algarismos é validado em nosso_numero_pagamentos. Zeros fazem o BTG
        # gerar o número (G069).
        #
        # @return [String] 20 caracteres numéricos.
        def formata_nosso_numero(pagamento)
          pagamento.nosso_numero.to_s.rjust(20, '0')
        end

        def complemento_trailer
          # CAMPO                               TAMANHO
          # Totalização cobrança simples        6 + 17
          # Totalização cobrança vinculada      6 + 17
          # Totalização cobrança caucionada     6 + 17
          # Totalização cobrança descontada     6 + 17
          # Número do aviso de lançamento       8
          # Uso exclusivo FEBRABAN              117
          # Os totais só são usados no retorno (C070/C071); na remessa vão zerados.
          "#{''.rjust(92, '0')}#{''.rjust(125, ' ')}"
        end

        # Trailer do arquivo com a quantidade de contas para conciliação (G037) zerada,
        # já que o campo é numérico.
        def monta_trailer_arquivo(nro_lotes, sequencial)
          trailer = ''                                        # CAMPO                     TAMANHO
          trailer += cod_banco                                # codigo banco              3
          trailer << '9999'                                   # lote de servico           4
          trailer << '9'                                      # tipo de registro          1
          trailer << ''.rjust(9, ' ')                         # uso FEBRABAN              9
          trailer << nro_lotes.to_s.rjust(6, '0')             # qtde de lotes             6
          trailer << sequencial.to_s.rjust(6, '0')            # qtde de registros         6
          trailer << ''.rjust(6, '0')                         # qtde contas concil.       6
          trailer << ''.rjust(205, ' ')                       # uso FEBRABAN              205
          trailer
        end
      end
    end
  end
end
