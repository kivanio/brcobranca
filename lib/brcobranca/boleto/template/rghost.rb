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
        include RGhost unless self.include?(RGhost)
        RGhost::Config::GS[:external_encoding] = Brcobranca.configuration.external_encoding

        # Gera o boleto em usando o formato desejado [:pdf, :jpg, :tif, :png, :ps, :laserjet, ... etc]
        #
        # @return [Stream]
        # @see http://wiki.github.com/shairontoledo/rghost/supported-devices-drivers-and-formats Veja mais formatos na documentação do rghost.
        # @see Rghost#modelo_generico Recebe os mesmos parâmetros do Rghost#modelo_generico.
        def to(formato, options={})
          modelo_generico(self, options.merge!({:formato => formato}))
        end

        # Gera o boleto em usando o formato desejado [:pdf, :jpg, :tif, :png, :ps, :laserjet, ... etc]
        #
        # @return [Stream]
        # @see http://wiki.github.com/shairontoledo/rghost/supported-devices-drivers-and-formats Veja mais formatos na documentação do rghost.
        # @see Rghost#modelo_generico Recebe os mesmos parâmetros do Rghost#modelo_generico.
        def lote(boletos, options={})
          modelo_generico_multipage(boletos, options)
        end


        def carne(boletos, options={})
          modelo_generico_carne(boletos, options)
        end

        #  Cria o métodos dinâmicos (to_pdf, to_gif e etc) com todos os fomátos válidos.
        #
        # @return [Stream]
        # @see Rghost#modelo_generico Recebe os mesmos parâmetros do Rghost#modelo_generico.
        # @example
        #  @boleto.to_pdf #=> boleto gerado no formato pdf
        def method_missing(m, *args)
          method = m.to_s
          if method.start_with?("to_")
            modelo_generico(self, (args.first || {}).merge!({:formato => method[3..-1]}))
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
        def modelo_generico(boleto, options={})
          doc=Document.new :paper => :A4 # 210x297

          template_path = File.join(File.dirname(__FILE__),'..','..','arquivos','templates','modelo_generico.eps')

          raise "Não foi possível encontrar o template. Verifique o caminho" unless File.exist?(template_path)

          modelo_generico_template(doc, boleto, template_path)
          modelo_generico_cabecalho(doc, boleto)
          modelo_generico_rodape(doc, boleto)

          #Gerando codigo de barra com rghost_barcode
          doc.barcode_interleaved2of5(boleto.codigo_barras, :width => '10.3 cm', :height => '1.3 cm', :x => '0.7 cm', :y => '5.8 cm' ) if boleto.codigo_barras

          # Gerando stream
          formato = (options.delete(:formato) || Brcobranca.configuration.formato)
          resolucao = (options.delete(:resolucao) || Brcobranca.configuration.resolucao)
          doc.render_stream(formato.to_sym, :resolution => resolucao)
        end

        # Retorna um stream para multiplos boletos pronto para gravação em arquivo.
        #
        # @return [Stream]
        # @param [Array] Instâncias de classes de boleto.
        # @param [Hash] options Opção para a criação do boleto.
        # @option options [Symbol] :resolucao Resolução em pixels.
        # @option options [Symbol] :formato Formato desejado [:pdf, :jpg, :tif, :png, :ps, :laserjet, ... etc]
        def modelo_generico_multipage(boletos, options={})
          doc=Document.new :paper => :A4 # 210x297

          template_path = File.join(File.dirname(__FILE__),'..','..','arquivos','templates','modelo_generico.eps')

          raise "Não foi possível encontrar o template. Verifique o caminho" unless File.exist?(template_path)

          boletos.each_with_index do |boleto, index|

            modelo_generico_template(doc, boleto, template_path)
            modelo_generico_cabecalho(doc, boleto)
            modelo_generico_rodape(doc, boleto)

            #Gerando codigo de barra com rghost_barcode
            doc.barcode_interleaved2of5(boleto.codigo_barras, :width => '10.3 cm', :height => '1.3 cm', :x => '0.7 cm', :y => '5.8 cm' ) if boleto.codigo_barras
            #Cria nova página se não for o último boleto
            doc.next_page unless index == boletos.length-1

          end
          # Gerando stream
          formato = (options.delete(:formato) || Brcobranca.configuration.formato)
          resolucao = (options.delete(:resolucao) || Brcobranca.configuration.resolucao)
          doc.render_stream(formato.to_sym, :resolution => resolucao)
        end

        # Define o template a ser usado no boleto
        def modelo_generico_template(doc, boleto, template_path)
          doc.define_template(:template, template_path, :x => '0.0 cm', :y => "0 cm")
          doc.use_template :template

          doc.define_tags do
            tag :grande, :size => 9
          end

          doc.define_tags do
            tag :pequena, :size => 6
          end
        end



        def modelo_generico_carne(boletos, options={})

          doc=Document.new :paper => :A4 # 210x297

          template_path = File.join(File.dirname(__FILE__),'..','..','arquivos','templates','modelo_carne.eps')

          raise "Não foi possível encontrar o template. Verifique o caminho" unless File.exist?(template_path)

          item = 1
          boletos.each_with_index do |boleto, index|

            case item
            when 1
              modelo_generico_template(doc, boleto, template_path)
              modelo_generico_recibo_item_1(doc, boleto)
              modelo_generico_ficha_item_1(doc, boleto)

              doc.moveto :x => '1.5 cm' , :y => '27.7 cm'
              doc.show "#{index + 1}/#{boletos.length}"
              #Gerando codigo de barra com rghost_barcode
              doc.barcode_interleaved2of5(boleto.codigo_barras, :width => '10.3 cm', :height => '1.0 cm', :x => '6.3 cm', :y => '20.1 cm' ) if boleto.codigo_barras
              item = 2
            when 2
              
              modelo_generico_recibo_item_2(doc, boleto)
              modelo_generico_ficha_item_2(doc, boleto)

              doc.moveto :x => '1.5 cm' , :y => '18 cm'
              doc.show "#{index + 1}/#{boletos.length}"

              #Gerando codigo de barra com rghost_barcode
              doc.barcode_interleaved2of5(boleto.codigo_barras, :width => '10.3 cm', :height => '1.0 cm', :x => '6.3 cm', :y => '10.4 cm' ) if boleto.codigo_barras
              item = 3
            when 3
              
              modelo_generico_recibo_item_3(doc, boleto)
              modelo_generico_ficha_item_3(doc, boleto)

              doc.moveto :x => '1.5 cm' , :y => '8.2 cm'
              doc.show "#{index + 1}/#{boletos.length}"


              #Gerando codigo de barra com rghost_barcode
              doc.barcode_interleaved2of5(boleto.codigo_barras, :width => '10.3 cm', :height => '1.0 cm', :x => '6.3 cm', :y => '0.6 cm' ) if boleto.codigo_barras
              #Cria nova página se não for o último boleto         
              doc.next_page unless index == boletos.length-1
              item = 1
            else

            end            
          end
          # Gerando stream
          formato = (options.delete(:formato) || Brcobranca.configuration.formato)
          resolucao = (options.delete(:resolucao) || Brcobranca.configuration.resolucao)
          doc.render_stream(formato.to_sym, :resolution => resolucao)
          
        end

        # Monta o cabeçalho do layout do boleto
        def modelo_generico_recibo_item_1(doc, boleto)
          #INICIO Primeira parte do BOLETO
          # LOGOTIPO do BANCO
          doc.image(boleto.logotipo, :x => '0.6 cm', :y => '28.35 cm', :zoom => 40)
          # Dados
          doc.moveto :x => '3.44 cm' , :y => '28.36 cm'
          doc.show "#{boleto.banco}-#{boleto.banco_dv}", :tag => :grande
          
          doc.moveto :x => '3.5 cm' , :y => '27.7 cm'
          doc.show boleto.data_vencimento.to_s_br

          doc.moveto :x => '1.5 cm' , :y => '27.05 cm'
          doc.show boleto.agencia_conta_boleto
          
          doc.moveto :x => '1.5 cm' , :y => '26.4 cm'
          doc.show boleto.nosso_numero_boleto
          
          doc.moveto :x => '1.5 cm' , :y => '25.75 cm'
          doc.show boleto.numero_documento

          doc.moveto :x => '1.5 cm' , :y => '25.1 cm'
          doc.show boleto.especie
          
          doc.moveto :x => '4 cm' , :y => '25.1 cm'
          doc.show boleto.quantidade
          
          doc.moveto :x => '1.5 cm' , :y => '24.45 cm'
          doc.show boleto.valor_documento.to_currency

             
          
          doc.moveto :x => '1.4 cm' , :y => '20.6 cm'
          doc.show "#{boleto.sacado}", :tag => :pequena
          
          

          doc.moveto :x => '1.4 cm' , :y => '20.2 cm'
          doc.show boleto.cedente, :tag => :pequena
          #FIM Primeira parte do BOLETO
        end

        # Monta o corpo e rodapé do layout do boleto
        def modelo_generico_ficha_item_1(doc, boleto)
          #INICIO Segunda parte do BOLETO BB
          # LOGOTIPO do BANCO
          doc.image(boleto.logotipo, :x => '6.45 cm', :y => '28.4 cm', :zoom => 40)
          doc.moveto :x => '9.25 cm' , :y => '28.45 cm'
          doc.show "#{boleto.banco}-#{boleto.banco_dv}", :tag => :grande
          doc.moveto :x => '11.45 cm' , :y => '28.45 cm'
          doc.show boleto.codigo_barras.linha_digitavel, :tag => :grande
          doc.moveto :x => '6.45 cm' , :y => '27.80 cm'
          doc.show boleto.local_pagamento
          doc.moveto :x => '17.45 cm' , :y => '27.80 cm'
          doc.show boleto.data_vencimento.to_s_br if boleto.data_vencimento
          doc.moveto :x => '6.45 cm' , :y => '27.15 cm'
          doc.show boleto.cedente
          doc.moveto :x => '17.45 cm' , :y => '27.15 cm'
          doc.show boleto.agencia_conta_boleto
          doc.moveto :x => '6.45 cm' , :y => '26.50 cm'
          doc.show boleto.data_documento.to_s_br if boleto.data_documento
          doc.moveto :x => '8.45 cm' , :y => '26.50 cm'
          doc.show boleto.numero_documento, :tag => :pequena
          doc.moveto :x => '10.45 cm' , :y => '26.50 cm'
          doc.show boleto.especie
          doc.moveto :x => '12.45 cm' , :y => '26.50 cm'
          doc.show boleto.aceite
          doc.moveto :x => '14.45 cm' , :y => '26.50 cm'
          doc.show boleto.data_processamento.to_s_br if boleto.data_processamento
          doc.moveto :x => '17.45 cm' , :y => '26.50 cm'
          doc.show boleto.nosso_numero_boleto
          doc.moveto :x => '8.45 cm' , :y => '25.75 cm'
          doc.show boleto.carteira
          doc.moveto :x => '10.45 cm' , :y => '25.75 cm'
          doc.show boleto.moeda
          doc.moveto :x => '12.45 cm' , :y => '25.75 cm'
          doc.show boleto.quantidade
          doc.moveto :x => '14.45 cm' , :y => '25.75 cm'
          doc.show boleto.valor.to_currency
          doc.moveto :x => '17.45 cm' , :y => '25.75 cm'
          doc.show boleto.valor_documento.to_currency
          doc.moveto :x => '6.45 cm' , :y => '25.00 cm'
          doc.show boleto.instrucao1
          doc.moveto :x => '6.45 cm' , :y => '24.60 cm'
          doc.show boleto.instrucao2
          doc.moveto :x => '6.45 cm' , :y => '24.20 cm'
          doc.show boleto.instrucao3
          doc.moveto :x => '6.45 cm' , :y => '23.80 cm'
          doc.show boleto.instrucao4
          doc.moveto :x => '6.45 cm' , :y => '23.40 cm'
          doc.show boleto.instrucao5
          doc.moveto :x => '6.45 cm' , :y => '23.10 cm'
          doc.show boleto.instrucao6
          doc.moveto :x => '6.45 cm' , :y => '22.40 cm'
          doc.show "#{boleto.sacado} - #{boleto.sacado_documento.formata_documento}" if boleto.sacado && boleto.sacado_documento
          doc.moveto :x => '6.45 cm' , :y => '22.05 cm'
          doc.show "#{boleto.sacado_endereco}"
          #FIM Segunda parte do BOLETO
        end


        # Monta o cabeçalho do layout do boleto
        def modelo_generico_recibo_item_2(doc, boleto)
           #INICIO Primeira parte do BOLETO
          # LOGOTIPO do BANCO
          doc.image(boleto.logotipo, :x => '0.6 cm', :y => '18.60 cm', :zoom => 40)
          # Dados
          doc.moveto :x => '3.44 cm' , :y => '18.60 cm'
          doc.show "#{boleto.banco}-#{boleto.banco_dv}", :tag => :grande
          
          doc.moveto :x => '3.5 cm' , :y => '18.0 cm'
          doc.show boleto.data_vencimento.to_s_br

          doc.moveto :x => '1.5 cm' , :y => '17.30 cm'
          doc.show boleto.agencia_conta_boleto
          
          doc.moveto :x => '1.5 cm' , :y => '16.7 cm'
          doc.show boleto.nosso_numero_boleto
          
          doc.moveto :x => '1.5 cm' , :y => '16.00 cm'
          doc.show boleto.numero_documento

          doc.moveto :x => '1.5 cm' , :y => '15.3 cm'
          doc.show boleto.especie
          
          doc.moveto :x => '4 cm' , :y => '15.33 cm'
          doc.show boleto.quantidade
          
          doc.moveto :x => '1.5 cm' , :y => '14.67 cm'
          doc.show boleto.valor_documento.to_currency

             
          
          doc.moveto :x => '1.4 cm' , :y => '10.80 cm'
          doc.show "#{boleto.sacado}", :tag => :pequena
          
          

          doc.moveto :x => '1.4 cm' , :y => '10.48 cm'
          doc.show boleto.cedente, :tag => :pequena
          #FIM Primeira parte do BOLETO
        end

        # Monta o corpo e rodapé do layout do boleto
        def modelo_generico_ficha_item_2(doc, boleto)
          #INICIO Segunda parte do BOLETO BB
          # LOGOTIPO do BANCO
          doc.image(boleto.logotipo, :x => '6.45 cm', :y => '18.7 cm', :zoom => 40)
          
          doc.moveto :x => '9.25 cm' , :y => '18.70 cm'
          doc.show "#{boleto.banco}-#{boleto.banco_dv}", :tag => :grande
          doc.moveto :x => '11.45 cm' , :y => '18.70 cm'
          doc.show boleto.codigo_barras.linha_digitavel, :tag => :grande
          doc.moveto :x => '6.45 cm' , :y => '18.05 cm'
          doc.show boleto.local_pagamento
          doc.moveto :x => '17.45 cm' , :y => '18.05 cm'
          doc.show boleto.data_vencimento.to_s_br if boleto.data_vencimento
          doc.moveto :x => '6.45 cm' , :y => '17.35 cm'
          doc.show boleto.cedente
          doc.moveto :x => '17.45 cm' , :y => '17.35 cm'
          doc.show boleto.agencia_conta_boleto
          doc.moveto :x => '6.45 cm' , :y => '16.65 cm'
          doc.show boleto.data_documento.to_s_br if boleto.data_documento
          doc.moveto :x => '8.45 cm' , :y => '16.65 cm'
          doc.show boleto.numero_documento, :tag => :pequena
          doc.moveto :x => '10.45 cm' , :y => '16.65 cm'
          doc.show boleto.especie
          doc.moveto :x => '12.45 cm' , :y => '16.65 cm'
          doc.show boleto.aceite
          doc.moveto :x => '14.45 cm' , :y => '16.65 cm'
          doc.show boleto.data_processamento.to_s_br if boleto.data_processamento
          doc.moveto :x => '17.45 cm' , :y => '16.65 cm'
          doc.show boleto.nosso_numero_boleto
          doc.moveto :x => '8.45 cm' , :y => '15.95 cm'
          doc.show boleto.carteira
          doc.moveto :x => '10.45 cm' , :y => '15.95 cm'
          doc.show boleto.moeda
          doc.moveto :x => '12.45 cm' , :y => '15.95 cm'
          doc.show boleto.quantidade
          doc.moveto :x => '14.45 cm' , :y => '15.95 cm'
          doc.show boleto.valor.to_currency
          doc.moveto :x => '17.45 cm' , :y => '15.95 cm'
          doc.show boleto.valor_documento.to_currency
          doc.moveto :x => '6.45 cm' , :y => '15.20 cm'
          doc.show boleto.instrucao1
          doc.moveto :x => '6.45 cm' , :y => '14.80 cm'
          doc.show boleto.instrucao2
          doc.moveto :x => '6.45 cm' , :y => '14.40 cm'
          doc.show boleto.instrucao3
          doc.moveto :x => '6.45 cm' , :y => '14.00 cm'
          doc.show boleto.instrucao4
          doc.moveto :x => '6.45 cm' , :y => '13.60 cm'
          doc.show boleto.instrucao5
          doc.moveto :x => '6.45 cm' , :y => '13.20 cm'
          doc.show boleto.instrucao6
          doc.moveto :x => '6.45 cm' , :y => '12.65 cm'
          doc.show "#{boleto.sacado} - #{boleto.sacado_documento.formata_documento}" if boleto.sacado && boleto.sacado_documento
          doc.moveto :x => '6.45 cm' , :y => '12.30 cm'
          doc.show "#{boleto.sacado_endereco}"
          #FIM Segunda parte do BOLETO
        end

        # Monta o cabeçalho do layout do boleto
        def modelo_generico_recibo_item_3(doc, boleto)
          #INICIO Primeira parte do BOLETO
          # LOGOTIPO do BANCO
          doc.image(boleto.logotipo, :x => '0.6 cm', :y => '8.85 cm', :zoom => 40)
          #Dados         
          doc.moveto :x => '3.44 cm' , :y => '8.85 cm'
          doc.show "#{boleto.banco}-#{boleto.banco_dv}", :tag => :grande
          
          doc.moveto :x => '3.5 cm' , :y => '8.25 cm'
          doc.show boleto.data_vencimento.to_s_br

          doc.moveto :x => '1.5 cm' , :y => '7.55 cm'
          doc.show boleto.agencia_conta_boleto
          
          doc.moveto :x => '1.5 cm' , :y => '6.95 cm'
          doc.show boleto.nosso_numero_boleto
          
          doc.moveto :x => '1.5 cm' , :y => '6.25 cm'
          doc.show boleto.numero_documento

          doc.moveto :x => '1.5 cm' , :y => '5.55 cm'
          doc.show boleto.especie
          
          doc.moveto :x => '4 cm' , :y => '5.55 cm'
          doc.show boleto.quantidade
          
          doc.moveto :x => '1.5 cm' , :y => '4.90 cm'
          doc.show boleto.valor_documento.to_currency

             
          
          doc.moveto :x => '1.4 cm' , :y => '1.05 cm'
          doc.show "#{boleto.sacado}", :tag => :pequena
          
          

          doc.moveto :x => '1.4 cm' , :y => '0.70 cm'
          doc.show boleto.cedente, :tag => :pequena
          #FIM Primeira parte do BOLETO
        end

        # Monta o corpo e rodapé do layout do boleto
        def modelo_generico_ficha_item_3(doc, boleto)
           doc.image(boleto.logotipo, :x => '6.45 cm', :y => '8.90 cm', :zoom => 40)
          
          doc.moveto :x => '9.25 cm' , :y => '8.90 cm'
          doc.show "#{boleto.banco}-#{boleto.banco_dv}", :tag => :grande
          doc.moveto :x => '11.45 cm' , :y => '8.90 cm'
          doc.show boleto.codigo_barras.linha_digitavel, :tag => :grande
          doc.moveto :x => '6.45 cm' , :y => '8.25 cm'
          doc.show boleto.local_pagamento
          doc.moveto :x => '17.45 cm' , :y => '8.25 cm'
          doc.show boleto.data_vencimento.to_s_br if boleto.data_vencimento
          doc.moveto :x => '6.45 cm' , :y => '7.60 cm'
          doc.show boleto.cedente
          doc.moveto :x => '17.45 cm' , :y => '7.60 cm'
          doc.show boleto.agencia_conta_boleto
          doc.moveto :x => '6.45 cm' , :y => '6.95 cm'
          doc.show boleto.data_documento.to_s_br if boleto.data_documento
          doc.moveto :x => '8.45 cm' , :y => '6.95 cm'
          doc.show boleto.numero_documento, :tag => :pequena
          doc.moveto :x => '10.45 cm' , :y => '6.95 cm'
          doc.show boleto.especie
          doc.moveto :x => '12.45 cm' , :y => '6.95 cm'
          doc.show boleto.aceite
          doc.moveto :x => '14.45 cm' , :y => '6.95 cm'
          doc.show boleto.data_processamento.to_s_br if boleto.data_processamento
          doc.moveto :x => '17.45 cm' , :y => '6.95 cm'
          doc.show boleto.nosso_numero_boleto
          doc.moveto :x => '8.45 cm' , :y => '6.20 cm'
          doc.show boleto.carteira
          doc.moveto :x => '10.45 cm' , :y => '6.20 cm'
          doc.show boleto.moeda
          doc.moveto :x => '12.45 cm' , :y => '6.20 cm'
          doc.show boleto.quantidade
          doc.moveto :x => '14.45 cm' , :y => '6.20 cm'
          doc.show boleto.valor.to_currency
          doc.moveto :x => '17.45 cm' , :y => '6.20 cm'
          doc.show boleto.valor_documento.to_currency
          doc.moveto :x => '6.45 cm' , :y => '5.45 cm'
          doc.show boleto.instrucao1
          doc.moveto :x => '6.45 cm' , :y => '5.05 cm'
          doc.show boleto.instrucao2
          doc.moveto :x => '6.45 cm' , :y => '4.65 cm'
          doc.show boleto.instrucao3
          doc.moveto :x => '6.45 cm' , :y => '4.25 cm'
          doc.show boleto.instrucao4
          doc.moveto :x => '6.45 cm' , :y => '3.85 cm'
          doc.show boleto.instrucao5
          doc.moveto :x => '6.45 cm' , :y => '3.45 cm'
          doc.show boleto.instrucao6
          doc.moveto :x => '6.45 cm' , :y => '2.90 cm'
          doc.show "#{boleto.sacado} - #{boleto.sacado_documento.formata_documento}" if boleto.sacado && boleto.sacado_documento
          doc.moveto :x => '6.45 cm' , :y => '2.55 cm'
          doc.show "#{boleto.sacado_endereco}"
          #FIM Segunda parte do BOLETO
        end






        # Monta o cabeçalho do layout do boleto
        def modelo_generico_cabecalho(doc, boleto)
          #INICIO Primeira parte do BOLETO
          # LOGOTIPO do BANCO
          doc.image(boleto.logotipo, :x => '0.5 cm', :y => '23.85 cm', :zoom => 80)
          # Dados
          doc.moveto :x => '5.2 cm' , :y => '23.85 cm'
          doc.show "#{boleto.banco}-#{boleto.banco_dv}", :tag => :grande
          doc.moveto :x => '7.5 cm' , :y => '23.85 cm'
          doc.show boleto.codigo_barras.linha_digitavel, :tag => :grande
          doc.moveto :x => '0.7 cm' , :y => '23 cm'
          doc.show boleto.cedente
          doc.moveto :x => '11 cm' , :y => '23 cm'
          doc.show boleto.agencia_conta_boleto
          doc.moveto :x => '14.2 cm' , :y => '23 cm'
          doc.show boleto.especie
          doc.moveto :x => '15.7 cm' , :y => '23 cm'
          doc.show boleto.quantidade
          doc.moveto :x => '0.7 cm' , :y => '22.2 cm'
          doc.show boleto.numero_documento
          doc.moveto :x => '7 cm' , :y => '22.2 cm'
          doc.show "#{boleto.documento_cedente.formata_documento}"
          doc.moveto :x => '12 cm' , :y => '22.2 cm'
          doc.show boleto.data_vencimento.to_s_br
          doc.moveto :x => '16.5 cm' , :y => '23 cm'
          doc.show boleto.nosso_numero_boleto
          doc.moveto :x => '16.5 cm' , :y => '22.2 cm'
          doc.show boleto.valor_documento.to_currency
          doc.moveto :x => '1.4 cm' , :y => '20.9 cm'
          doc.show "#{boleto.sacado} - #{boleto.sacado_documento.formata_documento}"
          doc.moveto :x => '1.4 cm' , :y => '20.6 cm'
          doc.show "#{boleto.sacado_endereco}"
          #FIM Primeira parte do BOLETO
        end

        # Monta o corpo e rodapé do layout do boleto
        def modelo_generico_rodape(doc, boleto)
          #INICIO Segunda parte do BOLETO BB
          # LOGOTIPO do BANCO
          doc.image(boleto.logotipo, :x => '0.5 cm', :y => '16.8 cm', :zoom => 80)
          doc.moveto :x => '5.2 cm' , :y => '16.8 cm'
          doc.show "#{boleto.banco}-#{boleto.banco_dv}", :tag => :grande
          doc.moveto :x => '7.5 cm' , :y => '16.8 cm'
          doc.show boleto.codigo_barras.linha_digitavel, :tag => :grande
          doc.moveto :x => '0.7 cm' , :y => '16 cm'
          doc.show boleto.local_pagamento
          doc.moveto :x => '16.5 cm' , :y => '16 cm'
          doc.show boleto.data_vencimento.to_s_br if boleto.data_vencimento
          doc.moveto :x => '0.7 cm' , :y => '15.2 cm'
          doc.show boleto.cedente
          doc.moveto :x => '16.5 cm' , :y => '15.2 cm'
          doc.show boleto.agencia_conta_boleto
          doc.moveto :x => '0.7 cm' , :y => '14.4 cm'
          doc.show boleto.data_documento.to_s_br if boleto.data_documento
          doc.moveto :x => '4.2 cm' , :y => '14.4 cm'
          doc.show boleto.numero_documento
          doc.moveto :x => '10 cm' , :y => '14.4 cm'
          doc.show boleto.especie
          doc.moveto :x => '11.7 cm' , :y => '14.4 cm'
          doc.show boleto.aceite
          doc.moveto :x => '13 cm' , :y => '14.4 cm'
          doc.show boleto.data_processamento.to_s_br if boleto.data_processamento
          doc.moveto :x => '16.5 cm' , :y => '14.4 cm'
          doc.show boleto.nosso_numero_boleto
          doc.moveto :x => '4.4 cm' , :y => '13.5 cm'
          doc.show boleto.carteira
          doc.moveto :x => '6.4 cm' , :y => '13.5 cm'
          doc.show boleto.moeda
          doc.moveto :x => '8 cm' , :y => '13.5 cm'
          doc.show boleto.quantidade
          doc.moveto :x => '11 cm' , :y => '13.5 cm'
          doc.show boleto.valor.to_currency
          doc.moveto :x => '16.5 cm' , :y => '13.5 cm'
          doc.show boleto.valor_documento.to_currency
          doc.moveto :x => '0.7 cm' , :y => '12.7 cm'
          doc.show boleto.instrucao1
          doc.moveto :x => '0.7 cm' , :y => '12.3 cm'
          doc.show boleto.instrucao2
          doc.moveto :x => '0.7 cm' , :y => '11.9 cm'
          doc.show boleto.instrucao3
          doc.moveto :x => '0.7 cm' , :y => '11.5 cm'
          doc.show boleto.instrucao4
          doc.moveto :x => '0.7 cm' , :y => '11.1 cm'
          doc.show boleto.instrucao5
          doc.moveto :x => '0.7 cm' , :y => '10.7 cm'
          doc.show boleto.instrucao6
          doc.moveto :x => '1.2 cm' , :y => '8.8 cm'
          doc.show "#{boleto.sacado} - #{boleto.sacado_documento.formata_documento}" if boleto.sacado && boleto.sacado_documento
          doc.moveto :x => '1.2 cm' , :y => '8.4 cm'
          doc.show "#{boleto.sacado_endereco}"
          #FIM Segunda parte do BOLETO
        end

      end #Base
    end
  end
end

