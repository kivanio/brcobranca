require File.join(File.dirname(__FILE__),'test_helper.rb')

class TestBancoBradesco < Test::Unit::TestCase #:nodoc:[all]

  def setup
    @boleto_novo = BancoBradesco.new
    @boleto_novo.cedente = "Kivanio Barbosa"
    @boleto_novo.documento_cedente = "12345678912"
    @boleto_novo.sacado = "Claudio Pozzebom"
    @boleto_novo.sacado_documento = "12345678900"
    @boleto_novo.aceite = "S"
    @boleto_novo.agencia = "4042"
    @boleto_novo.conta_corrente = "61900"
  end

  def boleto_1
    @boleto_novo.agencia = "1172"
    @boleto_novo.conta_corrente = "0403005"
    @boleto_novo.carteira = "06"
    @boleto_novo.moeda = "9"
    @boleto_novo.valor = 2952.95
    @boleto_novo.numero_documento = "75896452"
    @boleto_novo.data_documento = Date.parse("2009-04-30")
    @boleto_novo.dias_vencimento = 0
  end

  def boleto_2
    @boleto_novo.agencia = "4042"
    @boleto_novo.conta_corrente = "61900"
    @boleto_novo.carteira = "03"
    @boleto_novo.moeda = "9"
    @boleto_novo.valor = 135.00
    @boleto_novo.numero_documento = "777700168"
    @boleto_novo.data_documento = Date.parse("2008-02-01")
    @boleto_novo.dias_vencimento = 1
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
    assert_equal '237', @boleto_novo.banco
    assert_equal '06', @boleto_novo.carteira
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
    boleto_1
    assert_equal "2379422300002952951172060007589645204030050", @boleto_novo.monta_codigo_43_digitos
    assert_equal "23795422300002952951172060007589645204030050", @boleto_novo.codigo_barras
    boleto_2
    assert_equal "2379377000000135004042030077770016800619000", @boleto_novo.monta_codigo_43_digitos
    assert_equal "23791377000000135004042030077770016800619000", @boleto_novo.codigo_barras
    boleto_nil
    assert_equal nil, @boleto_novo.codigo_barras
    assert_raise RuntimeError do
      boleto_nil
      raise 'Verifique as informações do boleto!!!'
    end
  end

  def test_should_mont_correct_linha_digitalvel
    boleto_1
    assert_equal("23791.17209 60007.589645 52040.300502 5 42230000295295", @boleto_novo.codigo_barras.linha_digitavel)
    boleto_2
    assert_equal("23794.04201 30077.770011 68006.190000 1 37700000013500", @boleto_novo.codigo_barras.linha_digitavel)
  end

end