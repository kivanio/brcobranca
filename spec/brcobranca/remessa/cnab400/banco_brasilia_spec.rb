# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab400::BancoBrasilia do
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
    {
      carteira: '2',
      agencia: '083',
      conta_corrente: '0000490',
      digito_conta: '1',
      empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
      pagamentos: [pagamento]
    }
  end
  let(:banco_brasilia) { subject.class.new(params) }

  context 'validacoes dos campos' do
    context '@agencia' do
      it 'deve ser invalido se nao possuir uma agencia' do
        object = subject.class.new(params.merge!(agencia: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Agencia não pode estar em branco.')
      end

      it 'deve ser invalido se a agencia tiver mais de 3 digitos' do
        banco_brasilia.agencia = '1234'
        expect(banco_brasilia.invalid?).to be true
        expect(banco_brasilia.errors.full_messages).to include('Agencia deve ter 3 dígitos.')
      end
    end

    context '@digito_conta' do
      it 'deve ser invalido se nao possuir um digito da conta corrente' do
        objeto = subject.class.new(params.merge!(digito_conta: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Digito conta não pode estar em branco.')
      end

      it 'deve ser inválido se o dígito da conta tiver mais de 1 dígito' do
        banco_brasilia.digito_conta = '12'
        expect(banco_brasilia.invalid?).to be true
        expect(banco_brasilia.errors.full_messages).to include('Digito conta deve ter 1 dígito.')
      end
    end

    context '@conta_corrente' do
      it 'deve ser invalido se nao possuir uma conta corrente' do
        object = subject.class.new(params.merge!(conta_corrente: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Conta corrente não pode estar em branco.')
      end

      it 'deve ser invalido se a conta corrente tiver mais de 7 digitos' do
        banco_brasilia.conta_corrente = '12345678'
        expect(banco_brasilia.invalid?).to be true
        expect(banco_brasilia.errors.full_messages).to include('Conta corrente deve ter 7 dígitos.')
      end
    end

    context '@carteira' do
      it 'deve ser inválido se não possuir uma carteira' do
        object = subject.class.new(params.merge!(carteira: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Carteira não pode estar em branco.')
      end

      it 'deve ser inválido se a carteira tiver 1 dígito' do
        banco_brasilia.carteira = '12'
        expect(banco_brasilia.invalid?).to be true
        expect(banco_brasilia.errors.full_messages).to include('Carteira deve ter 1 dígito.')
      end
    end
  end

  context 'formatacoes dos valores' do
    it 'cod_banco deve ser 070' do
      expect(banco_brasilia.cod_banco).to eq '070'
    end

    it 'info_conta deve retornar com 10 posicoes as informacoes da conta' do
      info_conta = banco_brasilia.info_conta
      expect(info_conta.size).to eq 10
      expect(info_conta[0..2]).to eq '083'          # num. da agencia
      expect(info_conta[3..9]).to eq '0000490'      # num. da conta
    end
  end

  context 'monta remessa' do
    # it_behaves_like 'cnab400'

    context 'header' do
      it 'deve ter 39 posicoes' do
        expect(banco_brasilia.monta_header.size).to eq 39
      end

      it 'informacoes devem estar posicionadas corretamente no header' do
        header = banco_brasilia.monta_header
        expect(header[0..2]).to eq 'DCB'                              # literal DCB
        expect(header[3..5]).to eq '001'                              # versão
        expect(header[6..8]).to eq '075'                              # arquivo
        expect(header[9..18]).to eq banco_brasilia.info_conta         # informacoes da conta
        expect(header[19..32]).to eq Time.now.strftime('%Y%m%d%H%M%S')  # data/hora de formação
        expect(header[33..38]).to eq '000002'                         # num. de registros
      end
    end

    context 'detalhe' do
      it 'deve ter 400 posições' do
        expect(banco_brasilia.monta_detalhe(pagamento, 1).size).to eq 400
      end

      it 'informacoes devem estar posicionadas corretamente no detalhe' do
        detalhe = banco_brasilia.monta_detalhe pagamento, 1
        expect(detalhe[0..1]).to eq '01'                              # identificador
        expect(detalhe[2..11]).to eq banco_brasilia.info_conta        # info da conta
        expect(detalhe[12..25]).to eq '00012345678901'                # identificador
        expect(detalhe[26..60]).to eq 'PABLO DIEGO JOSE FRANCISCO DE PAULA'   # nome do pagador
        expect(detalhe[61..95]).to eq 'RUA RIO GRANDE DO SUL Sao paulo Min'   # endereço do pagador
        expect(detalhe[96..110]).to eq 'Santa rita de c'              # cidade do pagador
        expect(detalhe[111..112]).to eq 'SP'                          # uf do pagador
        expect(detalhe[113..120]).to eq '12345678'                    # cep do pagador
        expect(detalhe[121..121]).to eq '1'                           # tipo de pessoa
        expect(detalhe[122..134]).to eq "6969".rjust(13, "0")             # seu numero
        expect(detalhe[135..135]).to eq '2'                           # categoria de cobranca
        expect(detalhe[136..143]).to eq Date.current.strftime('%d%m%Y') # data de emissao
        expect(detalhe[144..145]).to eq '21'                          # tipo do documento
        expect(detalhe[146..146]).to eq '0'                           # código da natureza
        expect(detalhe[147..147]).to eq '0'                           # código da cond. pagamento
        expect(detalhe[148..149]).to eq '02'                          # código da moeda
        expect(detalhe[150..152]).to eq '070'                         # código do banco
        expect(detalhe[153..156]).to eq '0083'                        # código da agência
        expect(detalhe[157..186]).to eq ''.rjust(30, ' ')             # praça de cobranca
        expect(detalhe[187..194]).to eq Date.current.strftime('%d%m%Y') # data de vencimento
        expect(detalhe[195..208]).to eq '00000000019990'              # valor do titulo
        expect(detalhe[209..220]).to eq '200012307038'                # nosso numero
        expect(detalhe[221..222]).to eq '00'                          # tipo de juros
        expect(detalhe[223..236]).to eq ''.rjust(14, "0")             # valor dos juros
        expect(detalhe[237..250]).to eq ''.rjust(14, "0")             # valor dos abatimento
        expect(detalhe[251..252]).to eq '00'                          # tipo de desconto
        expect(detalhe[253..260]).to eq ''.rjust(8, "0")              # data limite de desconto
        expect(detalhe[261..274]).to eq ''.rjust(14, "0")             # valor dos descontos
        expect(detalhe[288..327]).to eq 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA   ' # emitente do titulo
      end
    end

    it 'montagem da remessa deve falhar se o objeto nao for valido' do
      expect { subject.class.new.gera_arquivo }.to raise_error(Brcobranca::RemessaInvalida)
    end

    it 'remessa deve conter os registros mais as quebras de linha' do
      remessa = banco_brasilia.gera_arquivo
      expect(remessa.size).to eq 845

      # registros
      expect(remessa[0..38]).to eq banco_brasilia.monta_header
      expect(remessa[41..440]).to eq banco_brasilia.monta_detalhe(pagamento, 2).upcase

      # quebras de linha
      expect(remessa[39..40]).to eq "\r\n"
      expect(remessa[441..442]).to eq "\r\n"
    end

    context 'arquivo' do
      before { Timecop.freeze(Time.local(2015, 7, 14, 16, 15, 15)) }
      after { Timecop.return }

      it { expect(banco_brasilia.gera_arquivo).to eq(read_remessa('remessa-banco-brasilia-cnab400.rem', banco_brasilia.gera_arquivo)) }
    end
  end
end
