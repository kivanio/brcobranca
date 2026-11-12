# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab240::BtgPactual do
  let(:pagamento) do
    Brcobranca::Remessa::Pagamento.new(valor: 200.0,
                                       data_vencimento: Date.current,
                                       nosso_numero: 6380,
                                       numero: 23_845,
                                       documento: 23_845,
                                       documento_sacado: '99999990000130',
                                       nome_sacado: 'EMPRESA SACADO EXEMPLO',
                                       endereco_sacado: 'RUA LAURO MULLER, 1116',
                                       bairro_sacado: 'BOTAFOGO',
                                       cep_sacado: '22290160',
                                       cidade_sacado: 'RIO DE JANEIRO',
                                       uf_sacado: 'RJ',
                                       codigo_multa: '2',
                                       percentual_multa: 2.0)
  end
  let(:params) do
    { empresa_mae: 'EMPRESA CEDENTE',
      agencia: '50',
      conta_corrente: '999999',
      digito_conta: '0',
      documento_cedente: '30306294000145',
      convenio: '001100983001401000',
      sequencial_remessa: '3',
      pagamentos: [pagamento] }
  end
  let(:btg) { described_class.new(params) }

  context 'validacoes' do
    it 'é válido com os parâmetros mínimos' do
      expect(btg.valid?).to be true
    end

    it 'exige o dígito da conta' do
      objeto = described_class.new(params.merge(digito_conta: nil))
      expect(objeto.invalid?).to be true
      expect(objeto.errors.full_messages).to include('Digito conta não pode estar em branco.')
    end

    it 'exige dígito da conta com 1 caractere' do
      btg.digito_conta = '12'
      expect(btg.invalid?).to be true
      expect(btg.errors.full_messages).to include('Digito conta deve ter 1 dígito.')
    end

    it 'limita a agência a 4 dígitos' do
      btg.agencia = '12345'
      expect(btg.invalid?).to be true
      expect(btg.errors.full_messages).to include('Agencia deve ser menor ou igual a 4 dígitos.')
    end

    it 'limita a conta corrente a 7 dígitos' do
      btg.conta_corrente = '12345678'
      expect(btg.invalid?).to be true
      expect(btg.errors.full_messages).to include('Conta corrente deve ser menor ou igual a 7 dígitos.')
    end

    it 'aceita remessa sem convênio' do
      expect(described_class.new(params.merge(convenio: nil)).valid?).to be true
    end

    it 'rejeita dígito da agência com mais de 1 caractere' do
      btg.digito_agencia = '12'
      expect(btg.invalid?).to be true
      expect(btg.errors.full_messages).to include('Digito agencia deve ter no máximo 1 caractere alfanumérico.')
    end

    it 'rejeita quebra de linha no dígito da agência, no dígito da conta e no convênio' do
      objeto = described_class.new(params.merge(digito_agencia: "\n", digito_conta: "\r", convenio: "4220\r\n91"))
      expect(objeto.invalid?).to be true
      expect(objeto.errors.full_messages).to include(
        'Digito agencia deve ter no máximo 1 caractere alfanumérico.',
        'Digito conta não pode conter caracteres de controle.',
        'Convenio não pode conter caracteres de controle.'
      )
    end

    it 'rejeita versões de layout não numéricas' do
      objeto = described_class.new(params.merge(versao_layout_arquivo: 'ABC'))
      expect(objeto.invalid?).to be true
      expect(objeto.errors.full_messages).to include('Versao layout arquivo deve ter 3 dígitos.')
    end

    it 'mede o tamanho de valores numéricos pela quantidade de dígitos' do
      expect(described_class.new(params.merge(agencia: 50, conta_corrente: 2_172_140)).valid?).to be true
      expect(described_class.new(params.merge(conta_corrente: 12_345_678)).invalid?).to be true
    end

    it 'rejeita nosso número com mais de 11 dígitos em vez de truncar' do
      pagamento.nosso_numero = '9912345678901'
      expect(btg.invalid?).to be true
      expect(btg.errors.full_messages).to include('Nosso numero "9912345678901" deve ter de 1 a 11 dígitos numéricos.')
      expect { btg.gera_arquivo }.to raise_error(Brcobranca::RemessaInvalida)
    end

    it 'rejeita nosso número com caracteres não numéricos ou quebra de linha' do
      ["123\n", "12\r\n34", '12A', '12 34'].each do |nosso_numero|
        pagamento.nosso_numero = nosso_numero
        expect(btg.invalid?).to be(true), "#{nosso_numero.inspect} deveria ser rejeitado"
        expect { btg.gera_arquivo }.to raise_error(Brcobranca::RemessaInvalida)
      end
    end

    it 'aceita nosso número numérico de 1 a 11 dígitos' do
      [1, '6380', '12345678901'].each do |nosso_numero|
        pagamento.nosso_numero = nosso_numero
        expect(btg.valid?).to be(true), "#{nosso_numero.inspect} deveria ser aceito"
      end
    end

    it 'limita o convênio a 20 caracteres' do
      btg.convenio = '1' * 21
      expect(btg.invalid?).to be true
      expect(btg.errors.full_messages).to include('Convenio deve ser menor ou igual a 20 caracteres.')
    end
  end

  context 'formatacao' do
    it 'codigo do banco deve retornar 208' do
      expect(btg.cod_banco).to eq '208'
    end

    it 'nome do banco deve ter 30 posicoes' do
      expect(btg.nome_banco).to eq 'BANCO BTG PACTUAL S.A.        '
    end

    it 'usa as versoes de layout do FEBRABAN 10.9 por padrao' do
      expect(btg.versao_layout_arquivo).to eq '103'
      expect(btg.versao_layout_lote).to eq '060'
    end

    it 'converte versoes de layout numericas para texto' do
      objeto = described_class.new(params.merge(versao_layout_arquivo: 103, versao_layout_lote: 60))
      expect(objeto.monta_header_arquivo[163..165]).to eq '103'
      expect(objeto.invalid?).to be true
      expect(objeto.errors.full_messages).to include('Versao layout lote deve ter 3 dígitos.')
    end

    it 'permite sobrescrever as versoes de layout' do
      objeto = described_class.new(params.merge(versao_layout_arquivo: '083', versao_layout_lote: '000'))
      expect(objeto.monta_header_arquivo[163..165]).to eq '083'
      expect(objeto.monta_header_lote(1)[13..15]).to eq '000'
    end

    it 'codigo do convenio deve ter 20 caracteres alinhados a esquerda' do
      expect(btg.codigo_convenio).to eq '001100983001401000  '
      expect(btg.convenio_lote).to eq btg.codigo_convenio
    end

    it 'digito da agencia em branco quando nao informado' do
      expect(btg.digito_agencia).to eq ' '
    end

    it 'info_conta deve retornar as informacoes nas posicoes corretas' do
      info_conta = btg.info_conta
      expect(info_conta.size).to eq 20
      expect(info_conta[0..4]).to eq '00050'          # agencia
      expect(info_conta[5]).to eq ' '                 # digito agencia
      expect(info_conta[6..17]).to eq '000000999999'  # conta corrente
      expect(info_conta[18]).to eq '0'                # dv conta corrente
      expect(info_conta[19]).to eq ' '                # dv agencia/conta
    end

    it 'complemento P deve retornar o nosso numero sem DV com 20 posicoes' do
      comp_p = btg.complemento_p(pagamento)
      expect(comp_p.size).to eq 34
      expect(comp_p[0..11]).to eq '000000999999'      # conta corrente
      expect(comp_p[12]).to eq '0'                    # dv conta corrente
      expect(comp_p[13]).to eq ' '                    # dv agencia/conta
      expect(comp_p[14..33]).to eq '00000000000000006380' # nosso numero
    end

    it 'nosso numero com 11 digitos alinhado a direita em 20 posicoes' do
      pagamento.nosso_numero = '12345678901'
      expect(btg.formata_nosso_numero(pagamento)).to eq '00000000012345678901'
    end

    it 'segmento P com os padroes do BTG' do
      segmento_p = btg.monta_segmento_p(pagamento, 1, 1)
      expect(segmento_p[57]).to eq '1'                # carteira: cobranca simples
      expect(segmento_p[58]).to eq '1'                # cadastramento: com registro
      expect(segmento_p[59]).to eq '1'                # tipo documento: tradicional
      expect(segmento_p[60]).to eq '2'                # emissao: cliente emite
      expect(segmento_p[61]).to eq '2'                # distribuicao: cliente distribui
      expect(segmento_p[106..107]).to eq '02'         # especie: DM
      expect(segmento_p[108]).to eq 'N'               # aceite
      expect(segmento_p[227..228]).to eq '09'         # moeda: real
    end

    it 'complemento header deve ter 29 brancos' do
      expect(btg.complemento_header).to eq ''.rjust(29, ' ')
    end

    it 'complemento trailer deve ter os totais zerados e 217 posicoes' do
      comp_trailer = btg.complemento_trailer
      expect(comp_trailer.size).to eq 217
      expect(comp_trailer[0..91]).to eq ''.rjust(92, '0')
      expect(comp_trailer[92..216]).to eq ''.rjust(125, ' ')
    end

    it 'trailer do arquivo com a quantidade de contas para conciliacao zerada' do
      trailer = btg.monta_trailer_arquivo(1, 6)
      expect(trailer.size).to eq 240
      expect(trailer[0..7]).to eq '20899999'
      expect(trailer[17..22]).to eq '000001'
      expect(trailer[23..28]).to eq '000006'
      expect(trailer[29..34]).to eq '000000'
    end
  end

  context 'geracao remessa' do
    it_behaves_like 'cnab240'

    context 'arquivo' do
      before { Timecop.freeze(Time.local(2024, 5, 2, 10, 50, 45)) }

      after { Timecop.return }

      it 'todas as linhas tem 240 posicoes' do
        btg.gera_arquivo.split("\r\n").each { |linha| expect(linha.size).to eq 240 }
      end

      it { expect(btg.gera_arquivo).to eq(read_remessa('remessa-btg-pactual-cnab240.rem', btg.gera_arquivo)) }
    end
  end
end
