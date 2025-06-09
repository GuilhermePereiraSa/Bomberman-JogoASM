include paths.mk

# Caminhos locais para o montador e simulador.
# Para o funcionamento correto, o arquivo paths.mk deve conter
# a definição ambos os caminhos. 
# Há um exemplo de como deve ser o arquivo em paths.mk.example
assembler_path ?= "path/to/assembler"
simulator_path ?= "path/to/simulator"


source_path := bomberman
charmap := $(source_path)/charmap.mif

simulate: $(source_path)/player-bomberman.mif $(charmap)
	$(simulator_path) $^


bomberman/player-bomberman.mif:
	$(assembler_path) bomberman/player-bomberman.asm $@
