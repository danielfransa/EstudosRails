# Layouts and Rendering in Rails

## 1 Visão geral: como as peças se encaixam

Este guia enfoca a interação entre Controller e View no triângulo Model-View-Controller. Como você sabe, o Controller é responsável por orquestrar todo o processo de tratamento de uma solicitação no Rails, embora normalmente entregue qualquer código pesado ao Modelo. Mas então, quando chega a hora de enviar uma resposta de volta ao usuário, o Controlador passa as coisas para a Visualização. É essa transferência o tema deste guia.

Em linhas gerais, isso envolve decidir o que deve ser enviado como resposta e chamar um método apropriado para criar essa resposta. Se a resposta for uma visualização completa, o Rails também faz algum trabalho extra para agrupar a visualização em um layout e possivelmente extrair visualizações parciais. Você verá todos esses caminhos posteriormente neste guia.


## 2 Criando Respostas

Do ponto de vista do controlador, existem três maneiras de criar uma resposta HTTP:

- Ligue `render` para criar uma resposta completa para enviar de volta ao navegador
- Chamada `redirect_to` para enviar um código de status de redirecionamento HTTP ao navegador
- Chamada `head` para criar uma resposta que consiste apenas em cabeçalhos HTTP para enviar de volta ao navegador

### 2.1 Renderização por padrão: convenção sobre configuração em ação

Você já ouviu falar que Rails promove “convenção em vez de configuração”. A renderização padrão é um excelente exemplo disso. Por padrão, os controladores no Rails renderizam automaticamente visualizações com nomes que correspondem a rotas válidas. Por exemplo, se você tiver este código em sua classe `BooksController`:

```rb
class BooksController < ApplicationController
end
```

E o seguinte no seu arquivo de rotas:

```rb
resources :books
```

E você tem um arquivo de visualização `app/views/books/index.html.erb`:

```rb
<h1>Books are coming soon!</h1>
```

Rails será renderizado automaticamente `app/views/books/index.html.erb` quando você navegar `/books` e você verá "Livros chegando em breve!" na sua tela.

No entanto, uma tela em breve é ​​minimamente útil, então em breve você criará seu modelo `Book` e adicionará a ação de índice a `BooksController`:

```rb
class BooksController < ApplicationController
  def index
    @books = Book.all
  end
end
```

Observe que não temos renderização explícita no final da ação do índice de acordo com o princípio da "convenção sobre configuração". A regra é que se você não renderizar algo explicitamente no final de uma ação do controlador, o Rails irá automaticamente procurar o modelo `action_name.html.erb` no caminho de visualização do controlador e renderizá-lo. Portanto, neste caso, o Rails irá renderizar o arquivo `app/views/books/index.html.erb`.

Se quisermos exibir as propriedades de todos os livros em nossa visualização, podemos fazer isso com um modelo ERB como este:

```rb
<h1>Listing Books</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Content</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @books.each do |book| %>
      <tr>
        <td><%= book.title %></td>
        <td><%= book.content %></td>
        <td><%= link_to "Show", book %></td>
        <td><%= link_to "Edit", edit_book_path(book) %></td>
        <td><%= link_to "Destroy", book, data: { turbo_method: :delete, turbo_confirm: "Are you sure?" } %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to "New book", new_book_path %>
```

![Layout and Redering in Rails - Padrão](/imagens/layout_rendering_rails1.JPG)


### 2.2 Usando `render`

Na maioria dos casos, o método do controlador `render` faz o trabalho pesado de renderizar o conteúdo do seu aplicativo para uso por um navegador. Existem várias maneiras de personalizar o comportamento do render. Você pode renderizar a visualização padrão para um modelo Rails, ou um modelo específico, ou um arquivo, ou código embutido, ou nada. Você pode renderizar texto, JSON ou XML. Você também pode especificar o tipo de conteúdo ou o status HTTP da resposta renderizada.

![Layout and Redering in Rails - render](/imagens/layout_rendering_rails2.JPG)


#### 2.2.1 Renderizando a Visualização de uma Ação

Se quiser renderizar a view que corresponde a um template diferente dentro do mesmo controlador, você pode usar `render` com o nome da view:

```rb
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render "edit"
  end
end
```

Se a chamada `update` falhar, chamar a ação `update` neste controlador renderizará o modelo `edit.html.erb` pertencente ao mesmo controlador.

Se preferir, você pode usar um símbolo em vez de uma string para especificar a ação a ser renderizada:

```rb
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render :edit, status: :unprocessable_entity
  end
end
```


#### 2.2.2 Renderizando um modelo de ação de outro controlador

E se você quiser renderizar um modelo de um controlador totalmente diferente daquele que contém o código de ação? Você também pode fazer isso com `render`, que aceita o caminho completo (relativo a `app/views`) do modelo a ser renderizado. Por exemplo, se você estiver executando um código `AdminProductsController` que reside em `app/controllers/admin`, poderá renderizar os resultados de uma ação em um modelo desta maneira `app/views/products`:

```show
render "products/show"
```

Rails sabe que esta visão pertence a um controlador diferente por causa do caractere de barra embutido na string. Se quiser ser explícito, você pode usar a opção `:template` (que era necessária no Rails 2.2 e anteriores):

```rb
render template: "products/show"
```

#### 2.2.3 Concluindo

As duas formas de renderização acima (renderizar o modelo de outra ação no mesmo controlador e renderizar o modelo de outra ação em um controlador diferente) são na verdade variantes da mesma operação.

Na verdade, na classe `BooksController`, dentro da ação de atualização onde queremos renderizar o modelo de edição se o livro não for atualizado com sucesso, todas as chamadas de renderização a seguir renderizariam o modelo `edit.html.erb` no diretório `views/books`:

```rb
render :edit
render action: :edit
render "edit"
render action: "edit"
render "books/edit"
render template: "books/edit"
```

Qual deles você usa é realmente uma questão de estilo e convenção, mas a regra geral é usar o mais simples que faça sentido para o código que você está escrevendo.

#### 2.2.4 Usando `render` com: `inline`

O método `render` pode funcionar completamente sem uma visualização, se você estiver disposto a usar a opção `:inline` de fornecer ERB como parte da chamada do método. Isto é perfeitamente válido:

```rb
render inline: "<% products.each do |p| %><p><%= p.name %></p><% end %>"
```

![Layout and Redering in Rails - render](/imagens/layout_rendering_rails3.JPG)

Por padrão, a renderização embutida usa ERB. Você pode forçá-lo a usar o Builder com a opção `:type`:

```rb
render inline: "xml.p {'Horrid coding practice!'}", type: :builder
```

#### 2.2.5 Renderizando Texto

Você pode enviar texto simples - sem nenhuma marcação - de volta ao navegador usando a opção `:plain` para render:

```rb
render plain: "OK"
```

![Layout and Redering in Rails - render](/imagens/layout_rendering_rails4.JPG)


#### 2.2.6 Renderizando HTML

Você pode enviar uma string HTML de volta ao navegador usando a opção `:html` para `render`:

```rb
render html: helpers.tag.strong('Not Found')
```

![Layout and Redering in Rails - render](/imagens/layout_rendering_rails5.JPG)


#### 2.2.7 Renderizando JSON

JSON é um formato de dados JavaScript usado por muitas bibliotecas Ajax. Rails tem suporte integrado para converter objetos em JSON e renderizar esse JSON de volta para o navegador:

```rb
render json: @product
```

![Layout and Redering in Rails - render](/imagens/layout_rendering_rails6.JPG)


#### 2.2.8 Renderizando XML

Rails também possui suporte integrado para converter objetos em XML e renderizar esse XML de volta para o chamador:

```rb
render xml: @product
```

![Layout and Redering in Rails - render](/imagens/layout_rendering_rails7.JPG)


#### 2.2.9 Renderizando JavaScript Vanilla

Rails pode renderizar JavaScript vanilla:

```rb
render js: "alert('Hello Rails');"
```

Isso enviará a string fornecida ao navegador com um tipo MIME `text/javascript`.

#### 2.2.10 Renderizando Corpo Bruto

Você pode enviar um conteúdo bruto de volta ao navegador, sem definir nenhum tipo de conteúdo, usando a opção `:body` para `render`:

```rb
render body: "raw"
```

![Layout and Redering in Rails - render](/imagens/layout_rendering_rails8.JPG)


#### 2.2.11 Renderizando arquivo bruto

Rails pode renderizar um arquivo bruto a partir de um caminho absoluto. Isso é útil para renderizar condicionalmente arquivos estáticos, como páginas de erro.

```rb
render file: "#{Rails.root}/public/404.html", layout: false
```

Isso renderiza o arquivo bruto (não suporta ERB ou outros manipuladores). Por padrão, ele é renderizado no layout atual.

![Layout and Redering in Rails - render](/imagens/layout_rendering_rails9.JPG)


#### 2.2.12 Renderizando Objetos

Rails pode renderizar objetos respondendo a `:render_in`.

```rb
render MyRenderable.new
```

Isso chama `render_in` o objeto fornecido com o contexto de visualização atual.

Você também pode fornecer o objeto usando a opção `:renderable` para `render`:

```rb
render renderable: MyRenderable.new
```

#### 2.2.13 Opções pararender

As chamadas ao rendermétodo geralmente aceitam seis opções:

- `:content_type`
- `:layout`
- `:location`
- `:status`
- `:formats`
- `:variants`


##### 2.2.13.1 A Opção `:content_type`

Por padrão, Rails servirá os resultados de uma operação de renderização com o tipo de conteúdo MIME de `text/html`(ou `application/json` se você usar a opção `:json`, ou `application/xml` para a opção `:xml`.). Há momentos em que você pode querer alterar isso e pode fazer isso definindo a opção `:content_type`:

```rb
render template: "feed", content_type: "application/rss"
```


##### 2.2.13.2 A Opção `:layout`

Com a maioria das opções ativadas `render`, o conteúdo renderizado é exibido como parte do layout atual. Você aprenderá mais sobre layouts e como usá-los posteriormente neste guia.

Você pode usar a opção `:layout` para dizer ao Rails para usar um arquivo específico como layout para a ação atual:

```rb
render layout: "special_layout"
```

Você também pode dizer ao Rails para renderizar sem nenhum layout:

```rb
render layout: false
```


##### 2.2.13.3 A Opção `:location`

Você pode usar a opção `:location` para definir o cabeçalho `Location` HTTP:

```rb
render xml: photo, location: photo_url(photo)
```

##### 2.2.13.4 A Opção `:status`

Rails irá gerar automaticamente uma resposta com o código de status HTTP correto (na maioria dos casos, é 200 OK). Você pode usar a opção `:status` para alterar isso:

```rb
render status: 500
render status: :forbidden
```

Rails entende os códigos de status numéricos e os símbolos correspondentes mostrados abaixo.

|Classe de resposta	|Código de status HTTP|	Símbolo|
| :--- | :---:| :--- |
|Informativo	| 100	| :continuar
| | 101	| :switching_protocols
| | 102	| :em processamento
Sucesso	| 200	| :OK
| | 201	| :criada
| | 202	| :aceitaram
| | 203	| :informações não_autorizadas
| | 204	| :no_content
| | 205	| :reset_content
| | 206	| :partial_content
| | 207	| :multi_status
| | 208	| :já_reportado
| | 226	| :estou acostumado
|Redirecionamento	| 300	| :escolhas múltiplas
| | 301	| :Movido Permanentemente
| | 302	| :encontrado
| | 303	| :ver_outro
| | 304	| :Não modificado
| | 305	| :use_proxy
| | 307	| :redirecionamento_temporário
| | 308	| :permanent_redirect
|Erro do cliente	| 400	| :pedido ruim
| | 401	| :não autorizado
| | 402	| :Pagamento Requerido
| | 403	| :proibido
| | 404	| :não encontrado
| | 405	| :Método não permitido
| | 406	| :não aceitável
| | 407	| :proxy_authentication_required
| | 408	| :request_timeout
| | 409	| :conflito
| | 410	| :perdido
| | 411	| :comprimento_requerido
| | 412	| :pré-condição_failed
| | 413	| :payload_too_large
| | 414	| :uri_too_long
| | 415	| :unsupported_media_type
| | 416	| :range_not_satisfiable
| | 417	| :expectation_failed
| | 421	| :misdirected_request
| | 422	| :entidade não processável
| | 423	| :bloqueado
| | 424	| :failed_dependency
| | 426	| :upgrade_required
| | 428	| :pré-condição_requerida
| | 429	| :muitos_pedidos
| | 431	| :request_header_fields_too_large
| | 451	| :indisponível_por_motivos_legais
|erro de servidor	| 500	| :Erro do Servidor Interno
| | 501	| :não implementado
| | 502	| :bad_gateway
| | 503	| :Serviço não disponível
| | 504	| :gateway_timeout
| | 505	| :http_version_not_supported
| | 506	| :variant_also_negotiates
| | 507	| :armazenamento_insuficiente
| | 508	| :loop_detectado
| | 510	| :não_estendido
| | 511	| :rede_autenticação_requerida


![Layout and Redering in Rails - respostas](/imagens/layout_rendering_rails10.JPG)


##### 2.2.13.5 A Opção `:formats`

Rails usa o formato especificado na solicitação (ou `:html` por padrão). Você pode alterar isso passando a opção `:formats` com um símbolo ou um array:

```rb
render formats: :xml
render formats: [:json, :xml]
```

Se um modelo com o formato especificado não existir, um erro `ActionView::MissingTemplate` será gerado.


##### 2.2.13.6 A Opção `:variants`

Isso diz ao Rails para procurar variações de template do mesmo formato. Você pode especificar uma lista de variantes passando a opção `:variants` com um símbolo ou array.

Um exemplo de uso seria este.

```rb
# called in HomeController#index
render variants: [:mobile, :desktop]
```

Com este conjunto de variantes, o Rails procurará o seguinte conjunto de modelos e usará o primeiro que existir.

- `app/views/home/index.html+mobile.erb`
- `app/views/home/index.html+desktop.erb`
- `app/views/home/index.html.erb`

Se um modelo com o formato especificado não existir, um erro `ActionView::MissingTemplate` será gerado.

Em vez de definir a variante na chamada de renderização, você também pode configurá-la no objeto de solicitação na ação do controlador.

```rb
def index
  request.variant = determine_variant
end

  private
    def determine_variant
      variant = nil
      # some code to determine the variant(s) to use
      variant = :mobile if session[:use_mobile]

      variant
    end
```


#### 2.2.14 Encontrando Layouts

Para encontrar o layout atual, o Rails primeiro procura por um arquivo `app/views/layouts` com o mesmo nome base do controlador. Por exemplo, a renderização de ações da classe `PhotosController` usará `app/views/layouts/photos.html.erb` (ou `app/views/layouts/photos.builder`). Se não houver tal layout específico do controlador, o Rails usará `app/views/layouts/application.html.erb` ou  `app/views/layouts/application.builder`. Se não houver layout `.erb`, o Rails usará um layout `.builder`, se existir. Rails também fornece diversas maneiras de atribuir layouts específicos com mais precisão a controladores e ações individuais.


##### 2.2.14.1 Especificando Layouts para Controladores

Você pode substituir as convenções de layout padrão em seus controladores usando a declaração `layout`. Por exemplo:

```rb
class ProductsController < ApplicationController
  layout "inventory"
  #...
end
```

Com esta declaração, todas as visualizações renderizadas pelo `ProductsController` usarão `app/views/layouts/inventory.html.erb` como layout.

Para atribuir um layout específico para toda a aplicação, utilize uma declaração `layout` na sua classe `ApplicationController`:

```rb
class ApplicationController < ActionController::Base
  layout "main"
  #...
end
```

Com esta declaração, todas as visualizações em todo o aplicativo serão utilizadas `app/views/layouts/main.html.erb` em seu layout.


##### 2.2.14.2 Escolhendo Layouts em Tempo de Execução

Você pode usar um símbolo para adiar a escolha do layout até que uma solicitação seja processada:

```rb
class ProductsController < ApplicationController
  layout :products_layout

  def show
    @product = Product.find(params[:id])
  end

  private
    def products_layout
      @current_user.special? ? "special" : "products"
    end
end
```

Agora, se o usuário atual for um usuário especial, ele receberá um layout especial ao visualizar um produto.

Você pode até usar um método embutido, como Proc, para determinar o layout. Por exemplo, se você passar um objeto Proc, o bloco que você fornecer ao Proc receberá a instância `controller`, então o layout pode ser determinado com base na solicitação atual:

```rb
class ProductsController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? "popup" : "application" }
end
```


##### 2.2.14.3 Layouts Condicionais

Os layouts especificados no nível do controlador suportam as opções `:only` e `:except`. Essas opções recebem um nome de método ou um array de nomes de métodos, correspondendo aos nomes de métodos dentro do controlador:

```rb
class ProductsController < ApplicationController
  layout "product", except: [:index, :rss]
end
```

Com esta declaração, o layout `product` seria usado para tudo, menos para os métodos `rss` e `index`.


#####  2.2.14.4 Herança de Layout

As declarações de layout caem em cascata na hierarquia e as declarações de layout mais específicas sempre substituem as mais gerais. Por exemplo:

- application_controller.rb

```rb
class ApplicationController < ActionController::Base
  layout "main"
end
```

- articles_controller.rb

```rb
class ArticlesController < ApplicationController
end
```

- special_articles_controller.rb

```rb
class SpecialArticlesController < ArticlesController
  layout "special"
end
```

- old_articles_controller.rb

```rb
class OldArticlesController < SpecialArticlesController
  layout false

  def show
    @article = Article.find(params[:id])
  end

  def index
    @old_articles = Article.older
    render layout: "old"
  end
  # ...
end
```

Nesta aplicação:

- Em geral, as visualizações serão renderizadas no layout `main`
- `ArticlesController#index` usará o layout `main`
- `SpecialArticlesController#index` usará o layout `special`
- `OldArticlesController#show` não usará nenhum layout
- `OldArticlesController#index` usará o layout `old`


##### 2.2.14.5 Herança de Modelo

Semelhante à lógica de herança de layout, se um modelo ou parcial não for encontrado no caminho convencional, o controlador procurará um modelo ou parcial para renderizar em sua cadeia de herança. Por exemplo:

```rb
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
end
```
```rb
# app/controllers/admin_controller.rb
class AdminController < ApplicationController
end
```
```rb
# app/controllers/admin/products_controller.rb
class Admin::ProductsController < AdminController
  def index
  end
end
```

A ordem de pesquisa para uma ação `admin/products#index` será:

- `app/views/admin/products/`
- `app/views/admin/`
- `app/views/application/`

Isto é `app/views/application/` um ótimo lugar para seus parciais compartilhados, que podem então ser renderizados em seu ERB como tal:

```rb
<%# app/views/admin/products/index.html.erb %>
<%= render @products || "empty_list" %>

<%# app/views/application/_empty_list.html.erb %>
There are no items in this list <em>yet</em>.
```


#### 2.2.15 Evitando erros de renderização dupla

Mais cedo ou mais tarde, a maioria dos desenvolvedores Rails verá a mensagem de erro "Só pode renderizar ou redirecionar uma vez por ação". Embora isso seja irritante, é relativamente fácil de corrigir. Geralmente isso acontece devido a um mal-entendido fundamental sobre o modo como funciona `render`.

Por exemplo, aqui está um código que irá desencadear este erro:

```rb
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
  render action: "regular_show"
end
```

Se `@book.special?` for avaliado como `true`, o Rails iniciará o processo de renderização para despejar a variável `@book` na visualização `special_show`. Mas isso não impedirá a execução do restante do código na ação `show` e, quando o Rails chegar ao final da ação, ele começará a renderizar a visualização da `regular_show`  e gerará um erro. A solução é simples: certifique-se de ter apenas uma chamada `render` ou `redirect` em um único caminho de código. Uma coisa que pode ajudar é return. Aqui está uma versão corrigida do método:

```rb
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
    return
  end
  render action: "regular_show"
end
```

Observe que a renderização implícita feita pelo ActionController detecta se `render` foi chamada, portanto o seguinte funcionará sem erros:

```rb
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
end
```

Isso renderizará um livro `special?` definido com o modelo `special_show`, enquanto outros livros serão renderizados com o modelo `show` padrão.


### 2.3 Usando `redirect_to`

 Outra maneira de lidar com o retorno de respostas a uma solicitação HTTP é com `redirect_to`. Como você viu, `render` informa ao Rails qual view (ou outro ativo) usar na construção de uma resposta. O método `redirect_to` faz algo completamente diferente: diz ao navegador para enviar uma nova solicitação para uma URL diferente. Por exemplo, você pode redirecionar de qualquer lugar em seu código para o índice de fotos em seu aplicativo com esta chamada:

```rb
redirect_to photos_url
```

Você pode usar `redirect_back` para retornar o usuário à página de onde acabou de sair. Esse local é extraído do cabeçalho `HTTP_REFERER` e não há garantia de que seja definido pelo navegador, portanto, você deve fornecer o `fallback_location` para usar neste caso.

```rb
redirect_back(fallback_location: root_path)
```

![Layout and Redering in Rails - respostas](/imagens/layout_rendering_rails11.JPG)



#### 2.3.1 Obtendo um código de status de redirecionamento diferente

Rails usa o código de status HTTP 302, um redirecionamento temporário, quando você chama redirect_to. Se quiser usar um código de status diferente, talvez 301, um redirecionamento permanente, você pode usar a opção `:status`:

```rb
redirect_to photos_path, status: 301
```

Assim como a opção `:status` for `render`, `:status` for `redirect_to` aceita designações de cabeçalho numéricas e simbólicas.

#### 2.3.2 A diferença entre `render` e `redirect_to`

Às vezes, desenvolvedores inexperientes pensam nisso `redirect_to` como uma espécie de comando `goto`, movendo a execução de um lugar para outro no seu código Rails. Isso não está correto. Seu código para de ser executado e aguarda uma nova solicitação do navegador. Acontece que você informou ao navegador qual solicitação ele deveria fazer em seguida, enviando de volta um código de status HTTP 302.

Considere estas ações para ver a diferença:

```rb
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    render action: "index"
  end
end
```

Com o código neste formato, provavelmente haverá um problema se a variável `@book` for `nil`. Lembre-se de que a `render :action` não executa nenhum código na ação de destino, portanto nada configurará a variável `@books` que a visualização `index` provavelmente exigirá. Uma maneira de corrigir isso é redirecionar em vez de renderizar:

```rb
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    redirect_to action: :index
  end
end
```

Com este código, o navegador fará uma nova solicitação para a página de índice, o código do método `index` será executado e tudo ficará bem.

A única desvantagem desse código é que ele requer uma viagem de ida e volta ao navegador: o navegador solicitou a ação show with `/books/1` e o controlador descobre que não há livros, então o controlador envia uma resposta de redirecionamento 302 ao navegador informando-o para ir para `/books/`, o navegador obedece e envia uma nova solicitação de volta ao controlador solicitando agora a ação `index`, o controlador então obtém todos os livros no banco de dados e renderiza o modelo de índice, enviando-o de volta ao navegador que o mostra na tela .

Embora em um aplicativo pequeno essa latência adicional possa não ser um problema, é algo a se pensar se o tempo de resposta for uma preocupação. Podemos demonstrar uma maneira de lidar com isso com um exemplo inventado:

```rb
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    @books = Book.all
    flash.now[:alert] = "Your book was not found"
    render "index"
  end
end
```

Isso detectaria que não há livros com o ID especificado, preencheria a variável `@books` de instância com todos os livros no modelo e, em seguida, renderizaria diretamente o modelo `index.html.erb`, retornando-o ao navegador com uma mensagem de alerta flash para informar ao usuário o que aconteceu.


### 2.4 Usando `head` para construir respostas somente de cabeçalho

O método `head` pode ser usado para enviar respostas apenas com cabeçalhos para o navegador. O método `head` aceita um número ou símbolo (ver tabela de referência ) representando um código de status HTTP. O argumento de opções é interpretado como um hash de nomes e valores de cabeçalho. Por exemplo, você pode retornar apenas um cabeçalho de erro:

```rb
head :bad_request
```

Isso produziria o seguinte cabeçalho:

```rb
HTTP/1.1 400 Bad Request
Connection: close
Date: Sun, 24 Jan 2010 12:15:53 GMT
Transfer-Encoding: chunked
Content-Type: text/html; charset=utf-8
X-Runtime: 0.013483
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

Ou você pode usar outros cabeçalhos HTTP para transmitir outras informações:

```rb
head :created, location: photo_path(@photo)
```

O que produziria:

```rb
HTTP/1.1 201 Created
Connection: close
Date: Sun, 24 Jan 2010 12:16:44 GMT
Transfer-Encoding: chunked
Location: /photos/1
Content-Type: text/html; charset=utf-8
X-Runtime: 0.083496
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```


## 3 Estruturação de Layouts

Quando o Rails renderiza uma view como resposta, ele faz isso combinando a view com o layout atual, usando as regras para encontrar o layout atual que foram abordadas anteriormente neste guia. Dentro de um layout, você tem acesso a três ferramentas para combinar diferentes partes da saída para formar a resposta geral:

- Tags de ativos
- `yield` e `content_for`
- Parciais

### 3.1 Auxiliares de tags de ativos

Os auxiliares de tags de ativos fornecem métodos para gerar HTML que vinculam visualizações a feeds, JavaScript, folhas de estilo, imagens, vídeos e áudios. Existem seis auxiliares de tags de ativos disponíveis no Rails:

- `auto_discovery_link_tag`
- `javascript_include_tag`
- `stylesheet_link_tag`
- `image_tag`
- `video_tag`
- `audio_tag`

Você pode usar essas tags em layouts ou outras visualizações, embora `auto_discovery_link_tag`, `javascript_include_tag`, e `stylesheet_link_tag`, sejam mais comumente usados ​​na seção `<head>` de um layout.

![Layout and Redering in Rails - layouts](/imagens/layout_rendering_rails12.JPG)


#### 3.1.1 Vinculando a feeds com o `auto_discovery_link_tag`

O auxiliar `auto_discovery_link_tag` cria HTML que a maioria dos navegadores e leitores de feed podem usar para detectar a presença de feeds RSS, Atom ou JSON. Ele leva o tipo de link ( `:rss`, `:atom`, ou `:json`), um hash de opções que são passadas para url_for e um hash de opções para a tag:

```rb
<%= auto_discovery_link_tag(:rss, {action: "feed"},
  {title: "RSS Feed"}) %>
```

Existem três opções de tags disponíveis para auto_discovery_link_tag:

- `:rel` especifica o valor `rel` no link. O valor padrão é "alternativo".
- `:type` especifica um tipo MIME explícito. Rails irá gerar um tipo MIME apropriado automaticamente.
- `:title` especifica o título do link. O valor padrão é o valor `:type` maiúsculo, por exemplo, "ATOM" ou "RSS".


#### 3.1.2 Vinculando a arquivos JavaScript com o `javascript_include_tag`

O auxiliar `javascript_include_tag` retorna uma tag `script` HTML para cada fonte fornecida.

Se você estiver usando Rails com o Asset Pipeline habilitado, este auxiliar irá gerar um link para `/assets/javascripts/` aquele `public/javascripts` que foi usado em versões anteriores do Rails. Esse link é então servido pelo pipeline de ativos.

Um arquivo JavaScript dentro de uma aplicação Rails ou motor Rails vai para um dos três locais: `app/assets`, `lib/assets` ou `vendor/assets`. Esses locais são explicados detalhadamente na seção Organização de ativos do Guia de pipeline de ativos.

Você pode especificar um caminho completo relativo à raiz do documento ou uma URL, se preferir. Por exemplo, para vincular a um arquivo JavaScript que está dentro de um diretório chamado `javascripts` dentro de um de `app/assets`, `lib/assets` ou `vendor/assets`, você faria o seguinte:

```rb
<%= javascript_include_tag "main" %>
```

Rails irá então gerar uma tag `script` como esta:

```rb
<script src='/assets/main.js'></script>
```

A solicitação para este ativo é então atendida pela gema Sprockets.

Para incluir vários arquivos como `app/assets/javascripts/main.js` e `app/assets/javascripts/columns.js` ao mesmo tempo:

```rb
<%= javascript_include_tag "main", "columns" %>
```

Para incluir `app/assets/javascripts/main.js` e `app/assets/javascripts/photos/columns.js`:

```rb
<%= javascript_include_tag "main", "/photos/columns" %>
```

Incluir `http://example.com/main.js`:

```rb
<%= javascript_include_tag "http://example.com/main.js" %>
```


#### 3.1.3 Vinculando a arquivos CSS com o `stylesheet_link_tag`

O auxiliar `stylesheet_link_tag` retorna uma tag `<link>` HTML para cada fonte fornecida.

Se você estiver usando Rails com o "Asset Pipeline" habilitado, este auxiliar irá gerar um link para `/assets/stylesheets/`. Este link é então processado pela gema Sprockets. Um arquivo de folha de estilo pode ser armazenado em um dos três locais: `app/assets`, `lib/assets` ou `vendor/assets`.

Você pode especificar um caminho completo relativo à raiz do documento ou um URL. Por exemplo, para vincular a um arquivo de folha de estilo que está dentro de um diretório chamado `stylesheets` dentro de `app/assets`, `lib/assets`, ou `vendor/assets`, você faria o seguinte:

```rb
<%= stylesheet_link_tag "main" %>
```

Para incluir `app/assets/stylesheets/main.css` e `app/assets/stylesheets/columns.css`:

```rb
<%= stylesheet_link_tag "main", "columns" %>
```

Para incluir `app/assets/stylesheets/main.css` e `app/assets/stylesheets/photos/columns.css`:

```rb
<%= stylesheet_link_tag "main", "photos/columns" %>
```

Incluir `http://example.com/main.css`:

```rb
<%= stylesheet_link_tag "http://example.com/main.css" %>
```

Por padrão, o `stylesheet_link_tag` cria links com `rel="stylesheet"`. Você pode substituir esse padrão especificando uma opção apropriada (`:rel`):

```rb
<%= stylesheet_link_tag "main_print", media: "print" %>
```


#### 3.1.4 Vinculando a imagens com o `image_tag`

O auxiliar `image_tag` cria uma tag `<img />` HTML para o arquivo especificado. Por padrão, os arquivos são carregados de `public/images`.

![Layout and Redering in Rails - tags](/imagens/layout_rendering_rails13.JPG)

```rb
<%= image_tag "header.png" %>
```

Você pode fornecer um caminho para a imagem, se desejar:
```rb
<%= image_tag "icons/delete.gif" %>
```
Você pode fornecer um hash de opções adicionais de HTML:

```rb
<%= image_tag "icons/delete.gif", {height: 45} %>
```

Você pode fornecer um texto alternativo para a imagem que será usado se o usuário tiver as imagens desativadas em seu navegador. Se você não especificar um texto alternativo explicitamente, o padrão será o nome do arquivo, em letras maiúsculas e sem extensão. Por exemplo, essas duas tags de imagem retornariam o mesmo código:

```rb
<%= image_tag "home.gif" %>
<%= image_tag "home.gif", alt: "Home" %>
```

Você também pode especificar uma tag de tamanho especial, no formato "{width}x{height}":

```rb
<%= image_tag "home.gif", size: "50x20" %>
```

Além das tags especiais acima, você pode fornecer um hash final de opções HTML padrão, como `:class`, `:id` ou `:name`:

```rb
<%= image_tag "home.gif", alt: "Go Home",
                          id: "HomeImage",
                          class: "nav_bar" %>
```


#### 3.1.5 Vinculando a vídeos com o `video_tag`

O auxiliar `video_tag` cria uma tag `<video>` HTML5 para o arquivo especificado. Por padrão, os arquivos são carregados de `public/videos`.

```rb
<%= video_tag "movie.ogg" %>
```

Produz

```rb
<video src="/videos/movie.ogg" />
```

Da mesma forma, `image_tag` você pode fornecer um caminho, absoluto ou relativo ao diretório `public/videos`. Além disso, você pode especificar a opção `size: "#{width}x#{height}"` como um arquivo `image_tag`. As tags de vídeo também podem ter qualquer uma das opções HTML especificadas no final ( `id`, `class` ...).

A tag de vídeo também oferece suporte a todas as opções `<video>` HTML por meio do hash de opções HTML, incluindo:

- `poster: "image_name.png"`, fornece uma imagem para colocar no lugar do vídeo antes de ele começar a ser reproduzido.
- `autoplay: true`, começa a reproduzir o vídeo no carregamento da página.
- `loop: true`, faz um loop no vídeo quando ele chega ao fim.
- `controls: true`, fornece controles fornecidos pelo navegador para o usuário interagir com o vídeo.
- `autobuffer: true`, o vídeo pré-carregará o arquivo para o usuário no carregamento da página.

Você também pode especificar vários vídeos para reprodução, passando uma série de vídeos para `video_tag`:

```rb
<%= video_tag ["trailer.ogg", "movie.ogg"] %>
```

Isso produzirá:

```rb
<video>
  <source src="/videos/trailer.ogg">
  <source src="/videos/movie.ogg">
</video>
```


#### 3.1.6 Vinculando arquivos de áudio com o `audio_tag`

O auxiliar `audio_tag` cria uma tag `<audio>` HTML5 para o arquivo especificado. Por padrão, os arquivos são carregados de `public/audios`.

```rb
<%= audio_tag "music.mp3" %>
```

Você pode fornecer um caminho para o arquivo de áudio, se desejar:

```rb
<%= audio_tag "music/first_song.mp3" %>
```

Você também pode fornecer um hash de opções adicionais, como `:id`, `:class`, etc.

Assim como o `video_tag`, o `audio_tag` tem opções especiais:

- `autoplay: true`, começa a reproduzir o áudio no carregamento da página
- `controls: true`, fornece controles fornecidos pelo navegador para o usuário interagir com o áudio.
- `autobuffer: true`, o áudio pré-carregará o arquivo para o usuário no carregamento da página.


### 3.2 Compreensão `yield`

Dentro do contexto de um layout, `yield` identifica uma seção onde o conteúdo da visualização deve ser inserido. A maneira mais simples de usar isso é ter um único arquivo `yield`, no qual é inserido todo o conteúdo da visualização que está sendo renderizada no momento:

```rb 
<html>
  <head>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

Você também pode criar um layout com diversas regiões de rendimento:

```rb
<html>
  <head>
  <%= yield :head %>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```
O corpo principal da visualização sempre será renderizado no arquivo yield. Para renderizar o conteúdo em um nomeado yield, você usa o método `content_for`.


### 3.3 Usando o Método `content_for`

O método `content_for` permite inserir conteúdo em um bloco `yield` nomeado em seu layout. Por exemplo, esta visualização funcionaria com o layout que você acabou de ver:

```rb
<% content_for :head do %>
  <title>A simple page</title>
<% end %>

<p>Hello, Rails!</p>
```

O resultado da renderização desta página no layout fornecido seria este HTML:

```rb
<html>
  <head>
  <title>A simple page</title>
  </head>
  <body>
  <p>Hello, Rails!</p>
  </body>
</html>
```

O content_formétodo é muito útil quando seu layout contém regiões distintas, como barras laterais e rodapés, que devem ter seus próprios blocos de conteúdo inseridos. Também é útil para inserir tags que carregam arquivos JavaScript ou CSS específicos da página no cabeçalho de um layout genérico.


### 3.4 Usando `Parcials`

Modelos parciais - geralmente chamados apenas de `"parcials"` - são outro dispositivo para dividir o processo de renderização em partes mais gerenciáveis. Com um `parcial`, você pode mover o código para renderizar uma parte específica de uma resposta para seu próprio arquivo.


#### 3.4.1 Nomeando Parcials

Para renderizar um parcial como parte de uma visualização, você usa o método `render` dentro da visualização:

```rb
<%= render "menu" %>
```

Isso renderizará um arquivo nomeado `_menu.html.erb` naquele ponto da visualização que está sendo renderizada. Observe o caractere de sublinhado inicial: as parciais são nomeadas com um sublinhado inicial para distingui-las das visualizações regulares, mesmo que sejam referidas sem o sublinhado. Isso vale mesmo quando você extrai uma parcial de outra pasta:

```rb
<%= render "application/menu" %>
```

Como os parciais de visualização dependem da mesma herança de modelo que os modelos e layouts, esse código extrairá o parcial de `app/views/application/_menu.html.erb`.


#### 3.4.2 Usando parciais para simplificar visualizações

Uma maneira de usar parciais é tratá-los como equivalentes a sub-rotinas: como uma forma de mover detalhes para fora de uma visualização para que você possa entender o que está acontecendo com mais facilidade. Por exemplo, você pode ter uma visualização parecida com esta:

```rb
<%= render "application/ad_banner" %>

<h1>Products</h1>

<p>Here are a few of our fine products:</p>
<%# ... %>

<%= render "application/footer" %>
```

Aqui, os parciais `_ad_banner.html.erb` e `_footer.html.erb` podem conter conteúdo compartilhado por muitas páginas do seu aplicativo. Você não precisa ver os detalhes dessas seções quando estiver se concentrando em uma página específica.

Conforme visto nas seções anteriores deste guia, `yield` é uma ferramenta muito poderosa para limpar seus layouts. Tenha em mente que é Ruby puro, então você pode usá-lo em quase qualquer lugar. Por exemplo, podemos usá-lo para secar definições de layout de formulário para vários recursos semelhantes:

- `users/index.html.erb`

```rb
<%= render "application/search_filters", search: @q do |form| %>
  <p>
    Name contains: <%= form.text_field :name_contains %>
  </p>
<% end %>
```

- `roles/index.html.erb`

```rb
<%= render "application/search_filters", search: @q do |form| %>
  <p>
    Title contains: <%= form.text_field :title_contains %>
  </p>
<% end %>
```

- `application/_search_filters.html.erb`

```rb
<%= form_with model: search do |form| %>
  <h1>Search form:</h1>
  <fieldset>
    <%= yield form %>
  </fieldset>
  <p>
    <%= form.submit "Search" %>
  </p>
<% end %>
```

![Layout and Redering in Rails - parcials](/imagens/layout_rendering_rails14.JPG)


#### 3.4.3 Layouts Parciais

Uma parcial pode usar seu próprio arquivo de layout, assim como uma visualização pode usar um layout. Por exemplo, você pode chamar um parcial assim:

```rb
<%= render partial: "link_area", layout: "graybar" %>
```

Isso procuraria um nome parcial `_link_area.html.erb` e o renderizaria usando o layout `_graybar.html.erb`. Observe que os layouts para parciais seguem a mesma nomenclatura de sublinhado inicial dos parciais regulares e são colocados na mesma pasta com o parcial ao qual pertencem (não na pasta `layouts` mestre).

Observe também que a especificação explícita `:partial` é necessária ao passar opções adicionais, como `:layout`.

#### 3.4.4 Passando Variáveis ​​Locais

Você também pode passar variáveis ​​locais para parciais, tornando-as ainda mais poderosas e flexíveis. Por exemplo, você pode usar esta técnica para reduzir a duplicação entre páginas novas e editadas, enquanto ainda mantém um pouco de conteúdo distinto:

- `new.html.erb`

```rb
<h1>New zone</h1>
<%= render partial: "form", locals: {zone: @zone} %>
```

- `edit.html.erb`

```rb
<h1>Editing zone</h1>
<%= render partial: "form", locals: {zone: @zone} %>
``` 

- `_form.html.erb`

```rb
<%= form_with model: zone do |form| %>
  <p>
    <b>Zone name</b><br>
    <%= form.text_field :name %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Embora a mesma parcial seja renderizada em ambas as visualizações, o auxiliar de envio do Action View retornará "Criar Zona" para a nova ação e "Atualizar Zona" para a ação de edição.

Para passar uma variável local para uma parcial apenas em casos específicos use o `local_assigns`.

- `index.html.erb`

```rb
<%= render user.articles %>
```

- `show.html.erb`

```rb
<%= render article, full: true %>
```

- `_article.html.erb`

```rb
<h2><%= article.title %></h2>

<% if local_assigns[:full] %>
  <%= simple_format article.body %>
<% else %>
  <%= truncate article.body %>
<% end %>
```

Desta forma é possível utilizar a parcial sem a necessidade de declarar todas as variáveis ​​locais.

Cada parcial também possui uma variável local com o mesmo nome da parcial (menos o sublinhado inicial). Você pode passar um objeto para esta variável local através da opção `:object`:

```rb
<%= render partial: "customer", object: @new_customer %>
```

Dentro da parcial `customer`, a variável `customer` será referenciada `@new_customer` na visualização pai.

Se você tiver uma instância de um modelo para renderizar em parcial, poderá usar uma sintaxe abreviada:

```rb
<%= render @customer %>
```

Supondo que a variável de instância `@customer` contenha uma instância do modelo `Customer`, isso será usado `_customer.html.erb` para renderizá-lo e passará a variável local `customer` para a parcial que se referirá à variável de instância `@customer` na visualização pai.


#### 3.4.5 Renderizando Coleções

Parciais são muito úteis na renderização de coleções. Quando você passa uma coleção para uma parcial através da opção `:collection`, a parcial será inserida uma vez para cada membro da coleção:

- `index.html.erb`

```rb
<h1>Products</h1>
<%= render partial: "product", collection: @products %>
```

- `_product.html.erb`

```rb
<p>Product Name: <%= product.name %></p>
```

Quando uma parcial é chamada com uma coleção pluralizada, as instâncias individuais da parcial têm acesso ao membro da coleção que está sendo renderizada por meio de uma variável nomeada após a parcial. Nesse caso, o parcial é `_product` e, dentro do `_product` parcial, você pode consultar `product` para obter a instância que está sendo renderizada.

Também existe uma abreviação para isso. Supondo que `@products` seja uma coleção de instâncias `Product`, você pode simplesmente escrever isso para `index.html.erb` produzir o mesmo resultado:

```rb
<h1>Products</h1>
<%= render @products %>
```

Rails determina o nome da parcial a ser usada observando o nome do modelo na coleção. Na verdade, você pode até criar uma coleção heterogênea e renderizá-la desta forma, e o Rails escolherá a parcial adequada para cada membro da coleção:

- `index.html.erb`

```rb
<h1>Contacts</h1>
<%= render [customer1, employee1, customer2, employee2] %>
```

- `customers/_customer.html.erb`

```rb
<p>Customer: <%= customer.name %></p>
```

- `employees/_employee.html.erb`

```rb
<p>Employee: <%= employee.name %></p>
```

Neste caso, Rails usará as parciais do cliente ou funcionário conforme apropriado para cada membro da coleção.

Caso a coleção esteja vazia, `render` retornará nulo, portanto deve ser bastante simples fornecer conteúdo alternativo.

```rb
<h1>Products</h1>
<%= render(@products) || "There are no products available." %>
```


#### 3.4.6 Variáveis ​​Locais

Para usar um nome de variável local personalizado na parcial, especifique a `:as` opção na chamada da parcial:

```rb
<%= render partial: "product", collection: @products, as: :item %>
```

Com essa mudança, você pode acessar uma instância da coleção `@products` como variável `item` local dentro da parcial.

Você também pode passar variáveis ​​locais arbitrárias para qualquer parcial que estiver renderizando com a opção `locals: {}`:

```rb
<%= render partial: "product", collection: @products,
           as: :item, locals: {title: "Products Page"} %>
```

Neste caso, o parcial terá acesso a uma variável local `title` com o valor “Página de Produtos”.


### 3.4.7 Variáveis ​​de Contador

O Rails também disponibiliza uma variável de contador dentro de uma parcial chamada pela coleção. A variável recebe o nome do título da parcial seguido de _counter. Por exemplo, ao renderizar uma coleção `@products` o parcial `_product.html.erb` pode acessar a variável `product_counter`. A variável indexa o número de vezes que a parcial foi renderizada na visualização envolvente, começando com um valor `0` na primeira renderização.

```rb
# index.html.erb
<%= render partial: "product", collection: @products %>
```

```rb
# _product.html.erb
<%= product_counter %> # 0 for the first product, 1 for the second product...
```

Isto também funciona quando o nome parcial é alterado usando a opção `as:`. Então, se você fizesse isso `as: :item`, a variável do contador seria `item_counter`.


#### 3.4.8 Modelos de espaçadores

Você também pode especificar uma segunda parcial a ser renderizada entre instâncias da parcial principal usando a opção  `:spacer_template`:

```rb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Rails renderizará a parcial `_product_ruler` (sem dados passados) entre cada par de parciais `_product`.


#### 3.4.9 Layouts Parciais de Coleção

Ao renderizar coleções também é possível utilizar a opção `:layout`:

```rb
<%= render partial: "product", collection: @products, layout: "special_layout" %>
```

O layout será renderizado junto com o parcial de cada item da coleção. As variáveis ​​​​objeto atual e object_counter também estarão disponíveis no layout, da mesma forma que estão no parcial.


### 3.5 Usando layouts aninhados

Você pode descobrir que seu aplicativo requer um layout ligeiramente diferente do layout normal do aplicativo para suportar um controlador específico. Em vez de repetir o layout principal e editá-lo, você pode fazer isso usando layouts aninhados (às vezes chamados de submodelos). Aqui está um exemplo:

Suponha que você tenha o seguinte layout `ApplicationController`:

- `app/views/layouts/application.html.erb`

```rb
<html>
<head>
  <title><%= @page_title or "Page Title" %></title>
  <%= stylesheet_link_tag "layout" %>
  <style><%= yield :stylesheets %></style>
</head>
<body>
  <div id="top_menu">Top menu items here</div>
  <div id="menu">Menu items here</div>
  <div id="content"><%= content_for?(:content) ? yield(:content) : yield %></div>
</body>
</html>
```

Nas páginas geradas por `NewsController`, você deseja ocultar o menu superior e adicionar um menu à direita:

- `app/views/layouts/news.html.erb`

```rb
<% content_for :stylesheets do %>
  #top_menu {display: none}
  #right_menu {float: right; background-color: yellow; color: black}
<% end %>
<% content_for :content do %>
  <div id="right_menu">Right menu items here</div>
  <%= content_for?(:news_content) ? yield(:news_content) : yield %>
<% end %>
<%= render template: "layouts/application" %>
```

É isso. As visualizações Notícias usarão o novo layout, ocultando o menu superior e adicionando um novo menu à direita dentro da div "conteúdo".

Existem várias maneiras de obter resultados semelhantes com diferentes esquemas de submodelagem usando esta técnica. Observe que não há limite nos níveis de aninhamento. Pode-se usar o método `ActionView::render` via `render template: 'layouts/news'` para basear um novo layout no layout Notícias. Se tiver certeza de que não irá submodelar o layout `News`, você pode substituir o `content_for?(:news_content) ? yield(:news_content) : yield` por simplesmente `yield`.