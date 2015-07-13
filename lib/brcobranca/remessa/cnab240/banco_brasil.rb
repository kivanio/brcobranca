# -*- encoding: utf-8 -*-
module Brcobranca
  module Remessa
    module Cnab240
      class BancoBrasil < Brcobranca::Remessa::Cnab240::Base
        # variacao da carteira
        attr_accessor :variacao
        # identificacao da emissao do boleto (attr na classe base)
        #   campo nao tratado pelo sistema do Banco do Brasil
        # identificacao da distribuicao do boleto (attr na classe base)
        #   campo nao tratado pelo sistema do Banco do Brasil

        validates_presence_of :carteira, :variacao, message: 'não pode estar em branco.'
        validates_length_of :conta_corrente, is: 5, message: 'deve ter 5 dígitos.'
        validates_length_of :agencia, is: 4, message: 'deve ter 4 dígitos.'
        validates_length_of :carteira, is: 2, message: 'deve ter 2 dígitos.'
        validates_length_of :variacao, is: 3, message: 'deve ter 3 dígitos.'
        validates_length_of :convenio, in: 4..7, message: 'não existente para este banco.'

        def initialize(campos = {})
          campos = { emissao_boleto: '0',
                     distribuicao_boleto: '0',
                     especie_titulo: '02' }.merge!(campos)
          super(campos)
        end

        def cod_banco
          '001'
        end

        def nome_banco
          'BANCO DO BRASIL S.A.'.ljust(30, ' ')
        end

        def versao_layout_arquivo
          '083'
        end

        def versao_layout_lote
          '042'
        end

        def digito_agencia
          # utilizando a agencia com 4 digitos
          # para calcular o digito
          agencia.modulo11(mapeamento: { 10 => 'X' }).to_s
        end

        def digito_conta
          # utilizando a conta corrente com 5 digitos
          # para calcular o digito
          conta_corrente.modulo11(mapeamento: { 10 => 'X' }).to_s
        end

        def codigo_convenio
          # CAMPO                TAMANHO
          # num. convenio        9
          # cobranca cedente     4
          # carteira             2
          # variacao carteira    3
          # campo reservado      2
          "#{convenio.rjust(9, '0')}0014#{carteira}#{variacao}  "
        end
        alias_method :convenio_lote, :codigo_convenio

        def info_conta
          # CAMPO                  TAMANHO
          # agencia                5
          # digito agencia         1
          # conta corrente         12
          # digito conta           1
          # digito agencia/conta   1
          "#{agencia.rjust(5, '0')}#{digito_agencia}#{conta_corrente.rjust(12, '0')}#{digito_conta} "
        end

        def complemento_header
          ''.rjust(29, ' ')
        end

        def complemento_trailer
          ''.rjust(217, ' ')
        end

        def complemento_p(pagamento)
          # CAMPO                   TAMANHO
          # conta corrente          12
          # digito conta            1
          # digito agencia/conta    1
          # ident. titulo no banco  20
          "#{conta_corrente.rjust(12, '0')}#{digito_conta} #{identificador_titulo(pagamento.nosso_numero)}"
        end

        # Retorna o nosso numero mais o digito verificador
        #
        # @return [String]
        #
        def formata_nosso_numero(nosso_numero)
          quantidade = case convenio.to_s.size
                         # convenio de 4 posicoes com nosso numero de 7
                       when 4 then 7
                         # convenio de 6 posicoes com nosso numero de 5
                       when 6 then 5
                         # convenio de 7 posicoes com nosso numero de 10
                       when 7 then 10
                       else
                         fail Brcobranca::NaoImplementado.new('Tipo de convênio não implementado.')
                       end
          nosso_numero = nosso_numero.to_s.rjust(quantidade, '0')

          # calcula o digito do nosso numero (menos para quando nosso numero tiver 10 posicoes)
          digito = "#{convenio}#{nosso_numero}".modulo11(mapeamento: { 10 => 'X' }) unless quantidade == 10
          "#{nosso_numero}#{digito}"
        end

        def identificador_titulo(nosso_numero)
          "#{convenio}#{formata_nosso_numero(nosso_numero)}".ljust(20, ' ')
        end
      end
    end
  end
end
