# -*- encoding: utf-8 -*-
# @author Kivanio Barbosa
module Brcobranca
  module Boleto
    # Classe base para todas as classes de boletos
    class Base
      include ActiveModel::Validations

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
      # <b>REQUERIDO</b>: Número da agencia sem <b>Digito Verificador</b>
      attr_accessor :agencia
      # <b>REQUERIDO</b>: Número da conta corrente sem <b>Digito Verificador</b>
      attr_accessor :conta_corrente
      # <b>REQUERIDO</b>: Nome do proprietario da conta corrente
      attr_accessor :cedente
      # <b>REQUERIDO</b>: Documento do proprietario da conta corrente (CPF ou CNPJ)
      attr_accessor :documento_cedente
      # <b>OPCIONAL</b>: Número sequencial utilizado para identificar o boleto
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

      # Validações
      validates_presence_of :agencia, :conta_corrente, :numero_documento, :message => "não pode estar em branco."
      validates_numericality_of :convenio, :agencia, :conta_corrente, :numero_documento, :message => "não é um número."

      # Nova instancia da classe Base
      # @param [Hash] campos usados na criação do boleto.
      def initialize(campos={})
        padrao = {
          :moeda => "9", :data_documento => Date.today, :dias_vencimento => 1, :quantidade => 1,
          :especie_documento => "DM", :especie => "R$", :aceite => "S", :valor => 0.0,
          :local_pagamento => "QUALQUER BANCO ATÉ O VENCIMENTO"
        }

        campos = padrao.merge!(campos)
        campos.each do |campo, valor|
          send "#{campo}=", valor
        end

        yield self if block_given?

        template_config
      end

      # Responsável por definir a logotipo usada no template genérico,
      # retorna o caminho para o <b>logotipo</b> ou <b>false</b> caso nao consiga encontrar o logotipo.
      def logotipo
        File.join(File.dirname(__FILE__),'..','arquivos','logos',"#{class_name}.jpg")
      end

      # Retorna dígito verificador do banco, calculado com modulo11 de 9 para 2
      def banco_dv
        self.banco.modulo11_9to2
      end

      # Retorna código da agencia formatado com zeros a esquerda.
      def agencia=(valor)
        @agencia = valor.to_s.rjust(4,'0') unless valor.nil?
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

      # Campo usado apenas na exibição no boleto
      #  Deverá ser sobreescrito para cada banco
      def nosso_numero_boleto
        raise NaoImplementado.new("Sobreescreva este método na classe referente ao banco que você esta criando")
      end

      # Campo usado apenas na exibição no boleto
      #  Deverá ser sobreescrito para cada banco
      def agencia_conta_boleto
        raise NaoImplementado.new("Sobreescreva este método na classe referente ao banco que você esta criando")
      end

      # Retorna o valor total do documento: <b>quantidate * valor</b> ou <b>zero(0)</b> caso não consiga efetuar o cálculo.
      def valor_documento
        self.quantidade.to_f * self.valor.to_f
      end

      # Retorna o valor total do documento formatado, sem milhar, centena e com zeros a esquerda
      def valor_documento_formatado
        self.valor_documento.limpa_valor_moeda.to_s.rjust(10,'0')
      end

      # Retorna data de vencimento baseado na <b>data_documento + dias_vencimento</b> ou <b>false</b> caso não consiga efetuar o cálculo.
      def data_vencimento
        raise ArgumentError, "data_documento não pode estar em branco." unless self.data_documento
        return self.data_documento unless self.dias_vencimento
        (self.data_documento + self.dias_vencimento.to_i)
      end

      # Retorna o fator de vencimento calculado com base na data de vencimento
      def fator_vencimento
        self.data_vencimento.fator_vencimento
      end

      # Retorna número da conta corrente formatado
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(7,'0') unless valor.nil?
      end

      # Codigo de barras do boleto
      #
      #   O codigo de barra para cobrança contém 44 posições dispostas da seguinte forma:
      #   Posição Tamanho Conteúdo
      #   01 a 03   3       Identificação do Banco
      #   04 a 04   1       Código da Moeda (Real = 9, Outras=0)
      #   05 a 05   1       Dígito verificador do Código de Barras
      #   06 a 09   4       Fator de Vencimento (Vide Nota)
      #   10 a 19   10      Valor
      #   20 a 44   25      Campo Livre - As posições do campo livre ficam a critério de cada Banco arrecadador.
      #
      # @raise [ArgumentError] caso o número de dígitos não seja igual a 44.
      # @return [String] código de barras formado por 44 dígitos.
      def codigo_barras
        raise Brcobranca::BoletoInvalido.new(self) unless self.valid?
        codigo = codigo_barras_primeira_parte
        codigo << codigo_barras_segunda_parte

        if codigo =~ /^(\d{4})(\d{39})$/
          codigo_dv = codigo.modulo11_2to9
          codigo = "#{$1}#{codigo_dv}#{$2}"
          codigo
        else
          raise Brcobranca::BoletoInvalido.new(self)
        end
      end

      # Responsável por montar a primeira parte do código de barras, que é a mesma para todos banco.
      def codigo_barras_primeira_parte
        "#{self.banco}#{self.moeda}#{self.fator_vencimento}#{self.valor_documento_formatado}"
      end

      # Responsável por montar a segunda parte do código de barras, que é específico para cada banco.
      #  Este método precisa ser reescrito para cada classe de boleto a ser criada.
      def codigo_barras_segunda_parte #:nodoc:
        raise NaoImplementado.new("Sobreescreva este método na classe referente ao banco que você esta criando")
      end

      protected

      def class_name
        self.class.to_s.split("::").last.downcase
      end

      def template_config
        case Brcobranca.configuration.gerador
        when :rghost
          extend Brcobranca::Boleto::Template::Rghost
        else
          raise "Configure o gerador na opção 'Brcobranca.configuration.gerador' corretamente!!!"
        end
      end

    end
  end
end