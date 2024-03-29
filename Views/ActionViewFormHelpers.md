# Action View Form Helpers


## 1 Lidando com Formulários Básicos

O principal auxiliar do formulário é `form_with`.

```rb
<%= form_with do |form| %>
  Form contents
<% end %>
```

Quando chamado sem argumentos como este, ele cria uma tag de formulário que, quando enviada, fará um POST na página atual. Por exemplo, supondo que a página atual seja uma página inicial, o HTML gerado ficará assim:

```rb
<form accept-charset="UTF-8" action="/" method="post">
  <input name="authenticity_token" type="hidden" value="J7CBxfHalt49OSHp27hblqK20c9PgwJ108nDHX/8Cts=" />
  Form contents
</form>
```

Você notará que o HTML contém um elemento `input` com tipo `hidden`. Isto `input` é importante porque os formulários não GET não podem ser enviados com êxito sem ele. O elemento de entrada oculto com o nome `authenticity_token` é um recurso de segurança do Rails chamado **proteção contra falsificação de solicitação entre sites** , e os auxiliares de formulário o geram para cada formulário não-GET (desde que esse recurso de segurança esteja habilitado). Você pode ler mais sobre isso no guia [Protegendo Aplicações Rails](https://guides.rubyonrails.org/security.html#cross-site-request-forgery-csrf) .


### 1.1 Um formulário de pesquisa genérico

Um dos formulários mais básicos que você vê na web é o formulário de pesquisa. Este formulário contém:

- um elemento de formulário com método "GET",
- um rótulo para a entrada,
- um elemento de entrada de texto e
- um elemento de envio.

Para criar este formulário você usará o `form_with` objeto construtor de formulário que ele produz. Igual a:

```rb
<%= form_with url: "/search", method: :get do |form| %>
  <%= form.label :query, "Search for:" %>
  <%= form.text_field :query %>
  <%= form.submit "Search" %>
<% end %>
```

Isso irá gerar o seguinte HTML:

```html
<form action="/search" method="get" accept-charset="UTF-8" >
  <label for="query">Search for:</label>
  <input id="query" name="query" type="text" />
  <input name="commit" type="submit" value="Search" data-disable-with="Search" />
</form>
```
exemplo visual: 

<form action="/search" method="get" accept-charset="UTF-8" >
  <label for="query">Search for:</label>
  <input id="query" name="query" type="text" />
  <input name="commit" type="submit" value="Search" data-disable-with="Search" />
</form>
<br>

![Action View Form Helpers - Básicos](/imagens/action_view_form_helpers1.JPG)


### 1.2 Auxiliares para Geração de Elementos de Formulário
O objeto construtor de formulário gerado por `form_with` fornece vários métodos auxiliares para gerar elementos de formulário, como campos de texto, caixas de seleção e botões de opção. O primeiro parâmetro desses métodos é sempre o nome da entrada. Quando o formulário for enviado, o nome será repassado junto com os dados do formulário, e seguirá para o controlador `params` com o valor informado pelo usuário para aquele campo. Por exemplo, se o formulário contiver `<%= form.text_field :query %>`, você poderá obter o valor deste campo no controlador com `params[:query]`.

Ao nomear entradas, Rails usa certas convenções que tornam possível enviar parâmetros com valores não escalares, como arrays ou hashes, que também estarão acessíveis em params. Você pode ler mais sobre eles na seção [Noções básicas sobre convenções de nomenclatura de parâmetros](https://guides.rubyonrails.org/form_helpers.html#understanding-parameter-naming-conventions) deste guia. Para obter detalhes sobre o uso preciso desses auxiliares, consulte a [documentação da API](https://api.rubyonrails.org/v7.1.3.2/classes/ActionView/Helpers/FormTagHelper.html) .


#### 1.2.1 Caixas de seleção

As caixas de seleção são controles de formulário que fornecem ao usuário um conjunto de opções que podem ser ativadas ou desativadas:

```rb
<%= form.check_box :pet_dog %>
<%= form.label :pet_dog, "I own a dog" %>
<%= form.check_box :pet_cat %>
<%= form.label :pet_cat, "I own a cat" %>
```

Isso gera o seguinte:

```html
<input type="checkbox" id="pet_dog" name="pet_dog" value="1" />
<label for="pet_dog">I own a dog</label>
<input type="checkbox" id="pet_cat" name="pet_cat" value="1" />
<label for="pet_cat">I own a cat</label>
```
Exemplo Visual:

<input type="checkbox" id="pet_dog" name="pet_dog" value="1" />
<label for="pet_dog">I own a dog</label>
<input type="checkbox" id="pet_cat" name="pet_cat" value="1" />
<label for="pet_cat">I own a cat</label>
<br>


O primeiro parâmetro `check_box` é o nome da entrada. Os valores da caixa de seleção (os valores que aparecerão em `params`) podem opcionalmente ser especificados usando o terceiro e quarto parâmetros. Consulte a documentação da API para obter detalhes.


#### 1.2.2 Botões de Rádio

Os botões de opção, embora semelhantes às caixas de seleção, são controles que especificam um conjunto de opções nas quais são mutuamente exclusivos (ou seja, o usuário só pode escolher uma):

```rb
<%= form.radio_button :age, "child" %>
<%= form.label :age_child, "I am younger than 21" %>
<%= form.radio_button :age, "adult" %>
<%= form.label :age_adult, "I am over 21" %>
```

Saída:
```html
<input type="radio" id="age_child" name="age" value="child" />
<label for="age_child">I am younger than 21</label>
<input type="radio" id="age_adult" name="age" value="adult" />
<label for="age_adult">I am over 21</label>
```
Exemplo visual:

<input type="radio" id="age_child" name="age" value="child" />
<label for="age_child">I am younger than 21</label>
<input type="radio" id="age_adult" name="age" value="adult" />
<label for="age_adult">I am over 21</label>
<br>

O segundo parâmetro `radio_button` é o valor da entrada. Como esses dois botões de opção compartilham o mesmo nome (`age`), o usuário só poderá selecionar um deles e `params[:age]` conterá `"child"` ou `"adult"`.

![Action View Form Helpers - Básicos](/imagens/action_view_form_helpers2.JPG)


### 1.3 Outros ajudantes de interesse

Outros controles de formulário que vale a pena mencionar são áreas de texto, campos ocultos, campos de senha, campos numéricos, campos de data e hora e muito mais:

```rb
<%= form.text_area :message, size: "70x5" %>
<%= form.hidden_field :parent_id, value: "foo" %>
<%= form.password_field :password %>
<%= form.number_field :price, in: 1.0..20.0, step: 0.5 %>
<%= form.range_field :discount, in: 1..100 %>
<%= form.date_field :born_on %>
<%= form.time_field :started_at %>
<%= form.datetime_local_field :graduation_day %>
<%= form.month_field :birthday_month %>
<%= form.week_field :birthday_week %>
<%= form.search_field :name %>
<%= form.email_field :address %>
<%= form.telephone_field :phone %>
<%= form.url_field :homepage %>
<%= form.color_field :favorite_color %>
```

Saída:
```html
<textarea name="message" id="message" cols="70" rows="5"></textarea>
<input type="hidden" name="parent_id" id="parent_id" value="foo" />
<input type="password" name="password" id="password" />
<input type="number" name="price" id="price" step="0.5" min="1.0" max="20.0" />
<input type="range" name="discount" id="discount" min="1" max="100" />
<input type="date" name="born_on" id="born_on" />
<input type="time" name="started_at" id="started_at" />
<input type="datetime-local" name="graduation_day" id="graduation_day" />
<input type="month" name="birthday_month" id="birthday_month" />
<input type="week" name="birthday_week" id="birthday_week" />
<input type="search" name="name" id="name" />
<input type="email" name="address" id="address" />
<input type="tel" name="phone" id="phone" />
<input type="url" name="homepage" id="homepage" />
<input type="color" name="favorite_color" id="favorite_color" value="#000000" />
```
Exemplo visual:

- textarea:
<textarea name="message" id="message" cols="50" rows="3"></textarea>
<br>

- hidden
<input type="hidden" name="parent_id" id="parent_id" value="foo" />
<br>

- password
<input type="password" name="password" id="password" />
<br>

- number
<input type="number" name="price" id="price" step="0.5" min="1.0" max="20.0" />
<br>

- range
<input type="range" name="discount" id="discount" min="1" max="100" />
<br>

- date
<input type="date" name="born_on" id="born_on" />
<br>

- time
<input type="time" name="started_at" id="started_at" />
<br>

- datetime-local
<input type="datetime-local" name="graduation_day" id="graduation_day" />
<br>

- month
<input type="month" name="birthday_month" id="birthday_month" />
<br>

- week
<input type="week" name="birthday_week" id="birthday_week" />
<br>

- search
<input type="search" name="name" id="name" />
<br>

- email
<input type="email" name="address" id="address" />
<br>

- tel
<input type="tel" name="phone" id="phone" />
<br>

- url
<input type="url" name="homepage" id="homepage" />
<br>

- color
<input type="color" name="favorite_color" id="favorite_color" value="#000000" />
<br>


As entradas ocultas não são mostradas ao usuário, mas contêm dados como qualquer entrada textual. Os valores dentro deles podem ser alterados com JavaScript.

![Action View Form Helpers - Básicos](/imagens/action_view_form_helpers3.JPG)


## 2 Lidando com objetos de modelo


### 2.1 Vinculando um Formulário a um Objeto

O `:model` argumento de `form_with` nos permite vincular o objeto construtor de formulário a um objeto modelo. Isso significa que o formulário terá como escopo esse objeto de modelo e os campos do formulário serão preenchidos com valores desse objeto de modelo.

Por exemplo, se tivermos um objeto `@article` modelo como:

```rb
@article = Article.find(42)
# => #<Article id: 42, title: "My Title", body: "My Body">
```
O seguinte formulário:

```rb
<%= form_with model: @article do |form| %>
  <%= form.text_field :title %>
  <%= form.text_area :body, size: "60x10" %>
  <%= form.submit %>
<% end %>
```

Saídas:

```html
<form action="/articles/42" method="post" accept-charset="UTF-8" >
  <input name="authenticity_token" type="hidden" value="..." />
  <input type="text" name="article[title]" id="article_title" value="My Title" />
  <textarea name="article[body]" id="article_body" cols="60" rows="10">
    My Body
  </textarea>
  <input type="submit" name="commit" value="Update Article" data-disable-with="Update Article">
</form>
```

Há várias coisas a serem observadas aqui:

- O formulário `action` é preenchido automaticamente com um valor apropriado para `@article`.
- Os campos do formulário são preenchidos automaticamente com os valores correspondentes de `@article`.
- Os nomes dos campos do formulário têm escopo `article[...]`. Isso significa que `params[:article]` será um hash contendo todos os valores desses campos. Você pode ler mais sobre o significado dos nomes de entrada no capítulo [Compreendendo as convenções de nomenclatura de parâmetros](https://guides.rubyonrails.org/form_helpers.html#understanding-parameter-naming-conventions) deste guia.
- O botão enviar recebe automaticamente um valor de texto apropriado.

![Action View Form Helpers - modelos](/imagens/action_view_form_helpers4.JPG)


#### 2.1.1 Formulários de chave primária composta

Os formulários também podem ser construídos com modelos de chave primária composta. Nesse caso, a sintaxe de construção do formulário é a mesma, com saída ligeiramente diferente.

Dado um objeto `@book` modelo com uma chave composta [:author_id, :id]:

```rb
@book = Book.find([2, 25])
# => #<Book id: 25, title: "Some book", author_id: 2>
```

O seguinte formulário:

```rb
<%= form_with model: @book do |form| %>
  <%= form.text_field :title %>
  <%= form.submit %>
<% end %>
```

Saídas:
```html
<form action="/books/2_25" method="post" accept-charset="UTF-8" >
  <input name="authenticity_token" type="hidden" value="..." />
  <input type="text" name="book[title]" id="book_title" value="My book" />
  <input type="submit" name="commit" value="Update Book" data-disable-with="Update Book">
</form>
```

Observe que o URL gerado contém `author_id` e é `id` delimitado por um sublinhado. Depois de enviado, o controlador pode extrair cada valor de chave primária dos parâmetros e atualizar o registro como faria com uma chave primária singular.


#### 2.1.2 O Ajudante `fields_for`

O auxiliar `fields_for` cria uma ligação semelhante, mas sem renderizar uma tag `<form>`. Isso pode ser usado para renderizar campos para objetos de modelo adicionais dentro do mesmo formulário. Por exemplo, se você tivesse um modelo `Person` com um modelo `ContactDetail` associado, você poderia criar um único formulário para ambos, assim:

```rb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <%= fields_for :contact_detail, @person.contact_detail do |contact_detail_form| %>
    <%= contact_detail_form.text_field :phone_number %>
  <% end %>
<% end %>
```
O que produz a seguinte saída:

```html
<form action="/people" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="bL13x72pldyDD8bgtkjKQakJCpd4A8JdXGbfksxBDHdf1uC0kCMqe2tvVdUYfidJt0fj3ihC4NxiVHv8GVYxJA==" />
  <input type="text" name="person[name]" id="person_name" />
  <input type="text" name="contact_detail[phone_number]" id="contact_detail_phone_number" />
</form>
```

O objeto gerado por `fields_for` é um construtor de formulários como aquele gerado por `form_with`.


### 2.2 Confiando na identificação do registro

O modelo Article está disponível diretamente para os usuários da aplicação, portanto - seguindo as melhores práticas para desenvolvimento com Rails - você deve declará-lo como **um recurso** :

```rb
resources :articles
```

![Action View Form Helpers - modelos](/imagens/action_view_form_helpers5.JPG)

Ao lidar com recursos RESTful, as chamadas para form_withpodem ficar significativamente mais fáceis se você confiar na identificação do registro . Resumindo, você pode simplesmente passar a instância do modelo e fazer com que o Rails descubra o nome do modelo e o resto. Em ambos os exemplos, o estilo longo e curto têm o mesmo resultado:

```rb
## Creating a new article
# long-style:
form_with(model: @article, url: articles_path)
# short-style:
form_with(model: @article)

## Editing an existing article
# long-style:
form_with(model: @article, url: article_path(@article), method: "patch")
# short-style:
form_with(model: @article)
```

Observe como a invocação de estilo abreviado `form_with` é convenientemente a mesma, independentemente de o registro ser novo ou existente. A identificação do registro é inteligente o suficiente para descobrir se o registro é novo perguntando `record.persisted?`. Ele também seleciona o caminho correto para enviar e o nome com base na classe do objeto.

Se você tiver um recurso único , precisará ligar `resource` para `resolve` que ele funcione `form_with`:

```rb
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

![Action View Form Helpers - modelos](/imagens/action_view_form_helpers6.JPG)


#### 2.2.1 Lidando com Namespaces

Se você criou rotas com namespace, `form_with` também existe um atalho bacana para isso. Se o seu aplicativo tiver um namespace de administrador, então

```rb
form_with model: [:admin, @article]
```

criará um formulário que será enviado para `ArticlesController` dentro do namespace admin (enviando para `admin_article_path(@article)` no caso de uma atualização). Se você tiver vários níveis de namespace, a sintaxe será semelhante:

```rb
form_with model: [:admin, :management, @article]
```

Para obter mais informações sobre o sistema de roteamento do Rails e as convenções associadas, consulte o guia [Rails Routing from the Outside In](https://guides.rubyonrails.org/routing.html).


### 2.3 Como funcionam os formulários com métodos PATCH, PUT ou DELETE?

A estrutura Rails incentiva o design RESTful de suas aplicações, o que significa que você fará muitas solicitações "PATCH", "PUT" e "DELETE" (além de "GET" e "POST"). No entanto, a maioria dos navegadores não suporta métodos diferentes de “GET” e “POST” quando se trata de envio de formulários.

Rails contorna esse problema emulando outros métodos sobre POST com uma entrada oculta chamada `"_method"`, que é definida para refletir o método desejado:

```rb
form_with(url: search_path, method: "patch")
```

Saída:

```html
<form accept-charset="UTF-8" action="/search" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->
</form>
```

Ao analisar dados POSTados, Rails levará em consideração o parâmetro `_method` especial e agirá como se o método HTTP fosse aquele especificado dentro dele ("PATCH" neste exemplo).

Ao renderizar um formulário, os botões de envio podem substituir o atributo `method` declarado através da `formmethod:` palavra-chave:

```rb
<%= form_with url: "/posts/1", method: :patch do |form| %>
  <%= form.button "Delete", formmethod: :delete, data: { confirm: "Are you sure?" } %>
  <%= form.button "Update" %>
<% end %>
```

Semelhante aos elementos `<form>`, a maioria dos navegadores não suporta a substituição de métodos de formulário declarados através de **formmethod** diferente de "GET" e "POST".

Rails contorna esse problema emulando outros métodos sobre POST através de uma combinação de atributos **formmethod** , **value** e **name** :

```html
<form accept-charset="UTF-8" action="/posts/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  <!-- ... -->

  <button type="submit" formmethod="post" name="_method" value="delete" data-confirm="Are you sure?">Delete</button>
  <button type="submit" name="button">Update</button>
</form>
```


## 3 Fazendo caixas de seleção com facilidade

As caixas de seleção em HTML exigem uma quantidade significativa de marcação - um elemento `<option>` para cada opção à sua escolha. Portanto, Rails fornece métodos auxiliares para reduzir essa carga.

Por exemplo, digamos que temos uma lista de cidades para o usuário escolher. Podemos usar o helper `select` assim:

```rb
<%= form.select :city, ["Berlin", "Chicago", "Madrid"] %>
```

Saída:

```html
<select name="city" id="city">
  <option value="Berlin">Berlin</option>
  <option value="Chicago">Chicago</option>
  <option value="Madrid">Madrid</option>
</select>
```

Também podemos designar valores `<option>` que diferem de seus rótulos:

```rb
<%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]] %>
```

Saída:

```html
<select name="city" id="city">
  <option value="BE">Berlin</option>
  <option value="CHI">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```

Dessa forma, o usuário verá o nome completo da cidade, mas `params[:city]` será `"BE"`, `"CHI"`, ou `"MD"`.

Por último, podemos especificar uma escolha padrão para a caixa de seleção com o argumento `:selected`:

```rb
<%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]], selected: "CHI" %>
```

Saída:

```html
<select name="city" id="city">
  <option value="BE">Berlin</option>
  <option value="CHI" selected="selected">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```


### 3.1 Grupos de Opções

Em alguns casos, podemos querer melhorar a experiência do usuário agrupando opções relacionadas. Podemos fazer isso passando um `Hash`(ou comparável `Array`) para `select`:

```rb
<%= form.select :city,
      {
        "Europe" => [ ["Berlin", "BE"], ["Madrid", "MD"] ],
        "North America" => [ ["Chicago", "CHI"] ],
      },
      selected: "CHI" %>
```

Saída:

```html
<select name="city" id="city">
  <optgroup label="Europe">
    <option value="BE">Berlin</option>
    <option value="MD">Madrid</option>
  </optgroup>
  <optgroup label="North America">
    <option value="CHI" selected="selected">Chicago</option>
  </optgroup>
</select>
```


### 3.2 Selecionar caixas e objetos de modelo

Assim como outros controles de formulário, uma caixa de seleção pode ser vinculada a um atributo de modelo. Por exemplo, se tivermos um objeto `@person` modelo como:

```rb
@person = Person.new(city: "MD")
```

O seguinte formulário:

```rb
<%= form_with model: @person do |form| %>
  <%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]] %>
<% end %>
```

Produz uma caixa de seleção como:

```html
<select name="person[city]" id="person_city">
  <option value="BE">Berlin</option>
  <option value="CHI">Chicago</option>
  <option value="MD" selected="selected">Madrid</option>
</select>
```

Observe que a opção apropriada foi marcada automaticamente `selected="selected"`. Como esta caixa de seleção estava vinculada a um modelo, não precisamos especificar um argumento `:selected`!


### 3.3 Fuso horário e seleção de país

`ActiveSupport::TimeZone` Para aproveitar o suporte de fuso horário no Rails, você precisa perguntar aos seus usuários em que fuso horário eles estão. Fazer isso exigiria a geração de opções de seleção a partir de uma lista de objetos predefinidos , mas você pode simplesmente usar o auxiliar `time_zone_select` que já envolve isso:

```rb
<%= form.time_zone_select :time_zone %>
```

O Rails costumava ter um auxiliar `country_select` para escolher países, mas ele foi extraído para o **plugin country_select** .


## 4 Usando auxiliares de formulário de data e hora

Se você não deseja usar entradas de data e hora HTML5, Rails fornece auxiliares alternativos de data e hora que renderizam caixas de seleção simples. Esses auxiliares renderizam uma caixa de seleção para cada componente temporal (por exemplo, ano, mês, dia, etc.). Por exemplo, se tivermos um objeto `@person` modelo como:

```rb
@person = Person.new(birth_date: Date.new(1995, 12, 21))
```

O seguinte formulário:

```rb
<%= form_with model: @person do |form| %>
  <%= form.date_select :birth_date %>
<% end %>
```

Gera caixas de seleção como:

```html
<select name="person[birth_date(1i)]" id="person_birth_date_1i">
  <option value="1990">1990</option>
  <option value="1991">1991</option>
  <option value="1992">1992</option>
  <option value="1993">1993</option>
  <option value="1994">1994</option>
  <option value="1995" selected="selected">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999">1999</option>
  <option value="2000">2000</option>
</select>
<select name="person[birth_date(2i)]" id="person_birth_date_2i">
  <option value="1">January</option>
  <option value="2">February</option>
  <option value="3">March</option>
  <option value="4">April</option>
  <option value="5">May</option>
  <option value="6">June</option>
  <option value="7">July</option>
  <option value="8">August</option>
  <option value="9">September</option>
  <option value="10">October</option>
  <option value="11">November</option>
  <option value="12" selected="selected">December</option>
</select>
<select name="person[birth_date(3i)]" id="person_birth_date_3i">
  <option value="1">1</option>
  ...
  <option value="21" selected="selected">21</option>
  ...
  <option value="31">31</option>
</select>
```

Observe que, quando o formulário for enviado, não haverá um valor único no `params` hash que contenha a data completa. Em vez disso, haverá vários valores com nomes especiais como `"birth_date(1i)"`. O Active Record sabe como montar esses valores especialmente nomeados em uma data ou hora completa, com base no tipo declarado do atributo do modelo. Portanto, podemos passar `params[:person]` para eg `Person.new` ou `Person#update` exatamente como faríamos se o formulário usasse um único campo para representar a data completa.

Além do `date_select` helper, o Rails fornece `time_select` e `datetime_select`.

### 4.1 Caixas de seleção para componentes temporais individuais

Rails também fornece ajudantes para renderizar caixas de seleção para componentes temporais individuais: `select_year`, `select_month`, `select_day`, `select_hour`, `select_minute`, e `select_second`. Esses auxiliares são métodos "básicos", o que significa que não são chamados em uma instância do construtor de formulários. Por exemplo:

```rb
<%= select_year 1999, prefix: "party" %>
```
Produz uma caixa de seleção como:

```html
<select name="party[year]" id="party_year">
  <option value="1994">1994</option>
  <option value="1995">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999" selected="selected">1999</option>
  <option value="2000">2000</option>
  <option value="2001">2001</option>
  <option value="2002">2002</option>
  <option value="2003">2003</option>
  <option value="2004">2004</option>
</select>
```

Para cada um desses auxiliares, você pode especificar um objeto de data ou hora em vez de um número como valor padrão, e o componente temporal apropriado será extraído e usado.


## 5 escolhas de uma coleção de objetos arbitrários

Às vezes, queremos gerar um conjunto de escolhas a partir de uma coleção de objetos arbitrários. Por exemplo, se tivermos um modelo `City` e associação `belongs_to :city`  correspondente:

```rb
class City < ApplicationRecord
end

class Person < ApplicationRecord
  belongs_to :city
end
```
```rb
City.order(:name).map { |city| [city.name, city.id] }
# => [["Berlin", 3], ["Chicago", 1], ["Madrid", 2]]
```

Então podemos permitir que o usuário escolha uma cidade no banco de dados com o seguinte formulário:

```rb
<%= form_with model: @person do |form| %>
  <%= form.select :city_id, City.order(:name).map { |city| [city.name, city.id] } %>
<% end %>
```

![Action View Form Helpers - collections](/imagens/action_view_form_helpers7.JPG)

No entanto, Rails fornece ajudantes que geram escolhas a partir de uma coleção sem ter que iterar explicitamente sobre ela. Esses auxiliares determinam o valor e o rótulo de texto de cada escolha chamando métodos especificados em cada objeto da coleção.


### 5.1 O Ajudante `collection_select`

Para gerar uma caixa de seleção, podemos usar `collection_select`:

```rb
<%= form.collection_select :city_id, City.order(:name), :id, :name %>
```

Saída:

```html
<select name="person[city_id]" id="person_city_id">
  <option value="3">Berlin</option>
  <option value="1">Chicago</option>
  <option value="2">Madrid</option>
</select>
```

![Action View Form Helpers - collections](/imagens/action_view_form_helpers8.JPG)


### 5.2 O Ajudante collection_radio_buttons

Para gerar um conjunto de botões de opção, podemos usar `collection_radio_buttons`:

```rb
<%= form.collection_radio_buttons :city_id, City.order(:name), :id, :name %>
```
Saída:

```html
<input type="radio" name="person[city_id]" value="3" id="person_city_id_3">
<label for="person_city_id_3">Berlin</label>

<input type="radio" name="person[city_id]" value="1" id="person_city_id_1">
<label for="person_city_id_1">Chicago</label>

<input type="radio" name="person[city_id]" value="2" id="person_city_id_2">
<label for="person_city_id_2">Madrid</label>
```


### 5.3 O Ajudante collection_check_boxes

Para gerar um conjunto de caixas de seleção — por exemplo, para apoiar uma associação `has_and_belongs_to_many` — podemos usar `collection_check_boxes`:

```rb
<%= form.collection_check_boxes :interest_ids, Interest.order(:name), :id, :name %>
```

Saída:

```html
<input type="checkbox" name="person[interest_id][]" value="3" id="person_interest_id_3">
<label for="person_interest_id_3">Engineering</label>

<input type="checkbox" name="person[interest_id][]" value="4" id="person_interest_id_4">
<label for="person_interest_id_4">Math</label>

<input type="checkbox" name="person[interest_id][]" value="1" id="person_interest_id_1">
<label for="person_interest_id_1">Science</label>

<input type="checkbox" name="person[interest_id][]" value="2" id="person_interest_id_2">
<label for="person_interest_id_2">Technology</label>
```


## 6 Fazendo upload de arquivos

Uma tarefa comum é fazer upload de algum tipo de arquivo, seja a foto de uma pessoa ou um arquivo CSV contendo dados a serem processados. Os campos de upload de arquivo podem ser renderizados com o auxiliar `file_field`.

```rb
<%= form_with model: @person do |form| %>
  <%= form.file_field :picture %>
<% end %>
```
A coisa mais importante a lembrar ao fazer upload de arquivos é que o atributo `enctype` do formulário renderizado deve ser definido como `"multipart/form-data"`. Isso é feito automaticamente se você usar um `file_field` dentro de um arquivo `form_with`. Você também pode definir o atributo manualmente:

```rb
<%= form_with url: "/uploads", multipart: true do |form| %>
  <%= file_field_tag :picture %>
<% end %>
```

Observe que, de acordo com `form_with` as convenções, os nomes dos campos nos dois formulários acima também serão diferentes. Ou seja, o nome do campo no primeiro formulário será `person[picture]`(acessível via `params[:person][:picture]`), e o nome do campo no segundo formulário será apenas `picture`(acessível via `params[:picture]`).

## 6.1 O que é carregado

O objeto no `params` hash é uma instância de `ActionDispatch::Http::UploadedFile`. O trecho a seguir salva o arquivo enviado com `#{Rails.root}/public/uploads` o mesmo nome do arquivo original.

```rb
def upload
  uploaded_file = params[:picture]
  File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'wb') do |file|
    file.write(uploaded_file.read)
  end
end
```

Depois que um arquivo é carregado, há uma infinidade de tarefas potenciais, desde onde armazenar os arquivos (no disco, Amazon S3, etc), associá-los a modelos, redimensionar arquivos de imagem e gerar miniaturas , etc. projetado para ajudar nessas tarefas.


## 7 Personalizando Construtores de Formulários

O objeto produzido por `form_with` e `fields_for` é uma instância de `ActionView::Helpers::FormBuilder`. Os construtores de formulários encapsulam a noção de exibição de elementos de formulário para um único objeto. Embora você possa escrever auxiliares para seus formulários da maneira usual, você também pode criar uma subclasse de `ActionView::Helpers::FormBuilder` e adicionar os auxiliares lá. Por exemplo, supondo que você tenha um método auxiliar definido em seu aplicativo chamado `text_field_with_label` da seguinte forma

```rb
module ApplicationHelper
  def text_field_with_label(form, attribute)
    form.label(attribute) + form.text_field(attribute)
  end
end
```
```rb
<%= form_with model: @person do |form| %>
  <%= text_field_with_label form, :first_name %>
<% end %>
```

pode ser substituído por

```rb
<%= form_with model: @person, builder: LabellingFormBuilder do |form| %>
  <%= form.text_field :first_name %>
<% end %>
```

definindo uma classe `LabellingFormBuilder` semelhante à seguinte:

```rb
class LabellingFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attribute, options = {})
    label(attribute) + super
  end
end
```

Se você reutilizar isso com frequência, poderá definir um auxiliar `labeled_form_with` que aplique automaticamente a opção `builder: LabellingFormBuilder`:

```rb
module ApplicationHelper
  def labeled_form_with(model: nil, scope: nil, url: nil, format: nil, **options, &block)
    options[:builder] = LabellingFormBuilder
    form_with model: model, scope: scope, url: url, format: format, **options, &block
  end
end
```

O construtor de formulários usado também determina o que acontece quando você faz:

```rb
<%= render partial: f %>
```

Se `f` for uma instância de `ActionView::Helpers::FormBuilder`, isso renderizará a parcial `form`, definindo o objeto do parcial para o construtor de formulário. Se o construtor de formulário for class `LabellingFormBuilder`, a parcial `labelling_form` será renderizado.


## 8 Compreendendo as convenções de nomenclatura de parâmetros

Os valores dos formulários podem estar no nível superior do `params` hash ou aninhados em outro hash. Por exemplo, em uma ação `create` padrão para um modelo Pessoa, `params[:person]` normalmente seria um hash de todos os atributos para a pessoa criar. O `params` hash também pode conter matrizes, matrizes de hashes e assim por diante.

Fundamentalmente, os formulários HTML não conhecem nenhum tipo de dados estruturados; tudo o que eles geram são pares nome-valor, onde os pares são apenas strings simples. Os arrays e hashes que você vê na sua aplicação são o resultado de algumas convenções de nomenclatura de parâmetros que o Rails usa.


### 8.1 Estruturas Básicas

As duas estruturas básicas são arrays e hashes. Hashes espelham a sintaxe usada para acessar o valor em `params`. Por exemplo, se um formulário contiver:

```rb
<input id="person_name" name="person[name]" type="text" value="Henry"/>
```
o `params` hash conterá

```RB
{ 'person' => { 'name' => 'Henry' } }
```

e `params[:person][:name]` recuperará o valor enviado no controlador.

Os hashes podem ser aninhados em quantos níveis forem necessários, por exemplo:

```RB
<input id="person_address_city" name="person[address][city]" type="text" value="New York"/>
```
resultará no `params` hash sendo

```RB
{ 'person' => { 'address' => { 'city' => 'New York' } } }
```

Normalmente o Rails ignora nomes de parâmetros duplicados. Se o nome do parâmetro terminar com um conjunto vazio de colchetes, `[]` eles serão acumulados em uma matriz. Se você quiser que os usuários possam inserir vários números de telefone, você pode colocar isso no formulário:

```html
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
```

Isso resultaria em `params[:person][:phone_number]` uma matriz contendo os números de telefone inseridos.


### 8.2 Combinando-os

Podemos misturar e combinar esses dois conceitos. Um elemento de um hash pode ser um array como no exemplo anterior, ou você pode ter um array de hashes. Por exemplo, um formulário pode permitir criar qualquer número de endereços repetindo o seguinte fragmento de formulário

```html
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
```

Isso resultaria em `params[:person][:addresses]`uma matriz de hashes com chaves `line1`, `line2` e `city`.

Porém, há uma restrição: embora os hashes possam ser aninhados arbitrariamente, apenas um nível de "matriz" é permitido. Arrays geralmente podem ser substituídos por hashes; por exemplo, em vez de ter um array de objetos modelo, pode-se ter um hash de objetos modelo codificados por seu id, um índice de array ou algum outro parâmetro.

![Action View Form Helpers - nomenclatura de parâmetros](/imagens/action_view_form_helpers9.JPG)


### 8.3 A Opção fields_for Auxiliar:index

Digamos que queremos renderizar um formulário com um conjunto de campos para cada endereço de uma pessoa. O ajudante `fields_for` com sua opção `:index` pode auxiliar:

```rb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <% @person.addresses.each do |address| %>
    <%= person_form.fields_for address, index: address.id do |address_form| %>
      <%= address_form.text_field :city %>
    <% end %>
  <% end %>
<% end %>
```

Supondo que a pessoa tenha dois endereços com IDs 23 e 45, o formulário acima renderizaria uma saída semelhante a:

```html
<form accept-charset="UTF-8" action="/people/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input id="person_name" name="person[name]" type="text" />
  <input id="person_address_23_city" name="person[address][23][city]" type="text" />
  <input id="person_address_45_city" name="person[address][45][city]" type="text" />
</form>
```

O que resultará em um `params` hash parecido com:

```rb
{
  "person" => {
    "name" => "Bob",
    "address" => {
      "23" => {
        "city" => "Paris"
      },
      "45" => {
        "city" => "London"
      }
    }
  }
}
```

Todas as entradas do formulário são mapeadas para o hash `"person"` porque chamamos `fields_for` o construtor de formulário `person_form`. Além disso, ao especificar `index: address.id`, renderizamos o atributo `name` de cada entrada de cidade como `person[address][#{address.id}][city]` em vez de `person[address][city]`. Assim podemos determinar quais registros de Endereço devem ser modificados ao processar o `params` hash.

Você pode passar outros números ou sequências significativas por meio da opção `:index`. Você pode até passar nil, o que produzirá um parâmetro de array.

Para criar aninhamentos mais complexos, você pode especificar explicitamente a parte inicial do nome de entrada. Por exemplo:

```rb
<%= fields_for 'person[address][primary]', address, index: address.id do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

criará entradas como:

```rb
<input id="person_address_primary_23_city" name="person[address][primary][23][city]" type="text" value="Paris" />
```

Você também pode passar uma opção `:index` diretamente para auxiliares como `text_field`, mas geralmente é menos repetitivo especificar isso no nível do construtor de formulário do que em campos de entrada individuais.

Falando de modo geral, o nome de entrada final será uma concatenação do nome dado a `fields_for` / `form_with`, o valor `:index` da opção e o nome do atributo.

Por último, como atalho, em vez de especificar um ID para `:index` (por exemplo `index: address.id`, ), você pode anexar `"[]"` ao nome fornecido. Por exemplo:

```rb
<%= fields_for 'person[address][primary][]', address do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

produz exatamente a mesma saída do nosso exemplo original.


## 9 Formulários para Recursos Externos

Os auxiliares de formulário do Rails também podem ser usados ​​para construir um formulário para postar dados em um recurso externo. Contudo, às vezes pode ser necessário definir um `authenticity_token` para o recurso; isso pode ser feito passando um `authenticity_token: 'your_external_token'`parâmetro para as opções `form_with`:

```rb
<%= form_with url: 'http://farfar.away/form', authenticity_token: 'external_token' do %>
  Form contents
<% end %>
```

Às vezes, ao enviar dados para um recurso externo, como um gateway de pagamento, os campos que podem ser usados ​​no formulário são limitados por uma API externa e pode ser indesejável gerar um arquivo `authenticity_token`. Para não enviar token basta passar `false` para a opção `:authenticity_token`:

```rb
<%= form_with url: 'http://farfar.away/form', authenticity_token: false do %>
  Form contents
<% end %>
```

## 10 Construindo Formulários Complexos

Muitos aplicativos vão além de simples formulários editando um único objeto. Por exemplo, ao criar um, Personvocê pode permitir que o usuário (no mesmo formulário) crie vários registros de endereço (casa, trabalho, etc.). Ao editar posteriormente essa pessoa, o usuário deverá ser capaz de adicionar, remover ou alterar endereços conforme necessário.

### 10.1 Configurando o Modelo

Active Record fornece suporte em nível de modelo por meio do método `accepts_nested_attributes_for`:

```rb
class Person < ApplicationRecord
  has_many :addresses, inverse_of: :person
  accepts_nested_attributes_for :addresses
end

class Address < ApplicationRecord
  belongs_to :person
end
```

Isso cria um `addresses_attributes`=método `Person` que permite criar, atualizar e (opcionalmente) destruir endereços.


### 10.2 Formulários aninhados

O formulário a seguir permite que um usuário crie um `Person` e seus endereços associados.

```rb
<%= form_with model: @person do |form| %>
  Addresses:
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>

        <%= addresses_form.label :street %>
        <%= addresses_form.text_field :street %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

Quando uma associação aceita atributos aninhados, `fields_for` seu bloco é renderizado uma vez para cada elemento da associação. Em particular, se uma pessoa não tiver endereços, ela não renderá nada. Um padrão comum é o controlador construir um ou mais filhos vazios para que pelo menos um conjunto de campos seja mostrado ao usuário. O exemplo abaixo resultaria na renderização de 2 conjuntos de campos de endereço no novo formulário de pessoa.

```rb
def new
  @person = Person.new
  2.times { @person.addresses.build }
end
```

Isso gera um construtor `fields_for` de formulários. O nome dos parâmetros será o esperado `accepts_nested_attributes_for`. Por exemplo, ao criar um usuário com 2 endereços, os parâmetros enviados seriam assim:

```rb
{
  'person' => {
    'name' => 'John Doe',
    'addresses_attributes' => {
      '0' => {
        'kind' => 'Home',
        'street' => '221b Baker Street'
      },
      '1' => {
        'kind' => 'Office',
        'street' => '31 Spooner Street'
      }
    }
  }
}
```

Os valores reais das chaves no `:addresses_attributes` hash não são importantes; no entanto, eles precisam ser sequências de números inteiros e diferentes para cada endereço.

Se o objeto associado já estiver salvo, `fields_for` gera automaticamente uma entrada oculta com o valor `id` do registro salvo. Você pode desativar isso passando `include_id: false` para `fields_for`.


### 10.3 O Controlador

Como sempre, você precisa declarar os parâmetros permitidos no controlador antes de passá-los para o modelo:

```rb
def create
  @person = Person.new(person_params)
  # ...
end

private
  def person_params
    params.require(:person).permit(:name, addresses_attributes: [:id, :kind, :street])
  end
```


### 10.4 Removendo Objetos

Você pode permitir que os usuários excluam objetos associados passando `allow_destroy: true` para `accepts_nested_attributes_for`

```rb
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, allow_destroy: true
end
```

Se o hash de atributos de um objeto contém a chave `_destroy` com um valor avaliado como `true` (por exemplo, 1, '1', verdadeiro ou 'verdadeiro'), então o objeto será destruído. Este formulário permite aos usuários remover endereços:

```rb
<%= form_with model: @person do |form| %>
  Addresses:
  <ul>
    <%= form.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.check_box :_destroy %>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

Não se esqueça de atualizar os parâmetros permitidos no seu controlador para incluir também o campo `_destroy`:

```rb
def person_params
  params.require(:person).
    permit(:name, addresses_attributes: [:id, :kind, :street, :_destroy])
end
```


### 10.5 Prevenindo Registros Vazios

Muitas vezes é útil ignorar conjuntos de campos que o usuário não preencheu. Você pode controlar isso passando um `:reject_if` proc para `accepts_nested_attributes_for`. Este proc será chamado a cada hash de atributos enviado pelo formulário. Se o processo retornar `true`, o Active Record não criará um objeto associado para esse hash. O exemplo abaixo só tenta construir um endereço se o atributo `kind` estiver definido.

```rb
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, reject_if: lambda { |attributes| attributes['kind'].blank? }
end
```

Por conveniência, você pode passar o símbolo `:all_blank` que criará um proc que rejeitará registros onde todos os atributos estão em branco, excluindo qualquer valor para `_destroy`.

### 10.6 Adicionando campos dinamicamente

Em vez de renderizar vários conjuntos de campos antecipadamente, você pode adicioná-los somente quando um usuário clicar no botão "Adicionar novo endereço". Rails não fornece nenhum suporte integrado para isso. Ao gerar novos conjuntos de campos, você deve garantir que a chave do array associado seja única - a data atual do JavaScript (milissegundos desde a época ) é uma escolha comum.


## 11 Usando Tag Helpers sem um Form Builder


Caso você precise renderizar campos de formulário fora do contexto de um construtor de formulário, Rails fornece auxiliares de tags para elementos de formulário comuns. Por exemplo, `check_box_tag`:

```rb
<%= check_box_tag "accept" %>
```

Saída:

```html
<input type="checkbox" name="accept" id="accept" value="1" />
```

Geralmente, esses auxiliares têm o mesmo nome de seus equivalentes no construtor de formulários, mais um sufixo `_tag`. Para obter uma lista completa, consulte a `FormTagHelper` [documentação da API](https://api.rubyonrails.org/v7.1.3.2/classes/ActionView/Helpers/FormTagHelper.html).


## 12 Usando form_tag e form_for

Antes de `form_with` ser introduzido no Rails 5.1, sua funcionalidade costumava ser dividida entre `form_tag` e `form_for`. Ambos agora estão obsoletos. A documentação sobre seu uso pode ser encontrada em versões mais antigas deste guia.

