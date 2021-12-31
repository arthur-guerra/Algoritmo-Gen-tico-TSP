module BuscaLocal

using Solution, Profile
export Buscalocal

const epsilon = 0.001 


function swap(solucao::Solucao)::Bool  # Função de troca de posição

	caminho::Vector{Int64} = solucao.caminho        
	distancia::Array{Float64, 2}= solucao.distancia        		
	custo_Corrente::Float64 = solucao.custo   
	
	tamanho::Int64 = length(caminho)

	melhor_custo::Float64 = custo_Corrente
	no_final_A::Int64 = 0
	no_final_B::Int64 = 0

	for no_A = 2:tamanho-2
		no_B::Int64 = no_A + 1
		no_A_anterior::Int64 = no_A - 1
		no_A_seguinte::Int64 = no_A + 1
		no_B_anterior::Int64 = no_B - 1
		no_B_seguinte::Int64 = no_B + 1

		@inbounds custo_Removido_A::Float64 = distancia[caminho[no_A_anterior], caminho[no_A]]
		@inbounds custo_Removido_B::Float64 = distancia[caminho[no_B], caminho[no_B_seguinte]]
		@inbounds custo_Adicionado_B::Float64 = distancia[caminho[no_A_anterior], caminho[no_B]]
		@inbounds custo_Adicionado_A::Float64 = distancia[caminho[no_A], caminho[no_B_seguinte]]

		custo_Removido::Float64 = custo_Removido_A + custo_Removido_B  # Custo original sem a mudança
		custo_Adicionado::Float64 = custo_Adicionado_B + custo_Adicionado_A # Custo com a inversão de B para A e A para B!
		custo::Float64 = custo_Corrente + custo_Adicionado - custo_Removido

		if(custo < melhor_custo)
			melhor_custo = custo
			no_final_A = no_A
			no_final_B = no_B
		end

		for no_B = no_A+2:tamanho-1

			no_A_anterior = no_A - 1
			no_A_seguinte = no_A + 1
			no_B_anterior = no_B - 1
			no_B_seguinte = no_B + 1

			@inbounds custo_Removido_A = distancia[caminho[no_A_anterior], caminho[no_A]] + distancia[caminho[no_A], caminho[no_A_seguinte]]
			@inbounds custo_Removido_B = distancia[caminho[no_B_anterior], caminho[no_B]] + distancia[caminho[no_B], caminho[no_B_seguinte]]
			@inbounds custo_Adicionado_B = distancia[caminho[no_A_anterior], caminho[no_B]] + distancia[caminho[no_B], caminho[no_A_seguinte]]
			@inbounds custo_Adicionado_A = distancia[caminho[no_B_anterior], caminho[no_A]] + distancia[caminho[no_A], caminho[no_B_seguinte]]

			custo_Removido = custo_Removido_A + custo_Removido_B  
			custo_Adicionado = custo_Adicionado_B + custo_Adicionado_A 
			custo = custo_Corrente + custo_Adicionado - custo_Removido

			if(custo + epsilon < melhor_custo)
				melhor_custo = custo
				no_final_A = no_A
				no_final_B = no_B

				#println("Melhor custo: ", melhor_custo)
				#println("No final A: ", no_final_A)
				#println("No final B: ", no_final_B)
				
			end
		end
	end

	#println("Validar Melhor custo: ", melhor_custo)
	#println("Validar No final A: ", no_final_A)
	#println("Validar No final B: ", no_final_B)

	if(melhor_custo + epsilon < custo_Corrente)
		swapVertices(solucao, no_final_A, no_final_B)
		return true
	end

	return false    
end

function busca_2opt(solucao::Solucao)::Bool

	caminho::Vector{Int64} = solucao.caminho		
	distancia::Array{Float64, 2} = solucao.distancia	
	custo_Corrente::Float64 = solucao.custo	
	melhor_custo::Float64 = custo_Corrente 	

	p1::Int64 = 0 
	p2::Int64 = 0 


	for node_inicial =2:length(caminho)-1 
		for node_final = node_inicial+1:length(caminho)-1 

			custo_Adicionado::Float64 = 0 
			custo_Removido::Float64 = 0 

			@inbounds custo_Adicionado += distancia[caminho[node_inicial],caminho[node_final+1]] # Calculo do extremo inicial 
			@inbounds custo_Adicionado += distancia[caminho[node_inicial-1],caminho[node_final]] # Calculo do extremo final 

			@inbounds custo_Removido += distancia[caminho[node_inicial-1],caminho[node_inicial]]
			@inbounds custo_Removido += distancia[caminho[node_final],caminho[node_final+1]]


			custo::Float64 = custo_Corrente + custo_Adicionado - custo_Removido 

			if(custo + epsilon < melhor_custo) 
				p1 = node_inicial 
				p2 = node_final 
				melhor_custo = custo 
			end 
		end 
	end 

	if (melhor_custo + epsilon < custo_Corrente) 
		reverseSegment(solucao, p1, p2)
		return true
	end 

	return false 
end 

function orOpt(solucao::Solucao, K::Int64)::Bool    # K é o tamanho da seção (1, 2 ou 3) 

	#solucao.caminho::Vector{Int64} = solucao.solucao.caminho			
	#solucao.dist::Array{Float64, 2} = solucao.dist			
	#solucao.custo::Float64 = solucao.custo		
	melhor_custo::Float64 = solucao.custo		
	melhor_Inicio::Int64 = 0					
	melhor_Destino::Int64 = 0 				

	for origem =2:length(solucao.caminho)-K

		custo_Adicionado::Float64 = 0
		custo_Removido::Float64 = 0 
		custo_Adicionado_1::Float64 = 0
		custo_Adicionado_2::Float64 = 0 
		custo_Adicionado_3::Float64 = 0
		custo::Float64 = 0 

		for destino = 2:origem-1

			@inbounds custo_Removido =   solucao.distancia[solucao.caminho[destino-1], solucao.caminho[destino]] + 
			solucao.distancia[solucao.caminho[origem-1], solucao.caminho[origem]] +  
			solucao.distancia[solucao.caminho[origem+K-1], solucao.caminho[origem+K]]
			
			@inbounds custo_Adicionado_1 =  solucao.distancia[solucao.caminho[destino-1], solucao.caminho[origem]]    
			@inbounds custo_Adicionado_2 =  solucao.distancia[solucao.caminho[origem+K-1], solucao.caminho[destino]]
			@inbounds custo_Adicionado_3 =  solucao.distancia[solucao.caminho[origem-1], solucao.caminho[origem+K]]
			
			custo_Adicionado = custo_Adicionado_1 + custo_Adicionado_2 + custo_Adicionado_3
			
			custo = solucao.custo + custo_Adicionado - custo_Removido

			if(custo + epsilon < melhor_custo)
				melhor_custo = custo
				melhor_Inicio = origem
				melhor_Destino = destino
			end
		end

		for destino = origem+1:length(solucao.caminho)-K

			@inbounds custo_Removido =    solucao.distancia[solucao.caminho[origem-1], solucao.caminho[origem]] + 
			solucao.distancia[solucao.caminho[origem+K-1], solucao.caminho[origem+K]] +  
			solucao.distancia[solucao.caminho[destino+K-1], solucao.caminho[destino+K]]

			@inbounds custo_Adicionado_1 =  solucao.distancia[solucao.caminho[origem-1], solucao.caminho[origem+K]]
			@inbounds custo_Adicionado_2 =  solucao.distancia[solucao.caminho[destino+K-1], solucao.caminho[origem]]      
			@inbounds custo_Adicionado_3 = solucao.distancia[solucao.caminho[origem+K-1], solucao.caminho[destino+K]]   

			custo_Adicionado = custo_Adicionado_1 + custo_Adicionado_2 + custo_Adicionado_3

			custo = solucao.custo + custo_Adicionado - custo_Removido

			if(custo + epsilon < melhor_custo)
				melhor_custo = custo
				melhor_Inicio = origem
				melhor_Destino = destino
			end
		end
	end
		
	


	if (melhor_custo + epsilon < solucao.custo)
		moveSegment(solucao, melhor_Inicio, melhor_Destino, K)
		return true
	end

	return false
	
end

function Buscalocal(solucao::Solucao)::Bool    #---dúvida (Verificar se o retorno de fato é assim)    # Consolidação dos movimentos e do algoritmo em si!

	vetor::Vector{Int64} = [1,2,3,4,5]		#[1,2,3,4,5]

	improvement::Bool = false

	while !isempty(vetor)

		a::Int64 = rand(1:length(vetor))

		if vetor[a] == 1
			improvement = swap(solucao)

		elseif vetor[a] == 2
			improvement = busca_2opt(solucao)

		elseif vetor[a] == 3
			improvement = orOpt(solucao, 1)

		elseif vetor[a] == 4
			improvement = orOpt(solucao, 2)

		else
			improvement = orOpt(solucao, 3)
		end

		if improvement
			vetor = [1,2,3,4,5]

		else
			splice!(vetor, a)
		end

	end

	return improvement
end


end



