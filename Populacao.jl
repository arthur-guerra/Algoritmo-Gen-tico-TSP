#push!(LOAD_PATH, pwd())

module Populacao  # precisa ter o nome do arquivo

using Solution, Profile, BuscaLocal, Random, Leitor, Extractor
export geraPopulacao, preencheArestas, diversidade, biasedFitness, selecionar_sobreviventes, binarytournament, crossoverOX

const epsilon = 0.001 
num_individuo = 20
Random.seed!(3)

#gerarPopulacao(distancia::Array{Float64,2}, tamanho_populacao::Int64)::Vector{Solucao}   
function geraPopulacao(distancia, tamanho_populacao)     #o retorno é solução.  Qual tipo?

	# populacao::Vector{Int64} = Vector{Int64}(undef, 0)
    populacao = []
	#linha_dist::Int64 = size(distancia, 1)
    linha_dist = size(distancia, 1)

    for i =1:tamanho_populacao #tamanho população
        
        #temp::Vector{Float64} = Vector{Float64}(undef, 0)       #Verificar!!!
        temp = []
        #nao_selecionado::Vector{Float64} = collect(1:linha_dist)
        nao_selecionado = collect(1:linha_dist)

        for i=1:linha_dist
            a = rand(1:length(nao_selecionado))
            #a::Int64= rand(1:length(nao_selecionado))
            push!(temp, nao_selecionado[a])
            splice!(nao_selecionado, a)
        end
            push!(temp, temp[1])        ##### Incluir o último elemento

        #solucao::Solucao = Solucao(temp, distancia)
        solucao = Solucao(temp, distancia)

        println("Solução pré busca local: ", solucao)


        Buscalocal(solucao) #Aplicação da busca local ######################

        println("Solução DEPOIS busca local: ", solucao)
        
        preencheArestas(solucao)

        for i = 1:linha_dist-1
            for j = i+1:linha_dist-1
                if solucao.caminho[i] == solucao.caminho[j]
                    println("Caminho validação: ", solucao.caminho)
                    throw("Erro")
                end
            end
        end

        push!(populacao, solucao)
    end
    println("POPULACAO ", populacao)
    return populacao
end
 
function preencheArestas(individuo)
    
    #tamanho_distancia = size(distancia, 1) # precisa ser calculado! Talvez colocar como global ou constnte

    tamanho_distancia = length(individuo.caminho)-1
    println("TAMANHO DISTANCIA: ",tamanho_distancia )

    individuo.arestas = Vector{Int64}(undef, tamanho_distancia) # pre alocação do espaço

        for j = 1:tamanho_distancia #tamanho distancia     # pra começar na posição 2
        
            individuo.arestas[individuo.caminho[j]] = individuo.caminho[j+1]

        end
    #println("População: ", populacao)
end


function distancia_arestas(individuo_1, individuo_2, distancia)

    distance = 0 #número de arestas diferentes

    tamanho_distancia = size(distancia, 1)

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




function mediasDistances(individuo_1, populacao, distancias, u_close)

    solucao = individuo_1
    #for solucao in populacao
        linha_dist = length(solucao.caminho)
        for i = 1:linha_dist-1
            for j = i+1:linha_dist-1
                if solucao.caminho[i] == solucao.caminho[j]
                    println("Caminho validação: ", solucao.caminho)
                    throw("Erro")
                end
            end
        end
    #end

    distances = []

    for individuo_2 in populacao
        
        if individuo_1 === individuo_2
            continue
        end
        push!(distances, distancia_arestas(individuo_1, individuo_2, distancias))
    end

    println("DISTANCES: ", distances)


    sort!(distances) # pra pegar os mais próximos

    #println("DISTANCES: ", distances)

    sum = 0

    for i = 1:u_close
        sum += distances[i]
    end

    solucao = individuo_1
    #for solucao in populacao
        linha_dist = length(solucao.caminho)
        for i = 1:linha_dist-1
            for j = i+1:linha_dist-1
                if solucao.caminho[i] == solucao.caminho[j]
                    println("Caminho validação: ", solucao.caminho)
                    throw("Erro")
                end
            end
        end
    #end

    return sum / u_close

end


function diversidade(populacao, distancia, u_close)

    tamanho_populacao = length(populacao)#depende da populacao

    for i =1:tamanho_populacao
        solucao = populacao[i]
        linha_dist = length(solucao.caminho)
        for i = 1:linha_dist-1
            for j = i+1:linha_dist-1
                if solucao.caminho[i] == solucao.caminho[j]
                    println("Caminho validação: ", solucao.caminho)
                    throw("Erro")
                end
            end
        end
        populacao[i].diversidade = mediasDistances(populacao[i], populacao, distancia, u_close)
    end

    for solucao in populacao
        linha_dist = length(solucao.caminho)
        for i = 1:linha_dist-1
            for j = i+1:linha_dist-1
                if solucao.caminho[i] == solucao.caminho[j]
                    println("Caminho validação: ", solucao.caminho)
                    throw("Erro")
                end
            end
        end
    end
end


function biasedFitness(populacao, distancia, u_elite, u_close)

    # Chamando a função de diversidade (meanDistances)
    diversidade(populacao, distancia, u_close)

    tamanho_populacao = length(populacao)

    rank_custo = copy(populacao)
    rank_diversidade = copy(populacao)
    
    sort!(rank_custo, by = elem -> elem.custo)      # menor é melhor
    sort!(rank_diversidade, by = elem -> -elem.diversidade) # maior é melhor (sinal de 'menor')
    
    #println("\nRank custo é: ", rank_custo)
    #println("Rank diversidade é: ", rank_diversidade)

    # Nesse primeiro, vai pegar na sequencia e essa sequencia vai estar em outra ordem no outro for
    for i = 1:tamanho_populacao
        rank_custo[i].rankcusto = i
    end

    for i = 1:tamanho_populacao     #### isso precisa ser ajustado
        rank_diversidade[i].biasedFitness = rank_diversidade[i].rankcusto + ((1- (u_elite/tamanho_populacao))* i)
    end

    println("\nRank custo é: ", rank_custo)
    println("\nRank diversidade é: ", rank_diversidade, "\n")

end


function binarytournament(populacao)

    tamanho_populacao =  length(populacao)           ### validar se vai funcionar assim
    nao_selecionado = collect(1:tamanho_populacao)

    pais = []       #Vector{Int64}(undef, 0) 
    
    for i=1:2
        a = rand(1:length(nao_selecionado))
        b = rand(1:length(nao_selecionado))

        #Aplicar o biasedFitness
        
        if populacao[nao_selecionado[a]].biasedFitness < populacao[nao_selecionado[b]].biasedFitness  #Testar se é assim! Não é assim, vai ser o menor biasedRank
            push!(pais, populacao[nao_selecionado[a]])
            splice!(nao_selecionado, a)
         else
            push!(pais, populacao[nao_selecionado[b]])
            splice!(nao_selecionado, b)
         end
    
    println("PAAAIS ", pais)
    end
    
    return pais
end



function crossoverOX(pais, distancia)  # Versão corrigida   pai_1, pai_2, distancia
    
    println("PAIsssss", pais)

    
    pai_1 = copy(pais[1].caminho)
    println("PAI 1", pai_1)
   
    pai_2 = copy(pais[2].caminho)
    println("PAI 2", pai_2)


    #tamanho_pai = length(pais[1].caminho) # ##Lembrar que tem uma posição a mais devido ao movimento circular. Pra descontar a posição circular
    tamanho_pai = length(pai_1)
    println("AQUI",tamanho_pai)

    # posição dos cortes 
    c1 = rand(2:tamanho_pai-2)       # essa posição já faz parte da seção a inserir
    c2 = rand(c1+1:tamanho_pai-1)    # essa posição já faz parte da seção a inserir

    #c1 = 4
    #c2 = 7

    # [[1, 8, 6], 4, 10, 7, 9, 2, 5, 3] 

    suporte = copy(pai_2)       # vai ser a base de onde será copiado as informações para o filho. A base de fato é a pai_1, que inicializará com o c1-c2
    
    #vetor = [7, 9, 4]

    for i = tamanho_pai - 1 :-1: c2 + 1
        pushfirst!(suporte, pai_2[i])
        println(pai_2[i])
    end

    # pai_2 = [4, 10, 7, 9, 2, 5, 3, 1, 8, 6, 4]

    
    println("O suporte é: ", suporte)
    
    deleteat!(suporte, tamanho_pai : tamanho_pai+(tamanho_pai-c2-1))     # exatamente o trecho final


    println("O suporte é: ", suporte)
    
    println("O que precisa ser excluido: ", pai_1[c1:c2])
    
    setdiff!(suporte, pai_1[c1:c2])

    println("O resultado final é: ", suporte)   # vetor que vai armazenar temporariamente a informação
    
    filho = deepcopy(pai_1[c1:c2])

    #=for i = 1:(c2-c1)
        push!(filho, suporte[i])
        println("filho: ", filho)
    end=#

    #for i = 1:length(suporte)
    # Para ir até a penultima posição pois a última é referente a posição circular


    posicao_fim = (tamanho_pai-1)-c2

    for i = 1:posicao_fim
        push!(filho, suporte[i])
        println("filho: ", filho)
    end
    
    #loop invertido com o tamanho do vetor suporte e o inicio da segunda seção
    #for i = length(suporte):-1:(c2-c1+1)
    # ERRO AQUI

    #for i = length(suporte):-1:(c2-c1+1)
    for i = length(suporte):-1:posicao_fim + 1          # pra começar da posição posterior a posição fim, do vetor suporte
        pushfirst!(filho, suporte[i])
        println("filho: ", filho)
    end

    push!(filho, filho[1])

    println("filho FIM: ", filho)

    solucao = Solucao(filho, distancia)

    println("Solucaoooo: ", solucao)
    
    return solucao

end

        
function selecionar_sobreviventes(populacao, tamanho_inicial, lambda)   # ajustar isso selecionar_sobreviventes

    biasedRank = copy(populacao)
    sort!(biasedRank, by = elem -> elem.biasedFitness)

    println("O rank do biased da População é: ", biasedRank)

    #Aplicar algum deleteat! aqui !!!!!!!!!

    deleteat!(biasedRank, tamanho_inicial + 1 : tamanho_inicial + lambda)

    println("Testar a populacao: ", populacao)

end

end