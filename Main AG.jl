
# @file Main AG.jl

# @author Arthur Leandro Guerra Pires

# Contact: a.guerrapires@hotmail.com




# Algoritmo genético

#Algorithm 1. HGS with diversity management for the SSP

# 1: Generate an initial population P with u random individuals   (Function gerarPopulacao() )

#### Calcular o custo logo aqui (tem que ter de qualquer maneira, por causa da  Busca Local)

# subject to local search                                          (Puxar da função do ILS)


#Função pra a 2 e 3 ou pra 2 e 5 - analisar o que fica melhor!

# 2: while the termination criterion is not attained do (20 vezes o tamanho da população ou do vetor do individuo? tem o limite de 1000 apontado por xico)


# 3: Select two parents S1 and S2 by binary tournament              ###### biasedFitness


# 4: Generate a single child S by order crossover on S1 and S2
# 5: Apply local search on S

# 6: Insert the resulting individual into the population P 

### Aplicar novamente a diversidade e o biased

# 7: if jPj ¼ l þ k then use a survivors selection procedure to
# discard k individuals, taking into account their quality
# and contribution to the wpopulation diversity
# 8: end while
# 9: return best solution found


#Teste #######################################

push!(LOAD_PATH, pwd())
using Populacao, Solution, BuscaLocal #(geraPopulacao,  )



# analisar o que precisa ser rescebido 

#u_close, u_elite, lambda, tamanho_inicial, distancia

function Genetico(distancia, tamanho_inicial, u_close, u_elite, lambda)

    tamanho_populacao = copy(tamanho_inicial) # isso vai crescer até o tamanho limite
    
    # já é aplicado a busca local em cada individuo gerado aleatoriamente
    populacao = geraPopulacao(distancia, tamanho_populacao)    

    # calcula a diversidade (nº de arestas diferentes entre individuo n e os demais)
    diversidade(populacao, distancia, u_close)          

    biasedFitness(populacao, distancia, u_elite, u_close)    
                  
   #     depois preciso adicionar a diversidade
   #     rankcusto e biasedRank vão ser adicionados na função biasedFitness   

   qtde_limite = 10
   x = 0

    while x < qtde_limite   # (termination criterion??? cereja do bolo  )
    
        x+=1

        pais = binarytournament(populacao)  # 1
        
        filho = crossoverOX(pais, distancia)           ## 2 --- verificar e validar a equação. Provavelmente vai ser necessário desconsiderar a última posição e depois adicionar!

        println("FILHOO: ", filho)
        
        Buscalocal(filho)                   ### 3
   
        preencheArestas(filho)

   #     dentro eu preciso criar a aresta

        push!(populacao, filho)             #### 4

   #     depois preciso adicionar a diversidade
   #     rankcusto e biasedRank vão ser adicionados na função biasedFitness
        diversidade(populacao, distancia, u_close)          

        biasedFitness(populacao, distancia, u_elite, u_close)

        tamanho_populacao = length(populacao)

        if tamanho_populacao == tamanho_inicial + lambda
            println("XXXXXX ENTROU PRA EXCLUIR")
            selecionar_sobreviventes(populacao, tamanho_inicial, lambda)        # pra eliminar os lambdas piores (maiores biasedFitness)
        end
    
    end
    return populacao
end


# Valores experimentais

u_close = 3
u_elite = 5
lambda = 5
tamanho_inicial = 10
#distancia

distancia = [0 1 2 3 4 5 6; 
            1 0 2 1 4 9 1; 
            2 2 0 5 9 7 2; 
            3 1 5 0 3 8 6; 
            4 4 9 3 0 2 5; 
            5 9 7 8 2 0 2; 
            6 1 2 6 5 2 0]


u_close = 3
u_elite = 5
lambda = 5
tamanho_inicial = 10

pop = Genetico(distancia, tamanho_inicial, u_close, u_elite, lambda)


println("POP 1: ", pop[1])
println("POP 5: ", pop[5])
println("POP 10: ", pop[10])
println("POP 15: ", pop[15])

println("O TAMANHO FINAL É: ", length(pop))
