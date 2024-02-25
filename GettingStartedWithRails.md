# Getting Started with Rails

## Inicio

Rails é uma estrutura de aplicação web executada na linguagem de programação Ruby. Se você não tem experiência anterior com Ruby, encontrará uma curva de aprendizado muito íngreme mergulhando direto no Rails.

## O que é Rails

Rails é um framework de desenvolvimento de aplicações web escrito na linguagem de programação Ruby. Ele foi projetado para facilitar a programação de aplicativos da Web, fazendo suposições sobre o que todo desenvolvedor precisa para começar. Ele permite que você escreva menos código e realize mais do que muitas outras linguagens e estruturas. Desenvolvedores experientes do Rails também relatam que isso torna o desenvolvimento de aplicações web mais divertido.

Rails é um software opinativo. Ela pressupõe que existe uma “melhor” maneira de fazer as coisas e foi projetada para encorajar essa maneira – e em alguns casos, para desencorajar alternativas. Se você aprender "The Rails Way" provavelmente descobrirá um tremendo aumento na produtividade. Se você persistir em trazer velhos hábitos de outras linguagens para o seu desenvolvimento em Rails e tentar usar padrões que aprendeu em outros lugares, poderá ter uma experiência menos feliz.

A filosofia Rails inclui dois princípios orientadores principais:

**- Don't Repeat Yourself:**

Não se repita: DRY é um princípio de desenvolvimento de software que afirma que "Cada pedaço de conhecimento deve ter uma representação única, inequívoca e oficial dentro de um sistema". Ao não escrever as mesmas informações repetidamente, nosso código é mais sustentável, mais extensível e com menos erros.

**- Convention Over Configuration:**

Convenção sobre configuração: Rails tem opiniões sobre a melhor maneira de fazer muitas coisas em uma aplicação web, e o padrão é esse conjunto de convenções, em vez de exigir que você especifique minúcias através de infinitos arquivos de configuração.

## Criando um Novo Projeto Rails

Para Criar um novo projeto podemos digitar:

```bash
$ rails new blog
```

Isso criará um aplicativo Rails chamado Blog em um blogdiretório e instalará as dependências gem que já foram mencionadas no Gemfileuso do bundle install.

O blogdiretório terá vários arquivos e pastas gerados que compõem a estrutura de uma aplicação Rails. A maior parte do trabalho neste tutorial acontecerá na apppasta, mas aqui está um resumo básico da função de cada um dos arquivos e pastas que o Rails cria por padrão:

| Pasta de arquivo |        Propósito |
|---|---|
aplicativo/	|Contém os controladores, modelos, visualizações, auxiliares, mailers, canais, trabalhos e ativos para seu aplicativo. Você se concentrará nesta pasta no restante deste guia.|
|caixa/ |	Contém o railsscript que inicia seu aplicativo e pode conter outros scripts usados ​​para configurar, atualizar, implementar ou executar seu aplicativo. |
| configuração/	| Contém configuração para rotas, banco de dados e muito mais do seu aplicativo. Isso é abordado com mais detalhes em Configurando Aplicações Rails .|
| config.ru |	Configuração de rack para servidores baseados em rack usados ​​para iniciar a aplicação. Para obter mais informações sobre o Rack, consulte o site do Rack . |
| banco de dados/	| Contém o esquema de banco de dados atual, bem como as migrações de banco de dados. |
| Dockerfile |	Arquivo de configuração do Docker. |
| GemfileGemfile.lock _	| Esses arquivos permitem que você especifique quais dependências de gem são necessárias para sua aplicação Rails. Esses arquivos são usados ​​pela gem Bundler. Para obter mais informações sobre o Bundler, consulte o site do Bundler . |
| biblioteca/	| Módulos estendidos para sua aplicação. |
| registro/	| Arquivos de log do aplicativo. |
| público/	| Contém arquivos estáticos e ativos compilados. Quando seu aplicativo estiver em execução, esse diretório será exposto como está. |
| Arquivo Rake |	Este arquivo localiza e carrega tarefas que podem ser executadas na linha de comando. As definições de tarefas são definidas em todos os componentes do Rails. Em vez de alterar Rakefile, você deve adicionar suas próprias tarefas adicionando arquivos ao lib/tasks diretório do seu aplicativo. |
| README.md |	Este é um breve manual de instruções para sua aplicação. Você deve editar esse arquivo para informar aos outros o que seu aplicativo faz, como configurá-lo e assim por diante. |
| armazenar/ |	Arquivos de armazenamento ativo para serviço de disco. Isso é abordado em Visão geral do armazenamento ativo . |
| teste/ |	Testes unitários, acessórios e outros aparelhos de teste. Eles são abordados em Testando Aplicações Rails . |
| tmp/ |	Arquivos temporários (como arquivos de cache e pid). |
| fornecedor/ |	Um lugar para todos os códigos de terceiros. Em uma aplicação Rails típica, isso inclui joias vendidas. |
| .dockerignore	| Este arquivo informa ao Docker quais arquivos ele não deve copiar para o contêiner. |
| .gitattributes |	Este arquivo define metadados para caminhos específicos em um repositório git. Esses metadados podem ser usados ​​pelo git e outras ferramentas para melhorar seu comportamento. Consulte a documentação dos atributos gitattributes para obter mais informações. |
| .gitignore |	Este arquivo informa ao git quais arquivos (ou padrões) ele deve ignorar. Consulte GitHub – Ignorando arquivos para obter mais informações sobre como ignorar arquivos. |
| .ruby-versão |	Este arquivo contém a versão padrão do Ruby. |


## Olá Rails!

Rails já traz um servidor junto com ele e assim já temos um aplicativo fubncional só colocando o servidor no ar e para isso basta digitar:

```bash
$ rails server
```

Isso iniciará o Puma, um servidor web distribuído com Rails por padrão. Para ver seu aplicativo em ação, abra uma janela do navegador e navegue até http://localhost:3000 . Você deverá ver a página de informações padrão do Rails:

Para que o Rails diga "Olá", você precisa criar no mínimo uma rota , um controlador com uma ação e uma visualização . Uma rota mapeia uma solicitação para uma ação do controlador. Uma ação do controlador executa o trabalho necessário para tratar a solicitação e prepara todos os dados para a visualização. Uma visualização exibe dados em um formato desejado.

Em termos de implementação: Rotas são regras escritas em Ruby DSL (Domain-Specific Language) . Controladores são classes Ruby e seus métodos públicos são ações. E as visualizações são modelos, geralmente escritos em uma mistura de HTML e Ruby.

Vamos começar adicionando uma rota ao nosso arquivo de rotas, config/routes.rb, no topo do Rails.application.routes.drawbloco:

```ruby
Rails.application.routes.draw do
  get "/articles", to: "articles#index"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
```

A rota acima declara que GET /articlesas solicitações são mapeadas para a index ação de ArticlesController.

Para criar ArticlesControllere sua indexação, executaremos o gerador do controlador (com a --skip-routesopção porque já temos uma rota apropriada):

```bash
$ rails generate controller Articles index --skip-routes
```


Olhando nosso Controller:

```ruby
class ArticlesController < ApplicationController
  def index
  end
end
```
A indexação está vazia. Quando uma ação não renderiza explicitamente uma visualização (ou aciona uma resposta HTTP), o Rails renderizará automaticamente uma visualização que corresponda ao nome do controlador e da ação. Convenção sobre configuração! As visualizações estão localizadas no app/viewsdiretório. Portanto, a index ação será renderizada app/views/articles/index.html.erb por padrão.


## Carregamento Automático

Os aplicativos Rails não usam requirepara carregar o código do aplicativo.

Você deve ter notado que ArticlesControllerherda de ApplicationController, mas app/controllers/articles_controller.rbnão tem nada parecido

```bash
require "application_controller" # DON'T DO THIS.
 ```

 Classes e módulos de aplicativos estão disponíveis em qualquer lugar, você não precisa e não deve carregar nada appno require. Esse recurso é chamado de carregamento automático e você pode aprender mais sobre ele em Carregamento automático e Recarregamento de constantes .

Você só precisa requirede chamadas para dois casos de uso:

Para carregar arquivos no libdiretório.
Para carregar dependências de gem que possuem require: falseno arquivo Gemfile.

## MVC e você

O Rails Usa o Padrão MVC (Model-View-Controller)

MVC é um padrão de design que divide as responsabilidades de um aplicativo para facilitar o raciocínio. Rails segue esse padrão de design por convenção.

![Imagem Modelo MVC](imagens\mvc.JPG)

Para criar um modelo no Rails podemos usar:

```bash
$ rails generate model Article title:string body:text
```

![Nota para criação do Model](imagens\nota_model.JPG)


O comando acima alem de criar o model cria também migrations. 

As migrações são usadas para alterar a estrutura do banco de dados de um aplicativo. Em aplicações Rails, as migrações são escritas em Ruby para que possam ser independentes de banco de dados.

```ruby
class CreateArticles < ActiveRecord::Migration[7.1]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
```

A chamada para create_tableespecifica como a articlestabela deve ser construída. Por padrão, o create_tablemétodo adiciona uma idcoluna como uma chave primária de incremento automático. Portanto, o primeiro registro da tabela terá valor id1, o próximo registro terá valor id2 e assim por diante.

Dentro do bloco for create_table, duas colunas são definidas: titlee body. Eles foram adicionados pelo gerador porque os incluímos em nosso comando de geração ( bin/rails generate model Article title:string body:text).

Na última linha do bloco há uma chamada para t.timestamps. Este método define duas colunas adicionais denominadas created_ate updated_at. Como veremos, o Rails irá gerenciá-los para nós, definindo os valores quando criarmos ou atualizarmos um objeto de modelo.

A migration foi criada mas ainda não fez nada no nosso banco de dados para essas alterações surtirem efeito é necessário "rodar" essa migration com o comando abaixo:

```bash
$ rails db:migrate
```

O comando exibirá uma saída indicando que a tabela foi criada:

![Saída do comando db:migrate](imagens\saida_migrate.JPG)

Vamos voltar ao nosso controlador app/controllers/articles_controller.rbe alterar a indexação para buscar todos os artigos do banco de dados:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end
end
```

Variáveis ​​de instância do controlador podem ser acessadas pela visualização. Isso significa que podemos fazer referência @articlesem app/views/articles/index.html.erb. Vamos abrir esse arquivo e substituir seu conteúdo por:

```erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= article.title %>
    </li>
  <% end %>
</ul>

```

O código acima é uma mistura de HTML e ERB . ERB é um sistema de templates que avalia o código Ruby incorporado em um documento. Aqui, podemos ver dois tipos de tags ERB: <% %>e <%= %>. A <% %>tag significa "avaliar o código Ruby incluído". A <%= %>tag significa "avaliar o código Ruby incluído e gerar o valor que ele retorna". Qualquer coisa que você possa escrever em um programa Ruby normal pode ficar dentro dessas tags ERB, embora geralmente seja melhor manter o conteúdo das tags ERB curto, para facilitar a leitura.

Como não queremos gerar o valor retornado por @articles.each, incluímos esse código em <% %>. Mas, como queremos gerar o valor retornado por article.title(para cada artigo), incluímos esse código em <%= %>.

## CRUD Onde o CRUD é devido

Se eu quiser ver apenas 1 artigo preciso criar uma rota para isso:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
  get "/articles/:id", to: "articles#show"
end
```

A nova rota é outra get rota, mas tem algo a mais em seu caminho: :id. Isso designa um parâmetro de rota . Um parâmetro de rota captura um segmento do caminho da solicitação e coloca esse valor no params Hash, que é acessível pela ação do controlador. Por exemplo, ao tratar uma solicitação como GET http://localhost:3000/articles/1, 1 seria capturado como o valor de :id, que seria então acessível como params[:id] na ação show de ArticlesController.

Vamos adicionar essa ação show agora, abaixo da ação index em app/controllers/articles_controller.rb:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end
end
```

A show chama Article.find( mencionada anteriormente ) com o ID capturado pelo parâmetro de rota. O artigo retornado é armazenado na @article variável de instância, portanto é acessível pela visualização. Por padrão, a show será renderizada app/views/articles/show.html.erb.

Vamos criar um app/views/articles/show.html.erb

```erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>
```

Agora podemos ver o artigo quando visitarmos http://localhost:3000/articles/1 !


Para finalizar, vamos adicionar uma maneira conveniente de acessar a página de um artigo. Vincularemos o título de cada artigo app/views/articles/index.html.erbà sua página:

```erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="/articles/<%= article.id %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

Até agora, cobrimos o “R” (Leitura) do CRUD. Eventualmente, cobriremos o “C” (Criar), “U” (Atualizar) e “D” (Excluir). Como você deve ter adivinhado, faremos isso adicionando novas rotas, ações de controlador e visualizações. Sempre que tivermos essa combinação de rotas, ações de controlador e visualizações que funcionam juntas para realizar operações CRUD em uma entidade, chamamos essa entidade de recurso . Por exemplo, em nossa aplicação, diríamos que um artigo é um recurso.

Rails fornece um método de rotas chamado resources que mapeia todas as rotas convencionais para uma coleção de recursos, como artigos. Portanto, antes de prosseguirmos para as seções "C", "U" e "D", vamos substituir as duas get rotas config/routes.rb por resources:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles
end
```

O resources método também configura métodos auxiliares de URL e caminho que podemos usar para evitar que nosso código dependa de uma configuração de rota específica. Os valores na coluna "Prefixo" acima mais um sufixo '_url' ou '_path' formam os nomes desses auxiliares. Por exemplo, o auxiliar 'article_path' retorna "/articles/#{article.id}" quando recebe um artigo. Podemos usá-lo para organizar nossos links em app/views/articles/index.html.erb:

```erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="<%= article_path(article) %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

No entanto, daremos um passo adiante usando o auxiliar 'link_to'. O auxiliar 'link_to' renderiza um link com seu primeiro argumento como o texto do link e seu segundo argumento como o destino do link. Se passarmos um objeto modelo como segundo argumento, 'link_to' chamará o auxiliar de caminho apropriado para converter o objeto em um caminho. Por exemplo, se passarmos um artigo, 'link_to' chamaremos 'article_path'. Assim app/views/articles/index.html.erb fica:

```erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>
```

Agora passamos para o “C” (Criar) do CRUD. 

'new' em uma aplicação Rails, essas etapas são tratadas convencionalmente por ações e controladores create. Vamos adicionar uma implementação típica dessas ações app/controllers/articles_controller.rb, abaixo da show:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(title: "...", body: "...")

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

![Nota para o Criate](imagens\nota_criar.JPG)

Vamos criar app/views/articles/new.html.erbcom o seguinte conteúdo:

```erb
<h1>New Article</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

Os dados do formulário enviado são colocados no Hash params, juntamente com os parâmetros de rota capturados. Assim, a 'create' pode acessar o título submetido via params[:article][:title]e o corpo submetido via params[:article][:body]. Poderíamos passar esses valores individualmente para Article.new, mas isso seria detalhado e possivelmente sujeito a erros. E ficaria pior à medida que adicionamos mais campos.

Em vez disso, passaremos um único Hash que contém os valores. Porém, ainda devemos especificar quais valores são permitidos nesse Hash. Caso contrário, um usuário mal-intencionado poderá enviar campos extras de formulário e substituir dados privados. Na verdade, se passarmos o Hash params[:article] não filtrado diretamente para Article.new, o Rails irá gerar um ForbiddenAttributesError para nos alertar sobre o problema. Portanto, usaremos um recurso do Rails chamado 'Strong Parameters' para filtrar params. Pense nisso como uma digitação forte para params.

Vamos adicionar um método privado na parte inferior do app/controllers/articles_controller.rb nome article_paramsque filtra params. E vamos mudar create para usá-lo:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

Como vimos, criar um recurso é um processo de várias etapas. Lidar com entradas inválidas do usuário é outra etapa desse processo. Rails fornece um recurso chamado validações para nos ajudar a lidar com entradas inválidas do usuário. Validações são regras verificadas antes de um objeto de modelo ser salvo. Se alguma das verificações falhar, o salvamento será abortado e mensagens de erro apropriadas serão adicionadas ao atributo  'errors' do objeto modelo.

Vamos adicionar algumas validações ao nosso modelo em app/models/article.rb:

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

A primeira validação declara que um valor 'title' deve estar presente. Como title é uma string, isso significa que o valor 'title' deve conter pelo menos um caractere que não seja um espaço em branco.

A segunda validação declara que um valor 'body' também deve estar presente. Além disso, declara que o valor 'body' deve ter pelo menos 10 caracteres.

![Nota sobre atributos do Model](imagens\nota2_modelo.JPG)

Com nossas validações implementadas, vamos modificar app/views/articles/new.html.erb para exibir quaisquer mensagens de erro para title e body:

```erb
<h1>New Article</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% @article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% @article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

O full_messages_for método retorna uma série de mensagens de erro fáceis de usar para um atributo especificado. Se não houver erros para esse atributo, o array estará vazio.


Cobrimos o “CR” do CRUD. Agora vamos passar para o “U” (Atualização). Atualizar um recurso é muito semelhante a criar um recurso. Ambos são processos de várias etapas. Primeiramente, o usuário solicita um formulário para editar os dados. Em seguida, o usuário envia o formulário. Se não houver erros, o recurso será atualizado. Caso contrário, o formulário será exibido novamente com mensagens de erro e o processo será repetido.

'edit' Essas etapas são convencionalmente tratadas por ações e controladores update. Vamos adicionar uma implementação típica dessas ações em app/controllers/articles_controller.rb, abaixo da ação 'create':

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

Observe como as ações edite update se assemelham às ações new e create .

A 'edit' busca o artigo no banco de dados e o armazena @article para que possa ser usado na construção do formulário. Por padrão, a 'edit' será renderizada em app/views/articles/edit.html.erb.

A 'update' (re)busca o artigo do banco de dados e tenta atualizá-lo com os dados do formulário enviado filtrados por 'article_params'. Se nenhuma validação falhar e a atualização for bem-sucedida, a ação redireciona o navegador para a página do artigo. Caso contrário, a ação exibe novamente o formulário — com mensagens de erro — renderizando app/views/articles/edit.html.erb.

Nosso 'edit' formulário será igual ao nosso 'new' formulário. Até o código será o mesmo, graças ao construtor de formulários Rails e ao roteamento engenhoso. O construtor de formulário configura automaticamente o formulário para fazer o tipo apropriado de solicitação, com base no fato de o objeto do modelo ter sido salvo anteriormente.

Como o código será o mesmo, vamos fatorá-lo em uma visualização compartilhada chamada 'parcial'. Vamos criar app/views/articles/_form.html.erb com o seguinte conteúdo:


```erb
<%= form_with model: article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```
O código acima é igual ao nosso formulário em app/views/articles/new.html.erb, exceto que todas as ocorrências de '@article' foram substituídas por 'article'. Como parciais são códigos compartilhados, é uma prática recomendada que eles não dependam de variáveis ​​de instância específicas definidas por uma ação do controlador. Em vez disso, passaremos o artigo para a parcial como uma variável local.

Vamos atualizar app/views/articles/new.html.erb para usar o parcial via render:

```erb
<h1>New Article</h1>

<%= render "form", article: @article %>
```

![Nota Sobre Partial](imagens\nota_partial.JPG)

E agora, vamos criar um muito semelhante app/views/articles/edit.html.erb:

```erb
<h1>Edit Article</h1>

<%= render "form", article: @article %>
```

Por fim, chegamos ao “D” (Delete) do CRUD. Excluir um recurso é um processo mais simples do que criar ou atualizar. Requer apenas uma rota e uma ação do controlador. E nosso roteamento engenhoso ( resources :articles) já fornece a rota, que mapeia DELETE /articles/:id as solicitações para a ação destroy de ArticlesController.

Então, vamos adicionar uma ação destroy típica em app/controllers/articles_controller.rb abaixo da ação update:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to root_path, status: :see_other
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

A 'destroy' busca o artigo no banco de dados e 'destroy' o chama. Em seguida, ele redireciona o navegador para o caminho raiz com o código de status '303'.

Optamos por redirecionar para o caminho raiz porque esse é nosso principal ponto de acesso para artigos. Mas, em outras circunstâncias, você pode optar por redirecionar para, por exemplo 'articles_path'.

Agora vamos adicionar um link na parte inferior app/views/articles/show.html.erb para que possamos excluir um artigo de sua própria página:

```erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article), data: {
                    turbo_method: :delete,
                    turbo_confirm: "Are you sure?"
                  } %></li>
</ul>
```

No código acima, usamos a opção 'data' de definir os atributos HTML 'data-turbo-methode' 'data-turbo-confirm' do link "Destruir". Ambos os atributos se conectam ao Turbo , que é incluído por padrão em novos aplicativos Rails. 'data-turbo-method="delete"' fará com que o link faça uma solicitação DELETE em vez de uma solicitação GET. 'data-turbo-confirm="Are you sure?"' fará com que uma caixa de diálogo de confirmação apareça quando o link for clicado. Se o usuário cancelar o diálogo, a solicitação será abortada.

E é isso! Agora podemos listar, mostrar, criar, atualizar e excluir artigos!

É hora de adicionar um segundo modelo ao aplicativo. O segundo modelo tratará de comentários em artigos.

Veremos o mesmo gerador que usamos antes ao criar o modelo 'Article'. Desta vez criaremos um modelo 'Comment' para conter uma referência a um artigo. Execute este comando em seu terminal:

```bash
$ rails generate model Comment commenter:string body:text article:references
```

Este comando irá gerar quatro arquivos

| Arquivo |	Propósito |
| --- | --- |
| db/migrate/20140120201010_create_comments.rb |	Migração para criar a tabela de comentários em seu banco de dados (seu nome incluirá um timestamp diferente) |
| app/models/comment.rb |	O modelo de comentário |
| teste/modelos/comment_test.rb |	Testando o equipamento para o modelo de comentários |
| teste/fixtures/comments.yml |	Exemplos de comentários para uso em testes |


As associações do Active Record permitem declarar facilmente o relacionamento entre dois modelos. No caso de comentários e artigos, você poderia escrever as relações desta forma:

 - Cada comentário pertence a um artigo.
 - Um artigo pode ter muitos comentários.

Na verdade, isso está muito próximo da sintaxe que o Rails usa para declarar esta associação. Você já viu a linha de código dentro do modelo Comment (app/models/comment.rb) que faz com que cada comentário pertença a um Artigo:

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

Você precisará editar app/models/article.rbpara adicionar o outro lado da associação:

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

Essas duas declarações permitem um bom comportamento automático. Por exemplo, se você tiver uma variável de instância '@article' contendo um artigo, poderá recuperar todos os comentários pertencentes a esse artigo como um array usando '@article.comments'.

Assim como acontece com o controlador 'articles', precisaremos adicionar uma rota para que o Rails saiba onde gostaríamos de navegar para ver 'comments'. Abra o arquivo 'config/routes.rb' novamente e edite-o da seguinte maneira:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles do
    resources :comments
  end
end
```

Isso cria um 'comments' recurso aninhado dentro do articles. Esta é outra parte da captura da relação hierárquica que existe entre artigos e comentários. 

Vai ficar algo assim:

```
http://localhost:3000//articles/:article_id/comments
```
mas isso depende do controlador e dos metodos implementados para funcionar.

