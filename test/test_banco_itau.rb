require File.join(File.dirname(__FILE__),'test_helper.rb')

class BancoItauTest < Test::Unit::TestCase #:nodoc:[all]

  BOLETO_ITAU_CARTEIRA_175 = {
    :carteira => "175",
    :moeda => "9",
    :valor => 135.00,
    :convenio => 0,
    :numero_documento => "12345678",
    :data_documento => Date.parse("2008-02-01"),
    :dias_vencimento => 0,
    :agencia => "0810",
    :conta_corrente => "53678"
  }

  def setup
    @boleto_novo = BancoItau.new # (BOLETO_CARTEIRA_175)
    BOLETO_ITAU_CARTEIRA_175.each do |nome, valor|
      @boleto_novo.send("#{nome}=".to_sym, valor)
    end
  end
  
  def test_should_initialize_correctly
    assert_equal '341', @boleto_novo.banco
    assert_equal "DM", @boleto_novo.especie_documento
    assert_equal "R$", @boleto_novo.especie
    assert_equal "9", @boleto_novo.moeda
    assert_equal Date.parse("2008-02-01"), @boleto_novo.data_documento
    assert_equal 0, @boleto_novo.dias_vencimento
    assert_equal((@boleto_novo.data_documento + 0), @boleto_novo.data_vencimento)
    assert_equal "S", @boleto_novo.aceite
    assert_equal 1, @boleto_novo.quantidade
    assert_equal 135.00, @boleto_novo.valor
    assert_equal 135.00, @boleto_novo.valor_documento
    assert_equal "QUALQUER BANCO ATÉ O VENCIMENTO", @boleto_novo.local_pagamento
  end

  def test_should_return_correct_agencia_conta_corrente_dv
    @boleto_novo.agencia = "0607"
    @boleto_novo.conta_corrente = "15255"
    assert_equal 0, @boleto_novo.agencia_conta_corrente_dv
    @boleto_novo.agencia = "1547"
    @boleto_novo.conta_corrente = "85547"
    assert_equal 6, @boleto_novo.agencia_conta_corrente_dv
    @boleto_novo.agencia = "1547"
    @boleto_novo.conta_corrente = "10207"
    assert_equal 7, @boleto_novo.agencia_conta_corrente_dv
    @boleto_novo.agencia = "0811"
    @boleto_novo.conta_corrente = "53678"
    assert_equal 8, @boleto_novo.agencia_conta_corrente_dv
  end

  def test_should_verify_nosso_numero_dv_calculation
    @boleto_novo.numero_documento = "00015448"
    assert_equal 6, @boleto_novo.nosso_numero_dv
    @boleto_novo.numero_documento = "15448"
    assert_equal 6, @boleto_novo.nosso_numero_dv
    @boleto_novo.numero_documento = "12345678"
    assert_equal 4, @boleto_novo.nosso_numero_dv
    @boleto_novo.numero_documento = "34230"
    assert_equal 5, @boleto_novo.nosso_numero_dv
    @boleto_novo.numero_documento = "258281"
    assert_equal 7, @boleto_novo.nosso_numero_dv
  end

  def test_should_build_correct_barcode
    assert_equal "3419376900000135001751234567840810536789000", @boleto_novo.monta_codigo_43_digitos
    assert_equal "34195376900000135001751234567840810536789000", @boleto_novo.codigo_barras
    
    @boleto_novo.numero_documento = "258281"
    @boleto_novo.data_documento = Date.parse("2004/09/03")
    assert_equal "3419252300000135001750025828170810536789000", @boleto_novo.monta_codigo_43_digitos
    assert_equal "34195252300000135001750025828170810536789000", @boleto_novo.codigo_barras
    
    @boleto_novo.numero_documento = "258281"
    @boleto_novo.data_documento = Date.parse("2004/09/03")
    @boleto_novo.carteira = 168
    assert_equal "3419252300000135001680025828120810536789000", @boleto_novo.monta_codigo_43_digitos
    assert_equal "34193252300000135001680025828120810536789000", @boleto_novo.codigo_barras

    @boleto_novo.carteira = 196
    @boleto_novo.convenio = "12345"
    @boleto_novo.seu_numero = "1234567"
    assert_equal "3419252300000135001960025828112345671234550", @boleto_novo.monta_codigo_43_digitos
    assert_equal "34199252300000135001960025828112345671234550", @boleto_novo.codigo_barras
    @boleto_novo.seu_numero = "123456"
    assert_equal "3419252300000135001960025828101234561234550", @boleto_novo.monta_codigo_43_digitos
    assert_equal "34191252300000135001960025828101234561234550", @boleto_novo.codigo_barras

    @boleto_novo.convenio = "1234"
    assert_equal "3419252300000135001960025828101234560123440", @boleto_novo.monta_codigo_43_digitos
    assert_equal "34191252300000135001960025828101234560123440", @boleto_novo.codigo_barras
  end

  def test_should_build_correct_typeable_line
    assert_equal "34191.75124 34567.840813 05367.890000 5 37690000013500", @boleto_novo.codigo_barras.linha_digitavel
    @boleto_novo.numero_documento = "258281"
    @boleto_novo.data_documento = Date.parse("2004/09/03")
    assert_equal "34191.75009 25828.170818 05367.890000 5 25230000013500", @boleto_novo.codigo_barras.linha_digitavel
  end

end