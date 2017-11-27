# -*- encoding: utf-8 -*-
shared_examples_for 'busca_logotipo' do
  it 'para layout padrão' do
    boleto_novo = described_class.new
    expect(File.exist?(boleto_novo.logotipo)).to be_truthy
    expect(File.stat(boleto_novo.logotipo).zero?).to be_falsey
  end

  it 'para layout de carnê' do
    Brcobranca.configuration.gerador = :rghost_carne
    boleto_novo = described_class.new
    expect(File.exist?(boleto_novo.logotipo)).to be_truthy
    expect(File.stat(boleto_novo.logotipo).zero?).to be_falsey
  end
end
