module Brcobranca
  module Boleto
    # Classe base para todas as classes de boletos
    class Base
      # <b>REQUERIDO</b>: Codigo do banco emissor (3 dígitos sempre)
      attr_accessor :banco
      # <b>REQUERIDO</b>: Número do convênio/contrato do cliente junto ao banco emissor
      attr_accessor :convenio
      # <b>REQUERIDO</b>: Tipo de moeda utilizada (Real(R$) e igual a 9)
      attr_accessor :moeda
      # <b>REQUERIDO</b>: Carteira utilizada
      attr_accessor :carteira
      # <b>OPCIONAL</b>: Variacao da carteira(opcional para a maioria dos bancos)
      attr_accessor :variacao
      # <b>OPCIONAL</b>: Data de processamento do boleto, geralmente igual a data_documento
      attr_accessor :data_processamento
      # <b>REQUERIDO</b>: Número de dias a vencer
      attr_accessor :dias_vencimento
      # <b>REQUERIDO</b>: Quantidade de boleto(padrão = 1)
      attr_accessor :quantidade
      # <b>REQUERIDO</b>: Valor do boleto
      attr_accessor :valor
      # <b>REQUERIDO</b>: Número da agencia
      attr_accessor :agencia
      # <b>REQUERIDO</b>: Número da conta corrente
      attr_accessor :conta_corrente
      # <b>REQUERIDO</b>: Nome do proprietario da conta corrente
      attr_accessor :cedente
      # <b>REQUERIDO</b>: Documento do proprietario da conta corrente (CPF ou CNPJ)
      attr_accessor :documento_cedente
      # <b>OPCIONAL</b>: Número sequencial utilizado identificar o boleto
      attr_accessor :numero_documento
      # <b>REQUERIDO</b>: Símbolo da moeda utilizada (R$ no brasil)
      attr_accessor :especie
      # <b>REQUERIDO</b>: Tipo do documento (Geralmente DM que quer dizer Duplicata Mercantil)
      attr_accessor :especie_documento
      # <b>REQUERIDO</b>: Data em que foi emitido o boleto
      attr_accessor :data_documento
      # <b>OPCIONAL</b>: Código utilizado para identificar o tipo de serviço cobrado
      attr_accessor :codigo_servico
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao sacado
      attr_accessor :instrucao1
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao sacado
      attr_accessor :instrucao2
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao sacado
      attr_accessor :instrucao3
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao sacado
      attr_accessor :instrucao4
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao sacado
      attr_accessor :instrucao5
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao sacado
      attr_accessor :instrucao6
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao sacado
      attr_accessor :instrucao7
      # <b>REQUERIDO</b>: Informação sobre onde o sacado podera efetuar o pagamento
      attr_accessor :local_pagamento
      # <b>REQUERIDO</b>: Informa se o banco deve aceitar o boleto após o vencimento ou não( S ou N, quase sempre S)
      attr_accessor :aceite
      # <b>REQUERIDO</b>: Nome da pessoa que receberá o boleto
      attr_accessor :sacado
      # <b>OPCIONAL</b>: Endereco da pessoa que receberá o boleto
      attr_accessor :sacado_endereco
      # <b>REQUERIDO</b>: Documento da pessoa que receberá o boleto
      attr_accessor :sacado_documento

      # Responsável por definir dados iniciais quando se cria uma nova intância da classe Base.
      def initialize(campos={})
        padrao = { :moeda => "9", :data_documento => Date.today, :dias_vencimento => 1, :quantidade => 1,
          :especie_documento => "DM", :especie => "R$", :aceite => "S", :valor => 0.0, 
          :local_pagamento => "QUALQUER BANCO ATÉ O VENCIMENTO"}

          campos = padrao.merge!(campos)

          campos.each do |campo, valor|
            instance_variable_set "@#{campo}", valor if self.respond_to?(campo)
          end

        end

        # Retorna dígito verificador do banco, calculado com modulo11 de 9 para 2
        def banco_dv
          self.banco.modulo11_9to2
        end

        # Retorna dígito verificador da agência, calculado com modulo11 de 9 para 2
        def agencia_dv
          self.agencia.modulo11_9to2
        end

        # Retorna dígito verificador da conta corrente, calculado com modulo11 de 9 para 2
        def conta_corrente_dv
          self.conta_corrente.modulo11_9to2
        end

        # Retorna dígito verificador do nosso número, calculado com modulo11 de 9 para 2
        def nosso_numero_dv
          self.numero_documento.modulo11_9to2
        end

        # Número sequencial utilizado para distinguir os boletos na agência
        def nosso_numero
          self.numero_documento
        end

        # Retorna o valor total do documento: <b>quantidate * valor</b> ou <b>zero(0)</b> caso não consiga efetuar o cálculo.
        def valor_documento
          begin
            self.quantidade * self.valor.to_f
          rescue
            0
          end
        end

        # Retorna data de vencimento baseado na <b>data_documento + dias_vencimento</b> ou <b>false</b> caso não consiga efetuar o cálculo.
        def data_vencimento
          begin
            return false unless self.data_documento.kind_of?(Date)
            (self.data_documento + self.dias_vencimento.to_i)
          rescue
            false
          end
        end

        # Retorna uma String com 44 caracteres representando o codigo de barras do boleto
        def codigo_barras
          codigo = monta_codigo_43_digitos
          return nil unless codigo
          return nil if codigo.size != 43
          codigo_dv = codigo.modulo11_2to9

          "#{codigo[0..3]}#{codigo_dv}#{codigo[4..42]}"
        end

        # Responsável por montar uma String com 43 caracteres que será usado na criação do código de barras
        #  Este metodo precisa ser reescrito para cada classe de boleto a ser criada. 
        def monta_codigo_43_digitos
          "Sobreescreva este método na classe referente ao banco que você esta criando"
        end
      end
    end
  end

