extends GutTest

func test_positive_1():
	var palabra = "palabra"
	var tamanyo = palabra.length()
	
	assert_eq(tamanyo, 7, "El tamaño es igual")
	
func test_negative_1():
	var palabra = "palabra"
	var tamanyo = palabra.length()
	
	assert_ne(tamanyo, 8, "El tamaño no es igual")
