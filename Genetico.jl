module Genetico

using Populacao, Solution, BuscaLocal, Leitor, Extractor
export Algoritmo_Genetico


function Algoritmo_Genetico(distancia::Array{Float64,2}, tamanho_inicial::Int64, u_close::Int64, u_elite::Int64, lambda::Int64)::Vector{Solucao}

    tamanho_populacao::Int64 = copy(tamanho_inicial)

    # já é aplicado a busca local em cada individuo gerado aleatoriamente
    populacao::Vector{Solucao} = geraPopulacao(distancia, tamanho_populacao)    

    # calcula a diversidade (nº de arestas diferentes entre individuo n e os demais)
    diversidade(populacao, u_close)          

    # calcula o valor do biasedFitness
    biasedFitness(populacao, u_elite, u_close)      
    
    qtde_limite::Int64 = min(20*tamanho_inicial, 10000)

    x::Int64 = 0

    while x < qtde_limite

        x+=1

        pais::Vector{Solucao} = binarytournament(populacao)
        
        filho::Solucao = crossoverOX(pais)

        Buscalocal(filho)

        preencheArestas(filho)

        push!(populacao, filho)

        # calcula a diversidade (nº de arestas diferentes entre individuo n e os demais)
        diversidade(populacao, u_close)

        # calcula o valor do biasedFitness
        biasedFitness(populacao, u_elite, u_close)

        tamanho_populacao = length(populacao)

        # seleção de sobreviventes
        if tamanho_populacao == tamanho_inicial + lambda
            seleciona_sobreviventes(populacao, tamanho_inicial, lambda)        # pra eliminar os lambdas piores (maiores biasedFitness)
        end

    end
    
    return populacao
end


end