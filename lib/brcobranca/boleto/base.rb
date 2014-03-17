# -*- encoding: utf-8 -*-
# @author Kivanio Barbosa
module Brcobranca
  module Boleto
    # Classe base para todas as classes de boletos
    class Base
      extend Template::Base

      # Configura gerador de arquivo de boleto e código de barras.
      extend define_template(Brcobranca.configuration.gerador)
      include define_template(Brcobranca.configuration.gerador)

      # Validações do Rails 3
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
      attr_accessor :beneficiario
      # <b>REQUERIDO</b>: Documento do proprietario da conta corrente (CPF ou CNPJ)
      attr_accessor :documento_beneficiario
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
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao pagador
      attr_accessor :instrucao1
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao pagador
      attr_accessor :instrucao2
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao pagador
      attr_accessor :instrucao3
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao pagador
      attr_accessor :instrucao4
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao pagador
      attr_accessor :instrucao5
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao pagador
      attr_accessor :instrucao6
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao pagador
      attr_accessor :instrucao7
      # <b>REQUERIDO</b>: Informação sobre onde o pagador podera efetuar o pagamento
      attr_accessor :local_pagamento
      # <b>REQUERIDO</b>: O título de cobrança foi reconhecido (assinado) pelo Pagador? (A = aceito, N = não)
      attr_accessor :aceite
      # <b>REQUERIDO</b>: Nome da pessoa que receberá o boleto
      attr_accessor :pagador
      # <b>OPCIONAL</b>: Endereco da pessoa que receberá o boleto
      attr_accessor :pagador_endereco
      # <b>REQUERIDO</b>: Documento da pessoa que receberá o boleto
      attr_accessor :pagador_documento

      # Validações
      validates_presence_of :agencia, :conta_corrente, :moeda, :especie_documento, :especie, :aceite, :numero_documento, :message => 'não pode estar em branco.'
      validates_numericality_of :convenio, :agencia, :conta_corrente, :numero_documento, :message => 'não é um número.', :allow_nil => true

      # Nova instancia da classe Base
      # @param [Hash] campos
      def initialize(campos={})
        padrao = {
            :moeda => '9', :data_documento => Date.today, :dias_vencimento => 1, :quantidade => 1,
            :especie_documento => 'DM', :especie => 'R$', :aceite => 'N', :valor => 0.0,
            :local_pagamento => 'QUALQUER BANCO ATÉ O VENCIMENTO'
        }

        campos = padrao.merge!(campos)
        campos.each do |campo, valor|
          send "#{campo}=", valor
        end

        yield self if block_given?
      end

      # Logotipo do banco
      # @return [Path] Caminho para o arquivo de logotipo do banco.
      def logotipo
        File.join(File.dirname(__FILE__),'..','arquivos','logos',"#{class_name}.jpg")
      end

      # Dígito verificador do banco
      # @return [Integer] 1 caracteres numéricos.
      def banco_dv
        self.banco.modulo11_9to2
      end

      # Código da agencia
      # @return [String] 4 caracteres numéricos.
      def agencia=(valor)
        @agencia = valor.to_s.rjust(4, '0') if valor
      end

      # Dígito verificador da agência
      # @return [Integer] 1 caracteres numéricos.
      def agencia_dv
        self.agencia.modulo11_9to2
      end

      # Dígito verificador da conta corrente
      # @return [Integer] 1 caracteres numéricos.
      def conta_corrente_dv
        self.conta_corrente.modulo11_9to2
      end

      # Dígito verificador do nosso número
      # @return [Integer] 1 caracteres numéricos.
      def nosso_numero_dv
        self.numero_documento.modulo11_9to2
      end

      # @abstract Deverá ser sobreescrito para cada banco.
      def nosso_numero_boleto
        raise Brcobranca::NaoImplementado.new('Sobreescreva este método na classe referente ao banco que você esta criando')
      end

      # @abstract Deverá ser sobreescrito para cada banco.
      def agencia_conta_boleto
        raise Brcobranca::NaoImplementado.new('Sobreescreva este método na classe referente ao banco que você esta criando')
      end

      # Valor total do documento: <b>quantidate * valor</b>
      # @return [Float]
      def valor_documento
        self.quantidade.to_f * self.valor.to_f
      end

      # Data de vencimento baseado na <b>data_documento + dias_vencimento</b>
      #
      # @return [Date]
      # @raise [ArgumentError] Caso {#data_documento} esteja em branco.
      def data_vencimento
        raise ArgumentError, 'data_documento não pode estar em branco.' unless self.data_documento
        return self.data_documento unless self.dias_vencimento
        (self.data_documento + self.dias_vencimento.to_i)
      end

      # Fator de vencimento calculado com base na data de vencimento do boleto.
      # @return [String] 4 caracteres numéricos.
      def fator_vencimento
        self.data_vencimento.fator_vencimento
      end

      # Número da conta corrente
      # @return [String] 7 caracteres numéricos.
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(7, '0') if valor
      end

      # Codigo de barras do boleto
      #
      # O codigo de barra para cobrança contém 44 posições dispostas da seguinte forma:<br/>
      # Posição |Tamanho |Conteúdo<br/>
      # 01 a 03 | 3  | Identificação do Banco<br/>
      # 04 a 04 | 1  | Código da Moeda (Real = 9, Outras=0)<br/>
      # 05 a 05 | 1  |  Dígito verificador do Código de Barras<br/>
      # 06 a 09 | 4  | Fator de Vencimento (Vide Nota)<br/>
      # 10 a 19 | 10 |  Valor<br/>
      # 20 a 44 | 25 |  Campo Livre - As posições do campo livre ficam a critério de cada Banco arrecadador.<br/>
      #
      # @raise [Brcobranca::BoletoInvalido] Caso as informações fornecidas não sejam suficientes ou sejam inválidas.
      # @return [String] código de barras formado por 44 caracteres numéricos.
      def codigo_barras
        raise Brcobranca::BoletoInvalido.new(self) unless self.valid?
        codigo = codigo_barras_primeira_parte #18 digitos
        codigo << codigo_barras_segunda_parte #25 digitos
        if codigo =~ /^(\d{4})(\d{39})$/
          codigo_dv = codigo.modulo11_2to9
          "#{$1}#{codigo_dv}#{$2}"
        else
          raise Brcobranca::BoletoInvalido.new(self)
        end
      end

      # Monta a segunda parte do código de barras, que é específico para cada banco.
      #
      # @abstract Deverá ser sobreescrito para cada banco.
      def codigo_barras_segunda_parte
        raise Brcobranca::NaoImplementado.new('Sobreescreva este método na classe referente ao banco que você esta criando')
      end

      private

      # Monta a primeira parte do código de barras, que é a mesma para todos bancos.
      # @return [String] 18 caracteres numéricos.
      def codigo_barras_primeira_parte
        "#{self.banco}#{self.moeda}#{self.fator_vencimento}#{valor_documento_formatado}"
      end

      # Valor total do documento
      # @return [String] 10 caracteres numéricos.
      def valor_documento_formatado
        self.valor_documento.limpa_valor_moeda.to_s.rjust(10, '0')
      end

      # Nome da classe do boleto
      # @return [String]
      def class_name
        self.class.to_s.split('::').last.downcase
      end

    end
  end
end
