require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BancoBanespa do

  before(:each) do
    @valid_attributes = {
      :especie_documento => "DM",
      :moeda => "9",
      :banco => "033",
      :data_documento => Date.today,
      :dias_vencimento => 1,
      :aceite => "S",
      :quantidade => 1,
      :valor => 0.0,
      :local_pagamento => "QUALQUER BANCO ATÉ O VENCIMENTO",
      :cedente => "Kivanio Barbosa",
      :documento_cedente => "12345678912",
      :sacado => "Claudio Pozzebom",
      :sacado_documento => "12345678900",
      :agencia => "400",
      :conta_corrente => "61900",
      :convenio => 12387989,
      :numero_documento => "777700168"
    }
  end

  it "Criar nova instancia com atributos padrões" do
    boleto_novo = BancoBanespa.new
    boleto_novo.banco.should eql("033")
    boleto_novo.especie_documento.should eql("DM")
    boleto_novo.especie.should eql("R$")
    boleto_novo.moeda.should eql("9")
    boleto_novo.data_documento.should eql(Date.today)
    boleto_novo.dias_vencimento.should eql(1)
    boleto_novo.data_vencimento.should eql(Date.today + 1)
    boleto_novo.aceite.should eql("S")
    boleto_novo.quantidade.should eql(1)
    boleto_novo.valor.should eql(0.0)
    boleto_novo.valor_documento.should eql(0.0)
    boleto_novo.local_pagamento.should eql("QUALQUER BANCO ATÉ O VENCIMENTO")
    boleto_novo.carteira.should eql("COB")
    boleto_novo.should be_instance_of(BancoBanespa)
  end

  it "Criar nova instancia com atributos válidos" do
    boleto_novo = BancoBanespa.new(@valid_attributes)
    boleto_novo.banco.should eql("033")
    boleto_novo.especie_documento.should eql("DM")
    boleto_novo.especie.should eql("R$")
    boleto_novo.moeda.should eql("9")
    boleto_novo.data_documento.should eql(Date.today)
    boleto_novo.dias_vencimento.should eql(1)
    boleto_novo.data_vencimento.should eql(Date.today + 1)
    boleto_novo.aceite.should eql("S")
    boleto_novo.quantidade.should eql(1)
    boleto_novo.valor.should eql(0.0)
    boleto_novo.valor_documento.should eql(0.0)
    boleto_novo.local_pagamento.should eql("QUALQUER BANCO ATÉ O VENCIMENTO")
    boleto_novo.cedente.should eql("Kivanio Barbosa")
    boleto_novo.documento_cedente.should eql("12345678912")
    boleto_novo.sacado.should eql("Claudio Pozzebom")
    boleto_novo.sacado_documento.should eql("12345678900")
    boleto_novo.conta_corrente.should eql("61900")
    boleto_novo.agencia.should eql("400")
    boleto_novo.convenio.should eql(12387989)
    boleto_novo.numero_documento.should eql("777700168")
    boleto_novo.carteira.should eql("COB")
    boleto_novo.should be_instance_of(BancoBanespa)
  end

  it "Não permitir gerar boleto com atributos inválido" do
    @valid_attributes[:valor] = 0
    @valid_attributes[:data_documento] = Date.parse("2008-02-01")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = ""
    @valid_attributes[:banco] = ""
    @valid_attributes[:carteira] = ""
    @valid_attributes[:moeda] = ""
    @valid_attributes[:convenio] = ""

    boleto_novo = BancoBanespa.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBanespa)
    lambda { boleto_novo.monta_codigo_43_digitos }.should raise_error(ArgumentError)
    lambda { boleto_novo.codigo_barras }.should raise_error(ArgumentError)
  end

  it "Gerar boleto" do
    @valid_attributes[:valor] = 103.58
    @valid_attributes[:data_documento] = Date.parse("2001-08-01")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:convenio] = 14813026478
    @valid_attributes[:numero_documento] = "0004952"
    @valid_attributes[:conta_corrente] = "0403005"
    boleto_novo = BancoBanespa.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBanespa)
    boleto_novo.conta_corrente_dv.should eql(2)
    boleto_novo.monta_codigo_43_digitos.should eql("0339139400000103581481302647800049520003306")
    boleto_novo.codigo_barras.should eql("03398139400000103581481302647800049520003306")
    boleto_novo.codigo_barras.linha_digitavel.should eql("03391.48132 02647.800040 95200.033066 8 13940000010358")

    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_documento] = Date.parse("2009-08-14")
    @valid_attributes[:dias_vencimento] = 5
    @valid_attributes[:convenio] = 40013012168
    @valid_attributes[:numero_documento] = "1234567"
    @valid_attributes[:conta_corrente] = "0403005"
    boleto_novo = BancoBanespa.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBanespa)
    boleto_novo.conta_corrente_dv.should eql(2)
    boleto_novo.monta_codigo_43_digitos.should eql("0339433400002952954001301216812345670003361")
    boleto_novo.codigo_barras.should eql("03398433400002952954001301216812345670003361")
    boleto_novo.codigo_barras.linha_digitavel.should eql("03394.00137 01216.812345 56700.033618 8 43340000295295")
  end

  it "Montar campo_livre_com_dv1_e_dv2" do
    @valid_attributes[:convenio] = "40013012168"
    @valid_attributes[:numero_documento] = "7469108"
    boleto_novo = BancoBanespa.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBanespa)
    boleto_novo.campo_livre_com_dv1_e_dv2.should eql("4001301216874691080003384")

    @valid_attributes[:convenio] = "40013012168"
    @valid_attributes[:numero_documento] = "1234567"
    boleto_novo = BancoBanespa.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBanespa)
    boleto_novo.campo_livre_com_dv1_e_dv2.should eql("4001301216812345670003361")
  end

  it "Montar nosso_numero e nosso_numero_dv" do
    @valid_attributes[:numero_documento] = "0403005"
    boleto_novo = BancoBanespa.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBanespa)
    boleto_novo.nosso_numero.should eql("4000403005")
    boleto_novo.nosso_numero_dv.should eql(6)
    boleto_novo.nosso_numero_boleto.should eql("400 0403005 6")

    @valid_attributes[:numero_documento] = "403005"
    boleto_novo = BancoBanespa.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBanespa)
    boleto_novo.nosso_numero.should eql("4000403005")
    boleto_novo.nosso_numero_dv.should eql(6)
    boleto_novo.nosso_numero_boleto.should eql("400 0403005 6")

    @valid_attributes[:numero_documento] = "1234567"
    boleto_novo = BancoBanespa.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBanespa)
    boleto_novo.nosso_numero.should eql("4001234567")
    boleto_novo.nosso_numero_dv.should eql(8)
    boleto_novo.nosso_numero_boleto.should eql("400 1234567 8")

    @valid_attributes[:agencia] = "123"
    boleto_novo = BancoBanespa.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBanespa)
    boleto_novo.nosso_numero.should eql("1231234567")
    boleto_novo.nosso_numero_dv.should eql(0)
    boleto_novo.nosso_numero_boleto.should eql("123 1234567 0")

    @valid_attributes[:agencia] = "123"
    @valid_attributes[:numero_documento] = "7469108"
    boleto_novo = BancoBanespa.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBanespa)
    boleto_novo.nosso_numero.should eql("1237469108")
    boleto_novo.nosso_numero_dv.should eql(3)
    boleto_novo.nosso_numero_boleto.should eql("123 7469108 3")
  end

  it "Montar agencia_conta_dv" do
    boleto_novo = BancoBanespa.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBanespa)
    boleto_novo.agencia_conta_boleto.should eql("000 12 38798 9")
  end

  it "Gerar boleto nos formatos válidos" do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_documento] = Date.parse("2009-08-14")
    @valid_attributes[:dias_vencimento] = 5
    @valid_attributes[:convenio] = 40013012168
    @valid_attributes[:numero_documento] = "1234567"
    @valid_attributes[:conta_corrente] = "0403005"
    boleto_novo = BancoBanespa.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBanespa)
    %w| pdf jpg tif png ps |.each do |format|
      file_body=boleto_novo.to(format.to_sym)
      tmp_file=Tempfile.new("foobar." << format)
      tmp_file.puts file_body
      tmp_file.close
      File.exist?(tmp_file.path).should be_true
      File.stat(tmp_file.path).zero?.should be_false
      File.delete(tmp_file.path).should eql(1)
      File.exist?(tmp_file.path).should be_false
    end
  end

end