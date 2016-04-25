# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab400::Santander do
  let(:pagamento) do
    Brcobranca::Remessa::Pagamento.new(valor: 199.9,
      data_vencimento: Date.today,
      nosso_numero: 123,
      documento_sacado: '12345678901',
      nome_sacado: 'PABLO DIEGO JOSÉ FRANCISCO DE PAULA JUAN NEPOMUCENO MARÍA DE LOS REMEDIOS CIPRIANO DE LA SANTÍSSIMA TRINIDAD RUIZ Y PICASSO',
      endereco_sacado: 'RUA RIO GRANDE DO SUL São paulo Minas caçapa da silva junior',
      bairro_sacado: 'São josé dos quatro apostolos magros',
      cep_sacado: '12345678',
      cidade_sacado: 'Santa rita de cássia maria da silva',
      uf_sacado: 'SP')
  end
  let(:params) do
    {
      codigo_transmissao: '17777751042700080112',
      empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
      documento_cedente: '12345678910',
      agencia: '8888',
      conta_corrente: '000002997',
      digito_conta: '8',
      pagamentos: [pagamento]
    }
  end
  let(:santander) { subject.class.new(params) }

  context 'validacoes dos campos' do
    context '@carteira' do
      it 'deve ser invalido se nao possuir uma carteira' do
        object = subject.class.new(params.merge!(carteira: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Carteira não pode estar em branco.')
      end

      it 'deve ser invalido' do
        object = subject.class.new
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to eq(["Pagamentos não pode estar em branco.", "Pagamentos deve ser uma coleção (Array).", "Empresa mae não pode estar em branco.", "Documento cedente não pode estar em branco.", "Documento cedente deve ter entre 11 e 14 dígitos.", "Codigo transmissao não pode estar em branco.", "Agencia não pode estar em branco.", "Conta corrente não pode estar em branco.", "Digito conta não pode estar em branco."])
      end

      it 'deve ser invalido se a carteira tiver mais de 3 digitos' do
        santander.carteira = '12345'
        expect(santander.invalid?).to be true
        expect(santander.errors.full_messages).to include('Carteira deve ter no máximo 3 dígitos.')
      end
    end

    context '@documento_cedente' do
      it 'deve ser invalido se nao possuir o documento cedente' do
        object = subject.class.new(params.merge!(documento_cedente: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Documento cedente não pode estar em branco.')
      end

      it 'deve ser invalido se o documento do cedente nao tiver entre 11 e 14 digitos' do
        santander.documento_cedente = '123'
        expect(santander.invalid?).to be true
        expect(santander.errors.full_messages).to include('Documento cedente deve ter entre 11 e 14 dígitos.')
      end
    end

    context '@codigo_transmissao' do
      it 'deve ser invalido se nao possuir o codigo_transmissao' do
        object = subject.class.new(params.merge!(codigo_transmissao: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Codigo transmissao não pode estar em branco.')
      end

      it 'deve ser invalido se o codigo_transmissao ter mais que 20 dígitos.' do
        santander.codigo_transmissao = '123456789012345678901'
        expect(santander.invalid?).to be true
        expect(santander.errors.full_messages).to include('Codigo transmissao deve ter no máximo 20 dígitos.')
      end
    end
  end

  context 'formatacoes dos valores' do
    it 'cod_banco deve ser 033' do
      expect(santander.cod_banco).to eq '033'
    end

    it 'nome_banco deve ser SANTANDER' do
      nome_banco = santander.nome_banco
      expect(nome_banco.strip).to eq 'SANTANDER'
    end

    it 'complemento deve retornar 275 caracteres' do
      expect(santander.complemento.size).to eq 275
    end

    it 'complemento zeros deve retornar 16 caracteres' do
      expect(santander.complemento_zeros.size).to eq 16
    end

    it 'info_conta deve retornar com 20 posicoes as informacoes da conta' do
      info_conta = santander.info_conta
      expect(info_conta.size).to eq 20
      expect(info_conta[0..19]).to eq '17777751042700080112' # codigo_transmissao

      cod_trans = '7777751042700080112'
      object = subject.class.new(params.merge!(codigo_transmissao: cod_trans))
      info_conta = object.info_conta
      expect(info_conta.size).to eq 20
      expect(info_conta[0..19]).to eq '07777751042700080112' # codigo_transmissao
    end
  end

  context 'monta remessa' do
    it_behaves_like 'cnab400'

    context 'header' do
      it 'informacoes devem estar posicionadas corretamente no header' do
        header = santander.monta_header
        expect(header[1]).to eq '1' # tipo operacao (1 = remessa)
        expect(header[2..8]).to eq 'REMESSA' # literal da operacao
        expect(header[26..45]).to eq santander.info_conta # informacoes da conta
        expect(header[76..78]).to eq '033' # codigo do banco
      end
    end

    context 'detalhe' do
      it 'informacoes devem estar posicionadas corretamente no detalhe' do
        detalhe = santander.monta_detalhe pagamento, 1
        expect(detalhe[62..69]).to eq '00000123' # nosso numero
        expect(detalhe[120..125]).to eq Date.today.strftime('%d%m%y') # data de vencimento
        expect(detalhe[126..138]).to eq '0000000019990' # valor do titulo
        expect(detalhe[220..233]).to eq '00012345678901' # documento do pagador
        expect(detalhe[234..263]).to eq 'PABLO DIEGO JOSE FRANCISCO DE ' # nome do pagador
      end
    end

    context 'trailer' do
      it 'trailer deve ter 400 posicoes' do
        expect(santander.monta_trailer(1).size).to eq 400
      end

      it 'informacoes devem estar posicionadas corretamente no trailer' do
        trailer = santander.monta_trailer 3
        expect(trailer[0]).to eq '9' # identificacao registro
        expect(trailer[1..6]).to eq '000003' # numero de linhas
        expect(trailer[7..19]).to eq '0000000019990' # valor total
        expect(trailer[20..393]).to eq ''.rjust(374, '0') # zeros
        expect(trailer[394..399]).to eq '000003' # numero sequencial do registro
      end
    end

    context 'arquivo' do
      before { Timecop.freeze(Time.local(2015, 7, 14, 16, 15, 15)) }
      after { Timecop.return }

      it { expect(santander.gera_arquivo).to eq(read_remessa('remessa-santander-cnab400.rem', santander.gera_arquivo)) }
    end
  end
end
