module Genetico

using Populacao, Solution, BuscaLocal, Leitor, Extractor
export Algoritmo_Genetico


function Algoritmo_Genetico(distancia::Matrix{Float64}, tamanho_inicial::Int64, u_close::Int64, u_elite::Int64, lambda::Int64)

    tamanho_populacao = copy(tamanho_inicial)

    # já é aplicado a busca local em cada individuo gerado aleatoriamente
    populacao = geraPopulacao(distancia, tamanho_populacao)    

    # calcula a diversidade (nº de arestas diferentes entre individuo n e os demais)
    diversidade(populacao, u_close)          

    # calcula o valor do biasedFitness
    biasedFitness(populacao, u_elite, u_close)      

    #qtde_limite = 20 * tamanho_inicial
    

    qtde_limite = min(20*tamanho_inicial, 10000)

    x = 0

    while x < qtde_limite   # (termination criterion???  

        x+=1

        pais = binarytournament(populacao)
        
        filho = crossoverOX(pais)

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
            selecionar_sobreviventes(populacao, tamanho_inicial, lambda)        # pra eliminar os lambdas piores (maiores biasedFitness)
        end

    end
    
    return populacao
end


end