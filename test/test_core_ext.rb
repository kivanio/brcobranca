require File.join(File.dirname(__FILE__),'test_helper.rb')

class CoreExtTest < Test::Unit::TestCase #:nodoc:[all]
  # Teste da Extensão de core do Brcobranca
  def test_should_format_correct_cpf
    assert_equal "987.892.987-90", 98789298790.to_br_cpf
    assert_equal "987.892.987-90", "98789298790".to_br_cpf
  end

  def test_should_format_correct_cep
    assert_equal "85253-100", 85253100.to_br_cep
    assert_equal "85253-100", "85253100".to_br_cep
  end

  def test_should_format_correct_cnpj
    assert_equal "88.394.510/0001-03", 88394510000103.to_br_cnpj
    assert_equal "88.394.510/0001-03", "88394510000103".to_br_cnpj
  end

  def test_should_return_correct_object_formated
    assert_equal "987.892.987-90", 98789298790.formata_documento
    assert_equal "987.892.987-90", "98789298790".formata_documento
    assert_equal "85253-100", 85253100.formata_documento
    assert_equal "85253-100", "85253100".formata_documento
    assert_equal "88.394.510/0001-03", 88394510000103.formata_documento
    assert_equal "88.394.510/0001-03", "88394510000103".formata_documento
  end

  def test_should_return_true_is_moeda
    assert_equal true, 1234.03.to_s.moeda?
    assert_equal true, +1234.03.to_s.moeda?
    assert_equal true, -1234.03.to_s.moeda?
    assert_equal false, 123403.to_s.moeda?
    assert_equal false, -123403.to_s.moeda?
    assert_equal false, +123403.to_s.moeda?
    assert_equal true, "1234.03".moeda?
    assert_equal true, "1234,03".moeda?
    assert_equal true, "1,234.03".moeda?
    assert_equal true, "1.234.03".moeda?
    assert_equal true, "1,234,03".moeda?
    assert_equal true, "12.340,03".moeda?
    assert_equal true, "+1234.03".moeda?
    assert_equal true, "+1234,03".moeda?
    assert_equal true, "+1,234.03".moeda?
    assert_equal true, "+1.234.03".moeda?
    assert_equal true, "+1,234,03".moeda?
    assert_equal true, "+12.340,03".moeda?
    assert_equal true, "-1234.03".moeda?
    assert_equal true, "-1234,03".moeda?
    assert_equal true, "-1,234.03".moeda?
    assert_equal true, "-1.234.03".moeda?
    assert_equal true, "-1,234,03".moeda?
    assert_equal true, "-12.340,03".moeda?
    assert_equal false, "1234ab".moeda?
    assert_equal false, "ab1213".moeda?
    assert_equal false, "ffab".moeda?
    assert_equal false, "1234".moeda?
  end

  def test_should_return_correct_number_days
    assert_equal 3769, (Date.parse "2008-02-01").fator_vencimento
    assert_equal 3770, (Date.parse "2008-02-02").fator_vencimento
    assert_equal 3774, (Date.parse "2008-02-06").fator_vencimento
  end

  def test_should_return_correct_formated_date
    assert_equal "01/02/2008", (Date.parse "2008-02-01").to_s_br
    assert_equal "02/02/2008", (Date.parse "2008-02-02").to_s_br
    assert_equal "06/02/2008", (Date.parse "2008-02-06").to_s_br
  end

  def test_should_clean_value
    assert_equal "123403", 1234.03.limpa_valor_moeda
    assert_equal "123403", +1234.03.limpa_valor_moeda
    assert_equal "123403", -1234.03.limpa_valor_moeda
    assert_equal 123403, 123403.limpa_valor_moeda
    assert_equal(-123403, -123403.limpa_valor_moeda)
    assert_equal(+123403, +123403.limpa_valor_moeda)
    assert_equal "123403", "1234.03".limpa_valor_moeda
    assert_equal "123403", "1234,03".limpa_valor_moeda
    assert_equal "123403", "1,234.03".limpa_valor_moeda
    assert_equal "123403", "1.234.03".limpa_valor_moeda
    assert_equal "123403", "1,234,03".limpa_valor_moeda
    assert_equal "1234003", "12.340,03".limpa_valor_moeda
    assert_equal "123403", "+1234.03".limpa_valor_moeda
    assert_equal "123403", "+1234,03".limpa_valor_moeda
    assert_equal "123403", "+1,234.03".limpa_valor_moeda
    assert_equal "123403", "+1.234.03".limpa_valor_moeda
    assert_equal "123403", "+1,234,03".limpa_valor_moeda
    assert_equal "1234003", "+12.340,03".limpa_valor_moeda
    assert_equal "123403", "-1234.03".limpa_valor_moeda
    assert_equal "123403", "-1234,03".limpa_valor_moeda
    assert_equal "123403", "-1,234.03".limpa_valor_moeda
    assert_equal "123403", "-1.234.03".limpa_valor_moeda
    assert_equal "123403", "-1,234,03".limpa_valor_moeda
    assert_equal "1234003", "-12.340,03".limpa_valor_moeda
    assert_equal "1234ab", "1234ab".limpa_valor_moeda
    assert_equal "ab1213", "ab1213".limpa_valor_moeda
    assert_equal "ffab", "ffab".limpa_valor_moeda
    assert_equal "1234", "1234".limpa_valor_moeda
  end

  def test_should_calculate_correct_module10
    assert_equal nil, " ".modulo10
    assert_equal nil, "".modulo10
    assert_equal 5, "001905009".modulo10
    assert_equal 9, "4014481606".modulo10
    assert_equal 4, "0680935031".modulo10
    assert_equal 5, "29004590".modulo10
    assert_equal 1, "341911012".modulo10
    assert_equal 8, "3456788005".modulo10
    assert_equal 1, "7123457000".modulo10
    assert_equal 8, "00571234511012345678".modulo10
    assert_kind_of( Fixnum, "001905009".modulo10 )
    assert_equal 0, 0.modulo10
    assert_equal 5, 1905009.modulo10
    assert_equal 9, 4014481606.modulo10
    assert_equal 4, 680935031.modulo10
    assert_equal 5, 29004590.modulo10
    assert_kind_of( Fixnum, 1905009.modulo10 )
  end

  def test_should_calculate_correct_modulo11_9to2
    assert_equal 9, "85068014982".modulo11_9to2
    assert_equal 1, "05009401448".modulo11_9to2
    assert_equal 2, "12387987777700168".modulo11_9to2
    assert_equal 8, "4042".modulo11_9to2
    assert_equal 0, "61900".modulo11_9to2
    assert_equal 6, "0719".modulo11_9to2
    assert_equal 5, "000000005444".modulo11_9to2
    assert_equal 5, "5444".modulo11_9to2
    assert_equal 3, "01129004590".modulo11_9to2
    assert_equal 10, "15735".modulo11_9to2
    assert_equal 0, "777700168".modulo11_9to2  
    assert_equal 3, "77700168".modulo11_9to2
    assert_equal 2, "00015448".modulo11_9to2
    assert_equal 2, "15448".modulo11_9to2
    assert_equal 9, "12345678".modulo11_9to2
    assert_equal 0, "34230".modulo11_9to2
    assert_equal 3, "258281".modulo11_9to2
    assert_kind_of( Fixnum, "5444".modulo11_9to2 )
    assert_kind_of( Fixnum, "000000005444".modulo11_9to2 )
    assert_equal 9, 85068014982.modulo11_9to2
    assert_equal 1, 5009401448.modulo11_9to2
    assert_equal 2, 12387987777700168.modulo11_9to2
    assert_equal 8, 4042.modulo11_9to2
    assert_equal 0, 61900.modulo11_9to2
    assert_equal 6, 719.modulo11_9to2
    assert_equal 5, 5444.modulo11_9to2
    assert_equal 3, 1129004590.modulo11_9to2
    assert_kind_of( Fixnum, 5444.modulo11_9to2 )
  end

  def test_should_calculate_correct_modulo11_9to2_10_como_x
    assert_equal 9, "85068014982".modulo11_9to2_10_como_x
    assert_equal 1, "05009401448".modulo11_9to2_10_como_x
    assert_equal 2, "12387987777700168".modulo11_9to2_10_como_x
    assert_equal 8, "4042".modulo11_9to2_10_como_x
    assert_equal 0, "61900".modulo11_9to2_10_como_x
    assert_equal 6, "0719".modulo11_9to2_10_como_x
    assert_equal 5, "000000005444".modulo11_9to2_10_como_x
    assert_equal 5, "5444".modulo11_9to2_10_como_x
    assert_equal 3, "01129004590".modulo11_9to2_10_como_x
    assert_equal "X", "15735".modulo11_9to2_10_como_x
    assert_kind_of( String, "15735".modulo11_9to2_10_como_x )
    assert_kind_of( Fixnum, "5444".modulo11_9to2_10_como_x )
    assert_kind_of( Fixnum, "000000005444".modulo11_9to2_10_como_x )
  end

  def test_should_calculate_correct_modulo11_2to9
    assert_equal 3, "0019373700000001000500940144816060680935031".modulo11_2to9
    assert_kind_of( Fixnum, "0019373700000001000500940144816060680935031".modulo11_2to9 )
    assert_equal 6, "3419166700000123451101234567880057123457000".modulo11_2to9
    assert_equal 3, 19373700000001000500940144816060680935031.modulo11_2to9
    assert_kind_of( Fixnum, 19373700000001000500940144816060680935031.modulo11_2to9 )
  end

  def test_should_calculate_correct_addiction_of_numbers
    assert_equal 3, 111.soma_digitos
    assert_equal 8, 8.soma_digitos
    assert_equal 3, "111".soma_digitos
    assert_equal 8, "8".soma_digitos
    assert_kind_of( Fixnum, 111.soma_digitos )
    assert_kind_of( Fixnum, "111".soma_digitos )
  end

  def test_should_fill_correctly_with_zeros
    assert_equal "123", "123".zeros_esquerda(:tamanho => 0)
    assert_equal "123", "123".zeros_esquerda(:tamanho => 1)
    assert_equal "123", "123".zeros_esquerda(:tamanho => 2)
    assert_equal "123", "123".zeros_esquerda(:tamanho => 3)
    assert_equal "0123", "123".zeros_esquerda(:tamanho => 4)
    assert_equal "00123", "123".zeros_esquerda(:tamanho => 5)
    assert_equal "0000000123", "123".zeros_esquerda(:tamanho => 10)
    assert_kind_of( String, "123".zeros_esquerda(:tamanho => 5) )
    assert_equal "123", 123.zeros_esquerda(:tamanho => 0)
    assert_equal "123", 123.zeros_esquerda(:tamanho => 1)
    assert_equal "123", 123.zeros_esquerda(:tamanho => 2)
    assert_equal "123", 123.zeros_esquerda(:tamanho => 3)
    assert_equal "0123", 123.zeros_esquerda(:tamanho => 4)
    assert_equal "00123", 123.zeros_esquerda(:tamanho => 5)
    assert_equal "0000000123", 123.zeros_esquerda(:tamanho => 10)
    assert_kind_of( String, 123.zeros_esquerda(:tamanho => 5) )
    assert_equal "123", "123".zeros_esquerda
    assert_equal "123", 123.zeros_esquerda
  end

  def test_should_mont_correct_linha_digitalvel
    assert_equal("00190.00009 01238.798779 77700.168188 2 37690000013500", "00192376900000135000000001238798777770016818".linha_digitavel)
    assert_kind_of(String, "00192376900000135000000001238798777770016818".linha_digitavel)
    assert_equal nil, "".linha_digitavel
    assert_equal nil, "00193373700".linha_digitavel
    assert_equal nil, "0019337370000193373700".linha_digitavel
    assert_equal nil, "00b193373700bb00193373700".linha_digitavel
    assert_equal nil, "0019337370000193373700bbb".linha_digitavel
    assert_equal nil, "0019237690000c135000c0000123f7987e7773016813".linha_digitavel
  end

  def test_should_return_correct_julian_date
    assert_equal "0429", (Date.parse "2009-02-11").to_juliano
    assert_equal "0428", (Date.parse "2008-02-11").to_juliano
    assert_equal "0989", (Date.parse "2009-04-08").to_juliano
    # Ano 2008 eh bisexto
    assert_equal "0998", (Date.parse "2008-04-08").to_juliano
  end

end
