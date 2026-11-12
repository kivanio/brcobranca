# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brcobranca::Retorno::Cnab240::BtgPactual do
  # Arquivos de exemplo do kit de homologação do BTG (docs/BtgPactual).
  let(:arquivo) { File.join(File.dirname(__FILE__), '..', '..', '..', 'arquivos', nome_arquivo) }

  context 'retorno padrão' do
    let(:nome_arquivo) { 'CNAB240BTGPACTUAL.RET' }

    it 'gera um retorno por título (segmentos T e U)' do
      expect(described_class.load_lines(arquivo).size).to eq(3)
    end

    it 'lê os campos do segmento T' do
      pagamento = described_class.load_lines(arquivo).first

      expect(pagamento.codigo_registro).to eql('3')
      expect(pagamento.sequencial).to eql('00019')
      expect(pagamento.codigo_ocorrencia).to eql('06')
      expect(pagamento.agencia_com_dv).to eql('000500')
      expect(pagamento.cedente_com_dv).to eql('0000009999999')
      expect(pagamento.nosso_numero).to eql('00000000000000009999')
      expect(pagamento.documento_numero).to eql('0000140015-02')
      expect(pagamento.data_vencimento).to eql('30042024')
      expect(pagamento.valor_titulo).to eql('000000004552875')
      expect(pagamento.banco_recebedor).to eql('208')
      expect(pagamento.agencia_recebedora_com_dv).to eql('000500')
      expect(pagamento.valor_tarifa).to eql('000000000000000')
      expect(pagamento.motivo_ocorrencia).to eql([])
    end

    it 'lê os campos do segmento U' do
      pagamento = described_class.load_lines(arquivo).first

      expect(pagamento.juros_mora).to eql('000000000000000')
      expect(pagamento.desconto_concedito).to eql('000000000000000')
      expect(pagamento.valor_abatimento).to eql('000000000000000')
      expect(pagamento.iof_desconto).to eql('000000000000000')
      expect(pagamento.valor_recebido).to eql('000000004552875')
      expect(pagamento.valor_lancamento).to eql('000000004552875')
      expect(pagamento.outras_despesas).to eql('000000000000000')
      expect(pagamento.outros_recebimento).to eql('000000000000000')
      expect(pagamento.data_ocorrencia).to eql('02052024')
      expect(pagamento.data_credito).to eql('02052024')
    end

    it 'não preenche dados de Pix sem o segmento Y-04' do
      pagamento = described_class.load_lines(arquivo).first

      expect(pagamento.tipo_chave_dict).to be_nil
      expect(pagamento.codigo_chave_dict).to be_nil
      expect(pagamento.txid).to be_nil
    end

    it 'ignora headers e trailers mesmo com filtro except do chamador' do
      retornos = described_class.load_lines(arquivo, except: /^$/)
      expect(retornos.size).to eq(3)
      expect(retornos.map(&:codigo_registro).uniq).to eq(['3'])
    end

    it 'é despachado pela base a partir do código 208, apesar do BOM no header' do
      expect(Brcobranca::Retorno::Cnab240::Base.codigo_banco_do_arquivo(arquivo)).to eq('208')
      expect(Brcobranca::Retorno::Cnab240::Base.load_lines(arquivo).first).to be_a(described_class)
    end
  end

  context 'com segmentos T e U fora de ordem' do
    let(:linhas) { File.readlines(File.join(File.dirname(__FILE__), '..', '..', '..', 'arquivos', 'CNAB240BTGPACTUAL.RET')) }
    let(:t) { linhas.find { |l| l[13] == 'T' } }
    let(:u) { linhas.find { |l| l[13] == 'U' } }
    let(:arquivo_invalido) { Tempfile.new(['btg', '.RET']) }

    after { arquivo_invalido.close! }

    def le(*segmentos)
      arquivo_invalido.write(segmentos.join)
      arquivo_invalido.flush
      described_class.load_lines(arquivo_invalido.path)
    end

    it 'rejeita T sem U antes do próximo T' do
      expect { le(t, t, u) }.to raise_error(ArgumentError, /Segmento T sem o segmento U/)
    end

    it 'rejeita T sem U no fim do arquivo' do
      expect { le(t, u, t) }.to raise_error(ArgumentError, /fim do retorno/)
    end

    it 'rejeita U sem T anterior' do
      expect { le(u, t, u) }.to raise_error(ArgumentError, /Segmento U sem segmento T/)
    end

    it 'rejeita U duplicado' do
      expect { le(t, u, u) }.to raise_error(ArgumentError, /Segmento U sem segmento T anterior ou duplicado/)
    end
  end

  context 'retorno com Bolepix (segmento Y-04)' do
    let(:nome_arquivo) { 'CNAB240BTGPACTUAL_BOLEPIX.RET' }

    it 'agrupa T, U e Y-04 em um único retorno por título' do
      expect(described_class.load_lines(arquivo).size).to eq(3)
    end

    it 'lê os dados do Pix do segmento Y-04' do
      pagamento = described_class.load_lines(arquivo).first

      expect(pagamento.codigo_ocorrencia).to eql('06')
      expect(pagamento.valor_recebido).to eql('000000004552875')
      expect(pagamento.tipo_chave_dict).to eql('5')
      expect(pagamento.codigo_chave_dict)
        .to eql('api.developer.btgpactual.com/v1/p/v2/cobv/2bd8534288dace48b9d7abbabf20ac53')
      expect(pagamento.txid).to eql('859aahugg1134f00333nhjensh41a5e6')
    end

    it 'mantém os dados de cada título separados' do
      ultimo = described_class.load_lines(arquivo).last

      expect(ultimo.codigo_ocorrencia).to eql('09')
      expect(ultimo.codigo_chave_dict).to end_with('2bd8534288dace48b9d7abbabf20ac52')
    end
  end
end
