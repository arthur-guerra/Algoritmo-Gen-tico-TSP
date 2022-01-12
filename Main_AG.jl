# @file Main AG.jl

# @author Arthur Leandro Guerra Pires

# Contact: a.guerrapires@hotmail.com

push!(LOAD_PATH, pwd())
using Genetico, Leitor, Extractor, Writer, PrettyTables

struct BenchILS
    nome
    custo_medio
    tempo_medio
end


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

    return melhor_individuo
end

function benchILS()

    intances_select = [] # ajeitar

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



function runInstances(K)

    instances = filterInstances()


    println("Teste instancia: ", instances[5])

    ok =[5]
    no_ok = [1,2, 3,4, 5, 9,10]

    resultados = []
    matrix = []

    bench_ILS = benchILS()

    i = 0

    for instance in instances

        i += 1

        if i ∉ ok		# só pegar o conjunto do "ok"
            continue  
        end

        #=if i ∈ no_ok		# só pegar o conjunto do "ok"
            continue  
        end  =#


        matrix = readFile(instance.fileName)

        println("matrix: MATRIX")
        
        println(instance.name)

        u_close = 3
        u_elite = 5
        lambda= 40
        tamanho_inicial = 20

        
        for j = 1:K

            individualTime = @elapsed populacao = Algoritmo_Genetico(matrix, tamanho_inicial, u_close, u_elite, lambda, bench_ILS[i].tempo_medio)

            println(" Tempo: ", round.(individualTime, digits=3), " s")
            
            melhor_individuo = bestindividuo(populacao, tamanho_inicial)
            
            println("Custo melhor individuo: ", melhor_individuo.custo)

            push!(resultados, Result(instance.name, j, melhor_individuo.custo, round.(individualTime, digits=3)))

        end        
    end

    writeFile("Resultados2.csv", resultados, ";")

end



runInstances(5)   