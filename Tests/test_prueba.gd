extends GutTest

func test_positive_1():
	var palabra = "palabra"
	var tamanyo = palabra.length()
	
	assert_eq(tamanyo, 7, "Palabra deberia tener 7 letras")
	
func test_negative_1():
	var palabra = "palabra"
	var tamanyo = palabra.length()
	
	assert_ne(tamanyo, 8, "Palabra no tiene 8 letras")
