# @file Main AG.jl

# @author Arthur Leandro Guerra Pires

# Contact: a.guerrapires@hotmail.com

push!(LOAD_PATH, pwd())
using Genetico,  Leitor, Extractor, PrettyTables


function filterInstances()
    files = readdir("Instancias")			#Vem com Instancia/Arquivo

    instances = []
    intances_select = []

    for file in files
        push!(instances, extractFile(string("Instancias/", file)))     ########## EXTRACTOR
    end

    i = 1
    cont = 0
    open("instancias.csv") do file         
        
        while !eof(file) # a função vai identificar um conjunto de caracteres no fim!
            line = readline(file) # Consome uma linha e "destroi" 

            while i <= length(instances) && string(line, ".tsp") != instances[i].realName # compara linha com instancias até encontrar um match
                rm(instances[i].fileName)
                i += 1
            end

            push!(intances_select,instances[i]) # para guardar as informações dos que sobrarem

            if i <= length(instances)
            end
            i += 1
            cont+=1
        end

        for j = i:length(instances)		#i é o último da lista, onde parou 
            rm(instances[j].fileName)
        end

    end
    
    return intances_select
end


function bestindividuo(populacao, tamanho_inicial)

    melhor_individuo = populacao[1]

    for i = 2:tamanho_inicial
        if populacao[i].custo < melhor_individuo.custo
            melhor_individuo = populacao[i]
        end
    end

    println("Melhor Custo individuo: ", melhor_individuo.custo)
    println("Melhor Caminho individuo: ", melhor_individuo.caminho)

end


function runInstances(K)

    instances = filterInstances()
    ok = [2]
    resultados = []
    matrix = []

    i = 0
    for instance in instances

        i += 1

        if i ∉ ok		# só pegar o conjunto do "ok"
            continue
        end

        matrix = readFile(instance.fileName)
        
        println(instance.name)

        u_close = 3
        u_elite = 5
        lambda= 40
        tamanho_inicial = 20
        
        for i = 1:K

            individualTime = @elapsed populacao = Algoritmo_Genetico(matrix, tamanho_inicial, u_close, u_elite, lambda)
            println(" Tempo: ", round.(individualTime, digits=3), " s")
            #println("Custo individuo: ", populacao[i].custo)

            bestindividuo(populacao, tamanho_inicial)

        end        
    end

end



runInstances(1)   