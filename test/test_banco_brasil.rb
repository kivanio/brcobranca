require File.join(File.dirname(__FILE__),'test_helper.rb')

class BancoBrasilTest < Test::Unit::TestCase #:nodoc:[all]

  def setup
    @boleto_novo = BancoBrasil.new
    @boleto_novo.cedente = "Kivanio Barbosa"
    @boleto_novo.documento_cedente = "12345678912"
    @boleto_novo.sacado = "Claudio Pozzebom"
    @boleto_novo.sacado_documento = "12345678900"
    @boleto_novo.aceite = "S"
    @boleto_novo.agencia = "4042"
    @boleto_novo.conta_corrente = "61900"
  end

  def boleto_convenio8_numero9_um
    @boleto_novo.banco = "001"
    @boleto_novo.carteira = "18"
    @boleto_novo.moeda = "9"
    @boleto_novo.valor = 135.00
    @boleto_novo.convenio = 12387989
    @boleto_novo.numero_documento = "777700168"
    @boleto_novo.data_documento = Date.parse("2008-02-01")
    @boleto_novo.dias_vencimento = 0
  end

  def boleto_convenio8_numero9_dois
    @boleto_novo.banco = "001"
    @boleto_novo.carteira = "18"
    @boleto_novo.moeda = "9"
    @boleto_novo.valor = 135.00
    @boleto_novo.convenio = 12387989
    @boleto_novo.numero_documento = "7700168"
    @boleto_novo.data_documento = Date.parse("2008-02-01")
    @boleto_novo.dias_vencimento = 1
  end

  def boleto_convenio7_numero10_um
    @boleto_novo.banco = "001"
    @boleto_novo.carteira = "18"
    @boleto_novo.moeda = "9"
    @boleto_novo.valor = 135.00
    @boleto_novo.convenio = 1238798
    @boleto_novo.numero_documento = "7777700168"
    @boleto_novo.data_documento = Date.parse("2008-02-01")
    @boleto_novo.dias_vencimento = 2
  end

  def boleto_convenio7_numero10_dois
    @boleto_novo.banco = "001"
    @boleto_novo.carteira = "18"
    @boleto_novo.moeda = "9"
    @boleto_novo.valor = 723.56
    @boleto_novo.convenio = 1238798
    @boleto_novo.numero_documento = "7777700168"
    @boleto_novo.data_documento = Date.parse("2008-02-01")
    @boleto_novo.dias_vencimento = 2
  end

  def boleto_convenio7_numero10_tres
    @boleto_novo.banco = "001"
    @boleto_novo.agencia = "4042"
    @boleto_novo.conta_corrente = "15735"
    @boleto_novo.carteira = "18"
    @boleto_novo.moeda = "9"
    @boleto_novo.valor = 723.56
    @boleto_novo.convenio = 1238798
    @boleto_novo.numero_documento = "7777700168"
    @boleto_novo.data_documento = Date.parse("2008-02-01")
    @boleto_novo.dias_vencimento = 0
  end

  def boleto_convenio6_numero5
    @boleto_novo.banco = "001"
    @boleto_novo.carteira = "18"
    @boleto_novo.agencia = "4042"
    @boleto_novo.conta_corrente = "61900"
    @boleto_novo.moeda = "9"
    @boleto_novo.valor = 135.00
    @boleto_novo.convenio = 123879
    @boleto_novo.numero_documento = "1234"
    @boleto_novo.data_documento = Date.parse("2008-02-01")
    @boleto_novo.dias_vencimento = 0
    @boleto_novo.codigo_servico = false
  end

  def boleto_convenio6_numero17_carteira16
    @boleto_novo.banco = "001"
    @boleto_novo.carteira = "16"
    @boleto_novo.agencia = "4042"
    @boleto_novo.conta_corrente = "61900"
    @boleto_novo.moeda = "9"
    @boleto_novo.valor = 135.00
    @boleto_novo.convenio = 123879
    @boleto_novo.numero_documento = "1234567899"
    @boleto_novo.data_documento = Date.parse("2008-02-01")
    @boleto_novo.dias_vencimento = 0
    @boleto_novo.codigo_servico = true
  end

  def boleto_convenio6_numero17_carteira17
    @boleto_novo.banco = "001"
    @boleto_novo.carteira = "17"
    @boleto_novo.agencia = "4042"
    @boleto_novo.conta_corrente = "61900"
    @boleto_novo.moeda = "9"
    @boleto_novo.valor = 135.00
    @boleto_novo.convenio = 123879
    @boleto_novo.numero_documento = "1234567899"
    @boleto_novo.data_documento = Date.parse("2008-02-01")
    @boleto_novo.dias_vencimento = 0
    @boleto_novo.codigo_servico = true
  end

  def boleto_convenio6_numero17_carteira18
    @boleto_novo.banco = "001"
    @boleto_novo.carteira = "18"
    @boleto_novo.agencia = "4042"
    @boleto_novo.conta_corrente = "61900"
    @boleto_novo.moeda = "9"
    @boleto_novo.valor = 135.00
    @boleto_novo.convenio = 123879
    @boleto_novo.numero_documento = "1234567899"
    @boleto_novo.data_documento = Date.parse("2008-02-01")
    @boleto_novo.dias_vencimento = 0
    @boleto_novo.codigo_servico = true
  end

  def boleto_convenio4_numero7
    @boleto_novo.banco = "001"
    @boleto_novo.carteira = "18"
    @boleto_novo.agencia = "4042"
    @boleto_novo.conta_corrente = "61900"
    @boleto_novo.moeda = "9"
    @boleto_novo.valor = 135.00
    @boleto_novo.convenio = 1238
    @boleto_novo.numero_documento = "123456"
    @boleto_novo.data_documento = Date.parse("2008-02-01")
    @boleto_novo.dias_vencimento = 0
  end

  def boleto_nil
    @boleto_novo.banco = ""
    @boleto_novo.carteira = ""
    @boleto_novo.moeda = ""
    @boleto_novo.valor = 0
    @boleto_novo.convenio = ""
    @boleto_novo.numero_documento = "" 
    @boleto_novo.data_documento = Date.parse("2008-02-01")
    @boleto_novo.dias_vencimento = 0
  end
  
  def test_should_initialize_correctly
    assert_equal '001', @boleto_novo.banco
    assert_equal "DM", @boleto_novo.especie_documento
    assert_equal "R$", @boleto_novo.especie
    assert_equal "9", @boleto_novo.moeda
    assert_equal Date.today, @boleto_novo.data_documento
    assert_equal 1, @boleto_novo.dias_vencimento
    assert_equal((Date.today + 1), @boleto_novo.data_vencimento)
    assert_equal "S", @boleto_novo.aceite
    assert_equal 1, @boleto_novo.quantidade
    assert_equal 0.0, @boleto_novo.valor
    assert_equal 0.0, @boleto_novo.valor_documento
    assert_equal "QUALQUER BANCO ATÉ O VENCIMENTO", @boleto_novo.local_pagamento
  end

  def test_should_mont_correct_codigo_barras
    boleto_convenio8_numero9_um
    assert_equal "0019376900000135000000001238798977770016818", @boleto_novo.monta_codigo_43_digitos
    assert_equal "00193376900000135000000001238798977770016818", @boleto_novo.codigo_barras
    boleto_convenio8_numero9_dois
    assert_equal "0019377000000135000000001238798900770016818", @boleto_novo.monta_codigo_43_digitos
    assert_equal "00193377000000135000000001238798900770016818", @boleto_novo.codigo_barras
    boleto_convenio7_numero10_um
    assert_equal "0019377100000135000000001238798777770016818", @boleto_novo.monta_codigo_43_digitos
    assert_equal "00193377100000135000000001238798777770016818", @boleto_novo.codigo_barras
    boleto_convenio7_numero10_dois
    assert_equal "0019377100000723560000001238798777770016818", @boleto_novo.monta_codigo_43_digitos
    assert_equal "00195377100000723560000001238798777770016818", @boleto_novo.codigo_barras
    boleto_convenio7_numero10_tres
    assert_equal "0019376900000723560000001238798777770016818", @boleto_novo.monta_codigo_43_digitos
    assert_equal "00194376900000723560000001238798777770016818", @boleto_novo.codigo_barras
    boleto_convenio6_numero5
    assert_equal "0019376900000135001238790123440420006190018", @boleto_novo.monta_codigo_43_digitos
    assert_equal "00192376900000135001238790123440420006190018", @boleto_novo.codigo_barras
    boleto_convenio6_numero17_carteira16
    assert_equal "0019376900000135001238790000000123456789921", @boleto_novo.monta_codigo_43_digitos
    assert_equal "00199376900000135001238790000000123456789921", @boleto_novo.codigo_barras
    assert_raise RuntimeError do
      boleto_convenio6_numero17_carteira17
      raise 'Verifique as informações do boleto!!!'
    end
    boleto_convenio6_numero17_carteira18
    assert_equal "0019376900000135001238790000000123456789921", @boleto_novo.monta_codigo_43_digitos
    assert_equal "00199376900000135001238790000000123456789921", @boleto_novo.codigo_barras
    boleto_convenio4_numero7
    assert_equal "0019376900000135001238012345640420006190018", @boleto_novo.monta_codigo_43_digitos
    assert_equal "00191376900000135001238012345640420006190018", @boleto_novo.codigo_barras
    boleto_nil
    assert_equal nil, @boleto_novo.codigo_barras
    assert_raise RuntimeError do
      boleto_nil
      raise 'Verifique as informações do boleto!!!'
    end
  end

  def test_should_mont_correct_linha_digitalvel
    boleto_convenio8_numero9_um
    assert_equal("00190.00009 01238.798977 77700.168188 3 37690000013500", @boleto_novo.codigo_barras.linha_digitavel)
    boleto_convenio8_numero9_dois
    assert_equal("00190.00009 01238.798902 07700.168185 3 37700000013500", @boleto_novo.codigo_barras.linha_digitavel)
    boleto_convenio7_numero10_um
    assert_equal("00190.00009 01238.798779 77700.168188 3 37710000013500", @boleto_novo.codigo_barras.linha_digitavel)
    boleto_convenio7_numero10_dois
    assert_equal("00190.00009 01238.798779 77700.168188 5 37710000072356", @boleto_novo.codigo_barras.linha_digitavel)
    boleto_convenio7_numero10_tres
    assert_equal("00190.00009 01238.798779 77700.168188 4 37690000072356", @boleto_novo.codigo_barras.linha_digitavel)
    boleto_convenio6_numero5
    assert_equal("00191.23876 90123.440423 00061.900189 2 37690000013500", @boleto_novo.codigo_barras.linha_digitavel)
    boleto_convenio6_numero17_carteira16
    assert_equal("00191.23876 90000.000126 34567.899215 9 37690000013500", @boleto_novo.codigo_barras.linha_digitavel)
    assert_raise RuntimeError do
      boleto_convenio6_numero17_carteira17
      raise 'Verifique as informações do boleto!!!'
    end
    boleto_convenio6_numero17_carteira18
    assert_equal("00191.23876 90000.000126 34567.899215 9 37690000013500", @boleto_novo.codigo_barras.linha_digitavel)
    boleto_convenio6_numero5
    assert_equal("00191.23876 90123.440423 00061.900189 2 37690000013500", @boleto_novo.codigo_barras.linha_digitavel)
    boleto_convenio4_numero7
    assert_equal("00191.23801 12345.640424 00061.900189 1 37690000013500", @boleto_novo.codigo_barras.linha_digitavel)
    assert_kind_of( String, @boleto_novo.codigo_barras.linha_digitavel)
  end

  def test_should_return_correctly_conta_corrente_dv
    boleto_convenio8_numero9_um
    assert_equal 0, @boleto_novo.conta_corrente_dv
    boleto_convenio8_numero9_dois
    assert_equal 0, @boleto_novo.conta_corrente_dv
    boleto_convenio7_numero10_um
    assert_equal 0, @boleto_novo.conta_corrente_dv
    boleto_convenio7_numero10_dois
    assert_equal 0, @boleto_novo.conta_corrente_dv
    boleto_convenio7_numero10_tres
    assert_equal "X", @boleto_novo.conta_corrente_dv
    boleto_convenio6_numero5
    assert_equal 0, @boleto_novo.conta_corrente_dv
    boleto_convenio6_numero17_carteira16
    assert_equal 0, @boleto_novo.conta_corrente_dv
    boleto_convenio6_numero17_carteira17
    assert_equal 0, @boleto_novo.conta_corrente_dv
    boleto_convenio6_numero17_carteira18
    assert_equal 0, @boleto_novo.conta_corrente_dv
    boleto_convenio4_numero7
    assert_equal 0, @boleto_novo.conta_corrente_dv
  end

  def test_should_verify_nosso_numero_dv_calculation
    @boleto_novo.numero_documento = "777700168"
    assert_equal 0, @boleto_novo.nosso_numero_dv
    @boleto_novo.numero_documento = "77700168"
    assert_equal 3, @boleto_novo.nosso_numero_dv
    @boleto_novo.numero_documento = "00015448"
    assert_equal 2, @boleto_novo.nosso_numero_dv
    @boleto_novo.numero_documento = "15448"
    assert_equal 2, @boleto_novo.nosso_numero_dv
    @boleto_novo.numero_documento = "12345678"
    assert_equal 9, @boleto_novo.nosso_numero_dv
    @boleto_novo.numero_documento = "34230"
    assert_equal 0, @boleto_novo.nosso_numero_dv
    @boleto_novo.numero_documento = "258281"
    assert_equal 3, @boleto_novo.nosso_numero_dv
  end

end