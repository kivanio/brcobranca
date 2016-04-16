# -*- encoding: utf-8 -*-
module Brcobranca
  module Remessa
    module Cnab240
      class Base < Brcobranca::Remessa::Base
        # documento do cedente (CPF/CNPJ)
        attr_accessor :documento_cedente
        # convenio do cedente
        attr_accessor :convenio
        # mensagem 1
        attr_accessor :mensagem_1
        # mensagem 2
        attr_accessor :mensagem_2
        # codigo da carteira
        #   opcoes:
        #     1 - cobranca simples
        #     2 - cobranca caucionada
        #     3 - cobranca descontada
        #     7 – modalidade Simples quando carteira 17 (apenas Banco do Brasil)
        attr_accessor :codigo_carteira
        # forma de cadastramento dos titulos (campo nao tratado pelo Banco do Brasil)
        #   opcoes:
        #     1 - com cadastramento (cobrança registrada)
        #     2 - sem cadastramento (cobrança sem registro)
        attr_accessor :forma_cadastramento
        # identificacao da emissao do boleto (verificar opcoes nas classes referentes aos bancos)
        attr_accessor :emissao_boleto
        # identificacao da distribuicao do boleto (verificar opcoes nas classes referentes aos bancos)
        attr_accessor :distribuicao_boleto
        # especie do titulo (verificar o padrao nas classes referentes aos bancos)
        attr_accessor :especie_titulo
        # tipo de documento (verificar o padrao nas classes referentes aos bancos)
        attr_accessor :tipo_documento

        validates_presence_of :agencia, :conta_corrente, message: 'não pode estar em branco.'
        validates_presence_of :documento_cedente, message: 'não pode estar em branco.'
        validates_length_of :codigo_carteira, is: 1, message: 'deve ter 1 dígito.'
        validates_length_of :forma_cadastramento, is: 1, message: 'deve ter 1 dígito.'
        validates_length_of :emissao_boleto, is: 1, message: 'deve ter 1 dígito.'
        validates_length_of :distribuicao_boleto, is: 1, message: 'deve ter 1 dígito.'

        def initialize(campos = {})
          campos = { codigo_carteira: '1',
            forma_cadastramento: '1',
            tipo_documento: ' ' }.merge!(campos)
          super(campos)
        end

        # Data de geracao do arquivo
        #
        # @return [String]
        #
        def data_geracao
          Date.today.strftime('%d%m%Y')
        end

        # Hora de geracao do arquivo
        #
        # @return [String]
        #
        def hora_geracao
          (Time.respond_to?(:current) ? Time.current : Time.now).strftime('%H%M%S')
        end

        # Monta o registro header do arquivo
        #
        # @return [String]
        #
        def monta_header_arquivo
          header_arquivo = '' # CAMPO                         TAMANHO
          header_arquivo << cod_banco # codigo do banco               3
          header_arquivo << '0000' # lote do servico               4
          header_arquivo << '0' # tipo de registro              1
          header_arquivo << ''.rjust(9, ' ') # uso exclusivo FEBRABAN        9
          header_arquivo << Brcobranca::Util::Empresa.new(documento_cedente, false).tipo # tipo inscricao                1
          header_arquivo << documento_cedente.to_s.rjust(14, '0') # numero de inscricao           14
          header_arquivo << codigo_convenio # codigo do convenio no banco   20
          header_arquivo << info_conta # informacoes da conta          20
          header_arquivo << empresa_mae.format_size(30) # nome da empresa               30
          header_arquivo << nome_banco.format_size(30) # nome do banco                 30
          header_arquivo << ''.rjust(10, ' ') # uso exclusivo FEBRABAN        10
          header_arquivo << '1' # codigo remessa                1
          header_arquivo << data_geracao # data geracao                  8
          header_arquivo << hora_geracao # hora geracao                  6
          header_arquivo << sequencial_remessa.to_s.rjust(6, '0') # numero seq. arquivo           6
          header_arquivo << versao_layout_arquivo # num. versao arquivo           3
          header_arquivo << ''.rjust(5, '0') # densidade gravacao            5
          header_arquivo << ''.rjust(20, '0') # uso exclusivo                 20
          header_arquivo << ''.rjust(20, '0') # uso exclusivo                 20
          header_arquivo << complemento_header # complemento do arquivo        29
          header_arquivo
        end

        # Monta o registro header do lote
        #
        # @param nro_lote [Integer]
        #   numero do lote no arquivo (iterar a cada novo lote)
        #
        # @return [String]
        #
        def monta_header_lote(nro_lote)
          header_lote = '' # CAMPO                   TAMANHO
          header_lote << cod_banco # codigo banco            3
          header_lote << nro_lote.to_s.rjust(4, '0') # lote servico            4
          header_lote << '1' # tipo de registro        1
          header_lote << 'R' # tipo de operacao        1
          header_lote << '01' # tipo de servico         2
          header_lote << '  ' # uso exclusivo           2
          header_lote << versao_layout_lote # num.versao layout lote  3
          header_lote << ' ' # uso exclusivo           1
          header_lote << Brcobranca::Util::Empresa.new(documento_cedente, false).tipo # tipo de inscricao       1
          header_lote << documento_cedente.to_s.rjust(15, '0') # inscricao cedente       15
          header_lote << convenio_lote # codigo do convenio      20
          header_lote << info_conta # informacoes conta       20
          header_lote << empresa_mae.format_size(30) # nome empresa            30
          header_lote << mensagem_1.to_s.format_size(40) # 1a mensagem             40
          header_lote << mensagem_2.to_s.format_size(40) # 2a mensagem             40
          header_lote << sequencial_remessa.to_s.rjust(8, '0') # numero remessa          8
          header_lote << data_geracao # data gravacao           8
          header_lote << ''.rjust(8, '0') # data do credito         8
          header_lote << ''.rjust(33, ' ') # complemento             33
          header_lote
        end

        # Monta o registro segmento P do arquivo
        #
        # @param pagamento [Brcobranca::Remessa::Pagamento]
        #   objeto contendo os detalhes do boleto (valor, vencimento, sacado, etc)
        # @param nro_lote [Integer]
        #   numero do lote que o segmento esta inserido
        # @param sequencial [Integer]
        #   numero sequencial do registro no lote
        #
        # @return [String]
        #
        def monta_segmento_p(pagamento, nro_lote, sequencial)
          # campos com * na frente nao foram implementados
          #                                                             # DESCRICAO                             TAMANHO
          segmento_p = cod_banco # codigo banco                          3
          segmento_p << nro_lote.to_s.rjust(4, '0') # lote de servico                       4
          segmento_p << '3' # tipo de registro                      1
          segmento_p << sequencial.to_s.rjust(5, '0') # num. sequencial do registro no lote   5
          segmento_p << 'P' # cod. segmento                         1
          segmento_p << ' ' # uso exclusivo                         1
          segmento_p << '01' # cod. movimento remessa                2
          segmento_p << agencia.to_s.rjust(5, '0') # agencia                               5
          segmento_p << digito_agencia.to_s # dv agencia                            1
          segmento_p << complemento_p(pagamento) # informacoes da conta                  34
          segmento_p << codigo_carteira # codigo da carteira                    1
          segmento_p << forma_cadastramento # forma de cadastro do titulo           1
          segmento_p << tipo_documento # tipo de documento                     1
          segmento_p << emissao_boleto # identificaco emissao                  1
          segmento_p << distribuicao_boleto # indentificacao entrega                1
          segmento_p << pagamento.numero_documento.to_s.rjust(15, '0') # uso exclusivo                         4
          segmento_p << pagamento.data_vencimento.strftime('%d%m%Y') # data de venc.                         8
          segmento_p << pagamento.formata_valor(15) # valor documento                       15
          segmento_p << ''.rjust(5, '0') # agencia cobradora                     5
          segmento_p << '0' # dv agencia cobradora                  1
          segmento_p << especie_titulo # especie do titulo                     2
          segmento_p << aceite # aceite                                1
          segmento_p << pagamento.data_emissao.strftime('%d%m%Y') # data de emissao titulo                8
          segmento_p << '0' # cod. do juros                         1   *
          segmento_p << ''.rjust(8, '0') # data juros                            8   *
          segmento_p << ''.rjust(15, '0') # valor juros                           15  *
          segmento_p << pagamento.cod_desconto # cod. do desconto                      1
          segmento_p << pagamento.formata_data_desconto('%d%m%Y') # data desconto                         8
          segmento_p << pagamento.formata_valor_desconto(15) # valor desconto                        15
          segmento_p << pagamento.formata_valor_iof(15) # valor IOF                             15
          segmento_p << pagamento.formata_valor_abatimento(15) # valor abatimento                      15
          segmento_p << ''.rjust(25, ' ') # identificacao titulo empresa          25  *
          segmento_p << '0' # cod. para protesto                    1   *
          segmento_p << '00' # dias para protesto                    2   *
          segmento_p << '0' # cod. para baixa                       1   *
          segmento_p << '000' # dias para baixa                       2   *
          segmento_p << '09' # cod. da moeda                         2
          segmento_p << ''.rjust(10, '0') # uso exclusivo                         10
          segmento_p << ' ' # uso exclusivo                         1
          segmento_p
        end

        # Monta o registro segmento Q do arquivo
        #
        # @param pagamento [Brcobranca::Remessa::Pagamento]
        #   objeto contendo os detalhes do boleto (valor, vencimento, sacado, etc)
        # @param nro_lote [Integer]
        #   numero do lote que o segmento esta inserido
        # @param sequencial [Integer]
        #   numero sequencial do registro no lote
        #
        # @return [String]
        #
        def monta_segmento_q(pagamento, nro_lote, sequencial)
          segmento_q = '' # CAMPO                                TAMANHO
          segmento_q << cod_banco # codigo banco                         3
          segmento_q << nro_lote.to_s.rjust(4, '0') # lote de servico                      4
          segmento_q << '3' # tipo de registro                     1
          segmento_q << sequencial.to_s.rjust(5, '0') # num. sequencial do registro no lote  5
          segmento_q << 'Q' # cod. segmento                        1
          segmento_q << ' ' # uso exclusivo                        1
          segmento_q << '01' # cod. movimento remessa               2
          segmento_q << pagamento.identificacao_sacado(false) # tipo insc. sacado                    1
          segmento_q << pagamento.documento_sacado.to_s.rjust(15, '0') # documento sacado                     14
          segmento_q << pagamento.nome_sacado.format_size(40) # nome cliente                         40
          segmento_q << pagamento.endereco_sacado.format_size(40) # endereco cliente                     40
          segmento_q << pagamento.bairro_sacado.format_size(15) # bairro                               15
          segmento_q << pagamento.cep_sacado[0..4] # cep                                  5
          segmento_q << pagamento.cep_sacado[5..7] # sufixo cep                           3
          segmento_q << pagamento.cidade_sacado.format_size(15) # cidade                               15
          segmento_q << pagamento.uf_sacado # uf                                   2
          segmento_q << pagamento.identificacao_avalista(false) # identificacao do sacador             1
          segmento_q << pagamento.documento_avalista.to_s.rjust(15, '0') # documento sacador                    15
          segmento_q << pagamento.nome_avalista.format_size(40) # nome avalista                         40
          segmento_q << ''.rjust(3, '0') # cod. banco correspondente            3
          segmento_q << ''.rjust(20, ' ') # nosso numero banco correspondente    20
          segmento_q << ''.rjust(8, ' ') # uso exclusivo                        8
          segmento_q
        end

        # Monta o registro trailer do lote
        #
        # @param nro_lote [Integer]
        #   numero do lote no arquivo (iterar a cada novo lote)
        #
        # @param nro_registros [Integer]
        #   numero de registros(linhas) no lote (contando header e trailer)
        #
        # @return [String]
        #
        def monta_trailer_lote(nro_lote, nro_registros)
          trailer_lote = '' # CAMPO                   # TAMANHO
          trailer_lote << cod_banco # codigo banco            3
          trailer_lote << nro_lote.to_s.rjust(4, '0') # lote de servico         4
          trailer_lote << '5' # tipo de servico         1
          trailer_lote << ''.rjust(9, ' ') # uso exclusivo           9
          trailer_lote << nro_registros.to_s.rjust(6, '0') # qtde de registros lote  6
          trailer_lote << complemento_trailer # uso exclusivo           217
          trailer_lote
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
          "#{cod_banco}99999#{''.rjust(9, ' ')}#{nro_lotes.to_s.rjust(6, '0')}#{sequencial.to_s.rjust(6, '0')}#{''.rjust(211, ' ')}"
        end

        # Monta um lote para o arquivo
        #
        # @param pagamento [Brcobranca::Remessa::Pagamento]
        #   objeto contendo os detalhes do boleto (valor, )
        #
        # @param nro_lote [Integer]
        # numero do lote no arquivo
        #
        # @return [Array]
        #
        def monta_lote(nro_lote)
          # contador dos registros do lote
          contador = 1 #header

          lote = [monta_header_lote(nro_lote)]

          pagamentos.each do |pagamento|
            fail Brcobranca::RemessaInvalida.new(pagamento) if pagamento.invalid?

            lote << monta_segmento_p(pagamento, nro_lote, contador)
            contador += 1
            lote << monta_segmento_q(pagamento, nro_lote, contador)
            contador += 1
          end
          contador += 1 #trailer

          lote << monta_trailer_lote(nro_lote, contador)

          lote
        end

        # Gera o arquivo remessa
        #
        # @return [String]
        #
        def gera_arquivo
          fail Brcobranca::RemessaInvalida.new(self) if self.invalid?

          arquivo = [monta_header_arquivo]

          # contador de do lotes
          contador = 1
          arquivo.push monta_lote(contador)

          arquivo << monta_trailer_arquivo(contador, ((pagamentos.size * 2) + (contador * 2) + 2))

          remittance = arquivo.join("\n").to_ascii.upcase
          remittance << "\n"
          remittance.encode(remittance.encoding, :universal_newline => true).encode(remittance.encoding, :crlf_newline => true)
        end

        # Complemento do registro
        #
        # Este metodo deve ser sobrescrevido na classe do banco
        #
        def complemento_header
          fail Brcobranca::NaoImplementado.new('Sobreescreva este método na classe referente ao banco que você esta criando')
        end

        # Numero da versao do layout do arquivo
        #
        # Este metodo deve ser sobrescrevido na classe do banco
        #
        def versao_layout_arquivo
          fail Brcobranca::NaoImplementado.new('Sobreescreva este método na classe referente ao banco que você esta criando')
        end

        # Numero da versao do layout do lote
        #
        # Este metodo deve ser sobrescrevido na classe do banco
        #
        def versao_layout_lote
          fail Brcobranca::NaoImplementado.new('Sobreescreva este método na classe referente ao banco que você esta criando')
        end

        # Informacoes do convenio para o lote
        #
        # Este metodo deve ser sobrescrevido na classe do banco
        #
        def convenio_lote
          fail Brcobranca::NaoImplementado.new('Sobreescreva este método na classe referente ao banco que você esta criando')
        end

        # Nome do banco
        #
        # Este metodo deve ser sobrescrevido na classe do banco
        #
        def nome_banco
          fail Brcobranca::NaoImplementado.new('Sobreescreva este método na classe referente ao banco que você esta criando')
        end

        # Codigo do banco
        #
        # Este metodo deve ser sobrescrevido na classe do banco
        #
        def cod_banco
          fail Brcobranca::NaoImplementado.new('Sobreescreva este método na classe referente ao banco que você esta criando')
        end

        # Informacoes da conta do cedente
        #
        # Este metodo deve ser sobrescrevido na classe do banco
        #
        def info_conta
          fail Brcobranca::NaoImplementado.new('Sobreescreva este método na classe referente ao banco que você esta criando')
        end

        # Codigo do convenio
        #
        # Este metodo deve ser sobrescrevido na classe do banco
        #
        def codigo_convenio
          fail Brcobranca::NaoImplementado.new('Sobreescreva este método na classe referente ao banco que você esta criando')
        end
      end
    end
  end
end
