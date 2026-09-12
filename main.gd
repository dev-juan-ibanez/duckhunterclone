extends Node2D

var patosnatela
var pato = preload("res://pato.tscn")
var flyaway = 0
var capturados = 0
var vidas = 3
var rodada = 0

var coracao_cheio = preload("res://Material Duck Hunt/coracao_cheio.png")
var coracao_vazio = preload("res://Material Duck Hunt/coracao_vazio.png")

var ranking = [] # {"nome": String, "pontos": int}, mantido enquanto o jogo estiver aberto

func _ready():
	atualizavidas()
	atualizarank()
	$TelaInicio.visible = true

func _process(_delta):
	# Corrigido: Se no seu HUD estiver "Label", mude aqui de Lavel para Label
	$HUD/Label.text = str(capturados)

	# Corrigido: Forma simplificada e precisa para seguir o mouse na Godot 4
	$Alvo.position = get_global_mouse_position()

func _on_comecar_pressed():
	$TelaInicio.visible = false
	capturados = 0
	vidas = 3
	rodada = 0
	atualizavidas()
	$gerapato.start()

func atualizavidas():
	var coracoes = [$HUD/Vida1, $HUD/Vida2, $HUD/Vida3]
	for i in coracoes.size():
		if i < vidas:
			coracoes[i].texture = coracao_cheio
		else:
			coracoes[i].texture = coracao_vazio

func nasce():
	var novop = pato.instantiate()
	add_child(novop)
	novop.add_to_group("patos")
	novop.position.x = randi_range(50, 700)
	novop.position.y = 700
	# Dificuldade sobe com a rodada, até um teto (senão vira bug de física / impossível de detectar colisão)
	novop.speed = min(100 + rodada * 10, 350)
	novop.subida = min(140 + rodada * 8, 400)

func _on_gerapato_timeout():
	rodada += 1
	var max_patos = min(5 + int(rodada / 2), 8)
	patosnatela = randi_range(1, max_patos)
	for n in patosnatela:
		nasce()

func _on_espera_timeout():
	$novo_turno.play()
	$gerapato.start()

func _on_topo_body_entered(body):
	$flyaway.play()
	flyaway = 1
	patosnatela -= 1
	body.queue_free()
	vidas -= 1
	atualizavidas()
	if vidas <= 0:
		fimdejogo()
	else:
		atualizaturno()

func _on_chao_body_entered(body):
	$colidiu.play()
	capturados += 1
	patosnatela -= 1
	body.queue_free()
	atualizaturno()

func atualizaturno():
	if patosnatela <= 0:
		$espera.start()
		if flyaway == 1:
			$cao.play("rindo")
			$cao_rindo.play()
			flyaway = 0
		else:
			$cao.play("captura")
			$cao_captura.play()
			flyaway = 0

func fimdejogo():
	$gerapato.stop()
	$espera.stop()
	for p in get_tree().get_nodes_in_group("patos"):
		p.queue_free()
	registrar_ranking(capturados)
	capturados = 0
	vidas = 3
	rodada = 0
	flyaway = 0
	atualizavidas()
	atualizarank()
	$TelaInicio.visible = true

func registrar_ranking(pontos):
	if pontos <= 0:
		return
	var nome = $TelaInicio/NomeInput.text.strip_edges()
	if nome == "":
		nome = "Jogador"
	ranking.append({"nome": nome, "pontos": pontos})
	ranking.sort_custom(func(a, b): return a["pontos"] > b["pontos"])
	if ranking.size() > 3:
		ranking = ranking.slice(0, 3)

func atualizarank():
	var tem_rank = ranking.size() > 0
	$TelaInicio/RankTitulo.visible = tem_rank
	$TelaInicio/RankLabel.visible = tem_rank
	if not tem_rank:
		return
	var texto = ""
	for i in ranking.size():
		texto += str(i + 1) + "º " + ranking[i]["nome"] + " - " + str(ranking[i]["pontos"]) + "\n"
	$TelaInicio/RankLabel.text = texto
