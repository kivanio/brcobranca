require File.join(File.dirname(__FILE__),'test_helper.rb')

class TestBancoReal < Test::Unit::TestCase #:nodoc:[all]

  def setup
    @boleto_novo = BancoReal.new
    @boleto_novo.cedente = "Kivanio Barbosa"
    @boleto_novo.documento_cedente = "12345678912"
    @boleto_novo.sacado = "Claudio Pozzebom"
    @boleto_novo.sacado_documento = "12345678900"
    @boleto_novo.aceite = "S"
    @boleto_novo.agencia = "4042"
    @boleto_novo.conta_corrente = "61900"
  end

  def boleto_carteira_registrada
    @boleto_novo.banco = "356"
    @boleto_novo.agencia = "4042"
    @boleto_novo.conta_corrente = "61900"
    @boleto_novo.carteira = "56"
    @boleto_novo.moeda = "9"
    @boleto_novo.valor = 135.00
    @boleto_novo.numero_documento = "7701684"
    @boleto_novo.data_documento = Date.parse("2008-02-01")
    @boleto_novo.dias_vencimento = 0
  end

  def boleto_carteira_sem_registro
    @boleto_novo.banco = "356"
    @boleto_novo.agencia = "4042"
    @boleto_novo.conta_corrente = "61900"
    @boleto_novo.carteira = "57"
    @boleto_novo.moeda = "9"
    @boleto_novo.valor = 135.00
    @boleto_novo.numero_documento = "777700168"
    @boleto_novo.data_documento = Date.parse("2008-02-01")
    @boleto_novo.dias_vencimento = 1
  end

  def boleto_carteira_sem_registro_2
    @boleto_novo.banco = "356"
    @boleto_novo.agencia = "1018"
    @boleto_novo.conta_corrente = "0016324"
    @boleto_novo.carteira = "57"
    @boleto_novo.moeda = "9"
    @boleto_novo.valor = 934.23
    @boleto_novo.numero_documento = "00005020"
    @boleto_novo.data_documento = Date.parse("2004-09-03")
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
    assert_equal '356', @boleto_novo.banco
    assert_equal '57', @boleto_novo.carteira
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
    boleto_carteira_sem_registro
    assert_equal "3569377000000135004042006190030000777700168", @boleto_novo.monta_codigo_43_digitos
    assert_equal "35692377000000135004042006190030000777700168", @boleto_novo.codigo_barras
    boleto_carteira_sem_registro_2
    assert_equal "3569252300000934231018001632490000000005020", @boleto_novo.monta_codigo_43_digitos
    assert_equal "35697252300000934231018001632490000000005020", @boleto_novo.codigo_barras
    boleto_carteira_registrada
    assert_equal "3569376900000135000000004042006190087701684", @boleto_novo.monta_codigo_43_digitos
    assert_equal "35691376900000135000000004042006190087701684", @boleto_novo.codigo_barras
    boleto_nil
    assert_equal nil, @boleto_novo.codigo_barras
    assert_raise RuntimeError do
      boleto_nil
      raise 'Verifique as informações do boleto!!!'
    end
  end

  def test_should_mont_correct_linha_digitalvel
    boleto_carteira_registrada
    assert_equal("35690.00007 04042.006199 00877.016840 1 37690000013500", @boleto_novo.codigo_barras.linha_digitavel)
    boleto_carteira_sem_registro
    assert_equal("35694.04209 06190.030004 07777.001681 2 37700000013500", @boleto_novo.codigo_barras.linha_digitavel)
    boleto_carteira_sem_registro_2
    assert_equal("35691.01805 01632.490007 00000.050203 7 25230000093423", @boleto_novo.codigo_barras.linha_digitavel)
  end

  def test_should_return_agencia_conta_corrente_nosso_numero_dv
    boleto_carteira_registrada
    assert_equal 8, @boleto_novo.agencia_conta_corrente_nosso_numero_dv
    boleto_carteira_sem_registro
    assert_equal 3, @boleto_novo.agencia_conta_corrente_nosso_numero_dv
  end
end