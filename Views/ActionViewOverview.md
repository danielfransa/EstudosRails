# Action View Overview

## O que é Action View?

No Rails, as solicitações da web são tratadas pelo Action Controller e Action View. Normalmente, o Action Controller se preocupa em se comunicar com o banco de dados e executar ações CRUD quando necessário. Action View é então responsável por compilar a resposta.

Os modelos Action View são escritos usando Ruby incorporado em tags misturadas com HTML. Para evitar sobrecarregar os modelos com código padrão, diversas classes auxiliares fornecem comportamento comum para formulários, datas e strings. Também é fácil adicionar novos auxiliares ao seu aplicativo à medida que ele evolui.

![Action View Overview](/imagens/action_view_overview1.JPG)


## Usando Action View com Rails

Para cada controlador, há um diretório associado no diretório `app/views` que contém os arquivos de modelo que compõem as visualizações associadas a esse controlador. Esses arquivos são usados ​​para exibir a visualização resultante de cada ação do controlador.

Vamos dar uma olhada no que o Rails faz por padrão ao criar um novo recurso usando o gerador de scaffold:

```bash
$ bin/rails generate scaffold article
      [...]
      invoke  scaffold_controller
      create    app/controllers/articles_controller.rb
      invoke    erb
      create      app/views/articles
      create      app/views/articles/index.html.erb
      create      app/views/articles/edit.html.erb
      create      app/views/articles/show.html.erb
      create      app/views/articles/new.html.erb
      create      app/views/articles/_form.html.erb
      [...]
```

Existe uma convenção de nomenclatura para visualizações no Rails. Normalmente, as visualizações compartilham seu nome com a ação do controlador associada, como você pode ver acima. Por exemplo, a ação do controlador de índice `articles_controller.rb` usará o arquivo de visualização `index.html.erb` no diretório `app/views/articles`. O HTML completo retornado ao cliente é composto por uma combinação desse arquivo ERB, um modelo de layout que o envolve e todos os parciais aos quais a visualização pode fazer referência. Neste guia, você encontrará documentação mais detalhada sobre cada um desses três componentes.

Conforme mencionado, a saída HTML final é uma composição de três elementos Rails `Templates`: `Partials` e `Layouts`. Abaixo está uma breve visão geral de cada um deles.


## Modelos

Os modelos do Action View podem ser escritos de diversas maneiras. Se o arquivo de modelo tiver uma extensão `.erb`, ele usará uma mistura de ERB (Embedded Ruby) e HTML. Se o arquivo de modelo tiver uma extensão `.builder`, a biblioteca `Builder::XmlMarkup` será usada.

Rails suporta vários sistemas de templates e usa uma extensão de arquivo para distingui-los. Por exemplo, um arquivo HTML usando o sistema de templates ERB terá `.html.erb` como extensão de arquivo.

### ERB

Dentro de um modelo ERB, o código Ruby pode ser incluído usando tags `<% %>` e `<%= %>`. As `<% %>` tags são usadas para executar código Ruby que não retorna nada, como condições, loops ou blocos, e as tags `<%= %>` são usadas quando você deseja saída.

Considere o seguinte loop para nomes:

```rb
<h1>Names of all the people</h1>
<% @people.each do |person| %>
  Name: <%= person.name %><br>
<% end %>
```

O loop é configurado usando tags de incorporação regulares (`<% %>`) e o nome é inserido usando as tags de incorporação de saída (`<%= %>`). Observe que isso não é apenas uma sugestão de uso: funções de saída regulares como `print` e `puts` não serão renderizadas na visualização com modelos ERB. Então isso seria errado:

```py
<%# WRONG %>
Hi, Mr. <% puts "Frodo" %>
```

Para suprimir espaços em branco à esquerda e à direita, você pode usar `<%-` `-%>` alternadamente com `<%` e `%>`.


### Construtor

Os modelos do Builder são uma alternativa mais programática ao ERB. Eles são especialmente úteis para gerar conteúdo XML. Um objeto XmlMarkup nomeado `xml` é disponibilizado automaticamente para modelos com uma extensão `.builder`.

Aqui estão alguns exemplos básicos:

```rb
xml.em("emphasized")
xml.em { xml.b("emph & bold") }
xml.a("A Link", "href" => "https://rubyonrails.org")
xml.target("name" => "compile", "option" => "fast")
```
que produziria:

```xml
<em>emphasized</em>
<em><b>emph &amp; bold</b></em>
<a href="https://rubyonrails.org">A link</a>
<target option="fast" name="compile" />
```

Qualquer método com um bloco será tratado como uma tag de marcação XML com marcação aninhada no bloco. Por exemplo, o seguinte:

```rb
xml.div {
  xml.h1(@person.name)
  xml.p(@person.bio)
}
```

produziria algo como:

```html
<div>
  <h1>David Heinemeier Hansson</h1>
  <p>A product of Danish Design during the Winter of '79...</p>
</div>
```

Abaixo está um exemplo completo de RSS realmente usado no Basecamp:

```rb
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.title(@feed_title)
    xml.link(@url)
    xml.description "Basecamp: Recent items"
    xml.language "en-us"
    xml.ttl "40"

    for item in @recent_items
      xml.item do
        xml.title(item_title(item))
        xml.description(item_description(item)) if item_description(item)
        xml.pubDate(item_pubDate(item))
        xml.guid(@person.firm.account.url + @recent_items.url(item))
        xml.link(@person.firm.account.url + @recent_items.url(item))
        xml.tag!("dc:creator", item.author_name) if item_has_creator?(item)
      end
    end
  end
end
```

3.3 Construtor

Jbuilder é uma gem mantida pela equipe Rails e incluída por padrão no Rails Gemfile. É semelhante ao Builder, mas é usado para gerar JSON, em vez de XML.

Se você não tiver, você pode adicionar o seguinte ao seu Gemfile:

```bash
gem 'jbuilder'
```

Um objeto Jbuilder nomeado `json` é disponibilizado automaticamente para modelos com uma  extensão `.jbuilder`.

Aqui está um exemplo básico:

```rb
json.name("Alex")
json.email("alex@example.com")
```
produziria:

```json
{
  "name": "Alex",
  "email": "alex@example.com"
}
```

Consulte a documentação do Jbuilder para obter mais exemplos e informações.


### Cache de Modelo

Por padrão, o Rails irá compilar cada template em um método para renderizá-lo. No ambiente de desenvolvimento, quando você altera um template, o Rails irá verificar o horário de modificação do arquivo e recompilá-lo.


## Parciais

Modelos parciais - geralmente chamados apenas de "`partials`" - são outro dispositivo para dividir o processo de renderização em partes mais gerenciáveis. Com parciais, você pode extrair trechos de código de seus modelos para separar arquivos e também reutilizá-los em seus modelos.


### Renderizando Parciais

Para renderizar um parcial como parte de uma visualização, você usa o método `render` dentro da visualização:

```rb
<%= render "menu" %>
```

Isso renderizará um arquivo nomeado `_menu.html.erb` naquele ponto da visualização que está sendo renderizada. Observe o caractere de sublinhado inicial: as parciais são nomeadas com um sublinhado inicial para distingui-las das visualizações regulares, mesmo que sejam referidas sem o sublinhado. Isso vale mesmo quando você extrai uma parcial de outra pasta:

```rb
<%= render "application/menu" %>
```

Esse código extrairá o parcial de `app/views/application/_menu.html.erb`.


## Usando parciais para simplificar visualizações

Uma maneira de usar parciais é tratá-los como equivalentes a sub-rotinas; uma maneira de mover detalhes para fora de uma visualização para que você possa entender o que está acontecendo com mais facilidade. Por exemplo, você pode ter uma visualização semelhante a esta:

```rb
<%= render "application/ad_banner" %>

<h1>Products</h1>

<p>Here are a few of our fine products:</p>
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>

<%= render "application/footer" %>
```

Aqui, os parciais `_ad_banner.html.erb` e `_footer.html.erb` podem conter conteúdo que é compartilhado entre muitas páginas do seu aplicativo. Você não precisa ver os detalhes dessas seções quando estiver se concentrando em uma página específica.

![Action View Overview](/imagens/action_view_overview2.JPG)

Além de resolver parciais com a cadeia de herança, os controladores também podem substituir parciais padrão com a cadeia de herança. Por exemplo, um `ProductsController` que herda de `ApplicationController` resolverá uma chamada para `<%= render "ad_banner" %>` pesquisando primeiro `app/views/products/_ad_banner.html.erb` antes de voltar para `app/views/application/_ad_banner.html.erb`.


## Render com Opção locals

Ao renderizar uma parcial, cada chave na opção `locals:` está disponível como uma variável local parcial:

```py
<%# app/views/products/show.html.erb %>

<%= render partial: "products/product", locals: { product: @product } %>

<%# app/views/products/_product.html.erb %>

<%= tag.div id: dom_id(product) do %>
  <h1><%= product.name %></h1>
<% end %>
```

Se um modelo se referir a uma variável que não é passada para a visualização como parte da opção `locals:`, o modelo gerará um `ActionView::Template::Error`:

```py
<%# app/views/products/_product.html.erb %>

<%= tag.div id: dom_id(product) do %>
  <h1><%= product.name %></h1>

  <%# => raises ActionView::Template::Error %>
  <% related_products.each do |related_product| %>
    <%# ... %>
  <% end %>
<% end %>
```

### Usando local_assigns

Cada chave na opção `locals:` está disponível como uma variável local parcial por meio do método auxiliar `local_assigns` :

```py
<%# app/views/products/show.html.erb %>

<%= render partial: "products/product", locals: { product: @product } %>

<%# app/views/products/_product.html.erb %>

<% local_assigns[:product]          # => "#<Product:0x0000000109ec5d10>" %>
<% local_assigns[:options]          # => nil %>
```

Como `local_assigns` é a Hash, é compatível com o operador de atribuição de correspondência de padrões do Ruby 3.1 :

```rb
local_assigns => { product:, **options }
product # => "#<Product:0x0000000109ec5d10>"
options # => {}
```

Quando outras chaves `:product` são atribuídas a uma variável local parcial Hash , elas podem ser divididas em chamadas de método auxiliar:

```rb
<%# app/views/products/_product.html.erb %>

<% local_assigns => { product:, **options } %>

<%= tag.div id: dom_id(product), **options do %>
  <h1><%= product.name %></h1>
<% end %>

<%# app/views/products/show.html.erb %>

<%= render "products/product", product: @product, class: "card" %>
<%# => <div id="product_1" class="card">
  #      <h1>A widget</h1>
  #    </div>
%>
```


A atribuição de correspondência de padrões também suporta renomeação de variáveis:

```rb
local_assigns => { product: record }
product             # => "#<Product:0x0000000109ec5d10>"
record              # => "#<Product:0x0000000109ec5d10>"
product == record   # => true
```

Como `local_assigns` retorna uma instância `Hash`, você pode ler condicionalmente uma variável e depois retornar a um valor padrão quando a chave não fizer parte das locals:opções:

```rb
<%# app/views/products/_product.html.erb %>

<% local_assigns.fetch(:related_products, []).each do |related_product| %>
  <%# ... %>
<% end %>
```

Combinar a atribuição de correspondência de padrões do Ruby 3.1 com chamadas para Hash#with_defaults permite atribuições de variáveis ​​padrão locais parciais compactas:

```rb
<%# app/views/products/_product.html.erb %>

<% local_assigns.with_defaults(related_products: []) => { product:, related_products: } %>

<%= tag.div id: dom_id(product) do %>
  <h1><%= product.name %></h1>

  <% related_products.each do |related_product| %>
    <%# ... %>
  <% end %>
<% end %>
```


### Render sem `partial` e opções `locals`

No exemplo acima, `render` são necessárias 2 opções: `partial` e `locals`. Mas se essas são as únicas opções que você deseja passar, você pode pular o uso dessas opções. Por exemplo, em vez de:

```ruby
<%= render partial: "product", locals: { product: @product } %>
```

Você também pode fazer:

```ruby
<%= render "product", product: @product %>
```

### As opções `as` e `object`

Por padrão `ActionView::Partials::PartialRenderer` tem seu objeto em uma variável local com o mesmo nome do template. Então, dado:

```ruby
<%= render partial: "product" %>
```

dentro de parcial `_product`  entraremos `@product` na variável local product, como se tivéssemos escrito:

```ruby
<%= render partial: "product", locals: { product: @product } %>
```

A opção `object` pode ser usada para especificar diretamente qual objeto será renderizado no parcial; útil quando o objeto do modelo está em outro lugar (por exemplo, em uma variável de instância diferente ou em uma variável local).

Por exemplo, em vez de:

```rb
<%= render partial: "product", locals: { product: @item } %>
```

faríamos:

```rb
<%= render partial: "product", object: @item %>
```

Com a opção `as`, podemos especificar um nome diferente para a referida variável local. Por exemplo, se quiséssemos que fosse `item` em vez de `product` faríamos:

```rb
<%= render partial: "product", object: @item, as: "item" %>
```

Isto é equivalente a

```rb
<%= render partial: "product", locals: { item: @item } %>
```


### Renderizando Coleções

Normalmente, um modelo precisará iterar sobre uma coleção e renderizar um submodelo para cada um dos elementos. Este padrão foi implementado como um método único que aceita um array e renderiza uma parcial para cada um dos elementos do array.

Então este exemplo para renderizar todos os produtos:

```rb
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>
```

pode ser reescrito em uma única linha:

```rb
<%= render partial: "product", collection: @products %>
```

Quando uma parcial é chamada com uma coleção, as instâncias individuais da parcial têm acesso ao membro da coleção que está sendo renderizada por meio de uma variável com o nome da parcial. Nesse caso, o parcial é `_product` e, dentro dele, você pode consultar `product` para obter o membro da coleção que está sendo renderizado.

Você pode usar uma sintaxe abreviada para renderizar coleções. Supondo que `@products` seja uma coleção de instâncias `Product`, você pode simplesmente escrever o seguinte para produzir o mesmo resultado:

```rb
<%= render @products %>
```

O Rails determina o nome da parcial a ser usada observando o nome do modelo na coleção, `Product` neste caso. Na verdade, você pode até renderizar uma coleção composta de instâncias de diferentes modelos usando esta abreviatura, e o Rails escolherá a parcial adequada para cada membro da coleção.


### Modelos de espaçadores

Você também pode especificar uma segunda parcial a ser renderizada entre instâncias da parcial principal usando a opção `:spacer_template`:

```rb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Rails renderizará o parcial `_product_ruler` (sem dados passados ​​para ele) entre cada par de parciais `_product`.


### Locais estritos

Por padrão, os modelos aceitarão qualquer argumento `locals` de palavra-chave. Para definir o que um `locals` modelo aceita, adicione um comentário `locals` mágico:

```rb
<%# locals: (message:) -%>
<%= message %>
```

Valores padrão também podem ser fornecidos:

```rb
<%# locals: (message: "Hello, world!") -%>
<%= message %>
```

Ou localspode ser totalmente desativado:

```rb
<%# locals: () %>
```


## Layouts

Layouts podem ser usados ​​para renderizar um modelo de visualização comum em torno dos resultados das ações do controlador Rails. Normalmente, um aplicativo Rails terá alguns layouts nos quais as páginas serão renderizadas. Por exemplo, um site pode ter um layout para um usuário conectado e outro para o lado de marketing ou vendas do site. O layout do usuário conectado pode incluir navegação de nível superior que deve estar presente em muitas ações do controlador. O layout de vendas de um aplicativo SaaS pode incluir navegação de nível superior para páginas como "Preços" e "Fale conosco". Você esperaria que cada layout tivesse uma aparência diferente. Você pode ler sobre layouts com mais detalhes no guia [Layouts e Renderização no Rails](https://guides.rubyonrails.org/layouts_and_rendering.html) .


### Layouts Parciais

Parciais podem ter seus próprios layouts aplicados a eles. Esses layouts são diferentes daqueles aplicados a uma ação de controle, mas funcionam de maneira semelhante.

Digamos que estejamos exibindo um artigo em uma página que deveria ser agrupada em um `div` para fins de exibição. Primeiramente, criaremos um novo `Article`:

```rb
Article.create(body: 'Partial Layouts are cool!')
```

No modelo `show`, renderizaremos a parcial `_article` envolvida no layout `box`:

**artigos/show.html.erb**

```rb
<%= render partial: 'article', layout: 'box', locals: { article: @article } %>
```

O layout `box` simplesmente envolve a parcial `_article` em uma `div`:

**artigos/_box.html.erb**

```rb
<div class='box'>
  <%= yield %>
</div>
```

Observe que o layout parcial tem acesso à variável `article` local que foi passada para a chamada `render`. No entanto, diferentemente dos layouts de todo o aplicativo, os layouts parciais ainda possuem o prefixo de sublinhado.

Você também pode renderizar um bloco de código dentro de um layout parcial em vez de chamar yield. Por exemplo, se não tivéssemos a parcial `_article`, poderíamos fazer isto:

**artigos/show.html.erb**

```rb
<% render(layout: 'box', locals: { article: @article }) do %>
  <div>
    <p><%= article.body %></p>
  </div>
<% end %>
```

Supondo que usemos a mesma parcial `_box` acima, isso produziria a mesma saída do exemplo anterior.


## Ver caminhos

Ao renderizar uma resposta, o controlador precisa resolver onde as diferentes visualizações estão localizadas. Por padrão, ele procura apenas dentro do diretório `app/views`.

Podemos adicionar outros locais e dar-lhes certa precedência ao resolver caminhos usando os métodos `prepend_view_path` e `append_view_path`.


### Caminho de visualização precedente

Isso pode ser útil, por exemplo, quando queremos colocar visualizações dentro de um diretório diferente para subdomínios.

Podemos fazer isso usando:

```rb
prepend_view_path "app/views/#{request.subdomain}"
```

Então o Action View procurará primeiro neste diretório ao resolver as visualizações.


### Anexar caminho de visualização

Da mesma forma, podemos acrescentar caminhos:

```rb
append_view_path "app/views/direct"
```

Isso será adicionado `app/views/direct` ao final dos caminhos de pesquisa.


## Helpers

Rails fornece muitos métodos auxiliares para usar com Action View. Isso inclui métodos para:

- Formatando datas, strings e números
- Criação de links HTML para imagens, vídeos, folhas de estilo, etc...
- Higienizando conteúdo
- Criando formulários
- Localização de conteúdo

Você pode aprender mais sobre helpers no [Action View Helpers Guide](https://guides.rubyonrails.org/action_view_helpers.html) e no [Action View Form Helpers Guide](https://guides.rubyonrails.org/form_helpers.html)


## Visualizações localizadas

Action View tem a capacidade de renderizar diferentes modelos dependendo da localidade atual.

Por exemplo, suponha que você tenha uma ação show `ArticlesController`. Por padrão, chamar esta ação renderizará arquivos `app/views/articles/show.html.erb`. Mas se você definir `I18n.locale = :de`, então `app/views/articles/show.de.html.erb` será renderizado. Se o modelo localizado não estiver presente, a versão não decorada será usada. Isso significa que você não é obrigado a fornecer visualizações localizadas para todos os casos, mas elas serão preferidas e usadas, se disponíveis.

Você pode usar a mesma técnica para localizar os arquivos de resgate em seu diretório público. Por exemplo, configurar `I18n.locale = :de` e criar `public/500.de.html` e `public/404.de.html` permitiria que você tivesse páginas de resgate localizadas.

Como o Rails não restringe os símbolos que você usa para definir I18n.locale, você pode aproveitar este sistema para exibir conteúdos diferentes dependendo do que desejar. Por exemplo, suponha que você tenha alguns usuários "especialistas" que deveriam ver páginas diferentes dos usuários "normais". Você pode adicionar o seguinte a `app/controllers/application_controller.rb`:

```rb
before_action :set_expert_locale

def set_expert_locale
  I18n.locale = :expert if current_user.expert?
end
```

Então você poderia criar visualizações especiais como `app/views/articles/show.expert.html.erb` as que seriam exibidas apenas para usuários experientes.

Você pode ler mais sobre a API Rails Internationalization (I18n) [aqui](https://guides.rubyonrails.org/i18n.html).