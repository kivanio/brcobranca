# frozen_string_literal: true

shared_examples_for 'busca_logotipo' do
  it 'para layout padrão' do
    boleto_novo = described_class.new
    expect(File).to exist(boleto_novo.logotipo)
    expect(File.stat(boleto_novo.logotipo)).not_to be_zero
  end

  it 'para layout de carnê' do
    Brcobranca.configuration.gerador = :rghost_carne
    boleto_novo = described_class.new
    expect(File).to exist(boleto_novo.logotipo)
    expect(File.stat(boleto_novo.logotipo)).not_to be_zero
  end
end
