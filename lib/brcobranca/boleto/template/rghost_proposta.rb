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
      module RghostProposta
        extend self
        include RGhost unless include?(RGhost)

        RGhost::Config::GS[:external_encoding] = Brcobranca.configuration.external_encoding

        # Gera a proposta em usando o formato desejado [:pdf, :jpg, :tif, :png, :ps, :laserjet, ... etc]
        #
        # @return [Stream]
        # @see http://wiki.github.com/shairontoledo/rghost/supported-devices-drivers-and-formats Veja mais formatos na documentação do rghost.
        # @see Rghost#modelo_proposta Recebe os mesmos parâmetros do Rghost#modelo_proposta.
        def to_proposta(formato, options = {})
          modelo_proposta(self, options.merge!(formato: formato))
        end

        # Gera a proposta em usando o formato desejado [:pdf, :jpg, :tif, :png, :ps, :laserjet, ... etc]
        #
        # @return [Stream]
        # @see http://wiki.github.com/shairontoledo/rghost/supported-devices-drivers-and-formats Veja mais formatos na documentação do rghost.
        # @see Rghost#modelo_proposta Recebe os mesmos parâmetros do Rghost#modelo_proposta.
        def lote_proposta(boletos, options = {})
          modelo_proposta_multipage(boletos, options)
        end

        #  Cria o métodos dinâmicos (to_pdf, to_gif e etc) com todos os fomátos válidos.
        #
        # @return [Stream]
        # @see Rghost#modelo_proposta Recebe os mesmos parâmetros do Rghost#modelo_proposta.
        # @example
        #  @boleto.to_pdf #=> boleto gerado no formato pdf
        def method_missing(m, *args)
          method = m.to_s

          if method.start_with?('to_')
            modelo_proposta(self, (args.first || {}).merge!(formato: method[3..-1]))
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
        def modelo_proposta(boleto, options = {})
          doc = Document.new paper: [21, 11.5]

          colunas = calc_colunas 1
          linhas = calc_linhas 0

          modelo_proposta_load_background(doc, 0)

          modelo_proposta_define_tags(doc)
          modelo_proposta_build_data(doc, boleto, colunas, linhas)

          # Gerando stream
          formato = (options.delete(:formato) || Brcobranca.configuration.formato)
          resolucao = (options.delete(:resolucao) || Brcobranca.configuration.resolucao)
          doc.render_stream(formato.to_sym, resolution: resolucao)
        end

        # carrega background do boleto
        def modelo_proposta_load_background(doc, margin_bottom)
          template_path = File.join(File.dirname(__FILE__), '..', '..', 'arquivos', 'templates', 'modelo_proposta.eps')
          raise 'Não foi possível encontrar o template. Verifique o caminho' unless File.exist?(template_path)

          doc.image template_path, x: 0.4, y: margin_bottom + 0.2
        end

        # define os tamanhos
        def modelo_proposta_define_tags(doc)
          doc.define_tags do
            tag :grande, size: 13
          end
        end

        # define as colunas do documento, conforme margem esquerda
        def calc_colunas(margin_left)
          colunas = [-0.4, 3.0, 4.3, 5.3, 6.2, 8.3, 11.3, 14.1]

          colunas.map.with_index { |v, i| colunas[i] = v + margin_left }
        end

        # define as linhas do documento conforme margem inferior
        def calc_linhas(margin_bottom)
          linhas = [10.6, 6.6, 5.75, 4.9, 4.2, 3.35, 2.5, 2.1, 0.3]

          linhas.map.with_index { |v, i| linhas[i] = v + margin_bottom }
        end

        def modelo_proposta_build_data(doc, boleto, colunas, linhas)
          # LOGOTIPO do BANCO
          doc.image boleto.logotipo, x: (colunas[0] + 0.5), y: (linhas[0] - 0.1)

          # Numero do banco
          doc.moveto x: colunas[2], y: linhas[0]
          doc.show "#{boleto.banco}-#{boleto.banco_dv}", tag: :grande

          # linha digitavel
          doc.moveto x: colunas[4], y: linhas[0]
          doc.show boleto.codigo_barras.linha_digitavel, tag: :grande

          # local de pagamento
          doc.moveto x: colunas[0], y: linhas[1]
          doc.show boleto.local_pagamento

          # cedente
          doc.moveto x: colunas[0], y: linhas[2]
          doc.show boleto.cedente

          # vencimento
          doc.moveto x: colunas[7], y: linhas[2]
          doc.show boleto.data_vencimento.to_s_br

          # dt processamento
          doc.moveto x: colunas[0], y: linhas[3]
          doc.show boleto.data_processamento.to_s_br if boleto.data_processamento

          # numero documento
          doc.moveto x: colunas[1], y: linhas[3]
          doc.show boleto.documento_numero

          # nosso numero
          doc.moveto x: colunas[3], y: linhas[3]
          doc.show boleto.nosso_numero_boleto

          # agencia/codigo cedente
          doc.moveto x: colunas[5], y: linhas[3]
          doc.show boleto.agencia_conta_boleto

          # carteira
          doc.moveto x: colunas[6], y: linhas[3]
          doc.show boleto.carteira

          # valor pago
          doc.moveto x: colunas[7], y: linhas[3]
          doc.show boleto.valor_documento.to_currency

          # valor abatimento
          # nada

          # valor pago
          doc.moveto x: colunas[7], y: linhas[5]
          doc.show boleto.valor_documento.to_currency

          # Sacado
          doc.moveto x: colunas[0], y: linhas[6]
          if boleto.sacado_documento
            doc.show "#{boleto.sacado} - #{boleto.sacado_documento.formata_documento}"
          else
            doc.show boleto.sacado
          end

          # Sacado endereço
          doc.moveto x: colunas[0], y: linhas[7]
          doc.show boleto.sacado_endereco

          # codigo de barras
          # Gerando codigo de barra com rghost_barcode
          doc.barcode_interleaved2of5(boleto.codigo_barras, width: "10.3 cm", height: "1.2 cm", x: colunas[0], y: linhas[8]) if boleto.codigo_barras
        end
      end # Base
    end
  end
end
