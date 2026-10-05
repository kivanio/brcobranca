# frozen_string_literal: true

shared_examples_for 'busca_logotipo' do
  around do |example|
    gerador_original = Brcobranca.configuration.gerador
    example.run
  ensure
    Brcobranca.configuration.gerador = gerador_original
  end

  it 'para layout padrão' do
    boleto_novo = described_class.new

    expect(Brcobranca.configuration.gerador).to be(:rghost)
    expect(boleto_novo.logotipo).to match(/\.eps\z/)
    expect(File).to exist(boleto_novo.logotipo)
    expect(File.stat(boleto_novo.logotipo)).not_to be_zero
  end

  it 'para layout de carnê' do
    Brcobranca.configuration.gerador = :rghost_carne
    boleto_novo = described_class.new

    expect(boleto_novo.logotipo).to match(/\.eps\z/)
    expect(File).to exist(boleto_novo.logotipo)
    expect(File.stat(boleto_novo.logotipo)).not_to be_zero
  end

  it 'para layout com prawn' do
    Brcobranca.configuration.gerador = :prawn
    boleto_novo = described_class.new

    expect(boleto_novo.logotipo).to match(/\.png\z/)
    expect(File).to exist(boleto_novo.logotipo)
    expect(File.stat(boleto_novo.logotipo)).not_to be_zero
  end
end
