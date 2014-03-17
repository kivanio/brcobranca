# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper.rb'

module Brcobranca #:nodoc:[all]
  module Currency #:nodoc:[all]
    describe String do
      it 'should return true if value seted is a valid ruby number' do
        '1234'.numeric?.should be_true
        '123.4'.numeric?.should be_true
        '123,4'.numeric?.should be_true
        '1234.03'.numeric?.should be_true
        '1234,03'.numeric?.should be_true
        '-1234'.numeric?.should be_true
        '-123.4'.numeric?.should be_true
        '-123,4'.numeric?.should be_true
        '-1234.03'.numeric?.should be_true
        '-1234,03'.numeric?.should be_true
        '+1234'.numeric?.should be_true
        '+123.4'.numeric?.should be_true
        '+123,4'.numeric?.should be_true
        '+1234.03'.numeric?.should be_true
        '+1234,03'.numeric?.should be_true
      end

      it 'should return false if value seted is NOT a valid ruby number' do
        '1234,'.numeric?.should be_false
        '1234.'.numeric?.should be_false
        '1,234.03'.numeric?.should be_false
        '1.234.03'.numeric?.should be_false
        '1,234,03'.numeric?.should be_false
        '12.340,03'.numeric?.should be_false
        '1234ab'.numeric?.should be_false
        'ab1213'.numeric?.should be_false
        'ffab'.numeric?.should be_false
      end

      it 'should convert value seted to valid ruby number' do
        '1234'.to_number.should eql(1234.0)
        '123.4'.to_number.should eql(123.4)
        '123,4'.to_number.should eql(123.4)
        '1234.03'.to_number.should eql(1234.03)
        '1234,03'.to_number.should eql(1234.03)
      end

      it 'should return nil when is not possible convert value seted' do
        '1234,'.to_number.should be_nil
        '1234.'.to_number.should be_nil
        '1,234.03'.to_number.should be_nil
        '1.234.03'.to_number.should be_nil
        '1,234,03'.to_number.should be_nil
        '12.340,03'.to_number.should be_nil
        '1234ab'.to_number.should be_nil
        'ab1213'.to_number.should be_nil
        'ffab'.to_number.should be_nil
      end
    end

    describe Number do
      it 'should convert value seted to currency value' do
        1234.to_currency.should eql('1.234,00')
        123.4.to_currency.should eql('123,40')
        1234.03.to_currency.should eql('1.234,03')
        1234.03.to_currency(options = {:unit => 'R$ '}).should eql('R$ 1.234,03')
        1234.03.to_currency(options = {:unit => 'R$ ', :separator => '.'}).should eql('R$ 1.234.03')
        1234.03.to_currency(options = {:unit => 'R$ ', :separator => '.', :delimiter => ','}).should eql('R$ 1,234.03')
        1234.03.to_currency(options = {:unit => 'R$ ', :precision => 3}).should eql('R$ 1.234,030')
      end

      it 'should convert value seted using delimiter and separator' do
        1234.with_delimiter.should eql('1,234')
        123.4.with_delimiter.should eql('123.4')
        1234.03.with_delimiter.should eql('1,234.03')
      end

      it 'should convert value seted using precision ' do
        1234.with_precision.should eql('1234.000')
        123.4.with_precision.should eql('123.400')
        1234.03.with_precision.should eql('1234.030')
      end
    end
  end
end