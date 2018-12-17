# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab240::BancoBrasil do
  let(:pagamento) do
    Brcobranca::Remessa::Pagamento.new(valor: 199.9,
      data_vencimento: Date.current,
      nosso_numero: 123,
      documento: 6969,
      documento_sacado: '12345678901',
      nome_sacado: 'PABLO DIEGO JOSÉ FRANCISCO,!^.?\/@  DE PAULA JUAN NEPOMUCENO MARÍA DE LOS REMEDIOS CIPRIANO DE LA SANTÍSSIMA TRINIDAD RUIZ Y PICASSO',
      endereco_sacado: 'RUA RIO GRANDE DO SUL,!^.?\/@ São paulo Minas caçapa da silva junior',
      bairro_sacado: 'São josé dos quatro apostolos magros',
      cep_sacado: '12345678',
      cidade_sacado: 'Santa rita de cássia maria da silva',
      uf_sacado: 'SP')
  end
  let(:params) do
    { empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
      agencia: '1234',
      conta_corrente: '12345',
      documento_cedente: '12345678901',
      convenio: '1234567',
      carteira: '12',
      variacao: '123',
      pagamentos: [pagamento] }
  end
  let(:banco_brasil) { subject.class.new(params) }

  context 'validacoes' do
    context '@carteira' do
      it 'deve ser invalido se nao possuir a carteira' do
        objeto = subject.class.new(params.merge!(carteira: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Carteira não pode estar em branco.')
      end

      it 'deve ser invalido se a carteira nao tiver 2 digitos' do
        banco_brasil.carteira = '123'
        expect(banco_brasil.invalid?).to be true
        expect(banco_brasil.errors.full_messages).to include('Carteira deve ter 2 dígitos.')
      end
    end

    context '@variacao' do
      it 'deve ser invalido se nao possuir a variacao da carteira' do
        objeto = subject.class.new(params.merge!(variacao: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Variacao não pode estar em branco.')
      end

      it 'deve ser invalido se a variacao nao tiver 3 digitos' do
        banco_brasil.variacao = '1234'
        expect(banco_brasil.invalid?).to be true
        expect(banco_brasil.errors.full_messages).to include('Variacao deve ter 3 dígitos.')
      end
    end

    context '@convenio' do
      it 'deve ser invalido se nao possuir o convenio' do
        objeto = subject.class.new(params.merge!(convenio: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Convenio não pode estar em branco.')
      end

      it 'deve ser invalido se o convenio nao tiver entre 4 e 7 digitos' do
        banco_brasil.convenio = '12345678'
        expect(banco_brasil.invalid?).to be true
        expect(banco_brasil.errors.full_messages).to include('Convenio deve ter de 4 a 7 dígitos.')
      end
    end

    context '@agencia' do
      it 'deve ser invalido se a agencia tiver mais de 5 digitos' do
        banco_brasil.agencia = '123456'
        expect(banco_brasil.invalid?).to be true
        expect(banco_brasil.errors.full_messages).to include('Agencia deve ter 5 dígitos.')
      end
    end

    context '@conta_corrente' do
      it 'deve ser invalido se a conta corrente tiver mais de 12 digitos' do
        banco_brasil.conta_corrente = '1234567890123'
        expect(banco_brasil.invalid?).to be true
        expect(banco_brasil.errors.full_messages).to include('Conta corrente deve ter 12 dígitos.')
      end
    end
  end

  context 'formatacoes' do
    it 'codigo do banco deve ser 001' do
      expect(banco_brasil.cod_banco).to eq '001'
    end

    it 'nome do banco deve ser Banco do Brasil com 30 posicoes' do
      nome_banco = banco_brasil.nome_banco
      expect(nome_banco.size).to eq 30
      expect(nome_banco[0..19]).to eq 'BANCO DO BRASIL S.A.'
    end

    it 'versao do layout do arquivo deve ser 083' do
      expect(banco_brasil.versao_layout_arquivo).to eq '083'
    end

    it 'versao do layout do lote deve ser 040' do
      expect(banco_brasil.versao_layout_lote).to eq '042'
    end

    it 'deve calcular o digito da agencia' do
      # digito calculado a partir do modulo 11 com base 9
      #
      # agencia = 1  2  3  4
      #
      #           4  3  2  1
      # x         9  8  7  6
      # =         36 24 14 6 = 80
      # 80 / 11 = 7 com resto 3
      expect(banco_brasil.digito_agencia).to eq '3'
    end

    it 'deve calcular  digito da conta' do
      # digito calculado a partir do modulo 11 com base 9
      #
      # conta = 1  2  3  4  5
      #
      #         5  4  3  2  1
      # x       9  8  7  6  5
      # =       45 32 21 12 5 = 116
      # 116 / 11 = 10 com resto 5
      expect(banco_brasil.digito_conta).to eq '5'
    end

    it 'cod. convenio deve retornar as informacoes nas posicoes corretas' do
      cod_convenio = banco_brasil.codigo_convenio
      expect(cod_convenio[0..8]).to eq '001234567'
      expect(cod_convenio[13..14]).to eq '12'
      expect(cod_convenio[15..17]).to eq '123'
    end

    it 'info conta deve retornar as informacoes nas posicoes corretas' do
      info_conta = banco_brasil.info_conta
      expect(info_conta[0..4]).to eq '01234'
      expect(info_conta[5]).to eq '3'
      expect(info_conta[6..17]).to eq '000000012345'
      expect(info_conta[18]).to eq '5'
    end

    it 'complemento header deve retornar espacos em branco' do
      expect(banco_brasil.complemento_header).to eq ''.rjust(29, ' ')
    end

    it 'complemento trailer deve retornar espacos em branco' do
      expect(banco_brasil.complemento_trailer).to eq ''.rjust(217, '0')
    end

    context 'formatacao nosso numero' do
      it 'deve falhar se convenio nao for implementado' do
        banco_brasil.convenio = '12345'
        expect { banco_brasil.formata_nosso_numero(1) }.to raise_error(Brcobranca::NaoImplementado)
      end

      it 'formata o nosso numero quando o convenio tiver 4 posicoes' do
        banco_brasil.convenio = '1234'
        nosso_numero = banco_brasil.formata_nosso_numero 1
        # modulo 11 com base 9
        #
        # convenio + nosso numero (7 posicoes)
        # 12340000001
        #
        #    1  0  0  0  0  0  0  4  3  2  1
        # x  9  8  7  6  5  4  3  2  9  8  7
        # =  9  0  0  0  0  0  0  8  27 16 7 = 67
        # 67 / 11 = 66 com resto 1
        expect(nosso_numero).to eq '00000011'
      end

      it 'formata o nosso numero quando o convenio tiver 6 posicoes' do
        banco_brasil.convenio = '123456'
        nosso_numero = banco_brasil.formata_nosso_numero 1
        # modulo 11 com base 9
        #
        # convenio + nosso numero (5 posicoes)
        # 12345600001
        #
        #     1  0  0  0  0  5  4  3  2  1
        # x   9  8  7  6  5  4  3  2  9  8
        # =   9  0  0  0  0  20 12 6  18 8 = 73
        # 73 / 11 = 66 com resto 7
        expect(nosso_numero).to eq '000017'
      end

      it 'formata o nosso numero quando o convenio tiver 7 posicoes' do
        banco_brasil.convenio = '1234567'
        # quando o nosso numero tiver 10 posicoes (convenio de 7 posicoes)
        # nao tera digito verificador
        expect(banco_brasil.formata_nosso_numero(1)).to eq '0000000001'
      end
    end

    it 'identificador do titulo deve ter as informacoes nas posicoes corretas' do
      identificador = banco_brasil.identificador_titulo 123
      expect(identificador[0..6]).to eq '1234567'
      expect(identificador[7..16]).to eq '0000000123'
    end
  end

  context 'geracao remessa' do
    it_behaves_like 'cnab240'

    context 'arquivo' do
      before { Timecop.freeze(Time.local(2015, 7, 14, 16, 15, 15)) }
      after { Timecop.return }

      it { expect(banco_brasil.gera_arquivo).to eq(read_remessa('remessa-banco_brasil-cnab240.rem', banco_brasil.gera_arquivo)) }
    end
  end
end
