# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> Idioma: o domínio (boletos, CNAB, bancos brasileiros), a documentação e os commits são em português. Escreva comentários, mensagens de validação e commits em português, como no restante do código.

## O que é

Gem `brcobranca` — emissão de boletos bancários e geração/leitura de arquivos CNAB (remessa e retorno) para bancos brasileiros. Biblioteca pura, sem Rails: **não depende de ActiveSupport nem de ActiveModel** (ver "Sem ActiveSupport" abaixo).

## Comandos

```bash
bundle exec rake                              # suíte completa (é o que o CI roda)
bundle exec rspec                             # idem
bundle exec rspec spec/brcobranca/boleto/itau_spec.rb          # um arquivo
bundle exec rspec spec/brcobranca/boleto/itau_spec.rb:42       # um exemplo (linha)
bundle exec rspec -e "nosso numero"           # por descrição
bundle exec rubocop --parallel                # lint (CI usa --fail-level E)
bundle exec rubocop -a                        # autocorreção segura
rake build / rake install / rake release      # tarefas do bundler/gem_tasks
```

### Ambiente

- **rbenv**; `.ruby-version` pede **3.4.3**, que pode não estar instalado localmente (há 3.4.9 e 4.0.x). Se `ruby -v` reclamar, use `RBENV_VERSION=3.4.9 bundle exec ...` ou instale a versão pedida — não altere `.ruby-version` sem combinar.
- **GhostScript é obrigatório** para gerar boletos (PDF/PNG/…) e os specs de boleto usam. macOS: `brew install ghostscript` (`gs`).
- Cobertura via SimpleCov sai em `coverage/` a cada `rspec`.

### Compatibilidade de sintaxe (importante)

O CI roda a matriz **Ruby 2.7 → 3.4 + head**, o gemspec exige `>= 2.7.0` e o RuboCop tem `TargetRubyVersion: 2.7`. Nada de sintaxe exclusiva de Ruby 3.x. `# frozen_string_literal: true` é obrigatório em todo arquivo.

## Arquitetura

Três subsistemas independentes sob `lib/brcobranca/`, todos registrados por `autoload` em `lib/brcobranca.rb`:

| Subsistema | Entrada | Saída |
| --- | --- | --- |
| `Boleto::*` | atributos do título | arquivo PDF/PNG/… + código de barras/linha digitável |
| `Remessa::*` | objetos `Pagamento` | string do arquivo CNAB 240/400/444 enviado ao banco |
| `Retorno::*` | arquivo CNAB do banco | array de objetos com os campos parseados |

**`lib/brcobranca.rb` é o registro central.** Toda classe nova (banco, remessa, retorno) precisa de uma linha `autoload` lá, senão simplesmente não existe. É também onde ficam as exceções (`NaoImplementado`, `BoletoInvalido`, `RemessaInvalida`, `ValorInvalido`) e o `Brcobranca.configuration` (`gerador`, `formato`, `resolucao`, `external_encoding`).

### Sem ActiveSupport / ActiveModel

Reimplementações próprias que se parecem com Rails mas não são:

- `Brcobranca::Validations` (`lib/brcobranca/validations.rb`) — reimplementa `validates_presence_of`, `validates_length_of`, `validates_numericality_of`, `validates_inclusion_of`, `validates_format_of`, `validates_each`, `with_options`, além de `valid?`/`invalid?`/`errors.full_messages`. Suporta só o que está implementado ali; ao precisar de uma validação nova, estenda esse módulo.
- `lib/brcobranca/util/date.rb` — define `Date.current` / `Time.current` (usa `Time.zone` se existir). Use sempre `Date.current`, nunca `Date.today`, para que o Timecop e o fuso do host funcionem nos specs.
- **Monkey patches em `String`/`Integer`/`Date`** — é por isso que `'341'.modulo11` e `valor.somente_numeros` funcionam:
  - `Calculo`: `modulo10`, `modulo11`, `duplo_digito`, `soma_digitos`, `multiplicador`
  - `Formatacao`: `somente_numeros`, `linha_digitavel`, `to_br_cpf/cnpj/cep`, `formata_documento`
  - `FormatacaoString`: `format_size(n)` (ljust/truncate), `truncate`, `remove_accents`
  - `CalculoData`: `fator_vencimento`, `to_s_br`, `to_juliano`

### Boleto

`Boleto::Base` concentra atributos, validações e a montagem genérica do código de barras: `codigo_barras` = `codigo_barras_primeira_parte` (18 díg.) + `codigo_barras_segunda_parte` (25 díg.) + DV módulo 11 inserido na 5ª posição = 44 dígitos.

Cada banco herda de `Base` e tipicamente sobrescreve:

- `banco` (código de 3 dígitos), `nosso_numero_dv`, `nosso_numero_boleto`, `agencia_conta_boleto`
- `codigo_barras_segunda_parte` — **o único método realmente obrigatório** além de `banco`
- setters (`agencia=`, `conta_corrente=`, `nosso_numero=`, `carteira=`) que fazem `rjust(n, '0')`, garantindo o tamanho fixo
- validações de tamanho específicas da carteira

**Renderização:** `Boleto::Template::Base.define_template` roda **no corpo de `Boleto::Base`, na primeira carga da classe**, escolhendo o módulo de template a partir de `Brcobranca.configuration.gerador` (`:rghost`, `:rghost2`, `:rghost_carne`, `:rghost_bolepix`, `:both`). Os métodos `to_pdf`, `to_png`, … são criados dinamicamente via `method_missing` em `Template::Rghost`. O desenho vem de arquivos EPS em `lib/brcobranca/arquivos/templates/` e o logo de `lib/brcobranca/arquivos/logos/<class_name>.eps` (`<class_name>_carne.eps` no modo carnê) — `Base#logotipo` resolve o caminho pelo nome da classe, então **todo banco novo precisa do seu `.eps` de logo** (e do `_carne`).

### Remessa

`Remessa::Base` (pagamentos + validação de que cada item é `Pagamento`/`PagamentoPix`) → `Cnab400::Base`, `Cnab240::Base`, `Cnab444::Itau` → classe do banco.

- **CNAB 400**: `gera_arquivo` monta `monta_header` + N × `monta_detalhe` + `monta_trailer`, junta com `\n`, aplica `.remove_accents.upcase` e converte para **CRLF**. Registros opcionais (multa, descontos adicionais, PIX) são adicionados quando o banco implementa `monta_detalhe_multa` / `monta_descontos_adicionais` / `monta_detalhe_pix` — detecção por `respond_to?`.
- **CNAB 240**: `Cnab240::Base` monta header de arquivo, header de lote, segmentos P/Q/R e trailers; o banco fornece `cod_banco`, `nome_banco`, `versao_layout_arquivo`, `versao_layout_lote`, `codigo_convenio`, `info_conta` etc.
- Os métodos que o banco deve sobrescrever levantam `Brcobranca::NaoImplementado` na base — é o contrato. `gera_arquivo` levanta `RemessaInvalida` se `invalid?`.
- `Pagamento` e `PagamentoPix` são os registros-detalhe (sacado, avalista, valor, vencimento, multa, desconto, etc.).

**Regra de ouro do CNAB:** é formato de posição fixa. Todo campo é concatenado já com o tamanho exato (`rjust(n, '0')` para numérico, `format_size(n)` para texto). Os comentários alinhados à direita nos métodos `monta_*` dão o tamanho de cada campo — mantenha-os ao editar; uma linha com 401 caracteres em vez de 400 quebra o arquivo inteiro sem erro visível.

### Retorno

Usa a gem `parseline` (`extend ParseLine::FixedWidth` + bloco `fixed_width_layout` com faixas de posição). O despacho é por código do banco lido do header do próprio arquivo:

- `Retorno::Cnab400::Base.load_lines` → banco em `header[76..78]`
- `Retorno::Cnab240::Base.load_lines` → banco em `header[0..2]`
- sem match, cai no parser genérico (`RetornoCnab400` está marcado como DEPRECATED)

Ao adicionar um banco, inclua o `when 'XXX'` no `case` da base correspondente, além do `autoload`.

### Documentação dos layouts

`docs/<Banco>/` guarda os manuais (PDFs) usados como referência. Consulte-os antes de mudar posições de campo — o README lista as carteiras e os layouts suportados por banco.

## Convenções de teste

- Specs espelham `lib/` em `spec/brcobranca/`. `disable_monkey_patching!`, ordem aleatória, sintaxe `expect`.
- **Remessa é testada por fixture de arquivo inteiro**: `read_remessa('remessa-itau-cnab240.rem', itau.gera_arquivo)` (`spec/support/remessa_helpers.rb`). ⚠️ O helper **grava** a fixture se ela não existir — então na primeira execução o teste passa trivialmente. Para regerar uma fixture após mudança intencional de layout, **apague o arquivo em `spec/fixtures/remessa/` e rode o spec**, depois revise o diff no git.
- `Timecop.freeze` é usado sempre que o arquivo contém data/hora de geração; sempre com `Timecop.return` no `after`.
- Shared examples em `spec/support/shared_examples/`: `cnab240`, `cnab400`, `cnab400 PIX`, `busca_logotipo`, `formatos_validos` — inclua-os nos specs novos com `it_behaves_like`.
- Arquivos de retorno de exemplo ficam em `spec/arquivos/*.RET`.

## Checklist para um banco novo

1. `lib/brcobranca/boleto/<banco>.rb` herdando de `Boleto::Base` (+ `codigo_barras_segunda_parte`, `banco`, setters com `rjust`).
2. Logos `lib/brcobranca/arquivos/logos/<banco>.eps` e `<banco>_carne.eps`.
3. `lib/brcobranca/remessa/cnab{240,400}/<banco>.rb` e/ou `lib/brcobranca/retorno/cnab{240,400}/<banco>.rb`.
4. `autoload` de cada classe nova em `lib/brcobranca.rb`.
5. `when '<código>'` no `case` de `Retorno::Cnab*::Base.load_lines`, se houver retorno.
6. Specs espelhando a estrutura + `it_behaves_like` dos shared examples + fixture de remessa.
7. Atualizar as tabelas do `README.md` (bancos, carteiras, retornos/remessas).

## Notas do repositório

- Branch principal: `master`. `.conductor/refactor/` é um **git worktree** da branch `refactor` — não edite arquivos por lá a partir daqui.
- `coverage/` e `pkg/` são gerados; não versione mudanças neles.
