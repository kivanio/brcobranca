# -*- encoding: utf-8 -*-
#
# @author Kivanio Barbosa
module Brcobranca
  module Boleto
    # Classe base para todas as classes de boletos
    class Base
      extend Template::Base

      # Configura gerador de arquivo de boleto e código de barras.
      define_template(Brcobranca.configuration.gerador).each do |klass|
        extend klass
        include klass
      end

      # Validações
      include Brcobranca::Validations

      # <b>REQUERIDO</b>: Número do convênio/contrato do cliente junto ao banco emissor
      attr_accessor :convenio
      # <b>REQUERIDO</b>: Tipo de moeda utilizada (Real(R$) e igual a 9)
      attr_accessor :moeda
      # <b>REQUERIDO</b>: Carteira utilizada
      attr_accessor :carteira
      # <b>OPCIONAL</b>: Variacao da carteira(opcional para a maioria dos bancos)
      attr_accessor :carteira_label
      # <b>OPCIONAL</b>: Rótulo da Carteira, RG ou SR, somente para impressão no boleto.
      attr_accessor :variacao
      # <b>OPCIONAL</b>: Data de processamento do boleto
      attr_accessor :data_processamento
      # <b>REQUERIDO</b>: Quantidade de boleto(padrão = 1)
      attr_accessor :quantidade
      # <b>REQUERIDO</b>: Valor do boleto
      attr_accessor :valor
      # <b>REQUERIDO</b>: Número da agencia sem <b>Digito Verificador</b>
      attr_accessor :agencia
      # <b>REQUERIDO</b>: Número da conta corrente sem <b>Digito Verificador</b>
      attr_accessor :conta_corrente
      # <b>REQUERIDO</b>: Nome do beneficiário
      attr_accessor :cedente
      # <b>REQUERIDO</b>: Documento do beneficiário (CPF ou CNPJ)
      attr_accessor :documento_cedente
      # <b>OPCIONAL</b>: Número sequencial utilizado para identificar o boleto
      attr_accessor :nosso_numero
      # <b>REQUERIDO</b>: Símbolo da moeda utilizada (R$ no brasil)
      attr_accessor :especie
      # <b>REQUERIDO</b>: Tipo do documento (Geralmente DM que quer dizer Duplicata Mercantil)
      attr_accessor :especie_documento
      # <b>REQUERIDO</b>: Data de pedido, Nota fiscal ou documento que originou o boleto
      attr_accessor :data_documento
      # <b>REQUERIDO</b>: Data de vencimento do boleto
      attr_accessor :data_vencimento
      # <b>OPCIONAL</b>: Número de pedido, Nota fiscal ou documento que originou o boleto
      attr_accessor :documento_numero
      # <b>OPCIONAL</b>: Código utilizado para identificar o tipo de serviço cobrado
      attr_accessor :codigo_servico
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao sacado
      attr_accessor :demonstrativo
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao caixa
      attr_accessor :instrucoes
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao caixa
      attr_accessor :instrucao1
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao caixa
      attr_accessor :instrucao2
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao caixa
      attr_accessor :instrucao3
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao caixa
      attr_accessor :instrucao4
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao caixa
      attr_accessor :instrucao5
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao caixa
      attr_accessor :instrucao6
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao caixa
      attr_accessor :instrucao7
      # <b>REQUERIDO</b>: Informação sobre onde o sacado podera efetuar o pagamento
      attr_accessor :local_pagamento
      # <b>REQUERIDO</b>: Informa se o banco deve aceitar o boleto após o vencimento ou não( S ou N, quase sempre S)
      attr_accessor :aceite
      # <b>REQUERIDO</b>: Nome do pagador
      attr_accessor :sacado
      # <b>OPCIONAL</b>: Endereco do pagador
      attr_accessor :sacado_endereco
      # <b>REQUERIDO</b>: Documento do pagador
      attr_accessor :sacado_documento
      # <b>OPCIONAL</b>: Nome do avalista
      attr_accessor :avalista
      # <b>OPCIONAL</b>: Documento do avalista
      attr_accessor :avalista_documento
      # <b>OPCIONAL</b>: Endereço do beneficiário
      attr_accessor :cedente_endereco

      # Validações
      validates_presence_of :agencia, :conta_corrente, :moeda, :especie_documento, :especie, :aceite, :nosso_numero, :sacado, :sacado_documento, message: 'não pode estar em branco.'
      validates_numericality_of :convenio, :agencia, :conta_corrente, :nosso_numero, message: 'não é um número.', allow_nil: true

      # Nova instancia da classe Base
      # @param [Hash] campos
      def initialize(campos = {})
        padrao = {
          moeda: '9',
          data_processamento: Date.current,
          data_vencimento: Date.current,
          quantidade: 1,
          especie_documento: 'DM',
          especie: 'R$',
          aceite: 'S',
          valor: 0.0,
          local_pagamento: 'QUALQUER BANCO ATÉ O VENCIMENTO'
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
        if Brcobranca.configuration.gerador == :rghost_carne
          File.join(File.dirname(__FILE__), '..', 'arquivos', 'logos', "#{class_name}_carne.eps")
        else
          File.join(File.dirname(__FILE__), '..', 'arquivos', 'logos', "#{class_name}.eps")
        end
      end

      # Dígito verificador do banco
      # @return [Integer] 1 caracteres numéricos.
      def banco_dv
        banco.modulo11
      end

      # Código da agencia
      # @return [String] 4 caracteres numéricos.
      def agencia=(valor)
        @agencia = valor.to_s.rjust(4, '0') if valor
      end

      # Dígito verificador da agência
      # @return [Integer] 1 caracteres numéricos.
      def agencia_dv
        agencia.modulo11
      end

      # Dígito verificador da conta corrente
      # @return [Integer] 1 caracteres numéricos.
      def conta_corrente_dv
        conta_corrente.modulo11
      end

      # Dígito verificador do nosso número
      # @return [Integer] 1 caracteres numéricos.
      def nosso_numero_dv
        nosso_numero.modulo11(mapeamento: { 10 => 0, 11 => 0 })
      end

      # @abstract Deverá ser sobreescrito para cada banco.
      def nosso_numero_boleto
        raise Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando'
      end

      # @abstract Deverá ser sobreescrito para cada banco.
      def agencia_conta_boleto
        raise Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando'
      end

      # Valor total do documento: <b>quantidate * valor</b>
      # @return [Float]
      def valor_documento
        quantidade.to_f * valor.to_f
      end

      # Fator de vencimento calculado com base na data de vencimento do boleto.
      # @return [String] 4 caracteres numéricos.
      def fator_vencimento
        data_vencimento.fator_vencimento
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
        raise Brcobranca::BoletoInvalido, self unless valid?
        codigo = codigo_barras_primeira_parte # 18 digitos
        codigo << codigo_barras_segunda_parte # 25 digitos
        if codigo =~ /^(\d{4})(\d{39})$/

          codigo_dv = codigo.modulo11(
            multiplicador: (2..9).to_a,
            mapeamento: { 0 => 1, 10 => 1, 11 => 1 }
          ) { |t| 11 - (t % 11) }

          codigo = "#{Regexp.last_match[1]}#{codigo_dv}#{Regexp.last_match[2]}"
          codigo
        else
          self.errors.add(:base, :too_long, message: "tamanho(#{codigo.size}) prévio do código de barras(#{codigo}) inválido, deveria ser 43 dígitos")
          raise Brcobranca::BoletoInvalido, self
        end
      end

      # Monta a segunda parte do código de barras, que é específico para cada banco.
      #
      # @abstract Deverá ser sobreescrito para cada banco.
      def codigo_barras_segunda_parte
        raise Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando'
      end

      private

      # Monta a primeira parte do código de barras, que é a mesma para todos bancos.
      # @return [String] 18 caracteres numéricos.
      def codigo_barras_primeira_parte
        "#{banco}#{moeda}#{fator_vencimento}#{valor_documento_formatado}"
      end

      # Valor total do documento
      # @return [String] 10 caracteres numéricos.
      def valor_documento_formatado
        valor_documento.round(2).limpa_valor_moeda.to_s.rjust(10, '0')
      end

      # Nome da classe do boleto
      # @return [String]
      def class_name
        self.class.to_s.split('::').last.downcase
      end
    end
  end
end
