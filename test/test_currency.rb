require File.join(File.dirname(__FILE__),'test_helper.rb')

class CurrencyTest < Test::Unit::TestCase #:nodoc:[all]
  # Teste do modulo currency

  # Testa se é numero Ex. 1321 ou 13.32
  def test_should_return_true_is_numeric
    assert_equal true, "1234".numeric?
    assert_equal true, "123.4".numeric?
    assert_equal true, "123,4".numeric?
    assert_equal true, "1234.03".numeric?
    assert_equal true, "1234,03".numeric?
    assert_equal true, "-1234".numeric?
    assert_equal true, "-123.4".numeric?
    assert_equal true, "-123,4".numeric?
    assert_equal true, "-1234.03".numeric?
    assert_equal true, "-1234,03".numeric?
    assert_equal true, "+1234".numeric?
    assert_equal true, "+123.4".numeric?
    assert_equal true, "+123,4".numeric?
    assert_equal true, "+1234.03".numeric?
    assert_equal true, "+1234,03".numeric?
    assert_equal false, "1234,".numeric?
    assert_equal false, "1234.".numeric?
    assert_equal false, "1,234.03".numeric?
    assert_equal false, "1.234.03".numeric?
    assert_equal false, "1,234,03".numeric?
    assert_equal false, "12.340,03".numeric?
    assert_equal false, "1234ab".numeric?
    assert_equal false, "ab1213".numeric?
    assert_equal false, "ffab".numeric?
  end

  def test_should_return_correct_number
    assert_equal 1234, "1234".to_number
    assert_equal 123.4, "123.4".to_number
    assert_equal 123.4, "123,4".to_number
    assert_equal nil, "1234,".to_number
    assert_equal nil, "1234.".to_number
    assert_equal 1234.03, "1234.03".to_number
    assert_equal 1234.03, "1234,03".to_number
    assert_equal nil, "1,234.03".to_number
    assert_equal nil, "1.234.03".to_number
    assert_equal nil, "1,234,03".to_number
    assert_equal nil, "12.340,03".to_number
    assert_equal nil, "1234ab".to_number
    assert_equal nil, "ab1213".to_number
    assert_equal nil, "ffab".to_number
  end

end
