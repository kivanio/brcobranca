# -*- encoding: utf-8 -*-

module Brcobranca
  module Remessa
    module Cnab240
      class Pagamento < Brcobranca::Remessa::Pagamento
        # Validações do Rails 3
        include ActiveModel::Validations

        # <b>OPCIONAL</b>: código do juros de mora
        #
        # Código adotado pela FEBRABAN para identificação do tipo de pagamento
        # de juros de mora.
        # Domínio:
        # '1' = Valor por Dia
        # '2' = Taxa Mensal
        # '3' = Isento
        attr_accessor :cod_juros_mora

        # <b>OPCIONAL</b>: data do juros de mora
        #
        # Data indicativa do início da cobrança do Juros de Mora de um
        # título de cobrança.
        # A data informada deverá ser maior que a Data de Vencimento do título
        # de cobrança
        # Caso seja inválida ou não informada será assumida a data do vencimento
        attr_accessor :data_juros_mora

        validate :data_juros_nao_pode_ser_anterior_ao_vencimento
        validate :data_multa_nao_pode_ser_anterior_ao_vencimento

        validates :cod_juros_mora, inclusion: { in: %w(1 2 3),
          message: "%{value} não é um valor válido" }, allow_blank: true

        validates :codigo_multa, inclusion: { in: %w(1 2),
          message: "%{value} não é um valor válido" }, allow_blank: true

        # Nova instancia da classe Pagamento
        #
        # @param campos [Hash]
        #
        def initialize(campos = {})
          super campos

          # TODO Remover código quando removido codigo específico
          # do Cnab400 da classe Brcobranca::Remessa::Pagamento
          @codigo_multa = nil if @codigo_multa == '0'
        end

        # Formata o juros de mora incluindo o código do juros, a data e o valor
        # ou percentual.
        #
        # @return [String]
        #
        def formata_mora
          formata_campo_de_codigo_data_valor @cod_juros_mora, @data_juros_mora, self.valor_mora, ['1', '2', '3']
        end

        # Formata a multa incluindo o código da multa, a data e o valor
        # ou percentual.
        #
        # @return [String]
        #
        def formata_multa
          formata_campo_de_codigo_data_valor @codigo_multa, @data_multa, self.valor_multa, ['1', '2']
        end

        private
        def formata_campo_de_codigo_data_valor codigo, data, valor, codigos_validos
          codigo = nil unless codigos_validos.include? codigo
          valor = 0.0 if valor.nil?

          campo_formatada = ''
          campo_formatada << if codigo.nil? then '0' else codigo end

          # data juros (8 digitos)
          campo_formatada << formata_data(data, '%d%m%Y')

          # valor juros (15 digitos)
          campo_formatada << format_value(valor, 15)

          campo_formatada
        end

        def data_juros_nao_pode_ser_anterior_ao_vencimento
          data_nao_pode_ser_anterior_ao_vencimento :data_juros_mora
        end
        def data_multa_nao_pode_ser_anterior_ao_vencimento
          data_nao_pode_ser_anterior_ao_vencimento :data_multa
        end

        def data_nao_pode_ser_anterior_ao_vencimento campo_a_comparar
          data_a_comparar =  self.send(campo_a_comparar)
          if data_a_comparar.present? && data_a_comparar < data_vencimento
            errors.add(campo_a_comparar, "não pode ser menor que data de vencimento")
          end
        end
      end
    end
  end
end
