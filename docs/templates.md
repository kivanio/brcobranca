# Templates de boleto

O BRCobranca desenha o boleto a partir de um *template*, escolhido pela opção
`gerador` da configuração. Há templates baseados em [RGhost](https://github.com/shairontoledo/rghost)
(Ghostscript) e um baseado em [Prawn](https://github.com/prawnpdf/prawn) (Ruby puro).

## Configuração

```ruby
# config/initializers/brcobranca.rb
Brcobranca.setup do |config|
  config.gerador = :rghost   # template usado (padrão: :rghost)
  config.formato = :pdf      # formato padrão de saída (padrão: :pdf)
  config.resolucao = 150     # resolução em DPI dos formatos de imagem (padrão: 150, só RGhost)
end
```

> **Importante:** o template é escolhido **uma única vez**, quando a classe
> `Brcobranca::Boleto::Base` é carregada pela primeira vez. Configure o `gerador`
> antes de usar qualquer classe de boleto (em Rails, num initializer). Alterar o
> `gerador` depois disso troca o logotipo usado, mas **não** troca o template, e
> pode gerar boletos com o logotipo no formato errado.

## Geradores disponíveis

| `gerador`         | Template                 | Layout                                   | PIX (QR Code) | Dependências                       |
| ----------------- | ------------------------ | ---------------------------------------- | ------------- | ---------------------------------- |
| `:rghost`         | `Template::Rghost`       | Boleto padrão, um por página (A4)        | Não           | Ghostscript                        |
| `:rghost_bolepix` | `Template::RghostBolepix`| Boleto padrão com QR Code PIX            | Sim           | Ghostscript                        |
| `:rghost2`        | `Template::Rghost2`      | Layout alternativo do boleto padrão      | Não           | Ghostscript                        |
| `:rghost_carne`   | `Template::RghostCarne`  | Carnê, até 3 boletos por página          | Não           | Ghostscript                        |
| `:both`           | `Rghost` + `RghostCarne` | Boleto padrão e carnê no mesmo processo  | Não           | Ghostscript                        |
| `:prawn`          | `Template::Prawn`        | Boleto padrão, um por página (A4)        | Sim           | gems `prawn`, `barby` e `rqrcode`  |

Qualquer valor não listado cai no `:rghost`.

O QR Code PIX é desenhado quando o boleto tem o atributo `emv` preenchido. Nos
templates sem suporte a PIX, o `emv` é ignorado.

### RGhost

Os templates RGhost dependem do **Ghostscript** instalado no servidor (`gs`). As
gems `rghost` e `rghost_barcode` já são dependências do BRCobranca.

Formatos aceitos: `:pdf`, `:jpg`, `:png`, `:tif`, `:ps` e os demais
[dispositivos suportados pelo RGhost](http://wiki.github.com/shairontoledo/rghost/supported-devices-drivers-and-formats).
A opção `resolucao` vale para os formatos de imagem.

Os logotipos usados são os arquivos EPS em `lib/brcobranca/arquivos/logos/`
(`<Banco>_carne.eps` no gerador `:rghost_carne`).

### Prawn

O template Prawn gera o PDF em Ruby puro, sem Ghostscript. As gems necessárias
**não** são instaladas junto com o BRCobranca; adicione-as ao `Gemfile` da
aplicação:

```ruby
gem 'prawn'
gem 'barby'    # código de barras
gem 'rqrcode'  # QR Code PIX (necessária apenas para boletos com `emv`)
```

Formatos aceitos:

- `:pdf`: retorna o conteúdo do PDF (String binária);
- `:prawn`: retorna o `Prawn::Document`, para quem quiser acrescentar conteúdo
  antes de renderizar.

Qualquer outro formato levanta `NotImplementedError`. A opção `resolucao` não se
aplica.

Os logotipos usados são os arquivos PNG em `lib/brcobranca/arquivos/logos/png/`,
e o texto usa a fonte Roboto, distribuída com a gem.

## Gerando boletos

```ruby
boleto = Brcobranca::Boleto::Itau.new(
  # ... atributos do boleto
  emv: '000201...' # opcional: QR Code PIX em :rghost_bolepix e :prawn
)

boleto.to_pdf             # formato pelo nome do método
boleto.to(:pdf)           # formato como argumento
boleto.to_png             # somente RGhost

# Vários boletos em um único arquivo
Brcobranca::Boleto::Base.lote([boleto1, boleto2], formato: :pdf)
```

Se `lote` for chamado sem `:formato`, é usado o `config.formato`.

### Carnê

Com `gerador = :rghost_carne`, `to_pdf` e os demais métodos dinâmicos geram o
carnê. Com `gerador = :both`, os dois layouts ficam disponíveis:

```ruby
boleto.to(:pdf)                                  # boleto padrão
boleto.to_carne(:pdf)                            # carnê
Brcobranca::Boleto::Base.lote(boletos, formato: :pdf)       # boletos padrão
Brcobranca::Boleto::Base.lote_carne(boletos, formato: :pdf) # carnê, até 3 por página
```

No `:both`, os métodos dinâmicos (`to_pdf`, `to_png`, ...) geram o **carnê**;
use `to(:pdf)` para o boleto padrão.
