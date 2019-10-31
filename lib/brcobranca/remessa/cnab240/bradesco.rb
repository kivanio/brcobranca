module Brcobranca
  module Remessa
    module Cnab240
      class Bradesco < Brcobranca::Remessa::Cnab240::Base

        # Logradouro da Empresa - Nome da Rua, Av, Pça, Etc
        attr_accessor :logradouro
        # Numero da Empresa - Numero do Local
        attr_accessor :numero
        # Complemento da Empresa - Casa, Apto, Sala, Etc
        attr_accessor :complemento
        # Cidade da Empresa - Nome da Cidade
        attr_accessor :cidade
        # CEP da Empresa - CEP
        attr_accessor :cep
        # Estado da Empresa - Sigla do Estado
        attr_accessor :estado

        validates_presence_of :carteira, message: 'não pode estar em branco.'
        validates_presence_of :convenio, message: 'não pode estar em branco.'
        validates_length_of :conta_corrente, maximum: 12, message: 'deve ter 12 dígitos.'
        validates_length_of :agencia, maximum: 5, message: 'deve ter 5 dígitos.'
        validates_length_of :carteira, is: 2, message: 'deve ter 2 dígitos.'
        validates_length_of :convenio, in: 4..7, message: 'deve ter de 4 a 7 dígitos.'

        def initialize(campos = {})
          campos = { emissao_boleto: '0',
            distribuicao_boleto: '0',
            especie_titulo: '02',
            codigo_carteira: '7',}.merge!(campos)
          super(campos)
        end

        def monta_lote(nro_lote)
          # contador dos registros do lote
          contador = 1

          lote = [monta_header_lote(nro_lote, '01')]

          transferencias.each do |transferencia|
            raise Brcobranca::RemessaInvalida, transferencia if transferencia.invalid?

            lote << monta_segmento_a(transferencia, nro_lote, contador)
            contador += 1
            lote << monta_segmento_b(transferencia, nro_lote, contador)
            contador += 1
          end
          contador += 1

          lote << monta_trailer_lote(nro_lote, contador, transferencias.map(&:valor).sum)

          lote
        end

        def monta_header_lote(nro_lote, forma_lancamento)
          header_lote = ''                                      # CAMPO                   TAMANHO
          header_lote << cod_banco                              # codigo banco            3
          header_lote << nro_lote.to_s.rjust(4, '0')            # lote servico            4
          header_lote << '1'                                    # tipo de registro        1
          header_lote << 'C'                                    # tipo de operacao        1
          # G0025 - '20' = Pagamento Fornecedor
          header_lote << '20'                                   # tipo de servico         2
          # vai ser definido na montagem do lote
          # 01 - Credito em Conta Corrente
          # 03 - DOC/TED (1) (2)
          # 05 - Credito em Conta Poupança
          header_lote << forma_lancamento.rjust(2, '0')         # forma de lançamento     2
          header_lote << versao_layout_lote                     # num.versao layout lote  3
          header_lote << ' '                                    # uso exclusivo           1

          header_lote << Brcobranca::Util::Empresa.new(documento_cedente, false).tipo # tipo de inscricao       1
          header_lote << documento_cedente.to_s.rjust(14, '0')  # inscricao cedente       14
          header_lote << codigo_convenio                        # codigo do convenio      20
          header_lote << info_conta                             # informacoes conta       20
          header_lote << empresa_mae.format_size(30)            # nome empresa            30
          # G031 - Texto referente a mensagens que serão impressas nos documentos e/ou avisos a serem emitidos.
          # Informacao 1: Genérica. Quando informada constará em todos os avisos e/ou documentos originados dos detalhes desse lote.
          # Informada no Header do Lote
          header_lote << ''.rjust(40, ' ')                      # 1a mensagem             40

          header_lote << logradouro.to_s.format_size(30)        # empresa Logradouro      30
          header_lote << numero.to_s.format_size(5)             # empresa numero          5
          header_lote << complemento.to_s.format_size(15)       # empresa complemento     15
          header_lote << cidade.to_s.format_size(20)            # empresa cidade          20
          header_lote << cep.to_s.format_size(8)                # empresa cep             8
          header_lote << estado.to_s.format_size(2)             # empresa estado          2
          header_lote << '01'                                   # forma de pagamento      2
          header_lote << ''.rjust(6, ' ')                       # uso exclusivo febraban  6
          header_lote << ''.rjust(10, ' ')                      # ocorrencias             10
          header_lote
        end

        def monta_trailer_lote(nro_lote, nro_registros, valor_total)
          trailer_lote = ''                                             # CAMPO                   # TAMANHO
          trailer_lote << cod_banco                                     # codigo banco            3
          trailer_lote << nro_lote.to_s.rjust(4, '0')                   # lote de servico         4
          trailer_lote << '5'                                           # tipo de servico         1
          trailer_lote << ''.rjust(9, ' ')                              # uso exclusivo           9
          trailer_lote << nro_registros.to_s.rjust(6, '0')              # qtde de registros lote  6
          trailer_lote << complemento_trailer(valor_total)              # uso exclusivo           217
          trailer_lote
        end        
        
        def cod_banco
          '237'
        end

        def nome_banco
          'BANCO BRADESCO SA'.ljust(30, ' ')
        end

        def versao_layout_arquivo
          '089'
        end

        def versao_layout_lote
          '045'
        end

        def digito_agencia
          # utilizando a agencia com 4 digitos
          # para calcular o digito
          agencia.modulo11(mapeamento: { 10 => 'X' }).to_s
        end

        def digito_conta
          # utilizando a conta corrente com 5 digitos
          # para calcular o digito
          conta_corrente.modulo11(mapeamento: { 10 => 'X' }).to_s
        end

        def codigo_convenio
          convenio.ljust(20, ' ')
        end

        # G020 - Densidade de Gravação do Arquivo
        # Densidade de gravação (BPI), do arquivo encaminhado.
        # Domínio:
        # 1600 BPI
        # 6250 BPI
        def densidade_gravacao
          '01600'
        end

        # Uso exclusivo do Banco
        def uso_exclusivo_banco
          ''.rjust(20, ' ')
        end

        # Uso exclusivo da Empresa
        def uso_exclusivo_empresa
          ''.rjust(20, ' ')
        end

        def complemento_header
          ''.rjust(29, ' ')
        end
        
        alias_method :convenio_lote, :codigo_convenio

        def info_conta
          # CAMPO                  TAMANHO
          # agencia                5
          # digito agencia         1
          # conta corrente         12
          # digito conta           1
          # digito agencia/conta   1
          "#{agencia.rjust(5, '0')}#{digito_agencia}#{conta_corrente.rjust(12, '0')}#{digito_conta} "
        end

        def complemento_trailer(valor_total)
          complemento = "#{format_value(valor_total, 18)}"
          complemento << ''.rjust(24, '0')
          complemento << ''.rjust(175, ' ')
          complemento
        end

        def complemento_p(pagamento)
          # CAMPO                   TAMANHO
          # conta corrente          12
          # digito conta            1
          # digito agencia/conta    1
          # ident. titulo no banco  20
          "#{conta_corrente.rjust(12, '0')}#{digito_conta} #{identificador_titulo(pagamento.nosso_numero)}"
        end

        # Retorna o nosso numero mais o digito verificador
        #
        # @return [String]
        #
        def formata_nosso_numero(nosso_numero)
          quantidade = case convenio.to_s.size
                         # convenio de 4 posicoes com nosso numero de 7
                       when 4 then
                         7
                         # convenio de 6 posicoes com nosso numero de 5
                       when 6 then
                         5
                         # convenio de 7 posicoes com nosso numero de 10
                       when 7 then
                         10
                       else
                         raise Brcobranca::NaoImplementado, 'Tipo de convênio não implementado.'
                       end
          nosso_numero = nosso_numero.to_s.rjust(quantidade, '0')

          # calcula o digito do nosso numero (menos para quando nosso numero tiver 10 posicoes)
          digito = "#{convenio}#{nosso_numero}".modulo11(mapeamento: { 10 => 'X' }) unless quantidade == 10
          "#{nosso_numero}#{digito}"
        end

        def identificador_titulo(nosso_numero)
          "#{convenio}#{formata_nosso_numero(nosso_numero)}".ljust(20, ' ')
        end

        def monta_segmento_a(transferencia, nro_lote, sequencial)
          segmento_a = cod_banco                                        # codigo banco                          3
          segmento_a << nro_lote.to_s.rjust(4, '0')                     # lote de servico                       4
          segmento_a << '3'                                             # tipo de registro                      1
          segmento_a << sequencial.to_s.rjust(5, '0')                   # num. sequencial do registro no lote   5
          segmento_a << 'A'                                             # cod. segmento                         1
          segmento_a << '0'                                             # tipo de movimento                     1
          segmento_a << transferencia.identificacao_ocorrencia              # cod. movimento remessa                2

          # FAVORECIDO
          segmento_a << transferencia.camara_centralizadora                 # camara centralizadora                 3
          segmento_a << transferencia.info_conta                            # informacoes da conta                  23
          segmento_a << transferencia.nome_sacado.format_size(30)           # nome do favorecido                    30
          segmento_a << ''.ljust(20,' ')                                # nome do favorecido                    20

          segmento_a << transferencia.data_vencimento.strftime('%d%m%Y')    # data de vencimento                    8
          segmento_a << "BRL"                                           # tipo da moeda                         3
          segmento_a << ''.rjust(15,'0')                                # Quantidade da Moeda                   15
          segmento_a << transferencia.formata_valor(15)                     # valor documento                       15
          segmento_a << ''.rjust(20,'0')                                # n do documento do banco               20
          segmento_a << ''.rjust(8,'0')                                 # data real do pag                      8
          segmento_a << ''.rjust(15,'0')                                # valor real do pag                     15

          segmento_a << ''.rjust(40, ' ')                               # informacoes                           40  G031
          segmento_a << ''.rjust(2, ' ')                                # comp tipo de servico                  2   P005
          segmento_a << transferencia.codigo_finalidade                     # codigo finalidade ted                 7   P011 ( 018 - TED )
          segmento_a << ''.rjust(3, ' ')                                # uso exlusico             3   G004
          segmento_a << '0'                                             # aviso ao favorecido      1   P006 ( não emite aviso )
          segmento_a << ''.rjust(10, ' ')                               # codigos das ocorrenc     10  G059

          segmento_a
        end

        def monta_segmento_b(transferencia, nro_lote, sequencial)
          segmento_b =  cod_banco                                       # codigo banco                          3
          segmento_b << nro_lote.to_s.rjust(4, '0')                     # lote de servico                       4
          segmento_b << '3'                                             # tipo de registro                      1
          segmento_b << sequencial.to_s.rjust(5, '0')                   # num. sequencial do registro no lote   5
          segmento_b << 'B'                                             # cod. segmento                         1
          segmento_b << ''.ljust(3,' ')                                 # uso exclusivo febraban                3

          # FAVORECIDO
          segmento_b << transferencia.identificacao_sacado(false)           # Tipo de Inscrição do Favorecido       1
          segmento_b << transferencia.documento_sacado.to_s.rjust(14, '0')  # Nº de Inscrição do Favorecido         14
          segmento_b << transferencia.endereco_sacado.format_size(50)       # endereco cliente                      35
          segmento_b << transferencia.bairro_sacado.format_size(15)         # bairro
          segmento_b << transferencia.cidade_sacado.format_size(20)         # cidade                                15
          segmento_b << transferencia.cep_sacado[0..4]                      # cep                                   5
          segmento_b << transferencia.cep_sacado[5..7]                      # sufixo cep                            3
          segmento_b << transferencia.uf_sacado                             # uf                                    2

          segmento_b << transferencia.data_vencimento.strftime('%d%m%Y')    # data de venc.                         8
          segmento_b << transferencia.formata_valor(15)                     # valor documento                       15
          segmento_b << transferencia.formata_valor_abatimento(15)          # valor abatimento                      15
          segmento_b << transferencia.formata_valor_desconto(15)            # valor desconto                        15
          segmento_b << transferencia.formata_valor_mora(15)                # valor mora                            15
          segmento_b << transferencia.formata_percentual_multa(15)          # valor multa                           15
          segmento_b << ''.rjust(15, ' ')                               # Código/Documento do Favorecido        15  

          segmento_b << '0'                                             # aviso                    1  
          segmento_b << ''.rjust(6, '0')                                # informaçoes              6  P012
          segmento_b << ''.rjust(8, '0')                                # informaçoes              8  P015

          segmento_b
        end
      end
    end
  end
end
