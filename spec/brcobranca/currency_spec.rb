# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brcobranca::Currency::String do
  it 'returns true if value seted is a valid ruby number' do
    expect('1234').to be_numeric
    expect('123.4').to be_numeric
    expect('123,4').to be_numeric
    expect('1234.03').to be_numeric
    expect('1234,03').to be_numeric
    expect('-1234').to be_numeric
    expect('-123.4').to be_numeric
    expect('-123,4').to be_numeric
    expect('-1234.03').to be_numeric
    expect('-1234,03').to be_numeric
    expect('+1234').to be_numeric
    expect('+123.4').to be_numeric
    expect('+123,4').to be_numeric
    expect('+1234.03').to be_numeric
    expect('+1234,03').to be_numeric
  end

  it 'returns false if value seted is NOT a valid ruby number' do
    expect('1234,').not_to be_numeric
    expect('1234.').not_to be_numeric
    expect('1,234.03').not_to be_numeric
    expect('1.234.03').not_to be_numeric
    expect('1,234,03').not_to be_numeric
    expect('12.340,03').not_to be_numeric
    expect('1234ab').not_to be_numeric
    expect('ab1213').not_to be_numeric
    expect('ffab').not_to be_numeric
  end

  it 'converts value seted to valid ruby number' do
    expect('1234'.to_number).to be(1234.0)
    expect('123.4'.to_number).to be(123.4)
    expect('123,4'.to_number).to be(123.4)
    expect('1234.03'.to_number).to be(1234.03)
    expect('1234,03'.to_number).to be(1234.03)
  end

  it 'returns nil when is not possible convert value seted' do
    expect('1234,'.to_number).to be_nil
    expect('1234.'.to_number).to be_nil
    expect('1,234.03'.to_number).to be_nil
    expect('1.234.03'.to_number).to be_nil
    expect('1,234,03'.to_number).to be_nil
    expect('12.340,03'.to_number).to be_nil
    expect('1234ab'.to_number).to be_nil
    expect('ab1213'.to_number).to be_nil
    expect('ffab'.to_number).to be_nil
  end
end

RSpec.describe Brcobranca::Currency::Number do
  it 'converts value seted to currency value' do
    expect(1234.to_currency).to eql('1.234,00')
    expect(123.4.to_currency).to eql('123,40')
    expect(1234.03.to_currency).to eql('1.234,03')
    expect(1234.03.to_currency({ unit: 'R$ ' })).to eql('R$ 1.234,03')
    expect(1234.03.to_currency({ unit: 'R$ ', separator: '.' })).to eql('R$ 1.234.03')
    expect(1234.03.to_currency({ unit: 'R$ ', separator: '.', delimiter: ',' })).to eql('R$ 1,234.03')
    expect(1234.03.to_currency({ unit: 'R$ ', precision: 3 })).to eql('R$ 1.234,030')
  end

  it 'converts value seted using delimiter and separator' do
    expect(1234.with_delimiter).to eql('1,234')
    expect(123.4.with_delimiter).to eql('123.4')
    expect(1234.03.with_delimiter).to eql('1,234.03')
  end

  it 'converts value seted using precision' do
    expect(1234.with_precision).to eql('1234.000')
    expect(123.4.with_precision).to eql('123.400')
    expect(1234.03.with_precision).to eql('1234.030')
  end
end
