# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab240::Cecred do
  let(:pagamento) do
    Brcobranca::Remessa::Pagamento.new(valor: 199.9,
      data_vencimento: Date.current,
      nosso_numero: 123,
      numero: 123,
      documento: 6969,
      documento_sacado: '12345678901',
      nome_sacado: 'PABLO DIEGO JOSÉ FRANCISCO,!^.?\/@  DE PAULA JUAN NEPOMUCENO MARÍA DE LOS REMEDIOS CIPRIANO DE LA SANTÍSSIMA TRINIDAD RUIZ Y PICASSO',
      endereco_sacado: 'RUA RIO GRANDE DO SUL,!^.?\/@ São paulo Minas caçapa da silva junior',
      bairro_sacado: 'São josé dos quatro apostolos magros',
      cep_sacado: '12345678',
      cidade_sacado: 'Santa rita de cássia maria da silva',
      uf_sacado: 'SP',
      codigo_multa: '2',
      percentual_multa: 2.0)
  end
  let(:params) do
    { empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
      agencia: '12345',
      conta_corrente: '1234567',
      documento_cedente: '12345678901',
      convenio: '123456',
      digito_agencia: '1',
      sequencial_remessa: '000001',
      pagamentos: [pagamento] }
  end
  let(:cecred) { subject.class.new(params) }

  context 'validacoes' do
    context '@digito_agencia' do
      it 'deve ser invalido se nao possuir o digito da agencia' do
        objeto = subject.class.new(params.merge!(digito_agencia: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Digito agencia não pode estar em branco.')
      end

      it 'deve ser invalido se o digito da agencia nao tiver 1 digito' do
        cecred.digito_agencia = '12'
        expect(cecred.invalid?).to be true
        expect(cecred.errors.full_messages).to include('Digito agencia deve ter 1 dígito.')
      end
    end

    context '@convenio' do
      it 'deve ser invalido se nao possuir o convenio' do
        objeto = subject.class.new(params.merge!(convenio: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Convenio não pode estar em branco.')
      end

      it 'deve ser invalido se o convenio tiver mais de 6 digitos' do
        cecred.convenio = '1234567'
        expect(cecred.invalid?).to be true
        expect(cecred.errors.full_messages).to include('Convenio deve ter 6 dígitos.')
      end
    end

    context '@conta_corrente' do
      it 'deve ser invalido se nao possuir o conta corrente' do
        objeto = subject.class.new(params.merge!(conta_corrente: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Conta corrente não pode estar em branco.')
      end

      it 'deve ser invalido se o conta corrente tiver mais de 7 digitos' do
        cecred.conta_corrente = ''.rjust(8, '0')
        expect(cecred.invalid?).to be true
        expect(cecred.errors.full_messages).to include('Conta corrente deve ter 7 dígitos.')
      end
    end
  end

  context 'formatacao' do
    it 'codigo do banco deve retornar 085' do
      expect(cecred.cod_banco).to eq '085'
    end

    it 'nome do banco deve ser Cecred com 30 posicoes' do
      nome_banco = cecred.nome_banco
      expect(nome_banco.size).to eq 30
      expect(nome_banco[0..5]).to eq 'CECRED'
    end

    it 'versao do layout do arquivo deve retornar 087' do
      expect(cecred.versao_layout_arquivo).to eq '087'
    end

    it 'versao do layout do lote deve ser 045' do
      expect(cecred.versao_layout_lote).to eq '045'
    end

    it 'codigo do convenio deve ser 20 caracteres' do
      expect(cecred.codigo_convenio).to eq '123456'.ljust(20, ' ')
    end

    it 'convenio lote deve retornar as informacoes nas posicoes corretas' do
      conv_lote = cecred.convenio_lote
      expect(conv_lote[0..5]).to eq '123456'
      expect(conv_lote[6..19]).to eq ''.rjust(14, ' ')
    end

    it 'info_conta deve retornar as informacoes nas posicoes corretas' do
      info_conta = cecred.info_conta
      expect(info_conta[0..4]).to eq '12345'            # agencia
      expect(info_conta[5]).to eq '1'                   # digito agencia
      expect(info_conta[6..17]).to eq '000001234567'    # conta corrente
      expect(info_conta[18]).to eq '9'                  # dv conta corrente
      expect(info_conta[19]).to eq ' '                  # dv agencia/conta
    end

    it 'complemento header deve retornar as informacoes nas posicoes corretas' do
      comp_header = cecred.complemento_header
      expect(comp_header.size).to eq 29
      expect(comp_header[0..28]).to eq ''.rjust(29, ' ')
    end

    it 'complemento trailer deve retornar as informacoes nas posicoes corretas' do
      comp_trailer = cecred.complemento_trailer
      expect(comp_trailer.size).to eq 217

      total_cobranca_simples    = "00000100000000000019990"
      total_cobranca_vinculada  = "".rjust(23, "0")
      total_cobranca_caucionada = "".rjust(23, "0")
      total_cobranca_descontada = "".rjust(23, "0")

      expect(comp_trailer).to eq "#{total_cobranca_simples}#{total_cobranca_vinculada}"\
                            "#{total_cobranca_caucionada}#{total_cobranca_descontada}".ljust(217, ' ')

    end

    it 'complemento P deve retornar as informacoes nas posicoes corretas' do
      comp_p = cecred.complemento_p pagamento
      expect(comp_p.size).to eq 34
      expect(comp_p[0..11]).to eq '000001234567'        # conta corrente
      expect(comp_p[12]).to eq '9'                      # dv conta corrente
      expect(comp_p[13]).to eq ' '                      # dv agencia/conta
      expect(comp_p[14..33]).to eq '12345679000000123'.ljust(20, ' ') # nosso numero
    end

    it 'tipo do documento deve ser 1 - Tradicional' do
      expect(cecred.tipo_documento).to eq '1'
    end

    it 'deve conter a identificacao do titulo da empresa' do
      segmento_p = cecred.monta_segmento_p(pagamento, 1, 2)
      expect(segmento_p[195..219]).to eq "6969".ljust(25, ' ')
    end
  end

  context 'geracao remessa' do
    it_behaves_like 'cnab240'

    context 'arquivo' do
      before { Timecop.freeze(Time.local(2015, 7, 14, 16, 15, 15)) }
      after { Timecop.return }

      it { expect(cecred.gera_arquivo).to eq(read_remessa('remessa-cecred-cnab240.rem', cecred.gera_arquivo)) }
    end
  end
end
