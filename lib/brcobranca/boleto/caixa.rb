# -*- encoding: utf-8 -*-
module Brcobranca
  module Boleto
    class Caixa < Base # Caixa Economica
      
      validates_length_of :convenio, :is => 11, :message => "deve ser igual a 11 dígitos (operacao (3) + convênio (8))."
                                
      CARTEIRAS = {
        14 => 'SR' # Cobranca sem Registro
      }
      
      # Nova instancia da CaixaEconomica
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos={})
        campos = {:carteira => CARTEIRAS[14]}.merge!(campos)
        super(campos)
      end
                  
      alias :valor_carteira :carteira
      def carteira             
        # Em caso de número, formatar para sigla
        return CARTEIRAS[self.valor_carteira] if self.valor_carteira.is_number?
        self.valor_carteira
      end
      
      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        "104"
      end
      
      def banco_dv
        self.banco.modulo10
      end
      
      # Número da agência/codigo_cedente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "2391/44335511-5"
      def agencia_conta_boleto            
        "#{self.agencia}/#{self.conta_corrente}-#{self.conta_corrente_dv}"
      end
      
      # Número seqüencial utilizado para identificar o boleto.
      # Carteira 14 - SR - Cobranca sem Registro:
      #  Fixo 2 mais 8 dígitos (ex: 8200000001) 
      # @raise  [Brcobranca::NaoImplementado] Caso o tipo de convênio não seja suportado pelo Brcobranca.
      #                       
      def numero_documento
        case self.carteira
        when 'SR'
          "82#{@numero_documento.to_s.rjust(8, '0')}"
        else
          raise Brcobranca::NaoImplementado.new("Tipo de convênio não implementado.")
        end
      end
      
      # Dígito verificador do nosso número.
      # @return [String] 1 caracteres numéricos.
      # @see BancoBrasil#numero_documento
      def nosso_numero_dv
        self.numero_documento.modulo11_2to9
      end
      
      # Nosso número para exibir no boleto.
      # (numero_documento + nosso_numero_dv)
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "12345678904"
      def nosso_numero_boleto
        "#{self.numero_documento}#{self.nosso_numero_dv}"
      end
      
      def codigo_barras_segunda_parte
        self.campo_livre
      end
        
      # Para as posições do Campo Livre, informar:
      # - Se carteira Sem Registro: Nosso número com 10 posições e Código do Cedente, ambos
      # sem o DV.
      # 
      # Ex.: 82NNNNNNNN AAAA YYYXXXXXXXX
      # 
      # Onde: 82 - Identificador da carteira Sem Registro
      # NNNNNNNN - Nosso número do Cliente
      # AAAA - CNPJ da Agência Cedente
      # YYY - Operação Código
      # XXXXXXXX - Código fornecido pela Agência
      #
      # Nota: A operação + o código fornecido pela agência = convênio
      def campo_livre
        "#{self.numero_documento}#{self.agencia}#{self.convenio}"
      end
      
    end
  end
end



































