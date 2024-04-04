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


## 3 rotas sem recursos

Além do roteamento de recursos, o Rails possui suporte poderoso para rotear URLs arbitrárias para ações. Aqui, você não obtém grupos de rotas gerados automaticamente por roteamento engenhoso. Em vez disso, você configura cada rota separadamente em seu aplicativo.

Embora você normalmente deva usar roteamento engenhoso, ainda há muitos lugares onde o roteamento mais simples é mais apropriado. Não há necessidade de tentar encaixar cada peça do seu aplicativo em uma estrutura engenhosa se isso não for uma boa opção.

Em particular, o roteamento simples torna muito fácil mapear URLs legados para novas ações do Rails.

### 3.1 Parâmetros vinculados

Ao configurar uma rota regular, você fornece uma série de símbolos que o Rails mapeia para partes de uma solicitação HTTP recebida. Por exemplo, considere esta rota:

```rb
get 'photos(/:id)', to: 'photos#display'
```

Se uma solicitação recebida for `/photos/1` processada por esta rota (porque não corresponde a nenhuma rota anterior no arquivo), o resultado será invocar a ação `display` de `PhotosController` e disponibilizar o parâmetro final `"1"` como `params[:id]`. Esta rota também encaminhará a solicitação recebida de `/photos` para  `PhotosController#display`, já que `:id` é um parâmetro opcional, indicado entre parênteses.


### 3.2 Segmentos Dinâmicos

Você pode configurar quantos segmentos dinâmicos desejar em uma rota regular. Qualquer segmento estará disponível para a ação como parte do `params`. Se você configurar esta rota:

```rb
get 'photos/:id/:user_id', to: 'photos#show'
```

Um caminho de entrada `/photos/1/2` será despachado para a ação `show`  do arquivo `PhotosController`. `params[:id]` será `"1"` e `params[:user_id]` será `"2"`.

![rails routing](/imagens/rails_routing11.JPG)


### 3.3 Segmentos Estáticos

Você pode especificar segmentos estáticos ao criar uma rota, não acrescentando dois pontos antes de um segmento:

```rb
get 'photos/:id/with_user/:user_id', to: 'photos#show'
```

Esta rota responderia a caminhos como `/photos/1/with_user/2`. Neste caso, `params` seria `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.


### 3.4 A string de consulta

Também incluirá quaisquer `params` parâmetros da string de consulta. Por exemplo, com esta rota:

```rb
get 'photos/:id', to: 'photos#show'
```

Um caminho de entrada `/photos/1?user_id=2` será despachado para a ação `show` do controlador `Photos`. `params` vai ser `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.


### 3.5 Definindo Padrões

Você pode definir padrões em uma rota fornecendo um hash para a opção `:defaults`. Isso se aplica até mesmo a parâmetros que você não especifica como segmentos dinâmicos. Por exemplo:

```rb
get 'photos/:id', to: 'photos#show', defaults: { format: 'jpg' }
```

Rails corresponderia `photos/12` à ação `show` de `PhotosController` e seria definido `params[:format]` como `"jpg"`.

Você também pode usar um bloco `defaults` para definir os padrões para vários itens:

```rb
defaults format: :json do
  resources :photos
end
```

![rails routing](/imagens/rails_routing12.JPG)


### 3.6 Nomeando Rotas

Você pode especificar um nome para qualquer rota usando a opção `:as`:

```rb
get 'exit', to: 'sessions#destroy', as: :logout
```

Isso criará `logout_path` e `logout_url` como auxiliares de rota nomeados em seu aplicativo. A chamada `logout_path` retornará `/exit`

Você também pode usar isso para substituir métodos de roteamento definidos por recursos, colocando rotas personalizadas antes de o recurso ser definido, assim:

```rb
get ':username', to: 'users#show', as: :user
resources :users
```

Isso definirá um método `user_path` que estará disponível em controladores, auxiliares e visualizações que irão para uma rota como `/bob`. Dentro da ação `show` de `UsersController`, `params[:username]` conterá o nome de usuário do usuário. Altere a definição da rota `:usernamea` se não quiser que o nome do seu parâmetro seja `:username`.


### 3.7 Restrições de verbos HTTP

Em geral, você deve usar os métodos `get`, `post`, `put`, `patche` `delete` para restringir uma rota a um verbo específico. Você pode usar o método `match` com a opção `:via` para combinar vários verbos de uma vez:

```rb
match 'photos', to: 'photos#show', via: [:get, :post]
```

Você pode combinar todos os verbos com uma rota específica usando `via: :all`:

```rb
match 'photos', to: 'photos#show', via: :all
```

![rails routing](/imagens/rails_routing13.JPG)


### 3.8 Restrições de segmento

Você pode usar a opção `:constraints` para impor um formato a um segmento dinâmico:

```rb
get 'photos/:id', to: 'photos#show', constraints: { id: /[A-Z]\d{5}/ }
```

Esta rota corresponderia a caminhos como `/photos/A12345`, mas não `/photos/893`. Você pode expressar de forma mais sucinta a mesma rota desta forma:

```rb
get 'photos/:id', to: 'photos#show', id: /[A-Z]\d{5}/
```

`:constraints` aceita expressões regulares com a restrição de que âncoras regexp não podem ser usadas. Por exemplo, a seguinte rota não funcionará:

```rb
get '/:id', to: 'articles#show', constraints: { id: /^\d/ }
```

Entretanto, observe que você não precisa usar âncoras porque todas as rotas estão ancoradas no início e no final.

Por exemplo, as rotas a seguir permitiriam que valores `articles` `to_param` como esse `1-hello-world` sempre comecem com um número e `users` com  `to_param` valores como esse `david` nunca comecem com um número para compartilhar o namespace raiz:

```rb
get '/:id', to: 'articles#show', constraints: { id: /\d.+/ }
get '/:username', to: 'users#show'
```


### 3.9 Restrições Baseadas em Solicitações

Você também pode restringir uma rota com base em qualquer método no objeto Request que retorne um arquivo `String`.

Você especifica uma restrição baseada em solicitação da mesma forma que especifica uma restrição de segmento:

```rb
get 'photos', to: 'photos#index', constraints: { subdomain: 'admin' }
```

Você também pode especificar restrições usando um bloco `constraints`:

```rb
namespace :admin do
  constraints subdomain: 'admin' do
    resources :photos
  end
end
```

![rails routing](/imagens/rails_routing14.JPG)


### 3.10 Restrições Avançadas

Se você tiver uma restrição mais avançada, poderá fornecer um objeto que responda ao `matches?` que o Rails deve usar. Digamos que você queira rotear todos os usuários de uma lista restrita para o arquivo `RestrictedListController`. Você poderia fazer:

```rb
class RestrictedListConstraint
  def initialize
    @ips = RestrictedList.retrieve_ips
  end

  def matches?(request)
    @ips.include?(request.remote_ip)
  end
end

Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: RestrictedListConstraint.new
end
```

Você também pode especificar restrições como lambda:

```rb
Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }
end
```

Tanto o método `matches?` quanto o lambda obtêm o objeto `request` como argumento.

#### 3.10.1 Restrições em um Formulário de Bloco

Você pode especificar restrições em formato de bloco. Isso é útil quando você precisa aplicar a mesma regra a diversas rotas. Por exemplo:

```rb
class RestrictedListConstraint
  # ...Same as the example above
end

Rails.application.routes.draw do
  constraints(RestrictedListConstraint.new) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

Você também pode usar um `lambda`:

```rb
Rails.application.routes.draw do
  constraints(lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```


### 3.11 Globbing de rota e segmentos curinga

Globbing de rota é uma forma de especificar que um parâmetro específico deve corresponder a todas as partes restantes de uma rota. Por exemplo:

```rb
get 'photos/*other', to: 'photos#unknown'
```

Esta rota corresponderia `photos/12a` or `/photos/long/path/to/12`, definida `params[:other]` como `"12"` ou `"long/path/to/12"`. Os segmentos prefixados com uma estrela são chamados de "segmentos curinga".

Os segmentos curinga podem ocorrer em qualquer lugar de uma rota. Por exemplo:

```rb
get 'books/*section/:title', to: 'books#show'
```

corresponderia `books/some/section/last-words-a-memoir` um `params[:section]` igual `'some/section'` e `params[:title]` igual `'last-words-a-memoir'`.

Tecnicamente, uma rota pode ter até mais de um segmento curinga. O matcher atribui segmentos a parâmetros de forma intuitiva. Por exemplo:

```rb
get '*a/foo/*b', to: 'test#index'
```

corresponderia `zoo/woo/foo/bar/baz` um `params[:a]` igual `'zoo/woo'` e  `params[:b]` igual à `'bar/baz'`.

![rails routing](/imagens/rails_routing15.JPG)

```rb
get '*pages', to: 'pages#show', format: false
```

![rails routing](/imagens/rails_routing16.JPG)

```rb
get '*pages', to: 'pages#show', format: true
```


## 3.12 Redirecionamento

Você pode redirecionar qualquer caminho para outro caminho usando o auxiliar `redirect` em seu roteador:

```rb
get '/stories', to: redirect('/articles')
```

Você também pode reutilizar segmentos dinâmicos da correspondência no caminho para redirecionar:

```rb
get '/stories/:name', to: redirect('/articles/%{name}')
```

Você também pode fornecer um bloco para `redirect`, que recebe os parâmetros do caminho simbolizado e o objeto de solicitação:

```rb
get '/stories/:name', to: redirect { |path_params, req| "/articles/#{path_params[:name].pluralize}" }
get '/stories', to: redirect { |path_params, req| "/articles/#{req.subdomain}" }
```

Observe que o redirecionamento padrão é um redirecionamento 301 "Movido permanentemente". Lembre-se de que alguns navegadores da web ou servidores proxy armazenarão esse tipo de redirecionamento em cache, tornando a página antiga inacessível. Você pode usar a opção `:status` para alterar o status da resposta:

```rb
get '/stories/:name', to: redirect('/articles/%{name}', status: 302)
```

Em todos esses casos, se você não fornecer o host principal (`http://www.example.com`), o Rails pegará esses detalhes da solicitação atual.


### 3.13 Roteamento para aplicações em rack

Em vez de uma String como `'articles#index'`, que corresponde à ação `index` no `ArticlesController`, você pode especificar qualquer [aplicativo Rack](https://guides.rubyonrails.org/rails_on_rack.html) como ponto final para um matcher:

```rb
match '/application.js', to: MyRackApp, via: :all
```

Enquanto `MyRackApp` responder `call` e retornar um `[status, headers, body]`, o roteador não saberá a diferença entre o aplicativo Rack e uma ação. Este é um uso apropriado de `via: :all`, pois você desejará permitir que seu aplicativo Rack manipule todos os verbos conforme considerar apropriado.

![rails routing](/imagens/rails_routing17.JPG)

Se você especificar um aplicativo Rack como ponto final para um matcher, lembre-se de que a rota permanecerá inalterada no aplicativo receptor. Com a rota a seguir, seu aplicativo Rack deve esperar que a rota seja `/admin`:

```rb
match '/admin', to: AdminApp, via: :all
```

Se você preferir que seu aplicativo Rack receba solicitações no caminho raiz, use `mount`:

```rb
mount AdminApp, at: '/admin'
```


### 3.14 Usandoroot

Você pode especificar para onde o Rails deve rotear `'/'` com o método `root`:

```rb
root to: 'pages#main'
root 'pages#main' # shortcut for the above
```

Você deve colocar a `root` rota no topo do arquivo, pois é a rota mais popular e deve ser correspondida primeiro.

![rails routing](/imagens/rails_routing18.JPG)

Você também pode usar root dentro de namespaces e escopos. Por exemplo:

```rb
namespace :admin do
  root to: "admin#index"
end

root to: "home#index"
```


### 3.15 Rotas de caracteres Unicode

Você pode especificar rotas de caracteres Unicode diretamente. Por exemplo:

```rb
get 'こんにちは', to: 'welcome#index'
```


### 3.16 Rotas Diretas

Você pode criar auxiliares de URL personalizados diretamente chamando `direct`. Por exemplo:

```rb
direct :homepage do
  "https://rubyonrails.org"
end

# >> homepage_url
# => "https://rubyonrails.org"
```

O valor de retorno do bloco deve ser um argumento válido para o método `url_for`. Portanto, você pode passar uma URL de string válida, Hash, Array, uma instância do Active Model ou uma classe do Active Model.

```rb
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```


### 3.17 Usando resolve

O método `resolve` permite customizar o mapeamento polimórfico de modelos. Por exemplo:

```rb
resource :basket

resolve("Basket") { [:basket] }
```

```rb
<%= form_with model: @basket do |form| %>
  <!-- basket form -->
<% end %>
```


Isso gerará o URL singular `/basket` em vez do arquivo `/baskets/:id`.


## 4 Personalizando Rotas com Recursos

Embora as rotas padrão e os auxiliares gerados por `resources` geralmente sejam úteis para você, você pode querer personalizá-los de alguma forma. Rails permite que você personalize praticamente qualquer parte genérica dos ajudantes engenhosos.

### 4.1 Especificando um controlador para usar

A opção `:controller` permite especificar explicitamente um controlador a ser usado para o recurso. Por exemplo:

```rb
resources :photos, controller: 'images'
```

reconhecerá os caminhos de entrada começando com `/photos` mas roteará para o controlador `Images`:


| HTTP Verb	| Path	| Controller#Action	| Named Route Helper |
| --- | --- | --- | --- |
| GET	| /photos	| images#index	| photos_path |
| GET	| /photos/new	| images#new	| new_photo_path |
| POST	| /photos	| images#create	| photos_path |
| GET	| /photos/:id	| images#show	| photo_path(:id) |
| GET	| /photos/:id/edit	| images#edit	| edit_photo_path(:id) |
| PATCH/PUT	| /photos/:id	| images#update	| photo_path(:id) |
| DELETE	| /photos/:id	| images#destroy	| photo_path(:id) |

![rails routing](/imagens/rails_routing19.JPG)

Para controladores com namespace você pode usar a notação de diretório. Por exemplo:

```rb
resources :user_permissions, controller: 'admin/user_permissions'
```
Isso será roteado para o controlador `Admin::UserPermissions`.

![rails routing](/imagens/rails_routing20.JPG)


### 4.2 Especificando Restrições

Você pode usar a opção  `:constraints` para especificar um formato necessário no arquivo `id`. Por exemplo:

```rb
resources :photos, constraints: { id: /[A-Z][A-Z][0-9]+/ }
```

Esta declaração restringe o parâmetro `:id` para corresponder à expressão regular fornecida. Portanto, neste caso, o roteador não corresponderia mais `/photos/1` a esta rota. Em vez disso, combinaria `/photos/RR27`.

Você pode especificar uma única restrição para aplicar a diversas rotas usando o formulário de bloco:

```rb
constraints(id: /[A-Z][A-Z][0-9]+/) do
  resources :photos
  resources :accounts
end
```

![rails routing](/imagens/rails_routing21.JPG)


### 4.3 Substituindo os auxiliares de rota nomeados


A opção `:as` permite substituir a nomenclatura normal dos auxiliares de rota nomeados. Por exemplo:

```rb
resources :photos, as: 'images'
```

reconhecerá os caminhos de entrada começando com `/photos` e encaminhará as solicitações para `PhotosController`, mas usará o valor da opção `:as` para nomear os auxiliares.


| HTTP Verb	| Path	| Controller#Action	| Named Route Helper |
| --- | --- | --- | --- |
| GET	| /photos	| photos#index	| images_path |
| GET	| /photos/new	| photos#new	| new_image_path |
| POST	| /photos	| photos#create	| images_path |
| GET	| /photos/:id	| photos#show	| image_path(:id) |
| GET	| /photos/:id/edit	| photos#edit	| edit_image_path(:id) |
| PATCH/PUT	| /photos/:id	| photos#update	| image_path(:id) |
| DELETE	| /photos/:id	| photos#destroy	| image_path(:id) |


### 4.4 Substituindo os segmentos `new` e `edit`

A opção `:path_names` permite substituir os segmentos gerados automaticamente `new` e `edit` nos caminhos:

```rb
resources :photos, path_names: { new: 'make', edit: 'change' }
```

Isso faria com que o roteamento reconhecesse caminhos como:

```rb
/photos/make
/photos/1/change
```

![rails routing](/imagens/rails_routing22.JPG)

```rb
scope path_names: { new: 'make' } do
  # rest of your routes
end
```


### 4.5 Prefixando os auxiliares de rota nomeados

Você pode usar a opção `:as` de prefixar os auxiliares de rota nomeados que o Rails gera para uma rota. Use esta opção para evitar colisões de nomes entre rotas usando um escopo de caminho. Por exemplo:

```rb
scope 'admin' do
  resources :photos, as: 'admin_photos'
end

resources :photos
```

Isso altera os auxiliares de rota de `/admin/photos`, `photos_path`, `new_photos_path` etc. para `admin_photos_path`, `new_admin_photo_path`, etc. Sem a adição de `as: 'admin_photos` no escopo resources
`:photos`, os sem escopo `resources :photos` não terão nenhum auxiliar de rota.

Para prefixar um grupo de auxiliares de rota, use `:as` with `scope`:

```rb
scope 'admin', as: 'admin' do
  resources :photos, :accounts
end

resources :photos, :accounts
```

Assim como antes, isso altera os auxiliares `/admin` de recursos com escopo definido para `admin_photos_path` e `admin_accounts_path` e permite que os recursos sem escopo usem `photos_path` e `accounts_path`.

![rails routing](/imagens/rails_routing23.JPG)


#### 4.5.1 Escopos Paramétricos

Você pode prefixar rotas com um parâmetro nomeado:

```rb
scope ':account_id', as: 'account', constraints: { account_id: /\d+/ } do
  resources :articles
end
```

Isso fornecerá caminhos como `/1/articles/9` e permitirá que você faça referência à `account_id` parte do caminho como `params[:account_id]` em controladores, auxiliares e visualizações.

Ele também gerará auxiliares de caminho e URL prefixados com `account_`, para os quais você poderá passar seus objetos conforme esperado:

```rb
account_article_path(@account, @article) # => /1/article/9
url_for([@account, @article])            # => /1/article/9
form_with(model: [@account, @article])   # => <form action="/1/article/9" ...>
```

Estamos usando uma restrição para limitar o escopo para corresponder apenas a strings semelhantes a ID. Você pode alterar a restrição para atender às suas necessidades ou omiti-la totalmente. A opção `:as` também não é estritamente necessária, mas sem ela, o Rails irá gerar um erro ao avaliar `url_for([@account, @article])` ou outros auxiliares que dependem de `url_for`, como `form_with`.


### 4.6 Restringindo as Rotas Criadas

Por padrão, Rails cria rotas para as sete ações padrão ( `index`, `show`, `new`, `create`, `edit`, `update` e `destroy`) para cada rota RESTful em sua aplicação. Você pode usar as opções `:only` e `:except` para ajustar esse comportamento. A opção `:only` diz ao Rails para criar apenas as rotas especificadas:

```rb
resources :photos, only: [:index, :show]
```

Agora, uma solicitação `GET` para `/photos` seria bem-sucedida, mas uma solicitação `POST` para `/photos` (que normalmente seria roteada para a ação `create`) falhará.

A opção `:except` especifica uma rota ou lista de rotas que o Rails não deve criar:

```rb
resources :photos, except: :destroy
```

Neste caso, Rails criará todas as rotas normais, exceto a rota para `destroy` (uma solicitação `DELETE` para `/photos/:id`, falhará).


![rails routing](/imagens/rails_routing24.JPG)


### 4.7 Caminhos traduzidos

Usando scope, podemos alterar os nomes dos caminhos gerados por resources:

```rb
scope(path_names: { new: 'neu', edit: 'bearbeiten' }) do
  resources :categories, path: 'kategorien'
end
```

Rails agora cria rotas para o `CategoriesController`.

| HTTP Verb	| Path	| Controller#Action	| Named Route Helper |
| --- | --- | --- | --- |
| GET	| /kategorien	| categories#index	| categories_path |
| GET	| /kategorien/neu	| categories#new	| new_category_path |
| POST	| /kategorien	| categories#create	| categories_path |
| GET	| /kategorien/:id	| categories#show	| category_path(:id) |
| GET	| /kategorien/:id/bearbeiten	| categories#edit	| edit_category_path(:id) |
| PATCH/PUT	| /kategorien/:id	| categories#update	| category_path(:id) |
| DELETE	| /kategorien/:id	| categories#destroy	| category_path(:id) |


### 4.8 Substituindo a Forma Singular

Se quiser substituir a forma singular de um recurso, você deve adicionar regras adicionais ao infletor por meio de `inflections`:

```rb
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tooth', 'teeth'
end
```


### 4.9 Usando recursos aninhados `:as`

A opção `:as` substitui o nome gerado automaticamente para o recurso em auxiliares de rota aninhados. Por exemplo:

```rb
resources :magazines do
  resources :ads, as: 'periodical_ads'
end
```

Isso criará auxiliares de roteamento como `magazine_periodical_ads_url` e `edit_magazine_periodical_ad_path`.


### 4.10 Substituindo Parâmetros de Rota Nomeada

A opção `:param` substitui o identificador de recurso padrão `:id`(nome do segmento dinâmico usado para gerar as rotas). Você pode acessar esse segmento do seu controlador usando `params[<:param>]`.

```rb
resources :videos, param: :identifier
```

```rb
    videos GET  /videos(.:format)                  videos#index
           POST /videos(.:format)                  videos#create
 new_video GET  /videos/new(.:format)              videos#new
edit_video GET  /videos/:identifier/edit(.:format) videos#edit
```

```rb
Video.find_by(identifier: params[:identifier])
```

Você pode substituir o modelo associado `ActiveRecord::Base#to_param`  para construir uma URL:

```rb
class Video < ApplicationRecord
  def to_param
    identifier
  end
end
```

```rb
video = Video.find_by(identifier: "Roman-Holiday")
edit_video_path(video) # => "/videos/Roman-Holiday/edit"
```


## 5 Dividindo arquivos de rota muito grandes em vários arquivos pequenos

Se você trabalha em um aplicativo grande com milhares de rotas, um único arquivo `config/routes.rb` pode se tornar complicado e difícil de ler.

Rails oferece uma maneira de dividir um único arquivo `routes.rb` gigantesco em vários arquivos pequenos usando a macro `draw`.

Você poderia ter uma rota `admin.rb` que contenha todas as rotas para a área administrativa, outro arquivo `api.rb` para recursos relacionados à API, etc.

```rb
# config/routes.rb

Rails.application.routes.draw do
  get 'foo', to: 'foo#bar'

  draw(:admin) # Will load another route file located in `config/routes/admin.rb`
end
```

```rb
# config/routes/admin.rb

namespace :admin do
  resources :comments
end
```
Chamar `draw(:admin)` dentro do `Rails.application.routes.draw` próprio bloco tentará carregar um arquivo de rota que tenha o mesmo nome do argumento fornecido (`admin.rb` neste exemplo). O arquivo precisa estar localizado dentro do diretório `config/routes` ou qualquer subdiretório (ou seja, `config/routes/admin.rb` ou `config/routes/external/admin.rb`).

Você pode usar o DSL de roteamento normal dentro do arquivo `admin.rb` de roteamento, mas não deve cercá-lo com o `Rails.application.routes.draw` bloco como fez no arquivo `config/routes.rb` principal.

### 5.1 Não use este recurso a menos que você realmente precise dele

Ter vários arquivos de roteamento dificulta a descoberta e a compreensão. Para a maioria dos aplicativos - mesmo aqueles com algumas centenas de rotas - é mais fácil para os desenvolvedores ter um único arquivo de roteamento. O DSL de roteamento Rails já oferece uma maneira de quebrar rotas de forma organizada com `namespace` e `scope`.


## 6 Rotas de inspeção e teste

Rails oferece facilidades para inspecionar e testar suas rotas.


### 6.1 Listando Rotas Existentes

Para obter uma lista completa das rotas disponíveis em sua aplicação, visite `http://localhost:3000/rails/info/routes` em seu navegador enquanto seu servidor está rodando no ambiente de desenvolvimento . Você também pode executar o comando `bin/rails routes`  em seu terminal para produzir a mesma saída.

Ambos os métodos listarão todas as suas rotas, na mesma ordem em que aparecem no arquivo `config/routes.rb`. Para cada rota, você verá:

- O nome da rota (se houver)
- O verbo HTTP usado (se a rota não responder a todos os verbos)
- O padrão de URL para correspondência
- Os parâmetros de roteamento para a rota

Por exemplo, aqui está uma pequena seção da saída `bin/rails routes` de uma rota RESTful:

![rails routing](/imagens/rails_routing25.JPG)

Você também pode usar a opção `--expanded` de ativar o modo de formatação de tabela expandida.

![rails routing](/imagens/rails_routing26.JPG)

Você pode pesquisar suas rotas com a opção grep: -g. Isso gera quaisquer rotas que correspondam parcialmente ao nome do método auxiliar de URL, ao verbo HTTP ou ao caminho do URL.

![rails routing](/imagens/rails_routing27.JPG)

Se você quiser ver apenas as rotas mapeadas para um controlador específico, existe a opção -c.

![rails routing](/imagens/rails_routing28.JPG)


### 6.2 Rotas de Teste
As rotas devem ser incluídas na sua estratégia de teste (assim como o resto da sua aplicação). Rails oferece três asserções integradas projetadas para simplificar o teste de rotas:

- assert_generates
- assert_recognizes
- assert_routing

