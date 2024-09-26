module Brcobranca
  module Remessa
    module Cnab400
      class Sicredi < Brcobranca::Remessa::Cnab400::Base
        attr_accessor :codigo_beneficiario, :numero_sicredi

        validates_presence_of :documento_cedente, :codigo_beneficiario, :sequencial_remessa
        validates_length_of :documento_cedente, minimum: 11, maximum: 14, message: 'deve ter entre 11 e 14 dígitos.'

        def initialize(campos = {})
          campos = { aceite: 'N', codigo_beneficiario: '12345' }.merge!(campos)
          super(campos)
        end

        # Código do banco Sicredi
        def cod_banco
          '748'
        end

        # Nome do banco Sicredi
        def nome_banco
          'SICREDI'.ljust(15)
        end

        # Informações da conta
        def info_conta
          codigo_beneficiario.to_s.rjust(5, '0')
        end

        # Data de geração do arquivo no formato AAAAMMDD
        def data_geracao
          Date.current.strftime('%Y%m%d')
        end

        # Header do arquivo de remessa
        def monta_header
          header = ''
          header << '0'                    # Identificação do Registro (0)
          header << '1'                    # Identificação do Arquivo (1)
          header << 'REMESSA'              # Literal Remessa
          header << '01'                    # Código do serviço de cobrança (1)
          header << 'COBRANCA'             # Literal Cobrança
          header << ''.ljust(7, ' ')       # Filler
          header << codigo_beneficiario.to_s.rjust(5, '0')  # Código do beneficiário/cedente
          header << documento_cedente.to_s.rjust(14, '0')   # CPF/CNPJ do beneficiário/cedente
          header << ''.ljust(31, ' ')      # Filler
          header << '748'                  # Número do Sicredi
          header << 'SICREDI'.ljust(15)    # Literal Sicredi
          header << Date.current.strftime('%Y%m%d')  # Data de geração do arquivo (AAAAMMDD)
          header << ''.ljust(8, ' ')       # Filler
          header << sequencial_remessa.to_s.rjust(7, '0')  # Número da remessa
          header << ''.ljust(273, ' ')     # Filler
          header << '2.00000001'
          header
        end

        # Detalhe do arquivo de remessa
        def monta_detalhe(pagamento, sequencial)
          detalhe = '1'  # Identificação do registro detalhe
          detalhe << 'A'  # Código da carteira
          detalhe << 'A'  # Tipo de cobrança com registro
          detalhe << 'A'  # Impressão realizada pelo beneficiário
          detalhe << ''.rjust(12, ' ')  # Filler
          detalhe << 'A'  # Impressão realizada pelo beneficiário
          detalhe << 'B'  # Impressão realizada pelo beneficiário
          detalhe << 'B'  # Impressão realizada pelo beneficiário
          detalhe << ''.rjust(28, ' ')  # Filler
          detalhe << pagamento.nosso_numero.to_s.rjust(9, '0')  # Nosso número
          detalhe << ''.rjust(6, ' ')  # Filler
          detalhe << pagamento.data_emissao.strftime('%Y%m%d')  # Data de emissão
          detalhe << ''.rjust(1, ' ')  # Filler
          detalhe << 'N'  # Impressão realizada pelo beneficiário
          detalhe << ''.rjust(1, ' ')  # Filler
          detalhe << 'B'  # Impressão realizada pelo beneficiário
          detalhe << ''.rjust(8, ' ')  # Filler
          detalhe << '00000000000200'  # Impressão realizada pelo beneficiário
          detalhe << ''.rjust(12, ' ')  # Filler
          detalhe << pagamento.cod_primeira_instrucao.to_s.rjust(2, '0')  # Instrução de protesto
          detalhe << pagamento.numero.to_s.rjust(10, '0')  # Valor do título
          detalhe << pagamento.data_vencimento.strftime('%d%m%y')  # Data de vencimento
          detalhe << pagamento.formata_valor  # Valor do título
          detalhe << ''.rjust(9, ' ')  # Filler
          detalhe << 'J'  # Impressão realizada pelo beneficiário
          detalhe << 'N'  # Impressão realizada pelo beneficiário
          detalhe << pagamento.data_emissao.strftime('%d%m%y')  # Data de emissão
          detalhe << '00'  # Impressão realizada pelo beneficiário
          detalhe << '00'  # Impressão realizada pelo beneficiário
          detalhe << pagamento.formata_valor_mora.to_s.rjust(13, '0')  # Valor dos juros por dia de atraso
          detalhe << '000000'  # Impressão realizada pelo beneficiário
          detalhe << pagamento.formata_valor_desconto.to_s.rjust(13, '0')  # Valor do desconto
          detalhe << ''.rjust(13, '0')  # Filler
          detalhe << pagamento.formata_valor_abatimento(13)  # Valor do desconto
          identificacao = pagamento.identificacao_sacado.to_s.sub(/^0+/, '')  # Remove zeros à esquerda
          detalhe << identificacao # Espécie do título
          detalhe << '0'  # Filler
          detalhe << pagamento.documento_sacado.to_s.rjust(14, '0')  # CPF/CNPJ do sacado
          detalhe << pagamento.nome_sacado.format_size(40)  # Nome do sacado
          detalhe << pagamento.endereco_sacado.format_size(40)  # Endereço do sacado
          detalhe << ''.rjust(5, '0')  # Filler
          detalhe << ''.rjust(6, '0')  # Filler
          detalhe << ''.rjust(1, ' ')  # Filler
          detalhe << pagamento.cep_sacado  # CEP do sacado
          detalhe << ''.rjust(5, '0')  # Filler
          detalhe << ''.rjust(14, ' ')  # CPF/CNPJ do sacado
          detalhe << ''.rjust(41, ' ')  # Filler
          detalhe << sequencial.to_s.rjust(6, '0')  # Número sequencial do registro
          detalhe
        end

        # Trailer do arquivo de remessa
        def monta_trailer(sequencial)
          "91748#{info_conta}#{''.rjust(384, ' ')}#{sequencial.to_s.rjust(6, '0')}"
        end
      end
    end
  end
end
