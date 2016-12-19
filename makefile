all: trabalho codigosTeste/
	./trabalho < ./codigosTeste/MDC.br > codigosGerado/MDC.cc
	./gabarito < codigosGerado/MDC.cc
	g++ -o outputs/saidamdc codigosGerado/MDC.cc
	./trabalho < ./codigosTeste/concatenacaoStrings.br > codigosGerado/concatenacaoStrings.cc
	./gabarito < codigosGerado/concatenacaoStrings.cc
	g++ -o outputs/saidaconcatenacao codigosGerado/concatenacaoStrings.cc
	./trabalho < ./codigosTeste/controleDeFluxo.br > codigosGerado/controleDeFluxo.cc
	./gabarito < codigosGerado/controleDeFluxo.cc
	g++ -o outputs/saidacontrole codigosGerado/controleDeFluxo.cc
	./trabalho < ./codigosTeste/multMatriz.br > codigosGerado/multMatriz.cc
	./gabarito < codigosGerado/multMatriz.cc
	g++ -o outputs/saidamultmatriz codigosGerado/multMatriz.cc
	./trabalho < ./codigosTeste/ref.br > codigosGerado/ref.cc
	./gabarito < codigosGerado/ref.cc
	g++ -o outputs/saidaref codigosGerado/ref.cc
	./trabalho < ./codigosTeste/testeIn.br > codigosGerado/testeIn.cc
	./gabarito < codigosGerado/testeIn.cc
	g++ -o outputs/saidatestein codigosGerado/testeIn.cc

lex.yy.c: trabalho.lex
	lex trabalho.lex

y.tab.c: trabalho.y
	yacc -v trabalho.y

trabalho: lex.yy.c y.tab.c
	g++ -std=c++11 -o trabalho y.tab.c -lfl
