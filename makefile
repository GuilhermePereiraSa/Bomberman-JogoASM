include paths.mk

# Caminhos locais para o montador e simulador.
# Para o funcionamento correto, o arquivo paths.mk deve conter
# a definição ambos os caminhos. 
# Há um exemplo de como deve ser o arquivo em paths.mk.example
assembler_path ?= "path/to/assembler"
simulator_path ?= "path/to/simulator"

.PHONY: clear

source_path := bomberman
program_name := player-bomberman
charmap := $(source_path)/charmap.mif

simulate: $(source_path)/$(program_name).mif $(charmap)
	$(simulator_path) $^

assemble: $(source_path)/$(program_name).mif

clear:
	rm $(source_path)/$(program_name).mif

$(source_path)/$(program_name).mif: $(source_path)/$(program_name).asm
	$(assembler_path) $(source_path)/$(program_name).asm $@
