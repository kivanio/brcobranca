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

        validates :cod_juros_mora, inclusion: { in: %w(1 2 3),
          message: "%{value} não é um valor válido" }, allow_blank: true

        # Formata o juros de mora incluindo o código do juros, a data e o valor
        # ou percentual.
        #
        # @return [String]
        #
        def formata_mora
          mora_formatada = ''

          # cod. do juros (1 digito)
          if ['1','2', '3'].include? cod_juros_mora
            mora_formatada << cod_juros_mora
          else #mantem compatibilidade
            mora_formatada << '0'
          end

          # data juros (8 digitos)
          mora_formatada << formata_data(data_juros_mora, '%d%m%Y')

          # valor juros (15 digitos)
          mora_formatada << formata_valor_mora(15)

          mora_formatada
        end

        private
        def data_juros_nao_pode_ser_anterior_ao_vencimento
          if data_juros_mora.present? && data_juros_mora < data_vencimento
            errors.add(:data_juros_mora, "não pode ser menor que data de vencimento")
          end
        end
      end
    end
  end
end
