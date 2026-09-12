extends CharacterBody2D

var lado = 1
var speed = 100
var subida = 140
var queda = 1

func _ready():
	$quack.wait_time = randf_range(0.8, 2)
	$quack.start()
	
	$movimento.wait_time = randf_range(0.4, 2)
	$movimento.start()
	
	$anima.wait_time = randf_range(0.6, 1)
	$anima.start() # <-- Corrigido: Agora ele inicia!
	
	$AnimatedSprite2D.play("cima")

func _physics_process(delta): # <-- Corrigido: Nós de física usam physics_process
	# Configura as velocidades nativas
	velocity.x = speed * lado
	velocity.y = -subida * queda
	
	# Move o corpo aplicando a física e detectando colisões automaticamente
	move_and_slide()
	
	# Espelhamento da imagem
	if lado < 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false

func _on_movimento_timeout():
	lado = lado * (-1)

func _on_anima_timeout():
	# Só troca animação se não estiver com susto ou morto
	if $AnimatedSprite2D.animation != "susto" and $AnimatedSprite2D.animation != "morte":
		if $AnimatedSprite2D.animation == "cima":
			$AnimatedSprite2D.animation = "lado"
		elif $AnimatedSprite2D.animation == "lado":
			$AnimatedSprite2D.animation = "cima"

func mata():
	$AnimatedSprite2D.animation = "susto"
	$morte.start() 

func _on_morte_timeout():
	$quack.stop()
	$AnimatedSprite2D.animation = "morte"
	queda = -1       # Inverte para fazê-lo cair
	lado = 0
	
func _on_quack_timeout():
	$audio.play()
