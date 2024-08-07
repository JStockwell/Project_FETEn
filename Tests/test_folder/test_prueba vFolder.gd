extends GdUnitTestSuite

func test_positive_1_vFolder():
	var palabra = "palabra"
	var tamanyo = palabra.length()
	
	assert_that(tamanyo).is_equal(7)
	
func test_negative_1_vFolder():
	var palabra = "palabra"
	var tamanyo = palabra.length()
	
	assert_that(tamanyo).is_not_equal(8)
