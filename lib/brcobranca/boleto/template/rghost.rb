begin
  require 'rghost' 
rescue LoadError
  puts 'Por favor execute `sudo gem install rghost` para usar o brcobranca'
end
begin
  require 'rghost_barcode' 
rescue LoadError
  puts 'Por favor execute `sudo gem install rghost_barcode` para usar o brcobranca'
end

module Brcobranca
  module Boleto
    module Template
      # Templates para usar com Rghost
      module Rghost
        include RGhost unless self.include?(RGhost)
        
        # Gera o boleto em usando o formato desejado [:pdf, :jpg, :tif, :png, :ps, :laserjet, ... etc]
        #  Veja mais formatos na documentação do rghost: http://wiki.github.com/shairontoledo/rghost/supported-devices-drivers-and-formats
        def to(formato)
          modelo_generico(:tipo => formato)
        end
        
        # Responsável por setar os valores necessários no template genérico
        # Retorna um stream pronto para gravaçào
        #
        # O tipo do arquivo gerado pode ser modificado incluindo a configuração a baixo dentro da sua aplicação:
        #  Brcobranca::Config::OPCOES[:tipo] = 'pdf'
        #
        # Ou pode ser passado como paramentro:
        #  :tipo => 'pdf'
        def modelo_generico(options={})
          doc=Document.new :paper => :A4 # 210x297

          template_path = File.join(File.dirname(__FILE__),'..','..','arquivos','templates','modelo_generico.eps')

          raise "Não foi possível encontrar o template. Verifique o caminho" unless File.exist?(template_path)

          doc.define_template(:template, template_path, :x => '0.3 cm', :y => "0 cm")
          doc.use_template :template

          doc.define_tags do
            tag :grande, :size => 13
          end
          
          # Busca logo automaticamente
          logo = monta_logo

          #INICIO Primeira parte do BOLETO
          # LOGOTIPO do BANCO
          doc.image(logo, :x => '0.5 cm', :y => '23.85 cm', :zoom => 80) if logo
          # Dados
          doc.moveto :x => '5.2 cm' , :y => '23.85 cm'
          doc.show "#{self.banco}-#{self.banco_dv}", :tag => :grande
          doc.moveto :x => '7.5 cm' , :y => '23.85 cm'
          doc.show self.codigo_barras.linha_digitavel, :tag => :grande
          doc.moveto :x => '0.7 cm' , :y => '23 cm'
          doc.show self.cedente
          doc.moveto :x => '11 cm' , :y => '23 cm'
          doc.show "#{self.agencia}-#{self.agencia_dv}/#{self.conta_corrente}-#{self.conta_corrente_dv}"
          doc.moveto :x => '14.2 cm' , :y => '23 cm'
          doc.show self.especie
          doc.moveto :x => '15.7 cm' , :y => '23 cm'
          doc.show self.quantidade
          doc.moveto :x => '0.7 cm' , :y => '22.2 cm'
          doc.show self.numero_documento
          doc.moveto :x => '7 cm' , :y => '22.2 cm'
          doc.show "#{self.sacado_documento.formata_documento}"
          doc.moveto :x => '12 cm' , :y => '22.2 cm'
          doc.show self.data_vencimento.to_s_br
          doc.moveto :x => '16.5 cm' , :y => '23 cm'
          doc.show self.nosso_numero
          doc.moveto :x => '16.5 cm' , :y => '22.2 cm'
          doc.show self.valor_documento.to_currency
          doc.moveto :x => '1.4 cm' , :y => '20.9 cm'
          doc.show "#{self.sacado} - #{self.sacado_documento.formata_documento}"
          doc.moveto :x => '1.4 cm' , :y => '20.6 cm'
          doc.show "#{self.sacado_endereco}"
          #FIM Primeira parte do BOLETO

          #INICIO Segunda parte do BOLETO BB
          # LOGOTIPO do BANCO
          doc.image(logo, :x => '0.5 cm', :y => '16.8 cm', :zoom => 80) if logo
          doc.moveto :x => '5.2 cm' , :y => '16.8 cm'
          doc.show "#{self.banco}-#{self.banco_dv}", :tag => :grande if self.banco && self.banco_dv
          doc.moveto :x => '7.5 cm' , :y => '16.8 cm'
          doc.show self.codigo_barras.linha_digitavel, :tag => :grande if self.codigo_barras && self.codigo_barras.linha_digitavel
          doc.moveto :x => '0.7 cm' , :y => '16 cm'
          doc.show self.local_pagamento if self.local_pagamento
          doc.moveto :x => '16.5 cm' , :y => '16 cm'
          doc.show self.data_vencimento.to_s_br if self.data_vencimento
          doc.moveto :x => '0.7 cm' , :y => '15.2 cm'
          doc.show self.cedente if self.cedente
          doc.moveto :x => '16.5 cm' , :y => '15.2 cm'
          doc.show "#{self.agencia}-#{self.agencia_dv}/#{self.conta_corrente}-#{self.conta_corrente_dv}"
          doc.moveto :x => '0.7 cm' , :y => '14.4 cm'
          doc.show self.data_documento.to_s_br if self.data_documento
          doc.moveto :x => '4.2 cm' , :y => '14.4 cm'
          doc.show self.numero_documento if self.numero_documento
          doc.moveto :x => '10 cm' , :y => '14.4 cm'
          doc.show self.especie if self.especie
          doc.moveto :x => '11.7 cm' , :y => '14.4 cm'
          doc.show self.aceite if self.aceite
          doc.moveto :x => '13 cm' , :y => '14.4 cm'
          doc.show self.data_processamento.to_s_br if self.data_processamento
          doc.moveto :x => '16.5 cm' , :y => '14.4 cm'
          doc.show self.nosso_numero
          doc.moveto :x => '4.4 cm' , :y => '13.5 cm'
          doc.show self.carteira if self.carteira
          doc.moveto :x => '6.4 cm' , :y => '13.5 cm'
          doc.show self.moeda if self.moeda
          doc.moveto :x => '8 cm' , :y => '13.5 cm'
          doc.show self.quantidade if self.quantidade
          doc.moveto :x => '11 cm' , :y => '13.5 cm'
          doc.show self.valor.to_currency if self.valor
          doc.moveto :x => '16.5 cm' , :y => '13.5 cm'
          doc.show self.valor_documento.to_currency if self.valor_documento
          doc.moveto :x => '0.7 cm' , :y => '12.7 cm'
          doc.show self.instrucao1 if self.instrucao1
          doc.moveto :x => '0.7 cm' , :y => '12.3 cm'
          doc.show self.instrucao2 if self.instrucao2
          doc.moveto :x => '0.7 cm' , :y => '11.9 cm'
          doc.show self.instrucao3 if self.instrucao3
          doc.moveto :x => '0.7 cm' , :y => '11.5 cm'
          doc.show self.instrucao4 if self.instrucao4
          doc.moveto :x => '0.7 cm' , :y => '11.1 cm'
          doc.show self.instrucao5 if self.instrucao5
          doc.moveto :x => '0.7 cm' , :y => '10.7 cm'
          doc.show self.instrucao6 if self.instrucao6
          doc.moveto :x => '1.2 cm' , :y => '8.8 cm'
          doc.show "#{self.sacado} - #{self.sacado_documento.formata_documento}" if self.sacado && self.sacado_documento
          doc.moveto :x => '1.2 cm' , :y => '8.4 cm'
          doc.show "#{self.sacado_endereco}" if self.sacado_endereco
          #FIM Segunda parte do BOLETO

          #Gerando codigo de barra com rghost_barcode
          doc.barcode_interleaved2of5(self.codigo_barras, :width => '10.3 cm', :height => '1.3 cm', :x => '0.7 cm', :y => '5.8 cm' ) if self.codigo_barras

          # Gerando stream
          unless options[:tipo]
            options[:tipo] = Brcobranca::Config::OPCOES[:tipo]
          end

          options[:tipo] = options[:tipo].to_sym unless options[:tipo].kind_of?(Symbol)
          doc.render_stream(options[:tipo])
        end
      end
    end
  end
end
