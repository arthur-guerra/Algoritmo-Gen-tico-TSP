module Genetico

using Populacao, Solution, BuscaLocal, Leitor, Extractor
export Algoritmo_Genetico


#=function Algoritmo_Genetico(distancia::Array{Float64,2}, tamanho_inicial::Int64, u_close::Int64, u_elite::Int64, lambda::Int64)::Vector{Solucao}

    tamanho_populacao::Int64 = copy(tamanho_inicial)

    # já é aplicado a busca local em cada individuo gerado aleatoriamente
    populacao::Vector{Solucao} = geraPopulacao(distancia, tamanho_populacao)    

    # calcula a diversidade (nº de arestas diferentes entre individuo n e os demais)
    diversidade(populacao, u_close)          

    # calcula o valor do biasedFitness
    biasedFitness(populacao, u_elite, u_close)      
    
    qtde_limite::Int64 = min(20*tamanho_inicial, 10000)
    tempo_limite = 

    x::Int64 = 0
    

    while x < qtde_limite

        x += 1

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
end=#



function loop_genetico(populacao::Vector{Solucao}, u_close::Int64, u_elite::Int64, tamanho_inicial::Int64, lambda::Int64)

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

function benchILS()

    intances_select = []

    open("Custo_Tempo_ILS.csv") do file

        while !eof(file) # a função vai identificar um conjunto de caracteres no fim!
            
            line = readline(file) # Consome uma linha e "destroi" 

            numbers::Vector{String} = split(line, ";")

            resultado_fim::BenchILS = BenchILS(numbers[1], parse(Float64, numbers[2]), parse(Float64, numbers[3]))

            push!(intances_select,resultado_fim) # para guardar as informações dos que sobrarem

        end
    end
    return intances_select
end



function Algoritmo_Genetico(distancia::Array{Float64,2}, tamanho_inicial::Int64, u_close::Int64, u_elite::Int64, lambda::Int64, tempo_limite::Float64)::Vector{Solucao}

    tamanho_populacao::Int64 = copy(tamanho_inicial)

    # já é aplicado a busca local em cada individuo gerado aleatoriamente
    populacao::Vector{Solucao} = geraPopulacao(distancia, tamanho_populacao)    

    # calcula a diversidade (nº de arestas diferentes entre individuo n e os demais)
    diversidade(populacao, u_close)          

    # calcula o valor do biasedFitness
    biasedFitness(populacao, u_elite, u_close)      
    
    qtde_limite::Int64 = min(20*tamanho_inicial, 10000)
    #x::Int64 = 0
    
    temp_1::Float64 = 0

    while temp_1 < tempo_limite
        temp_1 += @elapsed loop_genetico(populacao, u_close, u_elite , tamanho_inicial ,lambda) #+ temp_1
    end

    return populacao

end


end #Fim do módulo


