module Brcobranca
  module Boleto
    class Base

      if Brcobranca::Config::OPCOES[:gerador_pdf] == 'rghost'
        # necessario para gerar codigo de barras
        include RGhost unless self.include?(RGhost)
      end
      # Codigo do banco emissor (3 digitos sempre)
      attr_accessor :banco
      # Numero do convenio/contrato do cliente junto ao banco emissor
      attr_accessor :convenio
      # Tipo de moeda utilizada (Real(R$) e igual a 9)
      attr_accessor :moeda
      # Carteira utilizada
      attr_accessor :carteira
      # Variacao da carteira(opcional para a maioria dos bancos)
      attr_accessor :variacao
      # Data de processamento do boleto, geralmente igual a data_documento
      attr_accessor :data_processamento
      # Numero de dias a vencer
      attr_accessor :dias_vencimento
      # Quantidade de boleto(Quase sempre igual a 1)
      attr_accessor :quantidade
      # Valor do boleto
      attr_accessor :valor
      # Numero sequencial utilizado para distinguir os boletos
      attr_accessor :nosso_numero
      # Numero da agencia
      attr_accessor :agencia
      # Numero da conta corrente
      attr_accessor :conta_corrente
      # Nome do proprietario da conta corrente
      attr_accessor :cedente
      # Documento do proprietario da conta corrente (CPF ou CNPJ)
      attr_accessor :documento_cedente
      # Numero sequencial utilizado para protesto em carteiras registradas
      attr_accessor :numero_documento
      # Simbolo da moeda utilizada (R$ no brasil)
      attr_accessor :especie
      # Tipo do documento (Geralmente DM que quer dizer Duplicata Mercantil)
      attr_accessor :especie_documento
      # Data em que foi emitido o boleto
      attr_accessor :data_documento
      # Codigo utilizado para identificar o tipo de servico cobrado
      attr_accessor :codigo_servico
      # Utilizado para mostrar alguma informacao ao sacado
      attr_accessor :instrucao1
      # Utilizado para mostrar alguma informacao ao sacado
      attr_accessor :instrucao2
      # Utilizado para mostrar alguma informacao ao sacado
      attr_accessor :instrucao3
      # Utilizado para mostrar alguma informacao ao sacado
      attr_accessor :instrucao4
      # Utilizado para mostrar alguma informacao ao sacado
      attr_accessor :instrucao5
      # Utilizado para mostrar alguma informacao ao sacado
      attr_accessor :instrucao6
      # Utilizado para mostrar alguma informacao ao sacado
      attr_accessor :instrucao7
      # Informacao sobre onde o sacado podera efetuar o pagamento
      attr_accessor :local_pagamento
      # Informa se o banco deve aceitar o boleto apos o vencimento ou nao( S ou N, quase sempre S)
      attr_accessor :aceite
      # Nome da pessoa que recebera o boleto
      attr_accessor :sacado
      # Endereco da pessoa que recebera o boleto
      attr_accessor :sacado_endereco
      # Documento da pessoa que recebera o boleto
      attr_accessor :sacado_documento

      # Responsavel por definir dados iniciais quando se cria uma nova intancia da classe Base
      def initialize
        self.especie_documento = "DM"
        self.especie = "R$"
        self.moeda = "9"
        self.data_documento = Date.today
        self.dias_vencimento = 1
        self.aceite = "N"
        self.quantidade = 1
        self.valor = 0.0
        self.local_pagamento = "QUALQUER BANCO ATÉ O VENCIMENTO"
      end

      # Retorna digito verificador do banco, calculado com modulo11 de 9 para 2
      def banco_dv
        self.banco.modulo11_9to2
      end

      # Retorna digito verificador da agencia, calculado com modulo11 de 9 para 2
      def agencia_dv
        self.agencia.modulo11_9to2
      end

      # Retorna digito verificador da conta corrente, calculado com modulo11 de 9 para 2
      def conta_corrente_dv
        self.conta_corrente.modulo11_9to2
      end

      # Retorna digito verificador do nosso numero, calculado com modulo11 de 9 para 2
      def nosso_numero_dv
        self.nosso_numero.modulo11_9to2
      end

      # Retorna o valor total do documento:
      # quantidate * valor
      def valor_documento
        self.quantidade * self.valor.to_f
      end
      
      # Retorna data de vencimento baseado na data_documento + dias_vencimento
      def data_vencimento
        (self.data_documento + self.dias_vencimento.to_i)
      end

      # Retorna uma String com 44 caracteres representando o codigo de barras do boleto
      def codigo_barras
        codigo = monta_codigo_43_digitos
        return nil unless codigo
        return nil if codigo.size != 43
        codigo_dv = codigo.modulo11_2to9

        "#{codigo[0..3]}#{codigo_dv}#{codigo[4..42]}"
      end

      # Responsavel por montar uma String com 43 caracteres que será usado na criacao do codigo de barras
      # Este metodo precisa ser reescrito para cada classe de boleto a ser criada 
      def monta_codigo_43_digitos
        "Sobreescreva este método na classe referente ao banco que você esta criando"
      end

      # Gera o boleto em pdf usando template padrão
      # Opcoes disponiveis:
      # :template => 'public/boleto.eps' definir um novo template
      # :render, Tipo de saida desejada (PDF, JPG, GIF)
      def to_pdf(options={})

        if options[:template]
          template = options[:template] 
        else
          template = File.join(File.dirname(__FILE__),'..',File::SEPARATOR,'templates',File::SEPARATOR,'boleto_generico.eps')
        end

        if options[:render]
          saida = options[:render]
        else
          saida = Brcobranca::Config::OPCOES[:render]
        end

        # Busca logo automaticamente
        logo = monta_logo
        # Gera efetivamente o stream do boleto
        modelo_generico(template,logo,saida)
      end

      # Responsavel por setar os valores necessarios no template padrao
      # Retorna um stream pronto para gravacao
      def modelo_generico(template,logo,saida)
        doc=Document.new :paper => :A4 # 210x297

        if template
          raise "Não foi possível encontrar o template. Verifique o caminho" unless File.exist?(template)
          doc.define_template(:template, template, :x => '0.3 cm', :y => "0 cm")
          doc.use_template :template
        end

        doc.define_tags do
          tag :grande, :size => 13
        end

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
        doc.show "#{self.convenio}#{self.nosso_numero}-#{self.nosso_numero_dv}"
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
        doc.show "#{self.convenio}#{self.nosso_numero}-#{self.nosso_numero_dv}" if self.convenio && self.nosso_numero && self.nosso_numero_dv
        doc.moveto :x => '4.7 cm' , :y => '13.5 cm'
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
        saida = saida.kind_of?(Symbol) ? saida : saida.to_sym
        doc.render_stream(saida)
      end

      # Responsavel por definir a logotipo usada no template padrao
      # retorna o caminho para o logotipo ou false caso nao consiga encontrar o logotipo
      def monta_logo
        case self.class.to_s
        when "BancoBrasil"
          logo = File.join(File.dirname(__FILE__),'..',File::SEPARATOR,'logo',File::SEPARATOR,'bb.jpg')
          logo
        when "Itau"
          logo = File.join(File.dirname(__FILE__),'..',File::SEPARATOR,'logo',File::SEPARATOR,'itau.jpg')
          logo
        else
          false
        end
      end

    end
  end
end

