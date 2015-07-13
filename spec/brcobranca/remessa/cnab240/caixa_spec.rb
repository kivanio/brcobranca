# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab240::Caixa do
  let(:pagamento) do
    Brcobranca::Remessa::Pagamento.new(valor: 199.9,
                                       data_vencimento: Date.today,
                                       nosso_numero: 123,
                                       documento_sacado: '12345678901',
                                       nome_sacado: 'nome',
                                       endereco_sacado: 'endereco',
                                       bairro_sacado: 'bairro',
                                       cep_sacado: '12345678',
                                       cidade_sacado: 'cidade',
                                       uf_sacado: 'SP')
  end
  let(:params) do
    { empresa_mae: 'teste',
      agencia: '12345',
      conta_corrente: '1234',
      documento_cedente: '12345678901',
      convenio: '123456',
      versao_aplicativo: '1234',
      digito_agencia: '1',
      pagamentos: [pagamento] }
  end
  let(:caixa) { subject.class.new(params) }

  context 'validacoes' do
    context '@versao_aplicativo' do
      it 'deve ser invalido se nao possuir a versao do aplicativo' do
        objeto = subject.class.new(params.merge!(versao_aplicativo: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Versao aplicativo não pode estar em branco.')
      end

      it 'deve ser invalido se a versao do aplicativo tiver mais de 4 digitos' do
        caixa.versao_aplicativo = '12345'
        expect(caixa.invalid?).to be true
        expect(caixa.errors.full_messages).to include('Versao aplicativo não deve ter mais de 4 dígitos.')
      end
    end

    context '@digito_agencia' do
      it 'deve ser invalido se nao possuir o digito da agencia' do
        objeto = subject.class.new(params.merge!(digito_agencia: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Digito agencia não pode estar em branco.')
      end

      it 'deve ser invalido se o digito da agencia nao tiver 1 digito' do
        caixa.digito_agencia = '12'
        expect(caixa.invalid?).to be true
        expect(caixa.errors.full_messages).to include('Digito agencia deve ter 1 dígito.')
      end
    end

    context '@convenio' do
      it 'deve ser invalido se o convenio tiver mais de 6 digitos' do
        caixa.convenio = '1234567'
        expect(caixa.invalid?).to be true
        expect(caixa.errors.full_messages).to include('Convenio não deve ter mais de 6 dígitos.')
      end
    end

    context '@modalidade_carteira' do
      it 'padrao da modalidade deve ser 14' do
        expect(subject.class.new.modalidade_carteira).to eq '14'
      end

      it 'deve ser invalido se a modalidade de carteira tiver mais de 2 digitos' do
        caixa.modalidade_carteira = '123'
        expect(caixa.invalid?).to be true
        expect(caixa.errors.full_messages).to include('Modalidade carteira deve ter 2 dígitos.')
      end
    end
  end

  context 'formatacao' do
    it 'codigo do banco deve retornar 104' do
      expect(caixa.cod_banco).to eq '104'
    end

    it 'nome do banco deve ser Caixa com 30 posicoes' do
      nome_banco = caixa.nome_banco
      expect(nome_banco.size).to eq 30
      expect(nome_banco[0..22]).to eq 'CAIXA ECONOMICA FEDERAL'
    end

    it 'versao do layout do arquivo deve retornar 050' do
      expect(caixa.versao_layout_arquivo).to eq '050'
    end

    it 'versao do layout do lote deve ser 040' do
      expect(caixa.versao_layout_lote).to eq '030'
    end

    it 'codigo do convenio deve ser 20 zeros' do
      expect(caixa.codigo_convenio).to eq ''.rjust(20, '0')
    end

    it 'convenio lote deve retornar as informacoes nas posicoes corretas' do
      conv_lote = caixa.convenio_lote
      expect(conv_lote[0..5]).to eq '123456'
      expect(conv_lote[6..19]).to eq ''.rjust(14, ' ')
    end

    it 'info_conta deve retornar as informacoes nas posicoes corretas' do
      info_conta = caixa.info_conta
      expect(info_conta[0..4]).to eq '12345'    # agencia
      expect(info_conta[5]).to eq '1'           # digito agencia
      expect(info_conta[6..11]).to eq '123456'  # convenio
    end

    it 'complemento header deve retornar as informacoes nas posicoes corretas' do
      comp_header = caixa.complemento_header
      expect(comp_header.size).to eq 29
      expect(comp_header[0..3]).to eq '1234'  # versao do aplicativo
    end

    it 'complemento trailer deve retornar as informacoes nas posicoes corretas' do
      comp_trailer = caixa.complemento_trailer
      expect(comp_trailer.size).to eq 217
      expect(comp_trailer[0..68]).to eq ''.rjust(69, '0')
      expect(comp_trailer[69..216]).to eq ''.rjust(148, ' ')
    end

    it 'complemento P deve retornar as informacoes nas posicoes corretas' do
      comp_p = caixa.complemento_p pagamento
      expect(comp_p.size).to eq 34
      expect(comp_p[0..5]).to eq '123456'             # convenio
      expect(comp_p[17..18]).to eq '14'               # modalidade carteira
      expect(comp_p[19..33]).to eq '000000000000123'  # nosso numero
    end
  end

  context 'geracao remessa' do
    it_behaves_like 'cnab240'
  end
end
