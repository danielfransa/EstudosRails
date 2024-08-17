class HomeController < ApplicationController
  # GET /alunos
  def index
    @alunos = Aluno.all

    render json: {
      mensagem: "Bem vindo a API para o stimulus",
      endpoints: [
        "/alunos"
      ]
    }
  end
end
