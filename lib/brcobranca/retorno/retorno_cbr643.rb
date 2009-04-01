module Brcobranca
  module Boleto
    # Modalidade de Retorno para convênio de 7 dígitos
    class RetornoCbr643

      attr_accessor :arquivo_cominho

      def initialize(arquivo_retorno)
        if File.exist?(arquivo_retorno)
          self.arquivo_cominho = arquivo_retorno
        else
          raise "Arquivos inexistente"
        end
      end

      def retorno
        pagamentos = []
        linhas_to_array.each do |pagamento|
          #Hash com dados de cada linha
          pagamentos << { 
            :agencia_com_dv => pagamento[17..21], :cedente_com_dv => pagamento[22..30], :convenio => pagamento[31..37],
            :nosso_numero => pagamento[63..79], :tipo_cobranca => pagamento[80..80], :tipo_cobranca_anterior => pagamento[81..81],
            :natureza_recebimento => pagamento[86..87], :carteira_variacao => pagamento[91..93], :desconto => pagamento[95..99],
            :iof => pagamento[100..104], :carteira => pagamento[106..107], :comando => pagamento[108..109],
            :data_liquidacao => pagamento[110..115], :data_vencimento => pagamento[146..151], :valor_titulo => pagamento[152..164],
            :banco_recebedor => pagamento[165..167], :agencia_recebedora_com_dv => pagamento[168..172], :especie_documento => pagamento[173..174],
            :data_credito => pagamento[175..180], :valor_tarifa => pagamento[181..187], :outras_despesas => pagamento[188..200],
            :juros_desconto => pagamento[201..213], :iof_desconto => pagamento[214..226], :valor_abatimento => pagamento[227..239],
            :desconto_concedito => pagamento[240..252], :valor_recebido => pagamento[253..265], :juros_mora => pagamento[266..278],
            :outros_recebimento => pagamento[279..291], :abatimento_nao_aproveitado => pagamento[292..304], :valor_lancamento => pagamento[305..317],
            :indicativo_lancamento => pagamento[318..318], :indicador_valor => pagamento[319..319], :valor_ajuste => pagamento[320..331],
            :sequencial => pagamento[394..399]
          }
        end
        return pagamentos
      end

      private
      def linhas_to_array    
        # Separa as linhas do arquivo em um array
        linhas = File.readlines(self.arquivo_cominho).map {|l| l.rstrip}
        # Seleciona somente as linhas que são pagamentos, baseado no fato delas sempre começarem com 7(o que indica retorno)
        pagamentos = linhas.select{ |l| l if (l =~ /^[7]/) }
        return pagamentos
      end
    end
  end
end

