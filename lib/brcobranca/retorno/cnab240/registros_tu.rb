# frozen_string_literal: true

module Brcobranca
  module Retorno
    module Cnab240
      # Carrega retornos CNAB 240 formados por pares de registros T e U,
      # enriquecidos pelos registros opcionais do Split Payment IBS/CBS
      # (Segmento X-03/X-04, Layout Padrao Febraban 240 posicoes V11.0).
      #
      # O registro CNAB 240 usa dois tipos de registro que juntos formam um
      # retorno: o T, com os dados gerais da transacao, e o U, com os valores.
      # Os registros do Split Payment sao opcionais e sempre acompanham os
      # segmentos obrigatorios do titulo a que se referem - como eles nao
      # repetem a identificacao do titulo (nosso numero), o vinculo e feito pela
      # posicao no arquivo: o registro pertence ao ultimo titulo lido do MESMO
      # lote (Segmento T mais os registros que o seguem ate o proximo T ou ate o
      # fim do lote).
      #
      # Os bancos que seguem esse padrao sem particularidades apenas estendem
      # este modulo; cada um define a propria classe Line com o layout e as
      # listas REGISTRO_T_FIELDS e REGISTRO_U_FIELDS.
      module RegistrosTU
        # Regex para remocao de headers e trailers alem de registros diferentes
        # dos segmentos T, U, Y e X. O Y e o X sao os segmentos dos registros
        # opcionais (Split Payment e demais registros identificados pelo campo
        # G067 - o X, na V11.0, tem a identificacao nas posicoes 16-17).
        REGEX_DE_EXCLUSAO_DE_REGISTROS_NAO_T_U_Y_OU_X = /^((?!^.{7}3.{5}[TUYX].*$).)*$/.freeze

        def load_lines(file, options = {})
          default_options = { except: REGEX_DE_EXCLUSAO_DE_REGISTROS_NAO_T_U_Y_OU_X }
          options = default_options.merge!(options)

          linhas = self::Line.load_lines(file, options)

          # Os registros opcionais (Y/X) nao iniciam um titulo: sem esta guarda
          # um arquivo que so tem esses registros (ex.: Retorno de Boleto de
          # Pagamento, com G, H, Y e X) geraria um retorno vazio no lugar de
          # nenhum retorno.
          linhas.chunk_while { |anterior, linha| continua_titulo?(anterior, linha) }
                .select { |linhas_do_titulo| linhas_do_titulo.first.tipo_registro == 'T' }
                .map { |linhas_do_titulo| gera_retorno_do_titulo(linhas_do_titulo) }
        end

        # Se a linha continua o titulo iniciado no Segmento T: o titulo comeca
        # no T e nao atravessa o limite do lote, para que os registros
        # opcionais Y/X nao sejam associados ao titulo do lote anterior quando
        # os segmentos obrigatorios do lote deles sao descartados pelo filtro
        # (ex.: um lote de G/H com os Segmentos X-03/X-04).
        #
        # O lote (G002) e lido pelas classes Line que usam o
        # SegmentoSplitPayment; sem ele o agrupamento e apenas pelo Segmento T.
        def continua_titulo?(anterior, linha)
          return false if linha.tipo_registro == 'T'
          return true unless anterior.respond_to?(:lote_servico) && linha.respond_to?(:lote_servico)

          linha.lote_servico == anterior.lote_servico
        end

        # Um titulo no arquivo de retorno e formado pelos segmentos obrigatorios
        # T e U e, quando o banco devolve os dados do Split Payment, pelos
        # registros opcionais do Split Payment (X-03/X-04).
        def gera_retorno_do_titulo(linhas)
          linhas_t_u = linhas.select { |linha| %w[T U].include?(linha.tipo_registro) }

          validate_par_t_u!(linhas_t_u)

          retorno = generate_retorno_based_on_cnab_lines(linhas_t_u)
          aplica_dados_split_payment(retorno, linhas)
          retorno
        end

        # Validacao do par T/U, para os bancos que querem recusar arquivo
        # truncado/corrompido (veja Brcobranca::Retorno::Cnab240::Itau). Por
        # padrao nenhuma validacao e feita.
        def validate_par_t_u!(_linhas_t_u)
          nil
        end

        def generate_retorno_based_on_cnab_lines(cnab_lines)
          retorno = new
          cnab_lines.each do |line|
            campos = line.tipo_registro == 'T' ? self::Line::REGISTRO_T_FIELDS : self::Line::REGISTRO_U_FIELDS
            campos.each { |attr| retorno.send(:"#{attr}=", line.send(attr)) }
          end
          retorno
        end

        # Copia os dados dos registros opcionais do Split Payment (IBS/CBS) para
        # o retorno. Os registros sao opcionais: sem eles o retorno fica
        # exatamente como era antes do layout V11.0.
        def aplica_dados_split_payment(retorno, linhas)
          linhas.each { |linha| self::Line.aplica_campos_split_payment(retorno, linha) }
        end
      end
    end
  end
end
