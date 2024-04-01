# Rails Routing from the Outside In


## 1 O objetivo do roteador Rails

O roteador Rails reconhece URLs e as envia para uma ação de controlador ou para uma aplicação Rack. Ele também pode gerar caminhos e URLs, evitando a necessidade de codificar strings em suas visualizações.

### 1.1 Conectando URLs ao código

Quando sua aplicação Rails recebe uma solicitação para:

```rb
GET /patients/17
```

ele pede ao roteador para combiná-lo com uma ação do controlador. Se a primeira rota correspondente for:

```rb
get '/patients/:id', to: 'patients#show'
```

a solicitação é despachada para a ação patientsdo controlador showcom { id: '17' }in params.

![rails routing](/imagens/rails_routing1.JPG)


### 1.2 Gerando caminhos e URLs a partir do código

Você também pode gerar caminhos e URLs. Se a rota acima for modificada para ser:

```rb
get '/patients/:id', to: 'patients#show', as: 'patient'
```

e seu aplicativo contém este código no controlador:

```rb
@patient = Patient.find(params[:id])
```

e isso na visão correspondente:

```rb
<%= link_to 'Patient Record', patient_path(@patient) %>
```

então o roteador irá gerar o caminho `/patients/17`. Isso reduz a fragilidade da sua visão e torna o seu código mais fácil de entender. Observe que o id não precisa ser especificado no auxiliar de rota.


### 1.3 Configurando o Roteador Rails

As rotas para seu aplicativo ou mecanismo ficam no arquivo `config/routes.rb` e normalmente se parecem com isto:

```rb
Rails.application.routes.draw do
  resources :brands, only: [:index, :show] do
    resources :products, only: [:index, :show]
  end

  resource :basket, only: [:show, :update, :destroy]

  resolve("Basket") { route_for(:basket) }
end
```

Como este é um arquivo fonte Ruby normal, você pode usar todos os seus recursos para ajudá-lo a definir suas rotas, mas tome cuidado com nomes de variáveis, pois eles podem entrar em conflito com os métodos DSL do roteador.

![rails routing](/imagens/rails_routing2.JPG)


## 2 Roteamento de recursos: o padrão do Rails

O roteamento de recursos permite declarar rapidamente todas as rotas comuns para um determinado controlador com recursos. Uma única chamada to resourcespode declarar todas as rotas necessárias para suas ações index, show, new, edit, create, updatee destroy.

### 2.1 Recursos na Web

Os navegadores solicitam páginas do Rails fazendo uma solicitação de URL usando um método HTTP específico, como `GET`, `POST`, `PATCH`, `PUT` e `DELETE`. Cada método é uma solicitação para executar uma operação no recurso. Uma rota de recurso mapeia uma série de solicitações relacionadas a ações em um único controlador.

Quando sua aplicação Rails recebe uma solicitação para:

```rb
DELETE /photos/17
```

ele pede ao roteador para mapeá-lo para uma ação do controlador. Se a primeira rota correspondente for:

```rb
resources :photos
```

O Rails despacharia essa solicitação para a ação `destroy` no controlador `photos` com `{ id: '17' }` in `params`.


## 2.2 CRUD, verbos e ações

No Rails, uma rota engenhosa fornece um mapeamento entre verbos HTTP e URLs para ações do controlador. Por convenção, cada ação também é mapeada para uma operação CRUD específica em um banco de dados. Uma única entrada no arquivo de roteamento, como:

```rb
resources :photos
```

cria sete rotas diferentes em sua aplicação, todas mapeadas para o Photoscontrolador:


| HTTP Verb	| Path	| Controller#Action	| Used for |
| --- | --- | --- | --- |
| GET	| /photos	| photos#index	| exibir uma lista de todas as fotos |
| GET	| /photos/new	| photos#new	| retornar um formulário HTML para criar uma nova foto |
| POST	| /photos	| photos#create	| criar uma nova foto |
| GET	| /photos/:id	| photos#show	| exibir uma foto específica |
| GET	| /photos/:id/edit	| photos#edit	| retornar um formulário HTML para editar uma foto |
| PATCH/PUT	| /photos/:id	| photos#update	| atualizar uma foto específica |
| DELETE	| /photos/:id	| photos#destroy	| excluir uma foto específica |


![rails routing](/imagens/rails_routing3.JPG)


### 2.3 Auxiliares de caminho e URL

A criação de uma rota com recursos também exporá vários auxiliares aos controladores em seu aplicativo. No caso de `resources :photos`:

- `photos_path` retorna `/photos`
- `new_photo_path` retorna `/photos/new`
- `edit_photo_path(:id)` retorna `/photos/:id/edit` (por exemplo, `edit_photo_path(10)` retorna `/photos/10/edit`)
- `photo_path(:id)` retorna `/photos/:id` (por exemplo, `photo_path(10)` retorna `/photos/10`)

Cada um desses auxiliares possui um `_url` auxiliar correspondente (como `photos_url`) que retorna o mesmo caminho prefixado com o host, porta e prefixo de caminho atuais.

![rails routing](/imagens/rails_routing4.JPG)


### 2.4 Definindo Vários Recursos ao Mesmo Tempo

Se precisar criar rotas para mais de um recurso, você pode economizar um pouco de digitação definindo todas elas com uma única chamada para resources:

```rb
resources :photos, :books, :videos
```

Isso funciona exatamente da mesma forma que:

```rb
resources :photos
resources :books
resources :videos
```

### 2.5 Recursos Singulares

Às vezes, você tem um recurso que os clientes sempre consultam sem fazer referência a um ID. Por exemplo, você gostaria `/profile` mostrar sempre o perfil do usuário conectado no momento. Nesse caso, você pode usar um recurso singular para mapear `/profile` (em vez de `/profile/:id`) para a ação `show`:

```rb
get 'profile', to: 'users#show'
```

Passar um `String` para `to:` esperará um formato `controller#action`. Ao usar um `Symbol`, a opção `to:` deve ser substituída por `action:`. Ao usar a `String` sem `#`, a opção `to:` deve ser substituída por `controller:`:

```rb
get 'profile', action: :show, controller: 'users'
```

Esta rota engenhosa:

```rb
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

cria seis rotas diferentes em sua aplicação, todas mapeadas para o controlador `Geocoders`:



| HTTP Verb	| Path	| Controller#Action	| Used for
| --- | --- | --- | --- |
| GET	| /geocoder/new	| geocoders#new	| retornar um formulário HTML para criar o geocodificador
| POST	| /geocoder	| geocoders#create	| crie o novo geocodificador
| GET	| /geocoder	| geocoders#show	| exibir o único recurso do geocodificador
| GET	| /geocoder/edit	| geocoders#edit	| retornar um formulário HTML para edição do geocodificador
| PATCH/PUT	| /geocoder	| geocoders#update	| atualizar o único recurso do geocodificador
| DELETE	| /geocoder	| geocoders#destroy	| exclua o recurso do geocodificador

![rails routing](/imagens/rails_routing5.JPG)

Uma rota singular e cheia de recursos gera estes ajudantes:

- `new_geocoder_path` retorna `/geocoder/new`
- `edit_geocoder_path` retorna `/geocoder/edit`
- `geocoder_path` retorna `/geocoder`

![rails routing](/imagens/rails_routing6.JPG)

Tal como acontece com os recursos plurais, os mesmos auxiliares que terminam em _urltambém incluirão o host, a porta e o prefixo do caminho.

### 2.6 Namespaces e roteamento do controlador

Você pode organizar grupos de controladores em um namespace. Mais comumente, você pode agrupar vários controladores administrativos em um namespace `Admin::`  e colocar esses controladores no diretório `app/controllers/admin`. Você pode rotear para esse grupo usando um bloco `namespace`:

```rb
namespace :admin do
  resources :articles, :comments
end
```

Isso criará uma série de rotas para cada um dos controladores `articles` e `comments`. Para `Admin::ArticlesController`, Rails criará:


| HTTP Verb	| Path	| Controller#Action	| Named Route Helper|
| --- | --- | --- | --- |
| GET	| /admin/articles	| admin/articles#index	| admin_articles_path |
| GET	| /admin/articles/new	| admin/articles#new	| new_admin_article_path |
| POST	| /admin/articles	| admin/articles#create	| admin_articles_path |
| GET	| /admin/articles/:id	| admin/articles#show	| admin_article_path(:id) |
| GET	| /admin/articles/:id/edit	| admin/articles#edit	| edit_admin_article_path(:id) |
| PATCH/PUT	| /admin/articles/:id	| admin/articles#update	| admin_article_path(:id) |
| DELETE	| /admin/articles/:id	| admin/articles#destroy	| admin_article_path(:id) |

Se, em vez disso, você quiser rotear `/articles` (sem o prefixo `/admin`) para `Admin::ArticlesController`, poderá especificar o módulo com um bloco `scope` :

```rb
scope module: 'admin' do
  resources :articles, :comments
end
```

Isso também pode ser feito para uma única rota:

```rb
resources :articles, module: 'admin'
```

Se, em vez disso, você quiser rotear `/admin/articles` para `ArticlesController`(sem o prefixo do módulo `Admin::`), poderá especificar o caminho com um bloco `scope`:

```rb
scope '/admin' do
  resources :articles, :comments
end
```

Isso também pode ser feito para uma única rota:

```rb
resources :articles, path: '/admin/articles'
```

Em ambos os casos, os auxiliares de rota nomeados permanecem os mesmos como se você não usasse `scope`. No último caso, os seguintes caminhos são mapeados para `ArticlesController`:


| HTTP Verb	| Path	| Controller#Action	| Named Route Helper |
| --- | --- | --- | --- |
| GET	| /admin/articles	| articles#index	| articles_path |
| GET	| /admin/articles/new	| articles#new	| new_article_path |
| POST	| /admin/articles	| articles#create	| articles_path |
| GET	| /admin/articles/:id	| articles#show	| article_path(:id) |
| GET	| /admin/articles/:id/edit	| articles#edit	| edit_article_path(:id) |
| PATCH/PUT	| /admin/articles/:id	| articles#update	| article_path(:id) |
| DELETE	| /admin/articles/:id	| articles#destroy	| article_path(:id) |

![rails routing](/imagens/rails_routing7.JPG)


### 2.7 Recursos aninhados

É comum ter recursos que são logicamente filhos de outros recursos. Por exemplo, suponha que seu aplicativo inclua estes modelos:

```rb
class Magazine < ApplicationRecord
  has_many :ads
end

class Ad < ApplicationRecord
  belongs_to :magazine
end
```

Rotas aninhadas permitem capturar esse relacionamento em seu roteamento. Neste caso, você poderia incluir esta declaração de rota:

```rb
resources :magazines do
  resources :ads
end
```

Além dos roteiros para revistas, esta declaração também encaminhará anúncios para um arquivo `AdsController`. Os URLs dos anúncios exigem uma revista:


| HTTP | Verb	Path	| Controller#Action	| Usado para
| --- | --- | --- | --- |
| GET	| /magazines/:magazine_id/ads	| ads#index	|exibir uma lista de todos os anúncios de uma revista específica
| GET	| /magazines/:magazine_id/ads/new	| ads#new	| retornar um formulário HTML para criar um novo anúncio pertencente a uma revista específica
| POST	| /magazines/:magazine_id/ads	| ads#create	| crie um novo anúncio pertencente a uma revista específica
| GET	| /magazines/:magazine_id/ads/:id	| ads#show	| exibir um anúncio específico pertencente a uma revista específica
| GET	| /magazines/:magazine_id/ads/:id/edit	| ads#edit	| retornar um formulário HTML para editar um anúncio pertencente a uma revista específica
| PATCH/PUT	| /magazines/:magazine_id/ads/:id	| ads#update	| atualizar um anúncio específico pertencente a uma revista específica
| DELETE	| /magazines/:magazine_id/ads/:id	| ads#destroy	| excluir um anúncio específico pertencente a uma revista específica

Isso também criará auxiliares de roteamento como `magazine_ads_url` e `edit_magazine_ad_path`. Esses auxiliares usam uma instância de Magazine como primeiro parâmetro (`magazine_ads_url(@magazine)`).


#### 2.7.1 Limites para aninhamento

Você pode aninhar recursos em outros recursos aninhados, se desejar. Por exemplo:

```rb
resources :publishers do
  resources :magazines do
    resources :photos
  end
end
```

Recursos profundamente aninhados rapidamente se tornam complicados. Neste caso, por exemplo, a aplicação reconheceria caminhos como:

```rb
/publishers/1/magazines/2/photos/3
```

O auxiliar de rota correspondente seria `publisher_magazine_photo_url`, exigindo que você especifique objetos em todos os três níveis. Na verdade, esta situação é confusa o suficiente para que [um artigo popular de Jamis Buck](https://weblog.jamisbuck.org/2007/2/5/nesting-resources) proponha uma regra prática para um bom design do Rails:

![rails routing](/imagens/rails_routing8.JPG)


#### 2.7.2 Aninhamento Raso

Uma maneira de evitar o aninhamento profundo (conforme recomendado acima) é gerar as ações de coleção com escopo no pai, para ter uma noção da hierarquia, mas não aninhar as ações dos membros. Em outras palavras, construir apenas rotas com a quantidade mínima de informações para identificar exclusivamente o recurso, assim:

```rb
resources :articles do
  resources :comments, only: [:index, :new, :create]
end
resources :comments, only: [:show, :edit, :update, :destroy]
```

Esta ideia estabelece um equilíbrio entre rotas descritivas e aninhamento profundo. Existe uma sintaxe abreviada para conseguir exatamente isso, através da opção `:shallow`:

```rb
resources :articles do
  resources :comments, shallow: true
end
```

Isso gerará exatamente as mesmas rotas do primeiro exemplo. Você também pode especificar a opção `:shallow` no recurso pai; nesse caso, todos os recursos aninhados serão superficiais:

```rb
resources :articles, shallow: true do
  resources :comments
  resources :quotes
  resources :drafts
end
```

O recurso de artigos aqui terá as seguintes rotas geradas para ele:

| HTTP Verb	| Path	| Controller#Action	| Named Route Helper
| --- | --- | --- | --- |
| GET	| /articles/:article_id/comments(.:format)	| comments#index	| article_comments_path
| POST| /articles/:article_id/comments(.:format)	| comments#create	| article_comments_path
| GET	| /articles/:article_id/comments/new(.:format)	| comments#new	| new_article_comment_path
| GET	| /comments/:id/edit(.:format)	| comments#edit	| edit_comment_path
| GET	| /comments/:id(.:format)	| comments#show	| comment_path
| PATCH/PUT	| /comments/:id(.:format)	| comments#update	| comment_path
| DELETE	| /comments/:id(.:format)	| comments#destroy	| comment_path
| GET	| /articles/:article_id/quotes(.:format)	| quotes#index	| article_quotes_path
| POST	| /articles/:article_id/quotes(.:format)	| quotes#create	| article_quotes_path
| GET	| /articles/:article_id/quotes/new(.:format)	| quotes#new	| new_article_quote_path
| GET	| /quotes/:id/edit(.:format)	| quotes#edit	| edit_quote_path
| GET	| /quotes/:id(.:format)	| quotes#show	| quote_path
| PATCH/PUT	| /quotes/:id(.:format)	| quotes#update	| quote_path
| DELETE	| /quotes/:id(.:format)	| quotes#destroy	| quote_path
| GET	| /articles/:article_id/drafts(.:format)	| drafts#index	| article_drafts_path
| POST	| /articles/:article_id/drafts(.:format)	| drafts#create	| article_drafts_path
| GET	| /articles/:article_id/drafts/new(.:format)	| drafts#new	| new_article_draft_path
| GET	| /drafts/:id/edit(.:format)	| drafts#edit	| edit_draft_path
| GET	| /drafts/:id(.:format)	| drafts#show	| draft_path
| PATCH/PUT	| /drafts/:id(.:format)	| drafts#update	| draft_path
| DELETE	| /drafts/:id(.:format)	| drafts#destroy	| draft_path
| GET	| /articles(.:format)	| articles#index	| articles_path
| POST	| /articles(.:format)	| articles#create	| articles_path
| GET	| /articles/new(.:format)	| articles#new	| new_article_path
| GET	| /articles/:id/edit(.:format)	| articles#edit	| edit_article_path
| GET	| /articles/:id(.:format)	| articles#show	| article_path
| PATCH/PUT	| /articles/:id(.:format)	| articles#update	| article_path
| DELETE	| /articles/:id(.:format)	| articles#destroy	| article_path

O método `shallow` DSL cria um escopo dentro do qual todo aninhamento é superficial. Isso gera as mesmas rotas do exemplo anterior:

```rb
shallow do
  resources :articles do
    resources :comments
    resources :quotes
    resources :drafts
  end
end
```

Existem duas opções para personalizar `scope` rotas rasas. prefixa `:shallow_path` caminhos de membros com o parâmetro especificado:

```rb
scope shallow_path: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

O recurso de comentários aqui terá as seguintes rotas geradas para ele:

| HTTP Verb	| Path	| Controller#Action	| Named Route Helper |
| --- | --- | --- | --- |
| GET	| /articles/:article_id/comments(.:format)	| comments#index	| article_comments_path |
| POST	| /articles/:article_id/comments(.:format)	| comments#create	| article_comments_path |
| GET	| /articles/:article_id/comments/new(.:format)	| comments#new	| new_article_comment_path |
| GET	| /sekret/comments/:id/edit(.:format)	| comments#edit	| edit_comment_path |
| GET	| /sekret/comments/:id(.:format)	| comments#show	| comment_path |
| PATCH/PUT	| /sekret/comments/:id(.:format)	| comments#update	| comment_path |
| DELETE	| /sekret/comments/:id(.:format)	| comments#destroy	| comment_path |

A opção `:shallow_prefix` adiciona o parâmetro especificado aos auxiliares de rota nomeados:

```rb
scope shallow_prefix: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

O recurso de comentários aqui terá as seguintes rotas geradas para ele:

| HTTP Verb	| Path	| Controller#Action	| Named Route Helper |
| --- | --- | --- | --- |
| GET	| /articles/:article_id/comments(.:format)	| comments#index	| article_comments_path |
| POST	| /articles/:article_id/comments(.:format)	| comments#create	| article_comments_path |
| GET	| /articles/:article_id/comments/new(.:format)	| comments#new	| new_article_comment_path |
| GET	| /comments/:id/edit(.:format)	| comments#edit	| edit_sekret_comment_path |
| GET	| /comments/:id(.:format)	| comments#show	| sekret_comment_path |
| PATCH/PUT	| /comments/:id(.:format)	| comments#update	| sekret_comment_path |
| DELETE	| /comments/:id(.:format)	| comments#destroy	| sekret_comment_path |


### 2.8 Preocupações com roteamento

As preocupações de roteamento permitem declarar rotas comuns que podem ser reutilizadas dentro de outros recursos e rotas. Para definir uma preocupação, use um bloco `concern`:

```rb
concern :commentable do
  resources :comments
end

concern :image_attachable do
  resources :images, only: :index
end
```

Essas preocupações podem ser usadas em recursos para evitar duplicação de código e compartilhar comportamento entre rotas:

```rb
resources :messages, concerns: :commentable

resources :articles, concerns: [:commentable, :image_attachable]
```

O acima é equivalente a:

```rb
resources :messages do
  resources :comments
end

resources :articles do
  resources :comments
  resources :images, only: :index
end
```

Você também pode usá-los em qualquer lugar ligando para `concerns`. Por exemplo, em um bloco `scope` ou `namespace`:

```rb
namespace :articles do
  concerns :commentable
end
```


### 2.9 Criando caminhos e URLs a partir de objetos

Além de usar os auxiliares de roteamento, o Rails também pode criar caminhos e URLs a partir de uma variedade de parâmetros. Por exemplo, suponha que você tenha este conjunto de rotas:

```rb
resources :magazines do
  resources :ads
end
```

Ao usar `magazine_ad_path`, você pode passar instâncias de `Magazine` e `Ad` em vez dos IDs numéricos:

```rb
<%= link_to 'Ad details', magazine_ad_path(@magazine, @ad) %>
```

Você também pode usar `url_for` com um conjunto de objetos, e o Rails determinará automaticamente qual rota você deseja:

```rb
<%= link_to 'Ad details', url_for([@magazine, @ad]) %>
```

Neste caso, Rails verá que `@magazine` é a `Magazine` e `@ad` é um `Ad` e, portanto, usará o auxiliar `magazine_ad_path`. Em helpers como `link_to`, você pode especificar apenas o objeto no lugar da chamada `url_for` completa:

```rb
<%= link_to 'Ad details', [@magazine, @ad] %>
```

Se você quiser criar um link para apenas uma revista:

```rb
<%= link_to 'Magazine details', @magazine %>
```

Para outras ações, basta inserir o nome da ação como o primeiro elemento do array:

```rb
<%= link_to 'Edit Ad', [:edit, @magazine, @ad] %>
```

Isso permite que você trate instâncias de seus modelos como URLs e é uma vantagem importante no uso do estilo engenhoso.


### 2.10 Adicionando mais ações RESTful

Você não está limitado às sete rotas que o roteamento RESTful cria por padrão. Se desejar, você pode adicionar rotas adicionais que se aplicam à coleção ou a membros individuais da coleção.


#### 2.10.1 Adicionando Rotas Membros

Para adicionar uma rota membro, basta adicionar um bloco `member` ao bloco de recursos:

```rb
resources :photos do
  member do
    get 'preview'
  end
end
```

Isso será reconhecido `/photos/1/preview` com GET e roteado para a ação `preview` de `PhotosController`, com o valor do ID do recurso passado em `params[:id]`. Ele também criará os ajudantes `preview_photo_url` e `preview_photo_path`.

Dentro do bloco de rotas membros, cada nome de rota especifica o verbo HTTP que será reconhecido. Você pode usar `get`, `patch`, `put`, `post` ou `delete` aqui . Caso não tenha múltiplas rotas `member`, você também pode passar `:on` para uma rota, eliminando o bloqueio:

```rb
resources :photos do
  get 'preview', on: :member
end
```

Você pode deixar de fora a opção `:on`, isso criará a mesma rota de membro, exceto que o valor do ID do recurso estará disponível em `params[:photo_id]` em vez de `params[:id]`. Os auxiliares de rota também serão renomeados de `preview_photo_url`e `preview_photo_path` para `photo_preview_url` e `photo_preview_path`.


#### 2.10.2 Adicionando Rotas de Coleta

Para adicionar uma rota à coleção, use um bloco `collection`:

```rb
resources :photos do
  collection do
    get 'search'
  end
end
```

Isso permitirá que o Rails reconheça caminhos como `/photos/search` GET e direcione para a ação `search` de `PhotosController`. Ele também criará os ajudantes `search_photos_url` de rota `search_photos_path`.

Assim como nas rotas membro, você pode passar `:on` para uma rota:

```rb
resources :photos do
  get 'search', on: :collection
end
```

![rails routing](/imagens/rails_routing9.JPG)


#### 2.10.3 Adicionando Rotas para Novas Ações Adicionais

Para adicionar uma nova ação alternativa usando o atalho `:on`:

```rb
resources :comments do
  get 'preview', on: :new
end
```

Isso permitirá que o Rails reconheça caminhos como `/comments/new/preview` GET e direcione para a ação `preview` de `CommentsController`. Ele também criará os ajudantes `preview_new_comment_url` de rota `preview_new_comment_path`.

![rails routing](/imagens/rails_routing10.JPG)

