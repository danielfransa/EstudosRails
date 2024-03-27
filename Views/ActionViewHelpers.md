# Action View Helpers

## 1 Visão geral dos auxiliares fornecidos pelo Action View

O que se segue é apenas um breve resumo dos auxiliares disponíveis no Action View. É recomendável que você revise a [documentação da API](https://api.rubyonrails.org/v7.1.3.2/classes/ActionView/Helpers.html) , que aborda todos os auxiliares com mais detalhes, mas deve servir como um bom ponto de partida.


## 1.1 AssetTagHelper

Este módulo fornece métodos para gerar HTML que vincula visualizações a ativos como imagens, arquivos JavaScript, folhas de estilo e feeds.

Por padrão, o Rails vincula-se a esses ativos no host atual na pasta pública, mas você pode direcionar o Rails para vincular-se a ativos de um servidor de ativos dedicado definindo `config.asset_host` a configuração do aplicativo, normalmente em `config/environments/production.rb`. Por exemplo, digamos que seu host de ativos seja `assets.example.com`:

```rb
config.asset_host = "assets.example.com"
image_tag("rails.png")
# => <img src="http://assets.example.com/images/rails.png" />
```

#### 1.1.1 auto_discovery_link_tag

Retorna uma tag de link que navegadores e leitores de feed podem usar para detectar automaticamente um feed RSS, Atom ou JSON.

```rb
auto_discovery_link_tag(:rss, "http://www.example.com/feed.rss", { title: "RSS Feed" })
# => <link rel="alternate" type="application/rss+xml" title="RSS Feed" href="http://www.example.com/feed.rss" />
```

#### 1.1.2 caminho_imagem

Calcula o caminho para um ativo de imagem no app/assets/imagesdiretório. Caminhos completos da raiz do documento serão passados. Usado internamente por image_tagpara construir o caminho da imagem.

```rb
image_path("edit.png") # => /assets/edit.png
```

A impressão digital será adicionada ao nome do arquivo se config.assets.digest estiver definido como verdadeiro.

```rb
image_path("edit.png")
# => /assets/edit-2d1a2db63fc738690021fedb5a65b68e.png
```


#### 1.1.3 URL_da_imagem

Calcula a URL para um ativo de imagem no diretório `app/assets/images`. Isso chamará `image_path` internamente e se fundirá com seu host atual ou com seu host de ativos.

```rb
image_url("edit.png") # => http://www.example.com/assets/edit.png
```


#### 1.1.4 imagem_tag

Retorna uma tag de imagem HTML para a fonte. A fonte pode ser um caminho completo ou um arquivo que existe em seu diretório `app/assets/images`.

```rb
image_tag("icon.png") # => <img src="/assets/icon.png" />
```


#### 1.1.5 javascript_include_tag

Retorna uma tag de script HTML para cada uma das fontes fornecidas. Você pode passar o nome do arquivo ( `.js` a extensão é opcional) dos arquivos JavaScript que existem em seu diretório `app/assets/javascripts` para inclusão na página atual ou pode passar o caminho completo relativo à raiz do documento.

```rb
javascript_include_tag "common"
# => <script src="/assets/common.js"></script>
```

#### 1.1.6 caminho_javascript

Calcula o caminho para um ativo JavaScript no diretório `app/assets/javascripts`. Se o nome do arquivo de origem não tiver extensão, `.js` será anexado. Caminhos completos da raiz do documento serão passados. Usado internamente por `javascript_include_tag` para construir o caminho do script.

```rb
javascript_path "common" # => /assets/common.js
```


#### 1.1.7 javascript_url

Calcula a URL para um ativo JavaScript no diretório `app/assets/javascripts`. Isso chamará `javascript_path` internamente e se fundirá com seu host atual ou com seu host de ativos.

```rb
javascript_url "common"
# => http://www.example.com/assets/common.js
```


#### 1.1.8 imagem_tag

Retorna uma tag de imagem HTML para a fonte. Suporta a passagem de uma String, um Array ou um Bloco.

```rb
picture_tag("icon.webp", "icon.png")
```

Isso gera o seguinte HTML:

```rb
<picture>
  <source srcset="/assets/icon.webp" type="image/webp" />
  <source srcset="/assets/icon.png" type="image/png" />
  <img src="/assets/icon.png" />
</picture>
```

### 1.1.9 preload_link_tag

Retorna uma tag de link que os navegadores podem usar para pré-carregar a fonte. A origem pode ser o caminho de um recurso gerenciado pelo pipeline de ativos, um caminho completo ou um URI.

```rb
preload_link_tag "application.css"
# => <link rel="preload" href="/assets/application.css" as="style" type="text/css" />
```

#### 1.1.10 folha de estilo_link_tag

Retorna uma tag de link de folha de estilo para as fontes especificadas como argumentos. Se você não especificar uma extensão, .cssserá anexado automaticamente.

```rb
stylesheet_link_tag "application"
# => <link href="/assets/application.css" rel="stylesheet" />
```


### 1.1.11 caminho_da_folha de estilo

Calcula o caminho para um ativo de folha de estilo no diretório `app/assets/stylesheets`. Se o nome do arquivo de origem não tiver extensão, `.css` será anexado. Caminhos completos da raiz do documento serão passados. Usado internamente por `stylesheet_link_tag` para construir o caminho da folha de estilo.

```rb
stylesheet_path "application" # => /assets/application.css
```


#### 1.1.12 folha de estilo_url

Calcula a URL para um ativo de folha de estilo no diretório `app/assets/stylesheets`. Isso chamará `stylesheet_path` internamente e se fundirá com seu host atual ou com seu host de ativos.

```rb
stylesheet_url "application"
# => http://www.example.com/assets/application.css
```


### 1.2 AtomFeedHelper


#### 1.2.1 átomo_feed

Este auxiliar facilita a construção de um feed Atom. Aqui está um exemplo de uso completo:

 **config/rotas.rb** 

```rb
resources :articles
```

**app/controllers/articles_controller.rb**

```rb
def index
  @articles = Article.all

  respond_to do |format|
    format.html
    format.atom
  end
end
```

**app/views/articles/index.atom.builder**

```rb
atom_feed do |feed|
  feed.title("Articles Index")
  feed.updated(@articles.first.created_at)

  @articles.each do |article|
    feed.entry(article) do |entry|
      entry.title(article.title)
      entry.content(article.body, type: 'html')

      entry.author do |author|
        author.name(article.author_name)
      end
    end
  end
end
```


### 1.3 Auxiliar de referência


#### 1.3.1 referência

Permite medir o tempo de execução de um bloco em um template e registra o resultado no log. Envolva esse bloco em torno de operações caras ou possíveis gargalos para obter uma leitura do tempo da operação.

```rb
<% benchmark "Process data files" do %>
  <%= expensive_files_operation %>
<% end %>
```
Isso adicionaria algo como "Arquivos de dados do processo (0,34523)" ao log, que você pode usar para comparar tempos ao otimizar seu código.


### 1.4 Ajudante de Cache


#### 1.4.1 cache

Um método para armazenar em cache fragmentos de uma visualização em vez de uma ação ou página inteira. Essa técnica é útil para armazenar em cache peças como menus, listas de tópicos de notícias, fragmentos HTML estáticos e assim por diante. Este método utiliza um bloco que contém o conteúdo que você deseja armazenar em cache. Consulte `AbstractController::Caching::Fragments` para obter mais informações.

```rb
<% cache do %>
  <%= render "application/footer" %>
<% end %>
```

### 1.5 Captura Auxiliar

#### 1.5.1 captura

O método `capture` permite extrair parte de um modelo em uma variável. Você pode então usar essa variável em qualquer lugar dos seus modelos ou layout.

```rb
<% @greeting = capture do %>
  <p>Welcome! The date and time is <%= Time.now %></p>
<% end %>
```

A variável capturada pode então ser usada em qualquer outro lugar.

```rb
<html>
  <head>
    <title>Welcome!</title>
  </head>
  <body>
    <%= @greeting %>
  </body>
</html>
```

#### 1.5.2 conteúdo_para

A chamada `content_for` armazena um bloco de marcação em um identificador para uso posterior. Você pode fazer chamadas subsequentes ao conteúdo armazenado em outros modelos ou no layout, passando o identificador como argumento para `yield`.

Por exemplo, digamos que temos um layout de aplicativo padrão, mas também uma página especial que requer determinado JavaScript que o resto do site não precisa. Podemos incluir `content_for` este JavaScript em nossa página especial sem engordar o resto do site.

**app/views/layouts/application.html.erb**

```rb
<html>
  <head>
    <title>Welcome!</title>
    <%= yield :special_script %>
  </head>
  <body>
    <p>Welcome! The date and time is <%= Time.now %></p>
  </body>
</html>
cópia de
app/views/articles/special.html.erb

<p>This is a special page.</p>

<% content_for :special_script do %>
  <script>alert('Hello!')</script>
<% end %>
```

### 1.6 Auxiliar de Data

#### 1.6.1 distância_do_tempo_em_palavras

Informa a distância aproximada no tempo entre dois objetos de hora ou data ou números inteiros em segundos. Defina `include_seconds` como verdadeiro se desejar aproximações mais detalhadas.

```rb
distance_of_time_in_words(Time.now, Time.now + 15.seconds)
# => less than a minute
distance_of_time_in_words(Time.now, Time.now + 15.seconds, include_seconds: true)
# => less than 20 seconds
```


#### 1.6.2 time_ago_in_words

Como `distance_of_time_in_words`, mas onde `to_time` está fixo `Time.now`.

```rb
time_ago_in_words(3.minutes.from_now) # => 3 minutes
```

### 1.7 Auxiliar de depuração

Retorna uma `pre` tag que possui um objeto despejado pelo YAML. Isso cria uma maneira muito legível de inspecionar um objeto.

```rb
my_hash = { 'first' => 1, 'second' => 'two', 'third' => [1, 2, 3] }
debug(my_hash)
```

```rb
<pre class='debug_dump'>---
first: 1
second: two
third:
- 1
- 2
- 3
</pre>
```


### 1.8 Formulário Auxiliar

Os auxiliares de formulário são projetados para tornar o trabalho com modelos muito mais fácil em comparação ao uso apenas de elementos HTML padrão, fornecendo um conjunto de métodos para criar formulários baseados em seus modelos. Este auxiliar gera o HTML para formulários, fornecendo um método para cada tipo de entrada (por exemplo, texto, senha, seleção e assim por diante). Quando o formulário é enviado (ou seja, quando o usuário clica no botão enviar ou form.submit é chamado via JavaScript), as entradas do formulário serão agrupadas no objeto params e passadas de volta ao controlador.

Você pode aprender mais sobre auxiliares de formulário no [Guia de auxiliares de formulário do Action View](https://guides.rubyonrails.org/form_helpers.html).


## 1.9 Ajudante JavaScript

Fornece funcionalidade para trabalhar com JavaScript em suas visualizações.

### 1.9.1 escape_javascript

Escape de retornos de operadora e aspas simples e duplas para segmentos JavaScript.

### 1.9.2 javascript_tag

Retorna uma tag JavaScript envolvendo o código fornecido.

```rb
javascript_tag "alert('All is good')"
```

```rb
<script>
//<![CDATA[
alert('All is good')
//]]>
</script>
```


### 1.10 NúmeroAjudante

Fornece métodos para converter números em strings formatadas. Os métodos são fornecidos para números de telefone, moeda, porcentagem, precisão, notação posicional e tamanho do arquivo.

#### 1.10.1 número_para_moeda

Formata um número em uma string de moeda (por exemplo, US$ 13,65).

```rb
number_to_currency(1234567890.50) # => $1,234,567,890.50
```

#### 1.10.2 número_para_humano

Pretty imprime (formata e aproxima) um número para que seja mais legível pelos usuários; útil para números que podem ficar muito grandes.

```rb
number_to_human(1234)    # => 1.23 Thousand
number_to_human(1234567) # => 1.23 Million
```


#### 1.10.3 número_para_tamanho_humano

Formata o tamanho dos bytes em uma representação mais compreensível; útil para relatar tamanhos de arquivo aos usuários.

```rb
number_to_human_size(1234)    # => 1.21 KB
number_to_human_size(1234567) # => 1.18 MB
```


#### 1.10.4 número_para_percentagem

Formata um número como uma sequência de porcentagem.

```rb
number_to_percentage(100, precision: 0) # => 100%
```


#### 1.10.5 número_para_telefone

Formata um número em um número de telefone (EUA por padrão).

```rb
number_to_phone(1235551234) # => 123-555-1234
```


#### 1.10.6 número_com_delimitador

Formata um número com milhares agrupados usando um delimitador.

```rb
number_with_delimiter(12345678) # => 12,345,678
```


#### 1.10.7 número_com_precisão

Formata um número com o nível especificado de precision, cujo padrão é 3.

```rb
number_with_precision(111.2345)               # => 111.235
number_with_precision(111.2345, precision: 2) # => 111.23
```


### 1.11 SanitizeHelper

O módulo `SanitizeHelper` fornece um conjunto de métodos para limpar texto de elementos HTML indesejados.

#### 1.11.1 higienizar

Este auxiliar de limpeza codificará em HTML todas as tags e removerá todos os atributos que não são especificamente permitidos.

```rb
sanitize @article.body
```

Se as opções `:attributes` ou `:tags` forem passadas, apenas os atributos e tags mencionados serão permitidos e nada mais.

```rb
sanitize @article.body, tags: %w(table tr td), attributes: %w(id class style)
```

Para alterar os padrões para usos múltiplos, por exemplo, adicionando tags de tabela ao padrão:

```rb
class Application < Rails::Application
  config.action_view.sanitized_allowed_tags = 'table', 'tr', 'td'
end
```


#### 1.11.2 sanitize_css(estilo)

Limpa um bloco de código CSS.


#### 1.11.3 strip_links(html)

Remove todas as tags de link do texto, deixando apenas o texto do link.

```rb
strip_links('<a href="https://rubyonrails.org">Ruby on Rails</a>')
# => Ruby on Rails
```
```rb
strip_links('emails to <a href="mailto:me@email.com">me@email.com</a>.')
# => emails to me@email.com.
```
```rb
strip_links('Blog: <a href="http://myblog.com/">Visit</a>.')
# => Blog: Visit.
```


#### 1.11.4 strip_tags(html)
Remove todas as tags HTML do HTML, incluindo comentários. Esta funcionalidade é alimentada pela gem rails-html-sanitizer.

```rb
strip_tags("Strip <i>these</i> tags!")
# => Strip these tags!
```
```rb
strip_tags("<b>Bold</b> no more!  <a href='more.html'>See more</a>")
# => Bold no more!  See more
```

NB: A saída ainda pode conter caracteres '<', '>', '&' sem escape e confundir os navegadores.


### 1.12 Ajuda de URL

Fornece métodos para criar links e obter URLs que dependem do subsistema de roteamento.


#### 1.12.1 url_para

Retorna a URL do conjunto optionsfornecido.

##### 1.12.1.1 Exemplos

```rb
url_for @profile
# => /profiles/1

url_for [ @hotel, @booking, page: 2, line: 3 ]
# => /hotels/1/bookings/1?line=3&page=2

url_for @post # given a composite primary key [:blog_id, :id]
# => /posts/1_2
```

#### 1.12.2 link_para

Links para um URL derivado url_fordos bastidores. Usado principalmente para criar links de recursos RESTful, que neste exemplo se resumem a passar modelos para link_to.

**Exemplos**

```rb
link_to "Profile", @profile
# => <a href="/profiles/1">Profile</a>

link_to "Book", @book # given a composite primary key [:author_id, :id]
# => <a href="/books/2_1">Book</a>
```

Você também pode usar um bloco se o destino do seu link não couber no parâmetro name. Exemplo ERB:

```rb
<%= link_to @profile do %>
  <strong><%= @profile.name %></strong> -- <span>Check it out!</span>
<% end %>
```
produziria:

```rb
<a href="/profiles/1">
  <strong>David</strong> -- <span>Check it out!</span>
</a>
```

Consulte [a documentação da API para obter mais informações](https://api.rubyonrails.org/v7.1.3.2/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)


#### 1.12.3 botão_para

Gera um formulário que é enviado para a URL passada. O formulário possui um botão de envio com o valor de `name`.

##### 1.12.3.1 Exemplos

```rb
<%= button_to "Sign in", sign_in_path %>
```

produziria aproximadamente algo como:

```rb
<form method="post" action="/sessions" class="button_to">
  <input type="submit" value="Sign in" />
</form>
```

Consulte [a documentação da API para obter mais informações](https://api.rubyonrails.org/v7.1.3.2/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to)


## 1.13 CsrfHelper

Retorna as meta tags "csrf-param" e "csrf-token" com o nome do parâmetro de proteção contra falsificação de solicitação entre sites e do token, respectivamente.

```rb
<%= csrf_meta_tags %>
```

![Active View Helpers](/imagens/action_view_helpers1.JPG)