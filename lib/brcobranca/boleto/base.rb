module Brcobranca
  module Boleto
    class Base
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
      # :tipo, Tipo de saida desejada (PDF, JPG, GIF)
      def to_pdf(options={})
        # Gera efetivamente o stream do boleto
        modelo_generico(:tipo => options[:tipo])
      end

    end
  end
end

