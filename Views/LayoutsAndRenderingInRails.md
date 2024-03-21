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

