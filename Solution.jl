module Solution

export Solucao, swapVertices, reverseSegment, moveSegment, swapSegments, copySolution

mutable struct Solucao
    caminho::Vector{Int64}
    custo::Float64
    distancia::Array{Float64,2}	
	arestas::Vector{Int64}
    diversidade::Float64
    rankcusto::Int64
    biasedFitness::Float64

	Solucao(caminho::Vector{Int64}, dist::Array{Float64,2}) = new(caminho, custoCaminho(caminho, dist), dist, [], -1, 0, 0) # estados inválidos de arestas em diante

end

# Público
# copy = cópia superficial, objetos compartilham referências
# deepcopy = cópia profunda, cópia todos os subobjetos, cria objetos 100% independentes

# swap
function swapVertices(solucao::Solucao, inicio::Int64, destino::Int64)
	tmp::Int64 = solucao.caminho[inicio]
	solucao.caminho[inicio] = solucao.caminho[destino]
	solucao.caminho[destino] = tmp

	atualizaCusto(solucao)
end

# busca_2opt
function reverseSegment(solucao::Solucao, inicio::Int64, fim::Int64)
	reverse!(solucao.caminho, inicio, fim) 
	
	atualizaCusto(solucao)
end

# orOpt
function moveSegment(solucao::Solucao, inicio::Int64, destino::Int64, K::Int64)
	
	tmp::Vector{Int64} = solucao.caminho[inicio:inicio+K-1]
	signal::Int64 = sign(destino - inicio)
	zero_um = min(signal, 0)

	for i = inicio + zero_um: signal :destino
		solucao.caminho[i - zero_um * K] = solucao.caminho[i+(1 + zero_um) * K]
	end

	#=if inicio < destino
		for i = inicio:destino
			solucao.caminho[i] = solucao.caminho[i+K]
		end
	else
		for i = inicio-1:-1:destino
			solucao.caminho[i+K] = solucao.caminho[i]
		end
	end=#

	for i = 0:K-1
		solucao.caminho[destino+i] = tmp[i+1]
	end

	atualizaCusto(solucao)
end

# pertuba
function swapSegments(solucao::Solucao, p1::Int64, p2::Int64, p3::Int64, p4::Int64)

	seg_1::Vector{Int64} = solucao.caminho[p1:p2]
	seg_2::Vector{Int64} = solucao.caminho[p3:p4]

	for i = length(seg_1):-1:1  ## O loop invertido
		# insert!(collection, index, item)
		insert!(solucao.caminho, p3, seg_1[i])
	end
	
	deleteat!(solucao.caminho, p1:p2)
	deleteat!(solucao.caminho, p3:p4)

	#tamanho_seg_2 = length(seg_2)

	for i = length(seg_2):-1:1  ## O loop invertido
		insert!(solucao.caminho, p1, seg_2[i])
	end

	atualizaCusto(solucao)

end

# Privado

function atualizaCusto(solucao::Solucao)  	
	solucao.custo = custoCaminho(solucao.caminho, solucao.distancia)
end


#custoCaminho(caminho::Vector{Int64}, distancia::Array{Float64,2})::Float64
function custoCaminho(caminho, distancia)

	if length(caminho) == 0
		return typemax(Int64)
	end
	
	custo::Float64 = 0
	for i=1:length(caminho)-1
		custo += distancia[caminho[i], caminho[i+1]]
	end

	return custo
end


end