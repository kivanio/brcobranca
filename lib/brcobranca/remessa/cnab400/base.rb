# -*- encoding: utf-8 -*-
module Brcobranca
  module Remessa
    module Cnab400
      class Base < Brcobranca::Remessa::Base
        validates_presence_of :carteira, message: 'não pode estar em branco.'

        # Data da geracao do arquivo seguindo o padrao DDMMAA
        #
        # @return [String]
        #
        def data_geracao
          Date.current.strftime('%d%m%y')
        end

        # Header do arquivo remessa
        #
        # @return [String]
        #
        def monta_header
          # CAMPO                 TAMANHO    VALOR
          # tipo do registro      [1]        0
          # operacao              [1]        1
          # literal remessa       [7]        REMESSA
          # Código do serviço     [2]        01
          # cod. servico          [15]       COBRANCA
          # info. conta           [20]
          # empresa mae           [30]
          # cod. banco            [3]
          # nome banco            [15]
          # data geracao          [6]        formato DDMMAA
          # complemento registro  [294]
          # num. sequencial       [6]        000001
          "01REMESSA01COBRANCA       #{info_conta}#{empresa_mae.format_size(30)}#{cod_banco}#{nome_banco}#{data_geracao}#{complemento}000001"
        end

        # Trailer do arquivo remessa
        #
        # @param sequencial
        #   num. sequencial do registro no arquivo
        #
        # @return [String]
        #
        def monta_trailer(sequencial)
          # CAMPO                   TAMANHO  VALOR
          # identificacao registro  [1]      9
          # complemento             [393]
          # num. sequencial         [6]
          "9#{''.rjust(393, ' ')}#{sequencial.to_s.rjust(6, '0')}"
        end

        # Registro detalhe do arquivo remessa
        #
        # Este metodo deve ser sobrescrevido na classe do banco
        #
        def monta_detalhe(_pagamento, _sequencial)
          raise Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando'
        end

        # Gera o arquivo com os registros
        #
        # @return [String]
        def gera_arquivo
          raise Brcobranca::RemessaInvalida, self unless valid?

          # contador de registros no arquivo
          contador = 1
          ret = [monta_header]
          pagamentos.each do |pagamento|
            contador += 1
            ret << monta_detalhe(pagamento, contador)
            if pagamento.codigo_multa.to_i > 0 && self.respond_to?(:monta_detalhe_multa)
              contador += 1
              ret << monta_detalhe_multa(pagamento, contador)
            end
          end
          ret << monta_trailer(contador + 1)

          remittance = ret.join("\n").to_ascii.upcase
          remittance << "\n"

          remittance.encode(remittance.encoding, universal_newline: true).encode(remittance.encoding, crlf_newline: true)
        end

        # Informacoes referentes a conta do cedente
        #
        # Este metodo deve ser sobrescrevido na classe do banco
        #
        def info_conta
          raise Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando'
        end

        # Numero do banco na camara de compensacao
        #
        # Este metodo deve ser sobrescrevido na classe do banco
        #
        def cod_banco
          raise Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando'
        end

        # Nome por extenso do banco cobrador
        #
        # Este metodo deve ser sobrescrevido na classe do banco
        #
        def nome_banco
          raise Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando'
        end

        # Complemento do registro header
        #
        # Este metodo deve ser sobrescrevido na classe do banco
        #
        def complemento
          raise Brcobranca::NaoImplementado, 'Sobreescreva este método na classe referente ao banco que você esta criando'
        end
      end
    end
  end
end
