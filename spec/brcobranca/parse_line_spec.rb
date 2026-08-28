# frozen_string_literal: true

require 'spec_helper'

# Classe de exemplo para testar o módulo ParseLine
class TestParser
  extend Brcobranca::ParseLine

  attr_accessor :name, :age, :city, :amount

  fixed_width_layout do |layout|
    layout.field :name, 0..19
    layout.field :age, 20..24, lambda(&:to_i)
    layout.field :city, 25..39
    layout.field :amount, 40..50, lambda(&:to_f)
  end
end

# Classe para testar com layout simples sem transformadores
class SimpleParser
  extend Brcobranca::ParseLine

  attr_accessor :field1, :field2

  fixed_width_layout do |layout|
    layout.field :field1, 0..9
    layout.field :field2, 10..19
  end
end

# Classes para testar a heranca do layout entre classe mae e filha
class ParentParser
  extend Brcobranca::ParseLine

  attr_accessor :campo_proprio, :campo_sobrescrito

  fixed_width_layout do |layout|
    layout.field :campo_proprio, 0..4
    layout.field :campo_sobrescrito, 5..9
  end
end

class ChildParser < ParentParser
  fixed_width_layout do |layout|
    layout.field :campo_sobrescrito, 10..14
  end
end

# Classe para testar o transformador informado como bloco
class BlockParser
  extend Brcobranca::ParseLine

  attr_accessor :quantidade

  fixed_width_layout do |layout|
    layout.field :quantidade, 0..4 do |value|
      value.to_i * 2
    end
  end
end

# Classe para testar com layout complexo e transformadores que falham
class FailingParser
  extend Brcobranca::ParseLine

  attr_accessor :value

  fixed_width_layout do |layout|
    layout.field :value, 0..9, lambda { |_v|
      raise StandardError, 'Erro no transformador'
    }
  end
end

# Classe para testar com layout complexo e transformadores
class BankReturnParser
  extend Brcobranca::ParseLine

  attr_accessor :record_type, :document, :amount, :due_date

  fixed_width_layout do |layout|
    layout.field :record_type, 0..0
    layout.field :document, 1..14
    layout.field :amount, 15..27, ->(value) { value.to_f / 100 }
    layout.field :due_date, 28..35
  end
end

# Classe para testar com múltiplos transformadores complexos
class ComplexParser
  extend Brcobranca::ParseLine

  attr_accessor :name, :price, :active, :date

  fixed_width_layout do |layout|
    layout.field :name, 0..19, ->(value) { value.strip.upcase }
    layout.field :price, 20..29, ->(value) { value.to_f.round(2) }
    layout.field :active, 30..30, ->(value) { value == 'S' }
    layout.field :date, 31..40, ->(value) { value.strip.empty? ? nil : Date.parse(value) }
  end
end

RSpec.describe Brcobranca::ParseLine do
  describe '.fixed_width_layout' do
    it 'permite definir um layout com campos' do
      expect(TestParser).to respond_to(:fixed_width_layout)
    end

    it 'define os campos corretamente' do
      expect(TestParser.parse_values).to be_an(Array)
      expect(TestParser.parse_values.size).to eq(4)
    end
  end

  describe '.field' do
    it 'adiciona um campo ao layout' do
      expect(SimpleParser.parse_values.size).to eq(2)
    end

    it 'armazena o nome do campo, range e transformador' do
      field_definition = TestParser.parse_values.first
      expect(field_definition[0]).to eq(:name)
      expect(field_definition[1]).to eq(0..19)
    end
  end

  describe '.load_line' do
    context 'com dados válidos' do
      let(:line) { 'João Silva          00025São Paulo         001234.5  ' }

      it 'parseia uma linha corretamente' do
        result = TestParser.load_line(line)

        expect(result).to be_a(TestParser)
        expect(result.name).to eq('João Silva')
        expect(result.age).to eq(25)
        expect(result.city).to eq('São Paulo')
        expect(result.amount).to eq(1234.5)
      end

      it 'remove espaços em branco dos campos sem transformador' do
        result = TestParser.load_line(line)
        expect(result.name).to eq('João Silva')
        expect(result.city).to eq('São Paulo')
      end

      it 'aplica transformadores quando definidos' do
        result = TestParser.load_line(line)
        expect(result.age).to be_an(Integer)
        expect(result.amount).to be_a(Float)
      end
    end

    context 'com linha vazia ou com apenas espaços' do
      let(:line) { ' ' * 50 }

      it 'parseia linha vazia sem erros' do
        result = TestParser.load_line(line)

        expect(result.name).to eq('')
        expect(result.age).to eq(0)
        expect(result.city).to eq('')
        expect(result.amount).to eq(0.0)
      end
    end

    context 'com linha malformada' do
      let(:short_line) { 'abc' }

      it 'parseia linha curta sem erros (retorna valores vazios)' do
        result = TestParser.load_line(short_line)
        expect(result).to be_a(TestParser)
        expect(result.name).to eq('abc')
        expect(result.age).to eq(0)
      end
    end

    context 'quando o transformador falha' do
      it 'captura e relança o erro com mais contexto' do
        expect { FailingParser.load_line('test      ') }.to raise_error(
          Brcobranca::MalformedLayoutOrLine,
          /Erro original: \(StandardError\): Erro no transformador/
        )
      end
    end
  end

  describe '.load_lines' do
    let(:temp_file) { Tempfile.new(['test_parse', '.txt']) }

    after do
      temp_file.close
      temp_file.unlink
    end

    context 'sem filtros' do
      before do
        temp_file.write("João Silva          00025São Paulo         001234.56 \n")
        temp_file.write("Maria Santos        00030Rio de Janeiro    002345.67 \n")
        temp_file.write("Pedro Costa         00040Belo Horizonte    003456.78 \n")
        temp_file.rewind
      end

      it 'carrega todas as linhas do arquivo' do
        results = TestParser.load_lines(temp_file.path)

        expect(results.size).to eq(3)
        expect(results[0].name).to eq('João Silva')
        expect(results[1].name).to eq('Maria Santos')
        expect(results[2].name).to eq('Pedro Costa')
      end

      it 'retorna um array de objetos parseados' do
        results = TestParser.load_lines(temp_file.path)

        expect(results).to all(be_a(TestParser))
      end
    end

    context 'com filtro :except como array' do
      before do
        temp_file.write("Header linha        00000Ignorar           000000.00 \n")
        temp_file.write("João Silva          00025São Paulo         001234.56 \n")
        temp_file.write("Maria Santos        00030Rio de Janeiro    002345.67 \n")
        temp_file.write("Footer linha        00000Ignorar           000000.00 \n")
        temp_file.rewind
      end

      it 'ignora as linhas especificadas no array' do
        results = TestParser.load_lines(temp_file.path, except: [1, 4])

        expect(results.size).to eq(2)
        expect(results[0].name).to eq('João Silva')
        expect(results[1].name).to eq('Maria Santos')
      end

      it 'usa índice baseado em 1' do
        results = TestParser.load_lines(temp_file.path, except: [1])

        expect(results.size).to eq(3)
        expect(results[0].name).to eq('João Silva')
      end
    end

    context 'com filtro :except como regex' do
      before do
        temp_file.write("HEADER linha        00000Ignorar           000000.00 \n")
        temp_file.write("João Silva          00025São Paulo         001234.56 \n")
        temp_file.write("Maria Santos        00030Rio de Janeiro    002345.67 \n")
        temp_file.write("FOOTER linha        00000Ignorar           000000.00 \n")
        temp_file.rewind
      end

      it 'ignora as linhas que correspondem ao regex' do
        results = TestParser.load_lines(temp_file.path, except: /^(HEADER|FOOTER)/)

        expect(results.size).to eq(2)
        expect(results[0].name).to eq('João Silva')
        expect(results[1].name).to eq('Maria Santos')
      end
    end

    context 'com filtro :length' do
      before do
        temp_file.write("João Silva          00025São Paulo         1234.56\n")
        temp_file.write("abc\n")
        temp_file.write("Maria Santos        00030Rio de Janeiro    2345.67\n")
        temp_file.rewind
      end

      it 'considera apenas linhas com o tamanho especificado' do
        results = TestParser.load_lines(temp_file.path, length: 50)

        expect(results.size).to eq(2)
        expect(results[0].name).to eq('João Silva')
        expect(results[1].name).to eq('Maria Santos')
      end
    end

    context 'com filtro :length e brancos a direita' do
      before do
        # registro preenchido com brancos a direita, como num arquivo CNAB
        temp_file.write("#{'João Silva          00025São Paulo         12'.ljust(50, ' ')}\r\n")
        temp_file.rewind
      end

      it 'nao descarta a linha por causa do preenchimento' do
        results = TestParser.load_lines(temp_file.path, length: 50)

        expect(results.size).to eq(1)
        expect(results[0].name).to eq('João Silva')
      end
    end

    context 'com linhas em branco' do
      before do
        temp_file.write("João Silva          00025São Paulo         001234.56 \n")
        temp_file.write("\n")
        temp_file.write("Maria Santos        00030Rio de Janeiro    002345.67 \n")
        temp_file.rewind
      end

      it 'ignora linhas em branco ao usar filtro except array' do
        results = TestParser.load_lines(temp_file.path, except: [])

        expect(results.size).to eq(2)
      end

      it 'ignora linhas em branco ao usar filtro except regex' do
        results = TestParser.load_lines(temp_file.path, except: /^$/)

        expect(results.size).to eq(2)
      end
    end

    context 'com combinacao de filtros' do
      before do
        temp_file.write("HEADER linha        00000Ignorar           0000.00\n")
        temp_file.write("João Silva          00025São Paulo         1234.56\n")
        temp_file.write("abc\n")
        temp_file.write("Maria Santos        00030Rio de Janeiro    2345.67\n")
        temp_file.write("FOOTER linha        00000Ignorar           0000.00\n")
        temp_file.rewind
      end

      it 'except regex e length' do
        results = TestParser.load_lines(temp_file.path, except: /^(HEADER|FOOTER)/, length: 50)

        expect(results.size).to eq(2)
        expect(results[0].name).to eq('João Silva')
        expect(results[1].name).to eq('Maria Santos')
      end

      it 'except array e length' do
        results = TestParser.load_lines(temp_file.path, except: [1, 5], length: 50)

        expect(results.size).to eq(2)
        expect(results[0].name).to eq('João Silva')
        expect(results[1].name).to eq('Maria Santos')
      end
    end
  end

  describe '.load_lines_except_array' do
    let(:temp_file) { Tempfile.new(['test_parse', '.txt']) }

    after do
      temp_file.close
      temp_file.unlink
    end

    before do
      temp_file.write("Header              00000Ignorar           0000.00\n")
      temp_file.write("João Silva          00025São Paulo         1234.56\n")
      temp_file.write("\n")
      temp_file.write("Maria Santos        00030Rio de Janeiro    2345.67\n")
      temp_file.rewind
    end

    it 'exclui linhas baseadas em índices (1-based)' do
      results = TestParser.load_lines_except_array(temp_file.path, [1, 3])

      expect(results.size).to eq(2)
      expect(results[0].name).to eq('João Silva')
      expect(results[1].name).to eq('Maria Santos')
    end

    it 'ignora linhas em branco' do
      results = TestParser.load_lines_except_array(temp_file.path, [1])

      expect(results.size).to eq(2)
    end

    it 'respeita o filtro de length quando fornecido' do
      results = TestParser.load_lines_except_array(temp_file.path, [1], 50)

      expect(results.size).to eq(2)
      expect(results.all?(TestParser)).to be(true)
    end
  end

  describe '.load_lines_except_regex' do
    let(:temp_file) { Tempfile.new(['test_parse', '.txt']) }

    after do
      temp_file.close
      temp_file.unlink
    end

    before do
      temp_file.write("HEADER              00000Ignorar           0000.00\n")
      temp_file.write("João Silva          00025São Paulo         1234.56\n")
      temp_file.write("\n")
      temp_file.write("FOOTER              00000Ignorar           0000.00\n")
      temp_file.rewind
    end

    it 'exclui linhas que correspondem ao regex' do
      results = TestParser.load_lines_except_regex(temp_file.path, /^(HEADER|FOOTER)/)

      expect(results.size).to eq(1)
      expect(results[0].name).to eq('João Silva')
    end

    it 'ignora linhas em branco' do
      results = TestParser.load_lines_except_regex(temp_file.path, /^NONEXISTENT/)

      expect(results.size).to eq(3)
    end

    it 'respeita o filtro de length quando fornecido' do
      results = TestParser.load_lines_except_regex(temp_file.path, /^(HEADER|FOOTER)/, 50)

      expect(results.size).to eq(1)
      expect(results[0].name).to eq('João Silva')
    end
  end

  describe '.line_length_valid?' do
    it 'retorna true quando expected_length é nil' do
      expect(TestParser.line_length_valid?('qualquer linha', nil)).to be(true)
    end

    it 'retorna true quando o tamanho da linha corresponde' do
      line = "#{'a' * 50}\n"
      expect(TestParser.line_length_valid?(line, 50)).to be(true)
    end

    it 'retorna false quando o tamanho da linha não corresponde' do
      line = "#{'a' * 30}\n"
      expect(TestParser.line_length_valid?(line, 50)).to be(false)
    end

    it 'calcula corretamente para linhas de tamanhos diferentes' do
      line = "#{'a' * 48}\n"
      expect(TestParser.line_length_valid?(line, 47)).to be(false)
      expect(TestParser.line_length_valid?(line, 48)).to be(true)
      expect(TestParser.line_length_valid?(line, 49)).to be(false)
    end
  end

  describe 'casos de uso práticos' do
    context 'quando parseando arquivo de retorno bancário simplificado' do
      let(:temp_file) { Tempfile.new(['bank_return', '.ret']) }

      after do
        temp_file.close
        temp_file.unlink
      end

      before do
        temp_file.write("0              14\n") # Header
        temp_file.write("112345678901234000000012345620250101\n") # Detail
        temp_file.write("112345678901235000000067890120250115\n") # Detail
        temp_file.write("9              02\n") # Footer
        temp_file.rewind
      end

      it 'parseia corretamente arquivo de retorno' do
        results = BankReturnParser.load_lines(temp_file.path, except: /^[09]/)

        expect(results.size).to eq(2)
        expect(results[0].record_type).to eq('1')
        expect(results[0].document).to eq('12345678901234')
        expect(results[0].amount).to eq(1234.56)
        expect(results[0].due_date).to eq('20250101')

        expect(results[1].amount).to eq(6789.01)
      end
    end

    context 'com múltiplos transformadores complexos' do
      it 'aplica todos os transformadores corretamente' do
        line = 'produto teste       123.45678 S2025-02-01'
        result = ComplexParser.load_line(line)

        expect(result.name).to eq('PRODUTO TESTE')
        expect(result.price).to eq(123.46)
        expect(result.active).to be(true)
        expect(result.date).to eq(Date.new(2025, 2, 1))
      end

      it 'trata valores vazios nos transformadores' do
        line = 'produto             000.00000 N          '
        result = ComplexParser.load_line(line)

        expect(result.name).to eq('PRODUTO')
        expect(result.price).to eq(0.0)
        expect(result.active).to be(false)
        expect(result.date).to be_nil
      end
    end
  end

  describe 'heranca do layout' do
    it 'a classe filha comeca com os campos da classe mae' do
      campos = ChildParser.parse_values.map(&:first)

      expect(campos).to include(:campo_proprio)
    end

    it 'o campo redefinido na filha vence o da mae' do
      ranges = ChildParser.parse_values.each_with_object({}) { |(campo, range, _), acc| acc[campo] = range }

      expect(ranges[:campo_sobrescrito]).to eq(10..14)
    end

    it 'definir campo na filha nao altera o layout da mae' do
      ranges = ParentParser.parse_values.each_with_object({}) { |(campo, range, _), acc| acc[campo] = range }

      expect(ParentParser.parse_values.size).to eq(2)
      expect(ranges[:campo_sobrescrito]).to eq(5..9)
    end

    it 'a filha realmente usa o proprio layout ao parsear' do
      result = ChildParser.load_line('AAAAABBBBBCCCCC')

      expect(result.campo_proprio).to eq('AAAAA')
      expect(result.campo_sobrescrito).to eq('CCCCC')
    end
  end

  describe 'transformador informado como bloco' do
    it 'aplica o bloco ao valor do campo' do
      expect(BlockParser.load_line('00021').quantidade).to eq(42)
    end
  end
end
