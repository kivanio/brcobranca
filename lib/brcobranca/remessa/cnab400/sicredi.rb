# frozen_string_literal: true

module Brcobranca
  module Remessa
    module Cnab400
      class Sicredi < Brcobranca::Remessa::Cnab400::Base
        # Código do beneficiário (informado pelo Sicredi no cadastramento)
        attr_accessor :codigo_beneficiario

        validates_presence_of :agencia, :conta_corrente, :documento_cedente,
                              :digito_conta, :codigo_beneficiario,
                              message: 'não pode estar em branco.'

        validates_length_of :agencia, maximum: 4, message: 'deve ter 4 dígitos.'
        validates_length_of :conta_corrente, maximum: 5, message: 'deve ter 5 dígitos.'
        validates_length_of :documento_cedente, minimum: 11, maximum: 14, message: 'deve ter entre 11 e 14 dígitos.'
        validates_length_of :carteira, maximum: 2, message: 'deve ter 2 dígitos.'
        validates_length_of :digito_conta, maximum: 1, message: 'deve ter 1 dígito.'

        validates_inclusion_of :carteira, in: %w[1], message: 'não existente para este banco.'

        def initialize(campos = {})
          campos = { aceite: 'N' }.merge!(campos)
          super(campos)
        end

        def agencia=(valor)
          @agencia = valor.to_s.rjust(4, '0') if valor
        end

        def conta_corrente=(valor)
          @conta_corrente = valor.to_s.rjust(5, '0') if valor
        end

        def carteira=(valor)
          @carteira = valor.to_s.rjust(2, '0') if valor
        end

        def cod_banco
          '748'
        end

        def nome_banco
          'SICREDI'.ljust(15, ' ')
        end

        def identificador_complemento
          ' '
        end

        def nosso_numero(nosso_numero)
          nosso_numero.to_s.rjust(8, '0')
        end

        def nosso_numero_dv(nosso_numero)
          peso = [2, 3, 4, 5, 6, 7, 8, 9]
          soma = nosso_numero.to_s.chars.reverse.each_with_index.map { |char, i| char.to_i * peso[i % 8] }.sum
          dv = 11 - (soma % 11)
          dv = 0 if dv == 10 || dv == 11
          dv
        end

        def nosso_numero_boleto(nosso_numero)
          "#{nosso_numero(nosso_numero)}#{nosso_numero_dv(nosso_numero)}"
        end

        def formata_nosso_numero(nosso_numero)
          nosso_numero_boleto(nosso_numero).to_s
        end

        def codigo_beneficiario=(valor)
          @codigo_beneficiario = valor.to_s.rjust(20, '0') if valor
        end

        def info_conta
          codigo_beneficiario
        end

        def complemento
          codigo_beneficiario.rjust(277, ' ')
        end

        def sequencial_remessa=(valor)
          @sequencial_remessa = valor.to_s.rjust(7, '0') if valor
        end

        def digito_agencia
          agencia.modulo11(mapeamento: { 10 => 'X' }).to_s
        end

        def digito_conta
          conta_corrente.modulo11(mapeamento: { 10 => '0' }).to_s
        end

        def mapeamento_para_modulo_11
          { 10 => 0, 11 => 0 }
        end

        def monta_header
          header = "01REMESSA01COBRANCA       #{info_conta}"
          header += "#{empresa_mae.format_size(30)}#{cod_banco}"
          header << "#{nome_banco}#{data_geracao}       000"
          header << "#{sequencial_remessa}#{complemento}000001"
          header
        end

        def monta_detalhe(pagamento, sequencial)
          raise Brcobranca::RemessaInvalida, pagamento if pagamento.invalid?

          detalhe = '1' # Código de transação
          detalhe += agencia.rjust(4, '0') # Agência
          detalhe << digito_agencia # Dígito da agência
          detalhe << conta_corrente.rjust(8, '0') # Conta Corrente
          detalhe << digito_conta # Dígito da conta
          detalhe << ''.rjust(6, '0') # Zeros (filler)
          detalhe << formata_nosso_numero(pagamento.nosso_numero).rjust(8, '0') # Nosso número
          detalhe << '0' # Número da parcela (para Sicredi, pode ser 0)
          detalhe << ' ' * 25 # Controle do participante (branco)
          detalhe << cod_banco # Código do banco
          detalhe << '00' # Zeros (filler)
          detalhe << ''.rjust(25, ' ') # Brancos
          detalhe << '2' # Código de multa (percentual)
          detalhe << pagamento.formata_percentual_multa(10) # Valor da multa
          detalhe << pagamento.tipo_mora # Tipo de mora
          detalhe << 'N' # Aceite do título
          detalhe << ' ' * 2 # Branco (filler)
          detalhe << pagamento.identificacao_ocorrencia # Identificação da ocorrência (pagamento)
          detalhe << pagamento.numero.to_s.rjust(10, '0') # Número do documento
          detalhe << pagamento.data_vencimento.strftime('%d%m%y') # Data de vencimento
          detalhe << pagamento.formata_valor.rjust(13, '0') # Valor do documento
          detalhe << ''.rjust(10, '0') # Banco cobrador (zeros)
          detalhe << pagamento.cod_desconto.rjust(2, '0') # Código do desconto
          detalhe << pagamento.data_emissao.strftime('%d%m%y') # Data de emissão
          detalhe << ''.rjust(2, '0') # Zeros (filler)
          detalhe << pagamento.codigo_protesto # Código de protesto
          detalhe << pagamento.dias_protesto.rjust(2, '0') # Dias para protesto
          detalhe << pagamento.formata_valor_mora(13) # Valor mora ao dia
          detalhe << pagamento.formata_data_desconto # Data limite para desconto
          detalhe << pagamento.formata_valor_desconto.rjust(13, '0') # Valor do desconto
          detalhe << formata_nosso_numero(pagamento.nosso_numero) # Nosso número formatado
          detalhe << '00' # Zeros (filler)
          detalhe << pagamento.formata_valor_abatimento(13) # Valor do abatimento
          detalhe << pagamento.identificacao_sacado.rjust(2, '0') # Tipo de inscrição do sacado (CPF/CNPJ)
          detalhe << pagamento.documento_sacado.to_s.rjust(14, '0') # Documento do sacado
          detalhe << pagamento.nome_sacado.format_size(40) # Nome do sacado
          detalhe << pagamento.endereco_sacado.format_size(40) # Endereço do sacado
          detalhe << pagamento.bairro_sacado.format_size(12) # Bairro do sacado
          detalhe << pagamento.cep_sacado.rjust(8, '0') # CEP do sacado
          detalhe << pagamento.cidade_sacado.format_size(20) # Cidade do sacado
          detalhe << pagamento.uf_sacado # UF do sacado
          detalhe << pagamento.nome_avalista.format_size(38) # Nome do avalista
          detalhe << sequencial.to_s.rjust(6, '0') # Número sequencial
          detalhe
        end
        def monta_trailer(quantidade_registros)
          trailer = "9" # Código do trailer
          trailer << ''.rjust(393, '0') # Filler com zeros
          trailer << quantidade_registros.to_s.rjust(6, '0') # Número sequencial
          trailer
        end
      end  
    end
  end
end