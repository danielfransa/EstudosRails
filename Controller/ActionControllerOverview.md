# Action Controller Overview


1 O que um controlador faz?

Action Controller é o C em MVC . Depois que o roteador determinar qual controlador usar para uma solicitação, o controlador será responsável por dar sentido à solicitação e produzir a saída apropriada. Felizmente, o Action Controller faz a maior parte do trabalho de base para você e usa convenções inteligentes para tornar isso o mais simples possível.

Para a maioria dos aplicativos RESTful convencionais , o controlador receberá a solicitação (isso é invisível para você como desenvolvedor), buscará ou salvará dados de um modelo e usará uma visualização para criar a saída HTML. Se o seu controlador precisa fazer as coisas de maneira um pouco diferente, isso não é um problema, esta é apenas a maneira mais comum de um controlador funcionar.

Um controlador pode, portanto, ser pensado como um intermediário entre modelos e visualizações. Ele disponibiliza os dados do modelo para a visualização, para que possa exibi-los ao usuário e salva ou atualiza os dados do usuário no modelo.

![Action Controller Overview ](/imagens/action_controller_overview1.JPG)


## 2 Convenção de Nomenclatura de Controlador

A convenção de nomenclatura dos controladores no Rails favorece a pluralização da última palavra do nome do controlador, embora não seja estritamente obrigatória (por exemplo, `ApplicationController`). Por exemplo, `ClientsController` é preferível a `ClientController`, `SiteAdminsController` é preferível a `SiteAdminController` ou `SitesAdminsController` e assim por diante.

Seguir esta convenção permitirá que você use os geradores de rota padrão (por exemplo `resources`, , etc) sem a necessidade de qualificar cada um `:path` ou `:controller`, e manterá o uso dos auxiliares de rota nomeados consistente em todo o seu aplicativo. [Consulte Guia de Layouts e Renderização](https://guides.rubyonrails.org/layouts_and_rendering.html) para obter mais detalhes.

![Action Controller Overview ](/imagens/action_controller_overview2.JPG)


## 3 métodos e ações

Um controlador é uma classe Ruby que herda `ApplicationController` e possui métodos como qualquer outra classe. Quando sua aplicação recebe uma solicitação, o roteamento determinará qual controlador e ação executar, então o Rails cria uma instância desse controlador e executa o método com o mesmo nome da ação.

```rb
class ClientsController < ApplicationController
  def new
  end
end
```

Por exemplo, se um usuário acessar `/clients/new` sua aplicação para adicionar um novo cliente, o Rails criará uma instância `ClientsController` e chamará seu método `new`. Observe que o método vazio do exemplo acima funcionaria perfeitamente porque o Rails irá, por padrão, renderizar a visualização `new.html.erb`, a menos que a ação indique o contrário. Ao criar um new `Client`, o método `new` pode tornar uma variável `@client` de instância acessível na view:

```rb
def new
  @client = Client.new
end
```

O [Guia de Layouts e Renderização](https://guides.rubyonrails.org/layouts_and_rendering.html) explica isso com mais detalhes.

`ApplicationController` herda de `ActionController::Base`, que define vários métodos úteis. Este guia abordará alguns deles, mas se você estiver curioso para ver o que está lá, poderá ver todos eles na [documentação da API](https://api.rubyonrails.org/v7.1.3.2/classes/ActionController.html) ou no próprio código-fonte.


Somente métodos públicos podem ser chamados como ações. É uma prática recomendada diminuir a visibilidade de métodos (com `private` ou `protected`) que não se destinam a ser ações, como métodos auxiliares ou filtros.

![Action Controller Overview ](/imagens/action_controller_overview3.JPG)


## 4 parâmetros

Você provavelmente desejará acessar os dados enviados pelo usuário ou outros parâmetros nas ações do seu controlador. Existem dois tipos de parâmetros possíveis em uma aplicação web. Os primeiros são parâmetros enviados como parte da URL, chamados parâmetros de string de consulta. A string de consulta é tudo depois de "?" na URL. O segundo tipo de parâmetro é geralmente chamado de dados POST. Essas informações geralmente vêm de um formulário HTML preenchido pelo usuário. São chamados de dados POST porque só podem ser enviados como parte de uma solicitação HTTP POST. Rails não faz nenhuma distinção entre parâmetros de string de consulta e parâmetros POST, e ambos estão disponíveis no hash `params`  do seu controlador:

```rb
class ClientsController < ApplicationController
  # This action uses query string parameters because it gets run
  # by an HTTP GET request, but this does not make any difference
  # to how the parameters are accessed. The URL for
  # this action would look like this to list activated
  # clients: /clients?status=activated
  def index
    if params[:status] == "activated"
      @clients = Client.activated
    else
      @clients = Client.inactivated
    end
  end

  # This action uses POST parameters. They are most likely coming
  # from an HTML form that the user has submitted. The URL for
  # this RESTful request will be "/clients", and the data will be
  # sent as part of the request body.
  def create
    @client = Client.new(params[:client])
    if @client.save
      redirect_to @client
    else
      # This line overrides the default rendering behavior, which
      # would have been to render the "create" view.
      render "new"
    end
  end
end
```


### 4.1 Parâmetros de hash e array

O hash `params` não está limitado a chaves e valores unidimensionais. Ele pode conter matrizes e hashes aninhados. Para enviar uma matriz de valores, acrescente um par vazio de colchetes "[]" ao nome da chave:

```rb
GET /clients?ids[]=1&ids[]=2&ids[]=3
```

![Action Controller Overview ](/imagens/action_controller_overview4.JPG)

O valor de `params[:ids]` será agora `["1", "2", "3"]`. Observe que os valores dos parâmetros são sempre strings; Rails não tenta adivinhar ou lançar o tipo.

![Action Controller Overview ](/imagens/action_controller_overview5.JPG)

Para enviar um hash, você inclui o nome da chave entre colchetes:

```html
<form accept-charset="UTF-8" action="/clients" method="post">
  <input type="text" name="client[name]" value="Acme" />
  <input type="text" name="client[phone]" value="12345" />
  <input type="text" name="client[address][postcode]" value="12345" />
  <input type="text" name="client[address][city]" value="Carrot City" />
</form>
```

Quando este formulário for enviado, o valor de `params[:client]` será `{ "name" => "Acme", "phone" => "12345", "address" => { "postcode" => "12345", "city" => "Carrot City" } }`. Observe o hash aninhado em `params[:client][:address]`.

O objeto `params` atua como um Hash, mas permite usar símbolos e strings como chaves.


### 4.2 Parâmetros JSON

Se seu aplicativo expõe uma API, é provável que você aceite parâmetros no formato JSON. Se o cabeçalho "Content-Type" da sua solicitação estiver definido como "application/json", o Rails carregará automaticamente seus parâmetros no hash `params`, que você pode acessar normalmente.

Por exemplo, se você estiver enviando este conteúdo JSON:

```json
{ "company": { "name": "acme", "address": "123 Carrot Street" } }
```

Seu controlador receberá `params[:company]` como `{ "name" => "acme", "address" => "123 Carrot Street" }`.

Além disso, se você ativou `config.wrap_parameters` seu inicializador ou chamou seu controlador `wrap_parameters`, você pode omitir com segurança o elemento raiz no parâmetro JSON. Neste caso, os parâmetros serão clonados e agrupados com uma chave escolhida com base no nome do seu controlador. Portanto, a solicitação JSON acima pode ser escrita como:

```json
{ "name": "acme", "address": "123 Carrot Street" }
```

E, supondo que você esteja enviando os dados para `CompaniesController`, eles seriam agrupados na chave `:company` assim:

```rb
{ name: "acme", address: "123 Carrot Street", company: { name: "acme", address: "123 Carrot Street" } }
```

Você pode personalizar o nome da chave ou dos parâmetros específicos que deseja agrupar consultando a [documentação da API](https://api.rubyonrails.org/v7.1.3.2/classes/ActionController/ParamsWrapper.html).

![Action Controller Overview ](/imagens/action_controller_overview6.JPG)


### 4.3 Parâmetros de Roteamento

O hash `params` sempre conterá as chaves `:controller` e `:action`, mas você deve usar os métodos `controller_name` e `action_name` para acessar esses valores. Quaisquer outros parâmetros definidos pelo roteamento, como `:id`, também estarão disponíveis. Como exemplo, considere uma listagem de clientes onde a lista pode mostrar clientes ativos ou inativos. Podemos adicionar uma rota que capture o parâmetro `:status` em uma URL "bonita":

```rb
get '/clients/:status', to: 'clients#index', foo: 'bar'
```

Neste caso, quando um usuário abrir a URL `/clients/active`, `params[:status]` ela será definida como "ativa". Quando esta rota for utilizada, `params[:foo]` também será definido como "bar", como se tivesse sido passado na string de consulta. Seu controlador também receberá `params[:action]` como “índice” e `params[:controller]` como “clientes”.

### 4.4 Parâmetros Chave Compostos

Os parâmetros de chave composta contêm vários valores em um parâmetro. Por esse motivo, precisamos extrair cada valor e passá-los para o Active Record. Podemos aproveitar o método `extract_value` para este caso de uso.

Dado o seguinte controlador:

```rb
class BooksController < ApplicationController
  def show
    # Extract the composite ID value from URL parameters.
    id = params.extract_value(:id)
    # Find the book using the composite ID.
    @book = Book.find(id)
    # use the default rendering behaviour to render the show view.
  end
end
```

E o seguinte percurso:


```rb
get '/books/:id', to: 'books#show'
```

Quando um usuário abre o URL `/books/4_2`, o controlador extrairá o valor da chave composta `["4", "2"]` e o transmitirá `Book.find` para renderizar o registro correto na visualização. O método `extract_value` pode ser usado para extrair matrizes de quaisquer parâmetros delimitados.

## 4.5 default_url_options

Você pode definir parâmetros padrão globais para geração de URL definindo um método chamado `default_url_option` sem seu controlador. Tal método deve retornar um hash com os padrões desejados, cujas chaves devem ser símbolos:

```rb
class ApplicationController < ActionController::Base
  def default_url_options
    { locale: I18n.locale }
  end
end
```

Essas opções serão usadas como ponto de partida na geração de URLs, portanto é possível que sejam substituídas pelas opções passadas para chamadas `url_for`.

Se você definir `default_url_options` em `ApplicationController`, como no exemplo acima, esses padrões serão usados ​​para toda geração de URL. O método também pode ser definido em um controlador específico, caso em que afeta apenas as URLs ali geradas.

Em uma determinada solicitação, o método não é realmente chamado para cada URL gerada. Por motivos de desempenho, o hash retornado é armazenado em cache e há no máximo uma invocação por solicitação.

### 4.6 Parâmetros Fortes

Com parâmetros fortes, os parâmetros do Action Controller são proibidos de serem usados ​​em atribuições de massa do Modelo Ativo até que sejam permitidos. Isso significa que você terá que tomar uma decisão consciente sobre quais atributos permitir a atualização em massa. Esta é uma prática de segurança melhor para ajudar a evitar permitir acidentalmente que os usuários atualizem atributos confidenciais do modelo.

Além disso, os parâmetros podem ser marcados como necessários e fluirão através de um fluxo de aumento/resgate predefinido que resultará no retorno de uma Solicitação Inválida 400 se nem todos os parâmetros necessários forem passados.

```rb
class PeopleController < ActionController::Base
  # This will raise an ActiveModel::ForbiddenAttributesError exception
  # because it's using mass assignment without an explicit permit
  # step.
  def create
    Person.create(params[:person])
  end

  # This will pass with flying colors as long as there's a person key
  # in the parameters, otherwise it'll raise an
  # ActionController::ParameterMissing exception, which will get
  # caught by ActionController::Base and turned into a 400 Bad
  # Request error.
  def update
    person = current_account.people.find(params[:id])
    person.update!(person_params)
    redirect_to person
  end

  private
    # Using a private method to encapsulate the permissible parameters
    # is just a good pattern since you'll be able to reuse the same
    # permit list between create and update. Also, you can specialize
    # this method with per-user checking of permissible attributes.
    def person_params
      params.require(:person).permit(:name, :age)
    end
end
```


#### 4.6.1 Valores escalares permitidos

Ligando `permit` como:

```rb
params.permit(:id)
```

permite a inclusão da chave especificada ( ) `:id` se ela aparecer `params` e tiver um valor escalar permitido associado. Caso contrário, a chave será filtrada, portanto, arrays, hashes ou quaisquer outros objetos não poderão ser injetados.

Os tipos escalares permitidos são `String`, `Symbol`, `NilClass`, `Numeric`, `TrueClass`, `FalseClass`, `Date`, `Time`, `DateTime`, `StringIO`, `IO`, `ActionDispatch::Http::UploadedFile`, e `Rack::Test::UploadedFile`.

Para declarar que o valor em `params` deve ser um array de valores escalares permitidos, mapeie a chave para um array vazio:

```rb
params.permit(id: [])
```

Às vezes não é possível ou conveniente declarar as chaves válidas de um parâmetro hash ou sua estrutura interna. Basta mapear para um hash vazio:

```rb
params.permit(preferences: {})
```

mas tenha cuidado porque isso abre a porta para entradas arbitrárias. Nesse caso, `permit` garante que os valores na estrutura retornada sejam escalares permitidos e filtra qualquer outra coisa.

Para permitir um hash inteiro de parâmetros, o método `permit!` pode ser usado:

```rb
params.require(:log_entry).permit!
```

Isso marca o `:log_entry ` hash dos parâmetros e qualquer sub-hash dele como permitido e não verifica os escalares permitidos, qualquer coisa é aceita. Deve-se ter extremo cuidado ao usar `permit!`, pois permitirá que todos os atributos atuais e futuros do modelo sejam atribuídos em massa.

#### 4.6.2 Parâmetros aninhados

Você também pode usar parâmetros `permit` aninhados, como:

```rb
params.permit(:name, { emails: [] },
              friends: [ :name,
                         { family: [ :name ], hobbies: [] }])
```

Esta declaração permite os atributos `name`, `emails` e `friends` . Espera-se que `emails` seja uma matriz de valores escalares permitidos e que `friends` seja uma matriz de recursos com atributos específicos: eles devem ter um atributo `name` (quaisquer valores escalares permitidos são permitidos), um atributo `hobbies` como uma matriz de valores escalares permitidos e um atributo `family` que está restrito a ter um `name`(quaisquer valores escalares permitidos também são permitidos aqui).

#### 4.6.3 Mais exemplos

Você também pode usar os atributos permitidos em sua ação `new`. Isso levanta o problema de que você não pode usar `require` a chave raiz porque, normalmente, ela não existe ao chamar `new`:

```rb
# using `fetch` you can supply a default and use
# the Strong Parameters API from there.
params.fetch(:blog, {}).permit(:title, :author)
```

O método da classe modelo `accepts_nested_attributes_for` permite atualizar e destruir registros associados. Isso se baseia nos parâmetros `id` e `_destroy` :

```rb
# permit :id and :_destroy
params.require(:author).permit(:name, books_attributes: [:title, :id, :_destroy])
```

Hashes com chaves inteiras são tratados de forma diferente e você pode declarar os atributos como se fossem filhos diretos. Você obtém esses tipos de parâmetros quando usa `accepts_nested_attributes_for` em combinação com uma das associação `has_many`:

```rb
# To permit the following data:
# {"book" => {"title" => "Some Book",
#             "chapters_attributes" => { "1" => {"title" => "First Chapter"},
#                                        "2" => {"title" => "Second Chapter"}}}}

params.require(:book).permit(:title, chapters_attributes: [:title])
```

Imagine um cenário em que você tem parâmetros que representam o nome de um produto e um hash de dados arbitrários associados a esse produto e deseja permitir o atributo do nome do produto e também todo o hash de dados:

```rb
def product_params
  params.require(:product).permit(:name, data: {})
end
```

#### 4.6.4 Fora do Escopo de Parâmetros Fortes

A API de parâmetros fortes foi projetada tendo em mente os casos de uso mais comuns. Não é uma solução mágica para lidar com todos os seus problemas de filtragem de parâmetros. No entanto, você pode combinar facilmente a API com seu próprio código para se adaptar à sua situação.


## 5 Sessão

Sua aplicação possui uma sessão para cada usuário na qual você pode armazenar pequenas quantidades de dados que serão persistidos entre as solicitações. A sessão está disponível apenas no controlador e na visualização e pode usar um dos vários mecanismos de armazenamento diferentes:

- `ActionDispatch::Session::CookieStore` - Armazena tudo no cliente.
- `ActionDispatch::Session::CacheStore` - Armazena os dados no cache Rails.
- `ActionDispatch::Session::MemCacheStore`- Armazena os dados em um cluster memcached (esta é uma implementação legada; considere usár `CacheStore`).
- `ActionDispatch::Session::ActiveRecordStore` - Armazena os dados em um banco de dados usando Active Record (requer a gem `activerecord-session_store`)
- Uma loja personalizada ou uma loja fornecida por uma gem de terceiros

Todos os armazenamentos de sessão usam um cookie para armazenar um ID exclusivo para cada sessão (você deve usar um cookie, o Rails não permitirá que você passe o ID da sessão na URL, pois isso é menos seguro).

Para a maioria das lojas, esse ID é usado para consultar os dados da sessão no servidor, por exemplo, em uma tabela de banco de dados. Há uma exceção: o armazenamento de sessão padrão e recomendado - o CookieStore - que armazena todos os dados da sessão no próprio cookie (o ID ainda estará disponível para você se precisar). Isso tem a vantagem de ser muito leve e não requer nenhuma configuração em um novo aplicativo para usar a sessão. Os dados do cookie são assinados criptograficamente para torná-los à prova de falsificação. E também é criptografado para que qualquer pessoa com acesso a ele não possa ler seu conteúdo. (Rails não aceitará se tiver sido editado).

A CookieStore pode armazenar cerca de 4 kB de dados – muito menos que as outras – mas isso geralmente é suficiente. O armazenamento de grandes quantidades de dados na sessão é desencorajado, independentemente do armazenamento de sessão usado pelo seu aplicativo. Você deve evitar especialmente armazenar objetos complexos (como instâncias de modelo) na sessão, pois o servidor pode não conseguir remontá-los entre solicitações, o que resultará em erro.

Se suas sessões de usuário não armazenam dados críticos ou não precisam permanecer disponíveis por longos períodos (por exemplo, se você usa apenas o flash para mensagens), considere usar o `ActionDispatch::Session::CacheStore`. Isso armazenará sessões usando a implementação de cache que você configurou para seu aplicativo. A vantagem disso é que você pode usar sua infraestrutura de cache existente para armazenar sessões sem precisar de nenhuma configuração ou administração adicional. A desvantagem, claro, é que as sessões serão efêmeras e poderão desaparecer a qualquer momento.

Leia mais sobre armazenamento de sessão no [Guia de segurança](https://guides.rubyonrails.org/security.html).

Se precisar de um mecanismo de armazenamento de sessão diferente, você pode alterá-lo em um inicializador:

```rb
Rails.application.config.session_store :cache_store
```

Consulte o guia de configuração `config.session_store` para obter mais informações.

Rails configura uma chave de sessão (o nome do cookie) ao assinar os dados da sessão. Eles também podem ser alterados em um inicializador:

```rb
# Be sure to restart your server when you modify this file.
Rails.application.config.session_store :cookie_store, key: '_your_app_session'
```

Você também pode passar uma chave `:domain` e especificar o nome de domínio do cookie:

```rb
# Be sure to restart your server when you modify this file.
Rails.application.config.session_store :cookie_store, key: '_your_app_session', domain: ".example.com"
```

Rails configura (para o CookieStore) uma chave secreta usada para assinar os dados da sessão em `config/credentials.yml.enc`. Isso pode ser alterado com `bin/rails credentials:edit`.

```rb
# aws:
#   access_key_id: 123
#   secret_access_key: 345

# Used as the base secret for all MessageVerifiers in Rails, including the one protecting cookies.
secret_key_base: 492f...
```

![Action Controller Overview ](/imagens/action_controller_overview7.JPG)


### 5.1 Acessando a Sessão

No seu controlador, você pode acessar a sessão através do método `session` de instância.

![Action Controller Overview ](/imagens/action_controller_overview8.JPG)

Os valores da sessão são armazenados usando pares chave/valor como um hash:

```rb
class ApplicationController < ActionController::Base
  private
    # Finds the User with the ID stored in the session with the key
    # :current_user_id This is a common way to handle user login in
    # a Rails application; logging in sets the session value and
    # logging out removes it.
    def current_user
      @_current_user ||= session[:current_user_id] &&
        User.find_by(id: session[:current_user_id])
    end
end
```

Para armazenar algo na sessão, basta atribuí-lo à chave como um hash:

```rb
class LoginsController < ApplicationController
  # "Create" a login, aka "log the user in"
  def create
    if user = User.authenticate(params[:username], params[:password])
      # Save the user ID in the session so it can be used in
      # subsequent requests
      session[:current_user_id] = user.id
      redirect_to root_url
    end
  end
end
```

Para remover algo da sessão, exclua o par chave/valor:

```rb
class LoginsController < ApplicationController
  # "Delete" a login, aka "log the user out"
  def destroy
    # Remove the user id from the session
    session.delete(:current_user_id)
    # Clear the memoized current user
    @_current_user = nil
    redirect_to root_url, status: :see_other
  end
end
```

Para redefinir a sessão inteira, use `reset_session`.


### 5.2 O Flash

O flash é uma parte especial da sessão que é apagada a cada solicitação. Isso significa que os valores armazenados ali só estarão disponíveis na próxima solicitação, o que é útil para passar mensagens de erro, etc.

O flash é acessado através do método `flash`. Assim como a sessão, o flash é representado como um hash.

Vamos usar o ato de sair como exemplo. O controlador pode enviar uma mensagem que será exibida ao usuário na próxima solicitação:

```rb
class LoginsController < ApplicationController
  def destroy
    session.delete(:current_user_id)
    flash[:notice] = "You have successfully logged out."
    redirect_to root_url, status: :see_other
  end
end
```

Observe que também é possível atribuir uma mensagem flash como parte do redirecionamento. Você pode atribuir `:notice` ou `:alert` de uso geral `:flash`:

```rb
redirect_to root_url, notice: "You have successfully logged out."
redirect_to root_url, alert: "You're stuck here!"
redirect_to root_url, flash: { referral_code: 1234 }
```

A ação `destroy` redireciona para o aplicativo da aplicação `root_url`, onde a mensagem será exibida. Observe que cabe inteiramente à próxima ação decidir o que fará com o que a ação anterior colocou no flash, se houver alguma coisa. É convencional exibir alertas de erro ou avisos do flash no layout do aplicativo:

```rb
<html>
  <!-- <head/> -->
  <body>
    <% flash.each do |name, msg| -%>
      <%= content_tag :div, msg, class: name %>
    <% end -%>

    <!-- more content -->
  </body>
</html>
```

Dessa forma, se uma ação definir um aviso ou mensagem de alerta, o layout irá exibi-lo automaticamente.

Você pode passar qualquer coisa que a sessão possa armazenar; você não está limitado a avisos e alertas:

```rb
<% if flash[:just_signed_up] %>
  <p class="welcome">Welcome to our site!</p>
<% end %>
```

Se você quiser que um valor flash seja transferido para outra solicitação, use `flash.keep`:

```rb
class MainController < ApplicationController
  # Let's say this action corresponds to root_url, but you want
  # all requests here to be redirected to UsersController#index.
  # If an action sets the flash and redirects here, the values
  # would normally be lost when another redirect happens, but you
  # can use 'keep' to make it persist for another request.
  def index
    # Will persist all flash values.
    flash.keep

    # You can also use a key to keep only some kind of value.
    # flash.keep(:notice)
    redirect_to users_url
  end
end
```


#### 5.2.1 flash.now

Por padrão, adicionar valores ao flash os disponibilizará para a próxima solicitação, mas às vezes você pode querer acessar esses valores na mesma solicitação. Por exemplo, se a ação `create` falhar ao salvar um recurso e você renderizar o modelo `new` diretamente, isso não resultará em uma nova solicitação, mas você ainda pode querer exibir uma mensagem usando o flash. Para fazer isso, você pode usar `flash.now` da mesma forma que usa o normal flash:

```rb
class ClientsController < ApplicationController
  def create
    @client = Client.new(client_params)
    if @client.save
      # ...
    else
      flash.now[:error] = "Could not save client"
      render action: "new"
    end
  end
end
```


## 6 Cookies

Seu aplicativo pode armazenar pequenas quantidades de dados no cliente - chamados cookies - que serão persistidos em solicitações e até mesmo em sessões. Rails fornece acesso fácil aos cookies através do método `cookies`, que - assim como o `session` - funciona como um hash:

```rb
class CommentsController < ApplicationController
  def new
    # Auto-fill the commenter's name if it has been stored in a cookie
    @comment = Comment.new(author: cookies[:commenter_name])
  end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      flash[:notice] = "Thanks for your comment!"
      if params[:remember_name]
        # Remember the commenter's name.
        cookies[:commenter_name] = @comment.author
      else
        # Delete cookie for the commenter's name cookie, if any.
        cookies.delete(:commenter_name)
      end
      redirect_to @comment.article
    else
      render action: "new"
    end
  end
end
```

Observe que, embora para valores de sessão você possa definir a chave como `nil`, para excluir um valor de cookie você deve usar `cookies.delete(:key)`.

Rails também fornece um cookie jar assinado e um cookie jar criptografado para armazenar dados confidenciais. O cookie jar assinado anexa uma assinatura criptográfica aos valores do cookie para proteger sua integridade. O cookie jar criptografado criptografa os valores, além de assiná-los, para que não possam ser lidos pelo usuário final. Consulte a [documentação da API](https://api.rubyonrails.org/v7.1.3.2/classes/ActionDispatch/Cookies.html) para obter mais detalhes.

Esses cookies especiais usam um serializador para serializar os valores atribuídos em strings e desserializá-los em objetos Ruby na leitura. Você pode especificar qual serializador usar via `config.action_dispatch.cookies_serializer`.

O serializador padrão para novos aplicativos é `:json`. Esteja ciente de que JSON tem suporte limitado para objetos Ruby de ida e volta. Por exemplo, `Date`, `Time` e objetos `Symbol` (incluindo chaves `Hash`) serão serializados e desserializados em `Strings`:

```rb
class CookiesController < ApplicationController
  def set_cookie
    cookies.encrypted[:expiration_date] = Date.tomorrow # => Thu, 20 Mar 2014
    redirect_to action: 'read_cookie'
  end

  def read_cookie
    cookies.encrypted[:expiration_date] # => "2014-03-20"
  end
end
```

Se precisar armazenar esses ou objetos mais complexos, pode ser necessário converter manualmente seus valores ao lê-los em solicitações subsequentes.

Se você usar o armazenamento de sessão de cookies, o acima também se aplica ao hash `session` e `flash`.


## 7 Renderização

ActionController facilita a renderização de dados HTML, XML ou JSON. Se você gerou um controlador usando scaffolding, seria algo assim:

```rb
class UsersController < ApplicationController
  def index
    @users = User.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @users }
      format.json { render json: @users }
    end
  end
end
```

Você pode notar no código acima que estamos usando `render xml: @users`, não `render xml: @users.to_xml`. Se o objeto não for uma String, o Rails irá invocar automaticamente `to_xml` para nós.

Você pode aprender mais sobre renderização no [Guia de Layouts e Renderização](https://guides.rubyonrails.org/layouts_and_rendering.html).


## 8 filtros

Filtros são métodos executados "antes", "depois" ou "em torno" de uma ação do controlador.

Os filtros são herdados, portanto, se você definir um filtro como `ApplicationController`, ele será executado em todos os controladores do seu aplicativo.

Os filtros "antes" são registrados via `before_action`. Eles podem interromper o ciclo de solicitação. Um filtro "antes" comum é aquele que requer que um usuário esteja logado para que uma ação seja executada. Você pode definir o método de filtro desta forma:

```rb
class ApplicationController < ActionController::Base
  before_action :require_login

  private
    def require_login
      unless logged_in?
        flash[:error] = "You must be logged in to access this section"
        redirect_to new_login_url # halts request cycle
      end
    end
end
```

O método simplesmente armazena uma mensagem de erro no flash e redireciona-a para o formulário de login se o usuário não estiver logado. Se um filtro "antes" for renderizado ou redirecionado, a ação não será executada. Se houver filtros adicionais programados para execução após esse filtro, eles também serão cancelados.

Neste exemplo, o filtro é adicionado `ApplicationController` e, portanto, todos os controladores do aplicativo o herdam. Isso fará com que tudo no aplicativo exija que o usuário esteja logado para utilizá-lo. Por razões óbvias (o usuário não conseguiria fazer login!), nem todos os controladores ou ações deveriam exigir isso. Você pode impedir que esse filtro seja executado antes de ações específicas com `skip_before_action`:

```rb
class LoginsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
end
```

Agora, os `LoginsController`'s as ações `new` e `create` funcionarão como antes, sem exigir que o usuário esteja logado. A opção `:only` é usada para pular esse filtro apenas para essas ações, e também existe uma opção `:except` que funciona ao contrário. Essas opções também podem ser usadas ao adicionar filtros, para que você possa adicionar um filtro que seja executado apenas para ações selecionadas.

![Action Controller Overview ](/imagens/action_controller_overview9.JPG)


### 8.1 Filtros posteriores e filtros adjacentes

Além dos filtros "antes", você também pode executar filtros após a execução de uma ação, ou antes e depois.

Os filtros "depois" são registrados via `after_action`. Eles são semelhantes aos filtros “antes”, mas como a ação já foi executada, eles têm acesso aos dados de resposta que estão prestes a ser enviados ao cliente. Obviamente, os filtros "depois" não podem impedir a execução da ação. Observe que os filtros "após" são executados somente após uma ação bem-sucedida, mas não quando uma exceção é gerada no ciclo de solicitação.

Os filtros "around" são registrados via `around_action`. Eles são responsáveis ​​por executar suas ações associadas cedendo, semelhante à forma como os middlewares Rack funcionam.

Por exemplo, em um site onde as alterações têm um fluxo de trabalho de aprovação, um administrador poderia visualizá-las facilmente aplicando-as em uma transação:

```rb
class ChangesController < ApplicationController
  around_action :wrap_in_transaction, only: :show

  private
    def wrap_in_transaction
      ActiveRecord::Base.transaction do
        begin
          yield
        ensure
          raise ActiveRecord::Rollback
        end
      end
    end
end
```

Observe que um filtro "ao redor" também envolve a renderização. Em particular, no exemplo acima, se a própria visão lê o banco de dados (por exemplo, através de um escopo), ela o fará dentro da transação e, assim, apresentará os dados para visualização.

Você pode optar por não ceder e construir a resposta sozinho; nesse caso, a ação não será executada.


### 8.2 Outras maneiras de usar filtros

Embora a maneira mais comum de usar filtros seja criando métodos privados e usando `before_action`, `after_action`, ou `around_action` para adicioná-los, existem duas outras maneiras de fazer a mesma coisa.

A primeira é usar um bloco diretamente com os métodos `*_action`. O bloco recebe o controlador como argumento. O filtro `require_login`  acima pode ser reescrito para usar um bloco:

```rb
class ApplicationController < ActionController::Base
  before_action do |controller|
    unless controller.send(:logged_in?)
      flash[:error] = "You must be logged in to access this section"
      redirect_to new_login_url
    end
  end
end
```

Observe que o filtro, neste caso, utiliza `send` porque o método `logged_in?` é privado, e o filtro não roda no escopo do controlador. Esta não é a forma recomendada de implementar este filtro específico, mas em casos mais simples, pode ser útil.

Especificamente para `around_action`, o bloco também produz `action`:

```rb
around_action { |_controller, action| time(&action) }
```

A segunda maneira é usar uma classe (na verdade, qualquer objeto que responda aos métodos corretos servirá) para lidar com a filtragem. Isto é útil em casos mais complexos e que não podem ser implementados de forma legível e reutilizável usando os outros dois métodos. Por exemplo, você poderia reescrever o filtro de login novamente para usar uma classe:

```rb
class ApplicationController < ActionController::Base
  before_action LoginFilter
end

class LoginFilter
  def self.before(controller)
    unless controller.send(:logged_in?)
      controller.flash[:error] = "You must be logged in to access this section"
      controller.redirect_to controller.new_login_url
    end
  end
end
```

Novamente, este não é um exemplo ideal para este filtro, porque ele não é executado no escopo do controlador, mas faz com que o controlador seja passado como argumento. A classe de filtro deve implementar um método com o mesmo nome do filtro, portanto, para o filtro `before_action`, a classe deve implementar um método `before` e assim por diante. O método `around` deve executar a ação `yield`.


## 9 Solicitar proteção contra falsificação

A falsificação de solicitação entre sites é um tipo de ataque em que um site engana um usuário para que ele faça solicitações em outro site, possivelmente adicionando, modificando ou excluindo dados desse site sem o conhecimento ou permissão do usuário.

O primeiro passo para evitar isso é garantir que todas as ações "destrutivas" (criar, atualizar e destruir) só possam ser acessadas com solicitações não GET. Se você está seguindo as convenções RESTful, você já está fazendo isso. No entanto, um site malicioso ainda pode enviar uma solicitação não GET para o seu site com bastante facilidade, e é aí que entra a proteção contra falsificação de solicitação. Como o nome diz, ela protege contra solicitações forjadas.

A maneira como isso é feito é adicionar um token não adivinhável que só é conhecido pelo seu servidor para cada solicitação. Dessa forma, se uma solicitação chegar sem o token adequado, o acesso será negado.

Se você gerar um formulário como este:

```rb
<%= form_with model: @user do |form| %>
  <%= form.text_field :username %>
  <%= form.text_field :password %>
<% end %>
```

Você verá como o token é adicionado como um campo oculto:

```html
<form accept-charset="UTF-8" action="/users/1" method="post">
<input type="hidden"
       value="67250ab105eb5ad10851c00a5621854a23af5489"
       name="authenticity_token"/>
<!-- fields -->
</form>
```

O Rails adiciona esse token a cada formulário gerado usando os `helpers de formulário` , então na maioria das vezes você não precisa se preocupar com isso. Se você estiver escrevendo um formulário manualmente ou precisar adicionar o token por outro motivo, ele estará disponível através do método `form_authenticity_token`:

O `form_authenticity_token` gera um token de autenticação válido. Isso é útil em locais onde o Rails não o adiciona automaticamente, como em chamadas personalizadas do Ajax.

O [Guia de Segurança](https://guides.rubyonrails.org/security.html) tem mais sobre isso e muitos outros problemas relacionados à segurança dos quais você deve estar ciente ao desenvolver um aplicativo da web.


## 10 Os objetos de solicitação e resposta

Em cada controlador, existem dois métodos acessadores que apontam para os objetos de solicitação e de resposta associados ao ciclo de solicitação que está atualmente em execução. O método `request` contém uma instância `ActionDispatch::Request` e `response` retorna um objeto de resposta representando o que será enviado de volta ao cliente.

### 10.1 O Objeto request

O objeto request contém muitas informações úteis sobre a solicitação vinda do cliente. Para obter uma lista completa dos métodos disponíveis, consulte a [documentação da API Rails](https://api.rubyonrails.org/v7.1.3.2/classes/ActionDispatch/Request.html) e [a documentação do Rack](https://www.rubydoc.info/github/rack/rack/Rack/Request). Entre as propriedades que você pode acessar neste objeto estão:

|Propriedade de `request` | Propósito |
| :--- | :--- |
| host |	O nome do host usado para esta solicitação. |
| domain(n=2) |	Os primeiros nsegmentos do nome do host, começando pela direita (o TLD). |
| format	| O tipo de conteúdo solicitado pelo cliente. |
| method	| O método HTTP usado para a solicitação. |
| get?, post?, patch?, put?, delete?,head? |	Retorna verdadeiro se o método HTTP for GET/POST/PATCH/PUT/DELETE/HEAD. | 
| headers	| Retorna um hash contendo os cabeçalhos associados à solicitação. |
| port	| O número da porta (inteiro) usado para a solicitação. |
| protocol |	Retorna uma string contendo o protocolo utilizado mais "://", por exemplo "http://". |
| query_string |	A string de consulta que faz parte do URL, ou seja, tudo depois de "?". | 
| remote_ip | O endereço IP do cliente. |
| url | O URL inteiro usado para a solicitação. |


#### 10.1.1 path_parameters, query_parameters, erequest_parameters

O Rails coleta todos os parâmetros enviados junto com a solicitação no hash `params`, sejam eles enviados como parte da string de consulta ou no corpo da postagem. O objeto request possui três acessadores que dão acesso a esses parâmetros dependendo de onde eles vieram. O hash `query_parameters` contém parâmetros que foram enviados como parte da string de consulta, enquanto o hash `request_parameters` contém parâmetros enviados como parte do corpo da postagem. O hash `path_parameters` contém parâmetros que foram reconhecidos pelo roteamento como parte do caminho que leva a esse controlador e ação específicos.


### 10.2 O Objeto response

O objeto de resposta geralmente não é usado diretamente, mas é construído durante a execução da ação e renderização dos dados que estão sendo enviados de volta ao usuário, mas às vezes - como em um filtro posterior - pode ser útil para acessar a resposta diretamente. Alguns desses métodos acessadores também possuem setters, permitindo alterar seus valores. Para obter uma lista completa dos métodos disponíveis, consulte a [documentação da API Rails](https://api.rubyonrails.org/v7.1.3.2/classes/ActionDispatch/Response.html) e a [documentação do Rack](https://www.rubydoc.info/github/rack/rack/Rack/Response).


| Propriedade de response	| Propósito |
| --- | --- |
| body | 	Esta é a sequência de dados que está sendo enviada de volta ao cliente. Geralmente é HTML. |
| status |	O código de status HTTP da resposta, como 200 para uma solicitação bem-sucedida ou 404 para arquivo não encontrado. |
| location |	A URL para a qual o cliente está sendo redirecionado, se houver. |
| content_type |	O tipo de conteúdo da resposta. |
| charset | 	O conjunto de caracteres que está sendo usado para a resposta. O padrão é "utf-8". |
| headers |	Cabeçalhos usados ​​para a resposta. |


### 10.2.1 Configurando cabeçalhos personalizados

Se você deseja definir cabeçalhos personalizados para uma resposta, este `response.headers` é o lugar para fazê-lo. O atributo headers é um hash que mapeia os nomes dos cabeçalhos para seus valores, e o Rails definirá alguns deles automaticamente. Se você deseja adicionar ou alterar um cabeçalho, basta atribuí-lo `response.headers` desta forma:

```rb
response.headers["Content-Type"] = "application/pdf"
```

![Action Controller Overview ](/imagens/action_controller_overview10.JPG)


## 11 Autenticações HTTP

Rails vem com três mecanismos de autenticação HTTP integrados:

- Autenticação Básica
- Autenticação resumida
- Autenticação de token

### 11.1 Autenticação Básica HTTP

A autenticação básica HTTP é um esquema de autenticação suportado pela maioria dos navegadores e outros clientes HTTP. Como exemplo, considere uma seção de administração que só estará disponível inserindo um nome de usuário e uma senha na janela de diálogo HTTP básico do navegador. O uso da autenticação integrada requer apenas o uso de um método, `http_basic_authenticate_with`.

```rb
class AdminsController < ApplicationController
  http_basic_authenticate_with name: "humbaba", password: "5baa61e4"
end
```

Com isso implementado, você pode criar controladores com namespace que herdam de `AdminsController`. O filtro será então executado para todas as ações nesses controladores, protegendo-os com autenticação básica HTTP.


## 11.2 Autenticação HTTP Digest

A autenticação digest HTTP é superior à autenticação básica, pois não exige que o cliente envie uma senha não criptografada pela rede (embora a autenticação básica HTTP seja segura em HTTPS). Usar a autenticação digest com Rails requer apenas o uso de um método, `authenticate_or_request_with_http_digest`.

```rb
class AdminsController < ApplicationController
  USERS = { "lifo" => "world" }

  before_action :authenticate

  private
    def authenticate
      authenticate_or_request_with_http_digest do |username|
        USERS[username]
      end
    end
end
```

Como visto no exemplo acima, o bloco `authenticate_or_request_with_http_digest` leva apenas um argumento – o nome de usuário. E o bloco retorna a senha. Retornar `false` ou `nil` de `authenticate_or_request_with_http_digest` causará falha na autenticação.

### 11.3 Autenticação de Token HTTP

A autenticação de token HTTP é um esquema para permitir o uso de tokens de portador no cabeçalho `Authorization` HTTP. Existem muitos formatos de token disponíveis e descrevê-los está fora do escopo deste documento.

Por exemplo, suponha que você queira usar um token de autenticação emitido antecipadamente para realizar autenticação e acesso. A implementação da autenticação de token com Rails requer apenas o uso de um método, `authenticate_or_request_with_http_token`.

```rb
class PostsController < ApplicationController
  TOKEN = "secret"

  before_action :authenticate

  private
    def authenticate
      authenticate_or_request_with_http_token do |token, options|
        ActiveSupport::SecurityUtils.secure_compare(token, TOKEN)
      end
    end
end
```

Como visto no exemplo acima, o bloco `authenticate_or_request_with_http_token` recebe dois argumentos - o `token` e a `Hash` contendo as opções que foram analisadas no cabeçalho HTTP `Authorization`. O bloco deverá retornar `true` se a autenticação for bem-sucedida. Retornar `false` ou `nil` sobre ele causará uma falha de autenticação.


## 12 Streaming e downloads de arquivos

Às vezes você pode querer enviar um arquivo ao usuário em vez de renderizar uma página HTML. Todos os controladores em Rails possuem os métodos `send_data` e `send_file`, que transmitirão dados para o cliente. `send_file` é um método conveniente que permite fornecer o nome de um arquivo no disco e transmitirá o conteúdo desse arquivo para você.

Para transmitir dados para o cliente, use `send_data`:

```rb
require "prawn"
class ClientsController < ApplicationController
  # Generates a PDF document with information on the client and
  # returns it. The user will get the PDF as a file download.
  def download_pdf
    client = Client.find(params[:id])
    send_data generate_pdf(client),
              filename: "#{client.name}.pdf",
              type: "application/pdf"
  end

  private
    def generate_pdf(client)
      Prawn::Document.new do
        text client.name, align: :center
        text "Address: #{client.address}"
        text "Email: #{client.email}"
      end.render
    end
end
```

A ação `download_pdf` no exemplo acima irá chamar um método privado que realmente gera o documento PDF e o retorna como uma string. Essa string será então transmitida para o cliente como um download de arquivo e um nome de arquivo será sugerido ao usuário. Às vezes, ao transmitir arquivos para o usuário, você pode não querer que ele baixe o arquivo. Veja imagens, por exemplo, que podem ser incorporadas em páginas HTML. Para informar ao navegador que um arquivo não deve ser baixado, você pode definir a opção `:disposition` como `"inline"`. O valor oposto e padrão para esta opção é `"anexo"`.

### 12.1 Envio de arquivos

Se quiser enviar um arquivo que já existe no disco, utilize o método `send_file`.

```rb
class ClientsController < ApplicationController
  # Stream a file that has already been generated and stored on disk.
  def download_pdf
    client = Client.find(params[:id])
    send_file("#{Rails.root}/files/clients/#{client.id}.pdf",
              filename: "#{client.name}.pdf",
              type: "application/pdf")
  end
end
```

Isso lerá e transmitirá o arquivo de 4 KB por vez, evitando carregar o arquivo inteiro na memória de uma só vez. Você pode desligar o streaming com a opção `:stream` ou ajustar o tamanho do bloco com a opção `:buffer_size`.

Se `:type` não for especificado, será calculado a partir da extensão de arquivo especificada em `:file` name. Se o tipo de conteúdo não estiver registrado para a extensão, `application/octet-stream` será utilizado.

![Action Controller Overview ](/imagens/action_controller_overview11.JPG)


### 12.2 Downloads RESTful

Embora `send_data` funcione bem, se você estiver criando um aplicativo RESTful, geralmente não é necessário ter ações separadas para downloads de arquivos. Na terminologia REST, o arquivo PDF do exemplo acima pode ser considerado apenas mais uma representação do recurso do cliente. Rails fornece uma maneira inteligente de fazer downloads “RESTful”. Veja como você pode reescrever o exemplo para que o download do PDF faça parte da ação `show`, sem qualquer streaming:

```rb
class ClientsController < ApplicationController
  # The user can request to receive this resource as HTML or PDF.
  def show
    @client = Client.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf { render pdf: generate_pdf(@client) }
    end
  end
end
```

Para que este exemplo funcione, você deve adicionar o tipo PDF MIME ao Rails. Isso pode ser feito adicionando a seguinte linha ao arquivo `config/initializers/mime_types.rb`:

```rb
Mime::Type.register "application/pdf", :pdf
```

![Action Controller Overview ](/imagens/action_controller_overview12.JPG)

Agora o usuário pode solicitar a versão PDF de um cliente apenas adicionando ".pdf" à URL:

```rb
GET /clients/1.pdf
```


### 12.3 Transmissão ao vivo de dados arbitrários

Rails permite transmitir mais do que apenas arquivos. Na verdade, você pode transmitir o que quiser em um objeto de resposta. O módulo `ActionController::Live` permite criar uma conexão persistente com um navegador. Usando este módulo, você poderá enviar dados arbitrários ao navegador em momentos específicos.


#### 12.3.1 Incorporando transmissão ao vivo

Incluir `ActionController::Live` dentro da sua classe de controlador fornecerá a todas as ações dentro do controlador a capacidade de transmitir dados. Você pode misturar o módulo assim:

```rb
class MyController < ActionController::Base
  include ActionController::Live

  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    100.times {
      response.stream.write "hello world\n"
      sleep 1
    }
  ensure
    response.stream.close
  end
end
```

O código acima manterá uma conexão persistente com o navegador e enviará 100 mensagens de `"hello world\n"`, cada uma com intervalo de um segundo.

Há algumas coisas a serem observadas no exemplo acima. Precisamos ter certeza de fechar o fluxo de resposta. Esquecer de fechar o stream deixará o soquete aberto para sempre. Também precisamos definir o tipo de conteúdo `text/event-stream` antes de gravar no fluxo de resposta. Isso ocorre porque os cabeçalhos não podem ser gravados após a confirmação da resposta (quando `response.committed?` retorna um valor verdadeiro), o que ocorre quando você `write` ou `commit` o fluxo de resposta.


#### 12.3.2 Exemplo de uso

Suponhamos que você esteja fazendo uma máquina de karaokê e um usuário queira obter a letra de uma música específica. Cada `Song` tem um determinado número de versos e cada verso leva tempo `num_beats` para terminar de ser cantado.

Se quiséssemos retornar a letra no estilo Karaokê (só enviando a linha quando o cantor terminar a linha anterior), poderíamos usar `ActionController::Live` o seguinte:

```rb
class LyricsController < ActionController::Base
  include ActionController::Live

  def show
    response.headers['Content-Type'] = 'text/event-stream'
    song = Song.find(params[:id])

    song.each do |line|
      response.stream.write line.lyrics
      sleep line.num_beats
    end
  ensure
    response.stream.close
  end
end
```

O código acima envia a próxima linha somente após o cantor completar a linha anterior.

#### 12.3.3 Considerações sobre streaming

O streaming de dados arbitrários é uma ferramenta extremamente poderosa. Conforme mostrado nos exemplos anteriores, você pode escolher quando e o que enviar em um fluxo de resposta. No entanto, você também deve observar o seguinte:

- Cada fluxo de resposta cria um novo thread e copia as variáveis ​​locais do thread do thread original. Ter muitas variáveis ​​locais de thread pode impactar negativamente o desempenho. Da mesma forma, um grande número de threads também pode prejudicar o desempenho.
- Deixar de fechar o fluxo de resposta deixará o soquete correspondente aberto para sempre. Certifique-se de ligar `close` sempre que estiver usando um fluxo de resposta.
- Os servidores WEBrick armazenam todas as respostas em buffer e, portanto, a inclusão `ActionController::Live` não funcionará. Você deve usar um servidor web que não armazene respostas em buffer automaticamente.


## 13 Filtragem de registros

Rails mantém um arquivo de log para cada ambiente na pasta `log`. Eles são extremamente úteis ao depurar o que realmente está acontecendo em seu aplicativo, mas em um aplicativo ativo você pode não querer que todas as informações sejam armazenadas no arquivo de log.


## 13.1 Filtragem de Parâmetros

Você pode filtrar parâmetros de solicitação confidenciais de seus arquivos de log anexando-os `config.filter_parameters` na configuração do aplicativo. Esses parâmetros serão marcados como [FILTERED] no log.

```rb
config.filter_parameters << :password
```

![Action Controller Overview ](/imagens/action_controller_overview13.JPG)


### 13.2 Filtragem de Redirecionamentos

Às vezes é desejável filtrar dos arquivos de log alguns locais confidenciais para os quais seu aplicativo está redirecionando. Você pode fazer isso usando a opção `config.filter_redirect` de configuração:

```rb
config.filter_redirect << 's3.amazonaws.com'
```

Você pode configurá-lo como String, Regexp ou uma matriz de ambos.

```rb
config.filter_redirect.concat ['s3.amazonaws.com', /private_path/]
```

Os URLs correspondentes serão marcados como '[FILTERED]'.


## 14 Resgate

Muito provavelmente seu aplicativo conterá bugs ou gerará uma exceção que precisa ser tratada. Por exemplo, se o usuário seguir um link para um recurso que não existe mais no banco de dados, o Active Record lançará a exceção `ActiveRecord::RecordNotFound`.

O tratamento de exceções padrão do Rails exibe uma mensagem "500 Server Error" para todas as exceções. Se a solicitação foi feita localmente, um bom rastreamento e algumas informações adicionais serão exibidos, para que você possa descobrir o que deu errado e lidar com isso. Se a solicitação for remota, o Rails exibirá apenas uma mensagem simples "500 Server Error" para o usuário, ou "404 Not Found" se houver um erro de roteamento ou um registro não puder ser encontrado. Às vezes, você pode querer personalizar como esses erros são detectados e como são exibidos ao usuário. Existem vários níveis de tratamento de exceções disponíveis em uma aplicação Rails:


### 14.1 Os modelos padrão 500 e 404

Por padrão, no ambiente de produção, o aplicativo renderizará uma mensagem de erro 404 ou 500. No ambiente de desenvolvimento, todas as exceções não tratadas são simplesmente levantadas. Essas mensagens estão contidas em arquivos HTML estáticos na pasta pública, em `404.html` e `500.html` respectivamente. Você pode personalizar esses arquivos para adicionar informações e estilo extras, mas lembre-se de que eles são HTML estático; ou seja, você não pode usar ERB, SCSS, CoffeeScript ou layouts para eles.

### 14.2 rescue_from

Se você quiser fazer algo um pouco mais elaborado ao capturar erros, você pode usar o `rescue_from`, que trata exceções de um determinado tipo (ou vários tipos) em um controlador inteiro e suas subclasses.

Quando ocorre uma exceção capturada por uma diretiva `rescue_from`, o objeto de exceção é passado para o manipulador. O manipulador pode ser um método ou um objeto `Proc` passado para a opção `:with`. Você também pode usar um bloco diretamente em vez de um objeto `Proc` explícito.

Veja como você pode interceptar todos os `rescue_from`  `ActiveRecord::RecordNotFounderros` e fazer algo com eles.

```rb
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private
    def record_not_found
      render plain: "404 Not Found", status: 404
    end
end
```

É claro que este exemplo é tudo menos elaborado e não melhora em nada o tratamento de exceções padrão, mas uma vez que você possa capturar todas essas exceções, você estará livre para fazer o que quiser com elas. Por exemplo, você pode criar classes de exceção personalizadas que serão lançadas quando um usuário não tiver acesso a uma determinada seção do seu aplicativo:

```rb
class ApplicationController < ActionController::Base
  rescue_from User::NotAuthorized, with: :user_not_authorized

  private
    def user_not_authorized
      flash[:error] = "You don't have access to this section."
      redirect_back(fallback_location: root_path)
    end
end

class ClientsController < ApplicationController
  # Check that the user has the right authorization to access clients.
  before_action :check_authorization

  # Note how the actions don't have to worry about all the auth stuff.
  def edit
    @client = Client.find(params[:id])
  end

  private
    # If the user is not authorized, just throw the exception.
    def check_authorization
      raise User::NotAuthorized unless current_user.admin?
    end
end
```

![Action Controller Overview ](/imagens/action_controller_overview14.JPG)


## 15 Forçar protocolo HTTPS

Se quiser garantir que a comunicação com o seu controlador só seja possível via HTTPS, você deve fazer isso habilitando o `ActionDispatch::SSL` middleware via `config.force_ssl` na configuração do seu ambiente.


## 16 Ponto final de verificação de integridade integrado

Rails também vem com um endpoint de verificação de integridade integrado que pode ser acessado no caminho `/up`. Este endpoint retornará um código de status 200 se o aplicativo tiver sido inicializado sem exceções, e um código de status 500 caso contrário.

Na produção, muitos aplicativos são obrigados a relatar seu status upstream, seja para um monitor de tempo de atividade que avisará um engenheiro quando algo der errado ou para um balanceador de carga ou controlador Kubernetes usado para determinar a integridade de um pod. Este exame de saúde foi projetado para ser um modelo único que funcionará em muitas situações.

Embora qualquer aplicativo Rails recém-gerado tenha a verificação de integridade em `/up`, você pode configurar o caminho como quiser em seu `"config/routes.rb"`:

```rb
Rails.application.routes.draw do
  get "healthz" => "rails/health#show", as: :rails_health_check
end
```

A verificação de integridade agora estará acessível através do caminho `/healthz`.

![Action Controller Overview ](/imagens/action_controller_overview15.JPG)

Pense cuidadosamente sobre o que você deseja verificar, pois isso pode levar a situações em que seu aplicativo seja reiniciado devido a problemas em um serviço de terceiros. Idealmente, você deve projetar seu aplicativo para lidar com essas interrupções normalmente.
