module Brcobranca
  module Remessa
    module Cnab400
      class Sicredi < Brcobranca::Remessa::Cnab400::Base
        attr_accessor :codigo_beneficiario, :numero_sicredi

        validates_presence_of :documento_cedente, :codigo_beneficiario
        validates_length_of :documento_cedente, minimum: 11, maximum: 14, message: 'deve ter entre 11 e 14 dígitos.'

        def initialize(campos = {})
          campos = { aceite: 'N', codigo_beneficiario: '12345' }.merge!(campos)
          super(campos)
        end

        def cod_banco
          '748'
        end

        def nome_banco
          'SICREDI'.ljust(15)
        end

        def info_conta
          codigo_beneficiario.to_s.rjust(5, '0')
        end


        def data_geracao
          Date.current.strftime('%Y%m%d')
        end

        def monta_header
          cod = "1"
          version = "2.00"
          num_sequencial = 1.to_s.rjust(6, '0')
          "01REMESSA01COBRANCA       #{info_conta}#{documento_cedente}                               #{cod_banco}#{nome_banco}#{data_geracao}        #{cod.to_s.rjust(7, '0')}                                                                                                                                                                                                                                                                                 #{version}#{num_sequencial}"
        end

        def 

        def monta_detalhe(pagamento, sequencial)
          detalhe = '1AAA H'
          detalhe << ''.rjust(10, ' ')
          detalhe << 'ABB'
          detalhe << ''.rjust(28, ' ')
          detalhe << pagamento.nosso_numero.to_s.rjust(9, '0')
          detalhe << ''.rjust(6, ' ')
          detalhe << pagamento.data_emissao.strftime('%y%m%d')

          # above is incorrect implementation
          detalhe << pagamento.data_vencimento.strftime('%d%m%y')
          detalhe << pagamento.valor.to_s.rjust(13, '0')
          detalhe << cod_banco
          detalhe << pagamento.especie_titulo
          detalhe << aceite
          detalhe << pagamento.cod_primeira_instrucao
          detalhe << pagamento.formata_valor_mora
          detalhe << pagamento.formata_valor_desconto
          detalhe << pagamento.documento_sacado.to_s.rjust(14, '0')
          detalhe << pagamento.nome_sacado.ljust(40)
          detalhe << pagamento.endereco_sacado.ljust(40)
          detalhe << pagamento.cep_sacado
          detalhe << pagamento.cidade_sacado.ljust(15)
          detalhe << pagamento.uf_sacado
          detalhe << sequencial.to_s.rjust(6, '0')
          detalhe
        end

        def monta_trailer(sequencial)
          "9#{sequencial.to_s.rjust(6, '0')}#{''.rjust(374, '0')}#{sequencial.to_s.rjust(6, '0')}"
        end
      end
    end
  end
end
