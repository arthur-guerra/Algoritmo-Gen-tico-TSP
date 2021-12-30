


function crossoverOX()  # Versão corrigida   pai_1, pai_2, distancia
    
    #println("PAIsssss", pais)

    
    #pai_1 = copy(pais[1].caminho)
    #println("PAI 1", pai_1)
   
   # pai_2 = copy(pais[2].caminho)
    #println("PAI 2", pai_2)


    pai_1 = [1,2,3,4,5,6,7,8,9,10,1]
    pai_2 = [4,10,7,9,2,5,3,1,8,6,4]




    #tamanho_pai = length(pais[1].caminho) # ##Lembrar que tem uma posição a mais devido ao movimento circular. Pra descontar a posição circular
    tamanho_pai = length(pai_1)
    println("AQUI",tamanho_pai)

    # posição dos cortes 
    #c1 = rand(2:tamanho_pai-2)       # essa posição já faz parte da seção a inserir
    #c2 = rand(c1+1:tamanho_pai-1)    # essa posição já faz parte da seção a inserir


    c1 = 4
    c2 = 7

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
    for i = length(suporte):-1:posicao_fim+1
        pushfirst!(filho, suporte[i])
        println("filho: ", filho)
    end

    push!(filho, filho[1])

    println("filho FIM: ", filho)

    solucao = Solucao(filho, distancia)

    println("Solucaoooo: ", solucao)
    
    return solucao

end


crossoverOX()