#push!(LOAD_PATH, pwd())

module Populacao  # precisa ter o nome do arquivo

using Solution, Profile, BuscaLocal, Random, Leitor, Extractor
export geraPopulacao, preencheArestas, diversidade, biasedFitness, seleciona_sobreviventes, binarytournament, crossoverOX

const epsilon = 0.001
#Random.seed!(3)
  
function geraPopulacao(distancia::Array{Float64,2}, tamanho_populacao::Int64)::Vector{Solucao}     #o retorno é solução.  Qual tipo?

    populacao::Vector{Solucao} = []
    tamanho_caminho::Int64 = size(distancia, 1)

    for i =1:tamanho_populacao
        
        temp::Vector{Int64} = []
        nao_selecionado::Vector{Float64} = collect(1:tamanho_caminho)

        for i=1:tamanho_caminho
            a::Int64 = rand(1:length(nao_selecionado))
            push!(temp, nao_selecionado[a])
            splice!(nao_selecionado, a)
        end
            push!(temp, temp[1])        ##### Incluir o último elemento

        solucao::Solucao = Solucao(temp, distancia)

        #println("Solução pré busca local: ", solucao)  ## verificar pós

        # aplicando a busca local
        Buscalocal(solucao)
        
        # adicionando as arestas
        preencheArestas(solucao)
        
        push!(populacao, solucao)
    end
    
    return populacao
end

 
function preencheArestas(individuo::Solucao)

    # ignora a última posição do movimento circular (-1)
    tamanho_caminho::Int64 = length(individuo.caminho)-1 

    individuo.arestas::Vector{Int64} = Vector{Int64}(undef, tamanho_caminho) # pre alocação do espaço

        for j = 1:tamanho_caminho #tamanho distancia     # pra começar na posição 2
        
            @inbounds individuo.arestas[individuo.caminho[j]] = individuo.caminho[j+1]

        end
end


function distancia_arestas(individuo_1::Solucao, individuo_2::Solucao)::Int64

    distance::Int64 = 0 #número de arestas diferentes
    distancia::Array{Float64,2} = individuo_1.distancia #VERIFICAR

    tamanho_distancia::Int64 = size(distancia, 1)

    for i = 1:tamanho_distancia
        if individuo_1.arestas[i] == individuo_2.arestas[i]
            continue # pula o laço do for
        end

        if i != individuo_2.arestas[individuo_1.arestas[i]]

            distance += 1
        end
            
    end
    return distance
end


function diversidade(populacao::Vector{Solucao}, u_close::Int64)

    tamanho_populacao::Int64 = length(populacao)

    for i =1:tamanho_populacao

        distances::Vector{Int64} = []

        for j = 1:tamanho_populacao

            if populacao[i] === populacao[j]
                continue
            end

            push!(distances, distancia_arestas(populacao[i], populacao[j]))
        end

        sort!(distances) # pra pegar os mais próximos

        sum::Float64 = 0

        for i = 1:u_close
            sum += distances[i]
        end

        @inbounds populacao[i].diversidade =  sum / u_close
    end
        
end


function biasedFitness(populacao::Vector{Solucao}, u_elite::Int64, u_close::Int64)

    # Chamando a função de diversidade (meanDistances)
    diversidade(populacao, u_close)

    tamanho_populacao::Int64 = length(populacao)
    
    sort!(populacao, by = elem -> elem.custo)      # menor é melhor

    # Nesse primeiro, vai pegar na sequencia e essa sequencia vai estar em outra ordem no outro for
    for i = 1:tamanho_populacao
        @inbounds populacao[i].rankcusto = i
    end

    sort!(populacao, by = elem -> -elem.diversidade) # maior é melhor (sinal de 'menor')

    for i = 1:tamanho_populacao     #### isso precisa ser ajustado
        @inbounds populacao[i].biasedFitness = populacao[i].rankcusto + ((1- (u_elite/tamanho_populacao))* i)
    end

    #println("\nRank custo é: ", rank_custo)
    #println("\nRank diversidade é: ", rank_diversidade, "\n")

end


function binarytournament(populacao::Vector{Solucao})::Vector{Solucao}

    tamanho_populacao::Int64 =  length(populacao)           ### validar se vai funcionar assim
    nao_selecionado::Vector{Int64} = collect(1:tamanho_populacao)

    pais::Vector{Solucao} = Vector{Solucao}(undef, 0) #VERIFICAR
    
    for i=1:2
        a::Int64 = rand(1:length(nao_selecionado))
        b::Int64 = rand(1:length(nao_selecionado))

        #Verificar o biasedFitness
        if populacao[nao_selecionado[a]].biasedFitness < populacao[nao_selecionado[b]].biasedFitness  #Testar se é assim! Não é assim, vai ser o menor biasedRank
            push!(pais, populacao[nao_selecionado[a]])
            splice!(nao_selecionado, a)
         else
            push!(pais, populacao[nao_selecionado[b]])
            splice!(nao_selecionado, b)
         end
    end
    
    return pais
end


function crossoverOX(pais::Vector{Solucao})::Solucao  # Versão corrigida   pai_1, pai_2, distancia

    distancia::Array{Float64,2}	= pais[1].distancia #VERIFICAR
    
    pai_1::Vector{Int64} = copy(pais[1].caminho)
    pai_2::Vector{Int64} = copy(pais[2].caminho)

    tamanho_pai::Int64 = length(pai_1)

    # posição dos cortes. c1 e c2 já fazem parte da seção a inserir
    c1::Int64 = rand(2:tamanho_pai-2)
    c2::Int64 = rand(c1+1:tamanho_pai-1)    

    # vai ser a base de onde será copiado as informações para o filho. A base de fato é a pai_1, que inicializará com o c1-c2
    suporte::Vector{Int64} = copy(pai_2)

    # preenchendo com as posições depois do "c2", para inserir na frente do vetor suporte
    for i = tamanho_pai - 1 :-1: c2 + 1
        pushfirst!(suporte, pai_2[i])
    end

    # deletando as posições inseridas no começo e deixando preparado para gerar o "filho"
    deleteat!(suporte, tamanho_pai : tamanho_pai+(tamanho_pai-c2-1))    
    
    # retirando o trecho  do vetor suporte. Sequencia correta para gerar o "filho"
    setdiff!(suporte, pai_1[c1:c2])
    
    # trecho "central" do filho, considerando c1 e c2
    filho::Vector{Int64} = deepcopy(pai_1[c1:c2])

    # tamanho referente ao trecho pós c2
    posicao_fim::Int64 = (tamanho_pai-1)-c2

    # preenchendo o trecho pós c2
    for i = 1:posicao_fim
        push!(filho, suporte[i])
    end
    
    # preenchendo o trecho pré c1
    for i = length(suporte):-1:posicao_fim + 1          # pra começar da posição posterior a posição fim, do vetor suporte
        pushfirst!(filho, suporte[i])
    end

    push!(filho, filho[1])

    solucao::Solucao = Solucao(filho, distancia)
    
    return solucao

end

        
function seleciona_sobreviventes(populacao::Vector{Solucao}, tamanho_inicial::Int64, lambda::Int64)

    sort!(populacao, by = elem -> elem.biasedFitness)

    deleteat!(populacao, tamanho_inicial + 1 : tamanho_inicial + lambda)

end

end