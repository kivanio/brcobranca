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
      module RghostBolepix
        extend self
        include RGhost unless include?(RGhost)
        RGhost::Config::GS[:external_encoding] = Brcobranca.configuration.external_encoding
        RGhost::Config::GS[:default_params] << '-dNOSAFER'

        # Gera o boleto em usando o formato desejado [:pdf, :jpg, :tif, :png, :ps, :laserjet, ... etc]
        #
        # @return [Stream]
        # @see http://wiki.github.com/shairontoledo/rghost/supported-devices-drivers-and-formats Veja mais formatos na documentação do rghost.
        # @see Rghost#modelo_generico Recebe os mesmos parâmetros do Rghost#modelo_generico.
        def to(formato, options = {})
          modelo_generico(self, options.merge!(formato: formato))
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
            modelo_generico(self, (args.first || {}).merge!(formato: method[3..]))
          else
            super
          end
        end

        private

        def monta_logotipo(doc, boleto, x, y, scale)
          doc.graphic do |g|
            g.scale(scale, scale)
            fator = 1 / scale
            g.image boleto.logotipo, x: (x * fator), y: (y * fator)
          end
        end

        # Retorna um stream pronto para gravação em arquivo.
        #
        # @return [Stream]
        # @param [Boleto] Instância de uma classe de boleto.
        # @param [Hash] options Opção para a criação do boleto.
        # @option options [Symbol] :resolucao Resolução em pixels.
        # @option options [Symbol] :formato Formato desejado [:pdf, :jpg, :tif, :png, :ps, :laserjet, ... etc]
        def modelo_generico(boleto, options = {})
          doc = Document.new paper: :A4 # 210x297

          template_path = File.join(File.dirname(__FILE__), '..', '..', 'arquivos', 'templates', 'modelo_generico3.eps')

          raise 'Não foi possível encontrar o template. Verifique o caminho' unless File.exist?(template_path)

          modelo_generico_template(doc, boleto, template_path)
          modelo_generico_cabecalho(doc, boleto)

          # Gerando QRCode a partir de um emv
          if boleto.emv
            doc.barcode_qrcode(boleto.emv, width: '4.6 cm',
                                           height: '4.6 cm',
                                           eclevel: 'H',
                                           x: "#{@x - 10.8} cm",
                                           y: "#{@y - 6.9} cm")

            move_more(doc, @x + 10.8, @y - 3.70)
          end

          modelo_generico_rodape(doc, boleto)

          # Gerando codigo de barra com rghost_barcode
          if boleto.codigo_barras
            doc.barcode_interleaved2of5(boleto.codigo_barras, width: '11.3 cm',
                                                              height: '1.3 cm',
                                                              x: "#{@x} cm",
                                                              y: "#{@y - 1.87} cm")
          end

          # Gerando stream
          formato = options.delete(:formato) || Brcobranca.configuration.formato
          resolucao = options.delete(:resolucao) || Brcobranca.configuration.resolucao
          doc.render_stream(formato.to_sym, resolution: resolucao)
        end

        # Define o template a ser usado no boleto
        def modelo_generico_template(doc, _boleto, template_path)
          doc.define_template(:template, template_path, x: '0 cm', y: '0 cm')
          doc.use_template :template

          doc.define_tags do
            tag :menor, size: 8, name: 'Arial', color: '#4B5563'
            tag :menor_bold, size: 8, name: 'Arial-Bold', color: '#4B5563'
            tag :pequeno, size: 10, name: 'Arial', color: '#4B5563'
            tag :pequeno_bold, size: 10, name: 'Arial-Bold', color: '#4B5563'
            tag :grande, size: 12, name: 'Arial', color: '#4B5563'
            tag :grande_bold, size: 12, name: 'Arial-Bold', color: '#4B5563'
            tag :maior, size: 14, name: 'Arial', color: '#4B5563'
            tag :maior_bold, size: 14, name: 'Arial-Bold', color: '#4B5563'
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
          @x = 0
          @y = 0

          move_more(doc, 1.3, 26.0)
          doc.show boleto.sacado, tag: :pequeno_bold

          move_more(doc, 12, 0)
          doc.show 'Descrição:', tag: :menor_bold

          move_more(doc, 0, -0.45)
          doc.show boleto.instrucao1, tag: :menor

          move_more(doc, 0, -0.45)
          doc.show boleto.instrucao2, tag: :menor

          move_more(doc, -12, 0.45)
          doc.show boleto.sacado_documento.formata_documento, tag: :pequeno

          if boleto.sacado_endereco
            move_more(doc, 0, -0.45)
            doc.show boleto.sacado_endereco[:nome_logradouro], tag: :pequeno

            move_more(doc, 0, -0.45)
            doc.show "#{boleto.sacado_endereco[:nome_bairro]} - #{boleto.sacado_endereco[:nome_cidade]}/#{boleto.sacado_endereco[:sigla_UF]}", tag: :pequeno

            move_more(doc, 0, -0.45)
            doc.show boleto.sacado_endereco[:numero_CEP].to_br_cep, tag: :pequeno
          end

          move_more(doc, 1.9, -2.5)
          doc.show "#{boleto.especie} #{boleto.valor_documento.to_currency}", tag: :grande_bold

          move_more(doc, 9.4, 0)
          doc.show boleto.data_vencimento.to_s_br, tag: :grande_bold

          # FIM Primeira parte do BOLETO
        end

        # Monta o corpo e rodapé do layout do boleto
        def modelo_generico_rodape(doc, boleto)
          # INICIO Segunda parte do BOLETO BB
          # Pontos iniciais em x e y
          @x = 0.50
          @y = 12.22

          # LOGOTIPO do BANCO
          monta_logotipo(doc, boleto, 1.4, 11.2, 0.7)

          move_more(doc, 4.4, -0.95)
          doc.show "#{boleto.banco}-#{boleto.banco_dv}", tag: :grande_bold

          move_more(doc, 1.7, 0)
          doc.show boleto.codigo_barras.linha_digitavel, tag: :grande_bold

          move_more(doc, -5.1, -1.2)
          doc.show boleto.local_pagamento, tag: :menor_bold

          move_more(doc, 16.4, -0.2)
          doc.show boleto.data_vencimento.to_s_br, tag: :menor_bold if boleto.data_vencimento

          move_more(doc, -16.37, -0.97)
          doc.show "#{boleto.cedente} (#{boleto.documento_cedente.formata_documento})", tag: :menor_bold

          move_more(doc, 15.95, -0.2)
          doc.show boleto.agencia_conta_boleto, tag: :menor_bold

          move_more(doc, -14.7, -1)
          doc.show boleto.data_documento.to_s_br, tag: :menor_bold if boleto.data_documento

          move_more(doc, 3.65, 0)
          doc.show boleto.documento_numero, tag: :menor_bold

          move_more(doc, 2.4, 0)
          doc.show boleto.especie_documento, tag: :menor_bold

          move_more(doc, 1.9, 0)
          doc.show boleto.aceite, tag: :menor_bold

          move_more(doc, 1.9, 0)
          doc.show boleto.data_processamento.to_s_br, tag: :menor_bold if boleto.data_processamento

          move_more(doc, 4.7, 0)
          doc.show boleto.nosso_numero_boleto, tag: :menor_bold

          move_more(doc, -12.1, -1.1)
          if boleto.variacao
            doc.show "#{boleto.carteira}-#{boleto.variacao}", tag: :menor_bold
          else
            doc.show boleto.carteira, tag: :menor_bold
          end

          move_more(doc, 1.6, 0)
          doc.show boleto.especie, tag: :menor_bold

          move_more(doc, 3.95, 0)
          doc.show boleto.quantidade, tag: :menor_bold

          move_more(doc, 7.55, 0)
          doc.show boleto.valor_documento.to_currency, tag: :menor_bold

          if boleto.instrucoes
            doc.text_area boleto.instrucoes, width: '14 cm',
                                             text_align: :left, x: "#{@x -= 15.8} cm",
                                             y: "#{@y -= 0.9} cm",
                                             row_height: '0.4 cm',
                                             tag: :menor
            move_more(doc, 0, -2)
          else
            move_more(doc, -16.75, -0.7)
            doc.show boleto.instrucao3, tag: :menor

            move_more(doc, 0, -0.45)
            doc.show boleto.instrucao4, tag: :menor

            move_more(doc, 0, -0.45)
            doc.show boleto.instrucao5, tag: :menor

            move_more(doc, 0, -0.45)
            doc.show boleto.instrucao6, tag: :menor
          end

          move_more(doc, 0, -1.25)
          doc.show "#{boleto.sacado} (#{boleto.sacado_documento.formata_documento})", tag: :menor_bold

          if boleto.sacado_endereco
            move_more(doc, 0, -0.3)
            doc.show "#{boleto.sacado_endereco[:nome_logradouro]} - #{boleto.sacado_endereco[:nome_bairro]} - #{boleto.sacado_endereco[:nome_cidade]}/#{boleto.sacado_endereco[:sigla_UF]}, #{boleto.sacado_endereco[:numero_CEP].to_br_cep}", tag: :menor
          end

          # FIM Segunda parte do BOLETO
        end
      end
    end
  end
end
