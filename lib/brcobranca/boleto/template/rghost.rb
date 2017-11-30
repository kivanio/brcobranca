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
      module Rghost
        extend self
        include RGhost unless include?(RGhost)
        RGhost::Config::GS[:external_encoding] = Brcobranca.configuration.external_encoding

        # Gera o boleto em usando o formato desejado [:pdf, :jpg, :tif, :png, :ps, :laserjet, ... etc]
        #
        # @return [Stream]
        # @see http://wiki.github.com/shairontoledo/rghost/supported-devices-drivers-and-formats Veja mais formatos na documentação do rghost.
        # @see Rghost#modelo_generico Recebe os mesmos parâmetros do Rghost#modelo_generico.
        def to(formato, options = {})
          modelo_generico(self, options.merge!(formato: formato))
        end

        # Gera o boleto em usando o formato desejado [:pdf, :jpg, :tif, :png, :ps, :laserjet, ... etc]
        #
        # @return [Stream]
        # @see http://wiki.github.com/shairontoledo/rghost/supported-devices-drivers-and-formats Veja mais formatos na documentação do rghost.
        # @see Rghost#modelo_generico Recebe os mesmos parâmetros do Rghost#modelo_generico.
        def lote(boletos, options = {})
          modelo_generico_multipage(boletos, options)
        end

        #  Cria o métodos dinâmicos (to_pdf, to_gif e etc) com todos os fomátos válidos.
        #
        # @return [Stream]
        # @see Rghost#modelo_generico Recebe os mesmos parâmetros do Rghost#modelo_generico.
        # @example
        #  @boleto.to_pdf #=> boleto gerado no formato pdf
        def method_missing(m, *args)
          method = m.to_s
          if method.start_with?('to_')
            modelo_generico(self, (args.first || {}).merge!(formato: method[3..-1]))
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
        def modelo_generico(boleto, options = {})
          doc = Document.new paper: :A4 # 210x297

          template_path = File.join(File.dirname(__FILE__), '..', '..', 'arquivos', 'templates', 'modelo_generico.eps')

          raise 'Não foi possível encontrar o template. Verifique o caminho' unless File.exist?(template_path)

          modelo_generico_template(doc, boleto, template_path)
          modelo_generico_cabecalho(doc, boleto)
          modelo_generico_rodape(doc, boleto)

          # Gerando codigo de barra com rghost_barcode
          doc.barcode_interleaved2of5(boleto.codigo_barras, width: '10.3 cm', height: '1.3 cm', x: "#{@x - 1.7} cm", y: "#{@y - 1.67} cm") if boleto.codigo_barras

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
        def modelo_generico_multipage(boletos, options = {})
          doc = Document.new paper: :A4 # 210x297

          template_path = File.join(File.dirname(__FILE__), '..', '..', 'arquivos', 'templates', 'modelo_generico.eps')

          raise 'Não foi possível encontrar o template. Verifique o caminho' unless File.exist?(template_path)

          boletos.each_with_index do |boleto, index|
            modelo_generico_template(doc, boleto, template_path)
            modelo_generico_cabecalho(doc, boleto)
            modelo_generico_rodape(doc, boleto)

            # Gerando codigo de barra com rghost_barcode
            doc.barcode_interleaved2of5(boleto.codigo_barras, width: '10.3 cm', height: '1.3 cm', x: "#{@x - 1.7} cm", y: "#{@y - 1.67} cm") if boleto.codigo_barras

            # Cria nova página se não for o último boleto
            doc.next_page unless index == boletos.length - 1
          end
          # Gerando stream
          formato = (options.delete(:formato) || Brcobranca.configuration.formato)
          resolucao = (options.delete(:resolucao) || Brcobranca.configuration.resolucao)
          doc.render_stream(formato.to_sym, resolution: resolucao)
        end

        # Define o template a ser usado no boleto
        def modelo_generico_template(doc, _boleto, template_path)
          doc.define_template(:template, template_path, x: '0.5 cm', y: '2.7 cm')
          doc.use_template :template

          doc.define_tags do
            tag :grande, size: 13
            tag :maior, size: 15
          end
        end

        def move_more(doc, x, y)
          @x += x
          @y += y
          doc.moveto x: "#{@x} cm", y: "#{@y} cm"
        end
        # Monta o cabeçalho do layout do boleto
        def modelo_generico_cabecalho(doc, boleto)
          # INICIO Primeira parte do BOLETO
          # Pontos iniciais em x e y
          @x = 0.50
          @y = 27.42
          # LOGOTIPO do BANCO
          doc.image boleto.logotipo, x: "#{@x} cm", y: "#{@y} cm"
          # Dados

          move_more(doc, 4.84, 0.02)
          doc.show "#{boleto.banco}-#{boleto.banco_dv}", tag: :maior
          move_more(doc, 2, 0)
          doc.show boleto.codigo_barras.linha_digitavel, tag: :grande
          move_more(doc, -6.5, -0.83)

          doc.show boleto.cedente

          move_more(doc, 15.8, 0)
          doc.show boleto.agencia_conta_boleto

          move_more(doc, -15.8, -0.9)
          doc.show boleto.cedente_endereco

          move_more(doc, 15.8, 0)
          doc.show boleto.nosso_numero_boleto

          move_more(doc, -15.8, -0.8)
          doc.show boleto.documento_numero

          move_more(doc, 3.5, 0)
          doc.show boleto.especie

          move_more(doc, 1.5, 0)
          doc.show boleto.quantidade

          move_more(doc, 2, 0)
          doc.show "#{boleto.documento_cedente.formata_documento}"

          move_more(doc, 3.8, 0)
          doc.show boleto.data_vencimento.to_s_br

          move_more(doc, 5, 0)
          doc.show boleto.valor_documento.to_currency

          move_more(doc, -15, -1.3)
          doc.show "#{boleto.sacado} - #{boleto.sacado_documento.formata_documento}"

          move_more(doc, 0, -0.3)
          doc.show "#{boleto.sacado_endereco}"
          if boleto.demonstrativo
            doc.text_area boleto.demonstrativo, width: '18.5 cm', text_align: :left, x: "#{@x - 0.8} cm", y: "#{@y - 0.9} cm", row_height: '0.4 cm'
          end
          # FIM Primeira parte do BOLETO
        end

        # Monta o corpo e rodapé do layout do boleto
        def modelo_generico_rodape(doc, boleto)
          # INICIO Segunda parte do BOLETO BB
          # Pontos iniciais em x e y
          @x = 0.50
          @y = 12.22
          # LOGOTIPO do BANCO
          doc.image boleto.logotipo, x: "#{@x} cm", y: "#{@y} cm"

          move_more(doc, 4.84, 0.01)
          doc.show "#{boleto.banco}-#{boleto.banco_dv}", tag: :maior

          move_more(doc, 2, 0)
          doc.show boleto.codigo_barras.linha_digitavel, tag: :grande

          move_more(doc, -6.5, -0.9)
          doc.show boleto.local_pagamento

          move_more(doc, 15.8, 0)
          doc.show boleto.data_vencimento.to_s_br if boleto.data_vencimento

          move_more(doc, -15.8, -0.8)
          if boleto.cedente_endereco
            doc.show boleto.cedente_endereco
            move_more(doc, 1.2, 0.3)
            doc.show boleto.cedente
            move_more(doc, -1.2, -0.3)
          else
            doc.show boleto.cedente
          end

          move_more(doc, 15.8, 0)
          doc.show boleto.agencia_conta_boleto

          move_more(doc, -15.8 , -0.9)
          doc.show boleto.data_documento.to_s_br if boleto.data_documento

          move_more(doc, 3.5, 0)
          doc.show boleto.documento_numero

          move_more(doc, 5.8, 0)
          doc.show boleto.especie_documento

          move_more(doc, 1.7, 0)
          doc.show boleto.aceite

          move_more(doc, 1.3, 0)

          doc.show boleto.data_processamento.to_s_br if boleto.data_processamento

          move_more(doc, 3.5, 0)
          doc.show boleto.nosso_numero_boleto

          move_more(doc, -12.1, -0.8)
          if boleto.variacao
            doc.show "#{boleto.carteira}-#{boleto.variacao}"
          else
            doc.show boleto.carteira
          end

          move_more(doc, 2, 0)
          doc.show boleto.especie

          move_more(doc, 10.1, 0)
          doc.show boleto.valor_documento.to_currency

          if boleto.instrucoes
            doc.text_area boleto.instrucoes, width: '14 cm', text_align: :left, x: "#{@x -= 15.8} cm", y: "#{@y -= 0.9} cm", row_height: '0.4 cm'
            move_more(doc, 0, -2)
          else
            move_more(doc, -15.8, -0.9)
            doc.show boleto.instrucao1

            move_more(doc, 0, -0.4)
            doc.show boleto.instrucao2

            move_more(doc, 0, -0.4)
            doc.show boleto.instrucao3

            move_more(doc, 0, -0.4)
            doc.show boleto.instrucao4

            move_more(doc, 0, -0.4)
            doc.show boleto.instrucao5

            move_more(doc, 0, -0.4)
            doc.show boleto.instrucao6
          end


          move_more(doc, 0.5, -1.9)
          doc.show "#{boleto.sacado} - CPF/CNPJ: #{boleto.sacado_documento.formata_documento}" if boleto.sacado && boleto.sacado_documento

          move_more(doc, 0, -0.4)
          doc.show "#{boleto.sacado_endereco}"

          move_more(doc, 1.2, -0.93)
          if boleto.avalista && boleto.avalista_documento
            doc.show "#{boleto.avalista} - #{boleto.avalista_documento}"
          end
          # FIM Segunda parte do BOLETO
        end
      end # Base
    end
  end
end
