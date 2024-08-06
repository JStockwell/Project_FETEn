extends GdUnitTestSuite

func test_positive_1():
	var palabra = "palabra"
	var tamanyo = palabra.length()
	
	assert_that(tamanyo).is_equal(8)
	
func test_negative_1():
	var palabra = "palabra"
	var tamanyo = palabra.length()
	
	assert_that(tamanyo).is_not_equal(8)
