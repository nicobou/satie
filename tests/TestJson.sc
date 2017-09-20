TestJson : UnitTest {
	var input;

	test_stringify {
		input = 0.0 / 0.0;
		this.assert(ToJSON.stringify(input) == "null", "should be null");
		input = 1.0 / 0.0;
		this.assert(ToJSON.stringify(input) == "null", "should be null");
		input = 2;
		this.assert(ToJSON.stringify(input) == "2", "should be a string '2'");
		input = \test;
		this.assert(ToJSON.stringify(input).class === String, "should be a string");
		input = "a string";
		this.assert(ToJSON.stringify(input).class === String, "should be a string");
	}

	test_fromArray {
		input = [1,2,3,"boo"];
		this.assert(ToJSON.fromArray(input).class === String, "should be a string");
	}

	test_fromDict {
		input = Dictionary.newFrom(List[\a, 1, \b, 2, \c, 3]);
		this.assert(ToJSON.fromDict(input).class === String, "should be a string");
	}

}