require File.join(File.dirname(__FILE__),'test_helper.rb')

class BancoHsbcTest < Test::Unit::TestCase #:nodoc:[all]

  def setup
    @boleto_novo = BancoHsbc.new
    @boleto_novo.cedente = "Kivanio Barbosa"
    @boleto_novo.documento_cedente = "12345678912"
    @boleto_novo.sacado = "Claudio Pozzebom"
    @boleto_novo.sacado_documento = "12345678900"
    @boleto_novo.aceite = "S"
    @boleto_novo.agencia = "4042"
    @boleto_novo.valor = 2952.95
  end

  def test_should_return_correct_nosso_numero
    @boleto_novo.conta_corrente = "1122334"
    @boleto_novo.numero_documento = "12345678"
    @boleto_novo.dias_vencimento = 5
    @boleto_novo.data_documento = Date.parse("2000-07-04")
    assert_equal "12345678942", @boleto_novo.nosso_numero
    @boleto_novo.conta_corrente = "351202"
    @boleto_novo.numero_documento = "39104766"
    @boleto_novo.dias_vencimento = 0
    @boleto_novo.data_documento = Date.parse("2000-07-04")
    assert_equal "39104766340", @boleto_novo.nosso_numero
    @boleto_novo.conta_corrente = "351202"
    @boleto_novo.numero_documento = "39104766"
    @boleto_novo.dias_vencimento = 0
    @boleto_novo.data_documento = ""
    assert_equal "39104766354", @boleto_novo.nosso_numero
  end

  def test_should_mont_correct_codigo_barras
    @boleto_novo.conta_corrente = "1122334"
    @boleto_novo.numero_documento = "12345678"
    @boleto_novo.dias_vencimento = 5
    @boleto_novo.data_documento = Date.parse("2009-04-03")
    assert_equal "3999420100002952951122334000001234567809892", @boleto_novo.monta_codigo_43_digitos
    assert_equal "39998420100002952951122334000001234567809892", @boleto_novo.codigo_barras
  end

  def test_should_mont_correct_linha_digitalvel
    @boleto_novo.conta_corrente = "1122334"
    @boleto_novo.numero_documento = "12345678"
    @boleto_novo.dias_vencimento = 5
    @boleto_novo.data_documento = Date.parse("2009-04-03")
    assert_equal("39991.12232 34000.001239 45678.098927 8 42010000295295", @boleto_novo.codigo_barras.linha_digitavel)
  end

end