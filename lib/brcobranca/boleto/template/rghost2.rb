# frozen_string_literal: true

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
        module Rghost2
          extend self
          include RGhost unless include?(RGhost)
          RGhost::Config::GS[:external_encoding] = Brcobranca.configuration.external_encoding
          RGhost::Config::GS[:default_params] << '-dNOSAFER'
          RGhost::Config::GS[:unit]=Units::Cm
  
  
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
            doc = Document.new paper: [21,29.7] # A4
            template_path = File.join(File.dirname(__FILE__), '..', '..', 'arquivos', 'templates', 'modelo_generico2.eps')
            raise 'Não foi possível encontrar o template. Verifique o caminho' unless File.exist?(template_path)
            modelo_recibo_beneficiario(doc, boleto)
            modelo_generico_template(doc, boleto, template_path)
            modelo_generico_cabecalho(doc, boleto)
            modelo_generico_rodape(doc, boleto)
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
            doc = Document.new paper: [21,29.7] # A4
            template_path = File.join(File.dirname(__FILE__), '..', '..', 'arquivos', 'templates', 'modelo_generico2.eps')
            raise 'Não foi possível encontrar o template. Verifique o caminho' unless File.exist?(template_path)
            boletos.each_with_index do |boleto, index|
              modelo_generico_template(doc, boleto, template_path)
              modelo_recibo_beneficiario(doc, boleto)
              modelo_generico_cabecalho(doc, boleto)
              modelo_generico_rodape(doc, boleto)
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
            doc.define_template(:template, template_path, x: '0.732 cm', y: '2.060 cm')
            doc.use_template :template
  
            doc.define_tags do
              tag :menor, name: "LiberationMono", size: 8
              tag :menor_bold, name: "Helvetica-Bold", size: 9
              tag :medio, name: "Helvetica-Bold", size: 12
              tag :maior, name: "Helvetica-Bold", size: 13.5
            end
          end
  
          # Monta Recibo do Beneficiário
          def modelo_recibo_beneficiario(doc, boleto)
            doc.moveto x:  4.28, y: 26.87
            doc.show truncar(boleto.cedente, 90), tag: :menor
            doc.moveto x:  4.28, y: 26.33
            doc.show truncar(boleto.sacado, 90), tag: :menor
            doc.moveto x:  4.28, y: 25.76
            doc.show boleto.documento_numero, tag: :menor
            doc.moveto x:  4.28, y: 25.20
            doc.show boleto.nosso_numero_boleto, tag: :menor
            doc.moveto x:  4.28, y: 24.63
            doc.show boleto.data_vencimento.to_s_br, tag: :menor
            doc.moveto x:  4.28, y: 24.070
            doc.show "#{boleto.banco}-#{boleto.banco_dv}", tag: :menor
            doc.moveto x:  4.28, y: 23.49
            doc.show boleto.agencia_conta_boleto, tag: :menor
            doc.moveto x:  4.28, y: 22.95
            doc.show boleto.valor_documento.to_currency, tag: :menor
          end
  
          # Monta Recibo do Pagador boleto
          def modelo_generico_cabecalho(doc, boleto)
            monta_logotipo(doc, boleto, 0.782, 19.717, 0.85)
            doc.moveto x:  4.813, y: 19.801
            doc.show "#{boleto.banco}-#{boleto.banco_dv}", tag: :medio
            doc.moveto x:  0.823, y: 20.942
            doc.show boleto.codigo_barras.linha_digitavel, tag: :menor_bold
            doc.moveto x:  1.121, y: 18.924
            doc.show truncar(boleto.cedente, 47), tag: :menor
            doc.moveto x:  9.8, y: 18.924
            doc.show boleto.agencia_conta_boleto.tr(' ', ''), tag: :menor
            doc.moveto x:  16.423, y: 18.924
            doc.show boleto.nosso_numero_boleto, tag: :menor
            doc.moveto x:  1.121, y: 17.984
            doc.show boleto.documento_numero, tag: :menor
            doc.moveto x:  12.904, y: 18.924
            doc.show boleto.especie, tag: :menor
            doc.moveto x:  14.139, y: 18.924
            doc.show boleto.quantidade, tag: :menor
            doc.moveto x:  7.0, y: 17.984
            doc.show boleto.documento_cedente.formata_documento.to_s, tag: :menor
            doc.moveto x:  10.602, y: 17.984
            doc.show boleto.data_vencimento.to_s_br, tag: :menor
            doc.text_area "<menor>#{boleto.valor_documento.to_currency}</menor>", width: 5.78, text_align: :right, x:  14.12, y: 17.984, tag: :menor
            doc.moveto x:  1.109, y: 17.089
            doc.show truncar(boleto.sacado, 109), tag: :menor
          end
  
          # Monta o corpo e rodapé do layout do boleto
          def modelo_generico_rodape(doc, boleto)
            monta_logotipo(doc, boleto, 0.782, 13.9, 0.85)
            doc.text_area "<menor>#{boleto.data_vencimento.to_s_br if boleto.data_vencimento}</menor>", width: 5.786, text_align: :center, x: 14.47271, y: 13.11587
            doc.text_area "<menor>#{boleto.agencia_conta_boleto}</menor>", width: 5.786, text_align: :center, x:  14.47271, y: 12.26921
            doc.text_area "<menor>#{boleto.nosso_numero_boleto}</menor>", width: 5.786, text_align: :center, x:  14.47271, y: 11.42254
            doc.text_area "<menor>#{boleto.valor_documento.to_currency}</menor>", width: 5.5, text_align: :right, x:  14.47271, y: 10.56926
            doc.moveto x:  4.813, y: 13.977
            doc.show "#{boleto.banco}-#{boleto.banco_dv}", tag: :medio
            doc.moveto x:  6.815, y: 13.990
            doc.show boleto.codigo_barras.linha_digitavel, tag: :maior
            doc.moveto x:  1.121, y: 13.2
            doc.show boleto.local_pagamento, tag: :menor
            doc.moveto x:  1.121, y: 12.295
            doc.show truncar(boleto.cedente,54), tag: :menor
            doc.moveto x:  11.307, y: 12.295
            doc.show boleto.documento_cedente.formata_documento.to_s, tag: :menor
            doc.moveto x:  1.112, y: 11.42
            doc.show (boleto.data_documento.to_s_br if boleto.data_documento), tag: :menor
            doc.moveto x:  4.268, y: 11.42
            doc.show boleto.documento_numero, tag: :menor
            doc.moveto x: 7.471, y: 11.42
            doc.show boleto.especie_documento, tag: :menor
            doc.moveto x: 9.588, y: 11.42
            doc.show boleto.aceite, tag: :menor
            doc.moveto x: 11.660, y: 11.42
            doc.show (boleto.data_processamento.to_s_br if boleto.data_processamento), tag: :menor
            doc.moveto x: 4.62056, y: 10.56058
            if boleto.variacao
              doc.show "#{boleto.carteira}-#{boleto.variacao}"
            else
              doc.show boleto.carteira
            end
            doc.moveto x: 7.26640, y: 10.56058
            doc.show boleto.especie
            monta_instrucoes(doc, boleto, 0.8, 9.8)
            pagador = "<menor>#{truncar(boleto.sacado,75)} - CPF/CNPJ: #{boleto.sacado_documento.formata_documento}</menor>"
            pagador += "\n<menor>#{boleto.sacado_endereco.to_s}</menor>"
            doc.text_area pagador, width: 18, text_align: :left, x: 2.04611, y: 5.8, row_height: '0.4 cm'
            avalista = "#{boleto.avalista} - #{boleto.avalista_documento}" if boleto.avalista && boleto.avalista_documento
            if avalista
              doc.text_area "<menor>#{truncar(avalista, 59)}</menor>", width: 12.312, text_align: :left, x: 2.04611, y: 4.3, row_height: '0.4 cm'
            end
            # Gerando codigo de barra com rghost_barcode
            if boleto.codigo_barras
              doc.barcode_interleaved2of5(boleto.codigo_barras, width: '10.3 cm', height: '1.3 cm', x: 1.06, y: 2.12)
            end
            # FIM Segunda parte do BOLETO
          end

          def truncar(string, limite)
            if string.length > limite
              string = string[0...limite].upcase + "..."
            end
            string
          end

          def monta_instrucoes(doc, boleto, x, y)
            lista_instrucoes = Array[
              boleto.instrucoes,
              boleto.instrucao1,
              boleto.instrucao2,
              boleto.instrucao3,
              boleto.instrucao4,
              boleto.instrucao5,
              boleto.instrucao6,
            ].reject(&:blank?)
            lista_instrucoes = lista_instrucoes.map { |i| "<menor>#{i}</menor>" }
            texto_instrucoes = lista_instrucoes.join("\n")
            doc.text_area texto_instrucoes, width: 13.547, text_align: :left, x: x, y: y, row_height: '0.4 cm'
          end

          def monta_logotipo(doc, boleto, x, y, scale)
            doc.graphic do |g|
              g.scale(scale, scale)
              fator = 1/scale
              g.image boleto.logotipo, x: (x*fator), y: (y*fator)
            end
          end
        end
      end
    end
  end
  