# -*- encoding: utf-8 -*-

begin
  require 'rghost'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rghost'
  require 'rghost'
end

begin
  require 'rghost_barcode'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rghost_barcode'
  require 'rghost_barcode'
end

module Brcobranca
  module Boleto
    module Template
      # Templates para usar com Rghost
      module RghostCarne
        extend self
        include RGhost unless include?(RGhost)
        RGhost::Config::GS[:external_encoding] = Brcobranca.configuration.external_encoding

        # Gera o boleto em usando o formato desejado [:pdf, :jpg, :tif, :png, :ps, :laserjet, ... etc]
        #
        # @return [Stream]
        # @see http://wiki.github.com/shairontoledo/rghost/supported-devices-drivers-and-formats Veja mais formatos na documentação do rghost.
        # @see Rghost#modelo_carne Recebe os mesmos parâmetros do Rghost#modelo_carne.
        def to_carne(formato, options = {})
          modelo_carne(self, options.merge!(formato: formato))
        end

        # Gera o boleto em usando o formato desejado [:pdf, :jpg, :tif, :png, :ps, :laserjet, ... etc]
        #
        # @return [Stream]
        # @see http://wiki.github.com/shairontoledo/rghost/supported-devices-drivers-and-formats Veja mais formatos na documentação do rghost.
        # @see Rghost#modelo_carne Recebe os mesmos parâmetros do Rghost#modelo_carne.
        def lote_carne(boletos, options = {})
          modelo_carne_multipage(boletos, options)
        end

        #  Cria o métodos dinâmicos (to_pdf, to_gif e etc) com todos os fomátos válidos.
        #
        # @return [Stream]
        # @see Rghost#modelo_carne Recebe os mesmos parâmetros do Rghost#modelo_carne.
        # @example
        #  @boleto.to_pdf #=> boleto gerado no formato pdf
        def method_missing(m, *args)
          method = m.to_s
          if method.start_with?('to_')
            modelo_carne(self, (args.first || {}).merge!(formato: method[3..-1]))
          else
            super
          end
        end

        private

        # Retorna um stream pronto para gravação em arquivo.
        #
        # @return [Stream]
        # @param [Boleto] Instância de uma classe de boleto.
        # @param [Hash] options Opção para a criação do boleto.
        # @option options [Symbol] :resolucao Resolução em pixels.
        # @option options [Symbol] :formato Formato desejado [:pdf, :jpg, :tif, :png, :ps, :laserjet, ... etc]
        def modelo_carne(boleto, options = {})
          doc = Document.new paper: [21, 9]

          colunas = calc_colunas 1
          linhas = calc_linhas 0

          modelo_carne_load_background(doc, 0)

          modelo_carne_define_tags(doc)

          modelo_carne_build_data_left(doc, boleto, colunas, linhas)
          modelo_carne_build_data_right(doc, boleto, colunas, linhas)

          # Gerando stream
          formato = (options.delete(:formato) || Brcobranca.configuration.formato)
          resolucao = (options.delete(:resolucao) || Brcobranca.configuration.resolucao)
          doc.render_stream(formato.to_sym, resolution: resolucao)
        end

        # Retorna um stream para multiplos boletos pronto para gravação em arquivo.
        #
        # @return [Stream]
        # @param [Array] Instâncias de classes de boleto.
        # @param [Hash] options Opção para a criação do boleto.
        # @option options [Symbol] :resolucao Resolução em pixels.
        # @option options [Symbol] :formato Formato desejado [:pdf, :jpg, :tif, :png, :ps, :laserjet, ... etc]
        def modelo_carne_multipage(boletos, options = {})
          doc = Document.new paper: :A4

          max_per_page = 3
          curr_page_position = 0
          heigth_template = 9 # altura do template é de 9 cm
          initial_margin_bottom = 1.4 # margin inicial abaixo

          modelo_carne_define_tags(doc)

          boletos.each_with_index do |boleto, index|
            curr_page_position += 1

            margin_bottom = initial_margin_bottom + (heigth_template * (max_per_page - curr_page_position)) # onde o boleto sera impresso na pagina A4

            modelo_carne_load_background doc, margin_bottom

            colunas = calc_colunas 1
            linhas = calc_linhas margin_bottom

            modelo_carne_build_data_left(doc, boleto, colunas, linhas)
            modelo_carne_build_data_right(doc, boleto, colunas, linhas)

            if curr_page_position >= max_per_page # maximo 3 boletos por pagina
              # Cria nova página se não for o último boleto
              doc.next_page unless index == boletos.length - 1

              curr_page_position = 0 # reinicia contador por página
            end
          end

          # Gerando stream
          formato = (options.delete(:formato) || Brcobranca.configuration.formato)
          resolucao = (options.delete(:resolucao) || Brcobranca.configuration.resolucao)

          doc.render_stream(formato.to_sym, resolution: resolucao)
        end

        # carrega background do boleto
        def modelo_carne_load_background(doc, margin_bottom)
          template_path = File.join(File.dirname(__FILE__), '..', '..', 'arquivos', 'templates', 'modelo_carne.eps')
          raise 'Não foi possível encontrar o template. Verifique o caminho' unless File.exist?(template_path)

          doc.image template_path, x: 1, y: margin_bottom
        end

        # define os tamanhos
        def modelo_carne_define_tags(doc)
          doc.define_tags do
            tag :grande, size: 13
            tag :media, size: 10
          end
        end

        # define as colunas do documento, conforme margem lateral esquerda
        def calc_colunas(margin_left)
          colunas = [0.1, 3.4, 4.5, 7.1, 7.8, 8.5, 9.1, 9.7, 11, 12.4, 13.3, 15]

          colunas.each_with_index do |v, i|
            colunas[i] = v + margin_left
          end

          colunas
        end

        # define as linhas do documento conforme margem inferior
        def calc_linhas(margin_bottom)
          linhas = [8.2, 7.5, 6.92, 6.34, 5.74, 5.1, 4.7, 4.3, 3.9, 3.5, 3.1, 2.32, 1.92, 1.69, 0.1]

          linhas.each_with_index do |v, i|
            linhas[i] = v + margin_bottom
          end

          linhas
        end

        # aplica dados do lado esquerdo
        def modelo_carne_build_data_left(doc, boleto, colunas, linhas)
          # LOGOTIPO do BANCO
          doc.image boleto.logotipo, x: (colunas[0] - 0.11), y: linhas[0]

          # Dados

          # Numero do banco
          doc.moveto x: colunas[1], y: linhas[0]
          doc.show "#{boleto.banco}-#{boleto.banco_dv}"

          # vencimento
          doc.moveto x: colunas[0], y: linhas[1]
          doc.show boleto.data_vencimento.to_s_br

          # agencia/codigo cedente
          doc.moveto x: colunas[0], y: linhas[2]
          doc.show boleto.agencia_conta_boleto

          # nosso numero
          doc.moveto x: colunas[0], y: linhas[3]
          doc.show boleto.nosso_numero_boleto

          # valor do documento
          doc.moveto x: colunas[0], y: linhas[4]
          doc.show boleto.valor_documento.to_currency

          # numero documento
          doc.moveto x: colunas[0], y: linhas[11]
          doc.show boleto.documento_numero

          # sacado
          doc.moveto x: colunas[0], y: linhas[13]
          doc.show "#{boleto.sacado}"
        end

        # aplica dados do lado direito
        def modelo_carne_build_data_right(doc, boleto, colunas, linhas)
          # LOGOTIPO do BANCO
          doc.image boleto.logotipo, x: (colunas[2] - 0.11), y: linhas[0]

          # Numero do banco
          doc.moveto x: colunas[4], y: linhas[0]
          doc.show "#{boleto.banco}-#{boleto.banco_dv}", tag: :grande

          # linha digitavel
          doc.moveto x: colunas[6], y: linhas[0]
          doc.show boleto.codigo_barras.linha_digitavel, tag: :media

          # local de pagamento
          doc.moveto x: colunas[2], y: linhas[1]
          doc.show boleto.local_pagamento

          # vencimento
          doc.moveto x: colunas[11], y: linhas[1]
          doc.show boleto.data_vencimento.to_s_br

          # cedente
          doc.moveto x: colunas[2], y: linhas[2]
          doc.show boleto.cedente

          # agencia/codigo cedente
          doc.moveto x: colunas[11], y: linhas[2]
          doc.show boleto.agencia_conta_boleto

          # data do documento
          doc.moveto x: colunas[2], y: linhas[3]
          doc.show boleto.data_documento.to_s_br if boleto.data_documento

          # numero documento
          doc.moveto x: colunas[3], y: linhas[3]
          doc.show boleto.documento_numero

          # especie doc.
          doc.moveto x: colunas[8], y: linhas[3]
          doc.show boleto.especie_documento

          # aceite
          doc.moveto x: colunas[9], y: linhas[3]
          doc.show boleto.aceite

          # dt processamento
          doc.moveto x: colunas[10], y: linhas[3]
          doc.show boleto.data_processamento.to_s_br if boleto.data_processamento

          # nosso numero
          doc.moveto x: colunas[11], y: linhas[3]
          doc.show boleto.nosso_numero_boleto

          # uso do banco
          ## nada...

          # carteira
          doc.moveto x: colunas[3], y: linhas[4]
          doc.show boleto.carteira

          # especie
          doc.moveto x: colunas[5], y: linhas[4]
          doc.show boleto.especie

          # quantidade
          doc.moveto x: colunas[7], y: linhas[4]
          doc.show boleto.quantidade

          # valor documento
          doc.moveto x: colunas[8], y: linhas[4]
          doc.show boleto.valor_documento.to_currency

          # valor do documento
          doc.moveto x: colunas[11], y: linhas[4]
          doc.show boleto.valor_documento.to_currency

          # Instruções
          doc.moveto x: colunas[2], y: linhas[5]
          doc.show boleto.instrucao1
          doc.moveto x: colunas[2], y: linhas[6]
          doc.show boleto.instrucao2
          doc.moveto x: colunas[2], y: linhas[7]
          doc.show boleto.instrucao3
          doc.moveto x: colunas[2], y: linhas[8]
          doc.show boleto.instrucao4
          doc.moveto x: colunas[2], y: linhas[9]
          doc.show boleto.instrucao5
          doc.moveto x: colunas[2], y: linhas[10]
          doc.show boleto.instrucao6

          # Sacado
          doc.moveto x: colunas[2], y: linhas[11]
          doc.show "#{boleto.sacado} - #{boleto.sacado_documento.formata_documento}" if boleto.sacado && boleto.sacado_documento

          # Sacado endereço
          doc.moveto x: colunas[2], y: linhas[12]
          doc.show "#{boleto.sacado_endereco}"

          # codigo de barras
          # Gerando codigo de barra com rghost_barcode
          doc.barcode_interleaved2of5(boleto.codigo_barras, width: '10.3 cm', height: '1.2 cm', x: colunas[2], y: linhas[14]) if boleto.codigo_barras
        end
      end # Base
    end
  end
end
