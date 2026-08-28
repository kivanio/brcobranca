---
name: novo-banco
description: Adiciona suporte a um banco novo (ou a um layout novo de um banco existente) na gem brcobranca - boleto, remessa CNAB 240/400/444 e retorno. Use quando pedirem "adicionar banco X", "implementar CNAB 240 do banco Y", "criar remessa/retorno para Z" ou "suportar a carteira N".
---

# Adicionar banco / layout na brcobranca

## 1. Antes de escrever código

- Confirme com o usuário: **código do banco (3 dígitos), carteira(s), e o que exatamente** (boleto? remessa 400? remessa 240? retorno?).
- Procure o manual em `docs/<Banco>/`. Se não existir, peça o PDF/layout — **não invente posições de campo**.
- Escolha o banco mais parecido já implementado como modelo (mesmo layout FEBRABAN, mesmo tipo de convênio) e leia o arquivo dele inteiro antes de começar.

## 2. Boleto — `lib/brcobranca/boleto/<banco>.rb`

```ruby
# frozen_string_literal: true

module Brcobranca
  module Boleto
    class NomeBanco < Base
      validates_length_of :agencia, maximum: 4, message: 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :nosso_numero, maximum: 8, message: 'deve ser menor ou igual a 8 dígitos.'

      def initialize(campos = {})
        campos = { carteira: '01' }.merge!(campos)
        super(campos)
      end

      def banco
        '000' # 3 dígitos
      end

      # Setters sempre normalizam o tamanho do campo
      def agencia=(valor)
        @agencia = valor.to_s.rjust(4, '0') if valor
      end

      def nosso_numero_boleto
        "#{nosso_numero}-#{nosso_numero_dv}"
      end

      def agencia_conta_boleto
        "#{agencia} / #{conta_corrente}-#{conta_corrente_dv}"
      end

      # 25 dígitos exatos — a parte livre do código de barras, específica do banco
      def codigo_barras_segunda_parte
        "..."
      end
    end
  end
end
```

Atenção: o alvo é **Ruby 2.7** (RuboCop `TargetRubyVersion: 2.7`, matriz de CI a partir do 2.7) — nada de endless method, pattern matching ou outras novidades de 3.x.

O total tem que fechar: primeira parte (18) + segunda parte (25) = 43, + DV = 44. Se o tamanho não bater, `Base#codigo_barras` levanta `BoletoInvalido` dizendo o tamanho encontrado.

Logos: `lib/brcobranca/arquivos/logos/<class_name>.eps` e `<class_name>_carne.eps` (`class_name` = nome da classe em minúsculas). Sem eles o shared example `busca_logotipo` falha.

## 3. Remessa

- CNAB 400 → `lib/brcobranca/remessa/cnab400/<banco>.rb < Cnab400::Base`; implemente `info_conta`, `cod_banco`, `nome_banco`, `complemento`, `monta_detalhe(pagamento, sequencial)`.
- CNAB 240 → `lib/brcobranca/remessa/cnab240/<banco>.rb < Cnab240::Base`; implemente `cod_banco`, `nome_banco`, `versao_layout_arquivo`, `versao_layout_lote`, `codigo_convenio`, `convenio_lote`, `info_conta`, `complemento_header`, `complemento_trailer` (veja quais levantam `NaoImplementado` na base).

Cada campo é concatenado com tamanho fixo: `rjust(n, '0')` para numérico, `format_size(n)` para texto, `''.rjust(n, ' ')` para brancos. Mantenha o comentário `# nome do campo  <tamanho>` alinhado à direita como nos demais bancos — é a única defesa contra registro fora de tamanho.

Valide o tamanho de cada registro no spec (`expect(linha.size).to eq(400)` / `240`).

## 4. Retorno

`lib/brcobranca/retorno/cnab{240,400}/<banco>.rb`, `extend ParseLine::FixedWidth` + `fixed_width_layout` com as faixas de posição (índices 0-based, inclusivos). Copie a estrutura de `retorno/cnab400/itau.rb`.

Depois **registre o `when '<código>'`** no `case` de `Retorno::Cnab400::Base.load_lines` (banco em `header[76..78]`) ou `Retorno::Cnab240::Base.load_lines` (banco em `header[0..2]`).

## 5. Registro obrigatório

Adicione uma linha `autoload` para **cada** classe nova no módulo correspondente em `lib/brcobranca.rb`. Sem isso a classe não é carregada.

## 6. Specs

- `spec/brcobranca/boleto/<banco>_spec.rb`: validações, `nosso_numero_boleto`, `codigo_barras`, `codigo_barras.linha_digitavel`, `it_behaves_like 'busca_logotipo'` e `'formatos_validos'`.
- `spec/brcobranca/remessa/cnab{240,400}/<banco>_spec.rb`: `it_behaves_like 'cnab240'` / `'cnab400'`, `Timecop.freeze` na data usada pelo layout, e comparação do arquivo inteiro com `read_remessa('remessa-<banco>-cnab240.rem', obj.gera_arquivo)`.
  - A fixture é **criada automaticamente** na primeira rodada — confira o conteúdo gerado contra o manual antes de commitar, e apague o arquivo para regerar após mudanças de layout.
- `spec/brcobranca/retorno/cnab{240,400}/<banco>_spec.rb` com um arquivo de exemplo em `spec/arquivos/`.

## 7. Fechamento

```bash
bundle exec rspec spec/brcobranca/.../<banco>_spec.rb
bundle exec rubocop --parallel
```

Atualize as tabelas "Bancos Disponíveis" e "Retornos e Remessas" no `README.md`.
