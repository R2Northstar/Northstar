global function Testing_Init
global function RunAllTests
global function RunAllTests_SaveToFile
global function RunTestsByCategory
global function RunTestByCategoryAndName

global function AddTest

struct TestInfo
{
	string testName
	var functionref() callback
	// whether the test completed successfully
	// if this is true, actualResult is valid
	bool completed
	// var not string because then i can just set it to an exception
	// which print can then handle
	var error
	// whether the test is considered successful
	var expectedResult
	var actualResult
	bool passed
}

struct {
	table< string, array< TestInfo > > tests = {}
} file

void function Testing_Init()
{
	// tests for the testing functions :)
	//AddTest( "Example Tests", "example succeeding test", ExampleTest_ReturnsTrue, true )
	//AddTest( "Example Tests", "example failing test", ExampleTest_ReturnsFalse, true )
	//AddTest( "Example Tests", "example erroring test", ExampleTest_ThrowsError, true )
	//AddTest( "Example Tests", "example test with args", var function() {
	//	return ExampleTest_HasArgs_ReturnsNonVar( 2, 3 )
	//}, 6 )
}

int function ExampleTest_HasArgs_ReturnsNonVar( int first, int second )
{
	return first * second
}

var function ExampleTest_ReturnsFalse()
{
	return false
}

var function ExampleTest_ReturnsTrue()
{
	return true
}

var function ExampleTest_ThrowsError()
{
	throw "Example exception"
	return null
}

void function RunAllTests_SaveToFile()
{
	RunAllTests()

	#if UI
	string fileName = "ns-unit-tests-UI.json"
	#elseif CLIENT
	string fileName = "ns-unit-tests-CLIENT.json"
	#elseif SERVER
	string fileName = "ns-unit-tests-SERVER.json"
	#endif

	// cant encode structs so have to reconstruct a table manually from the structs
	table out = {}
	foreach ( category, tests in file.tests )
	{
		array categoryResults = []
		foreach ( test in tests )
		{
			table testTable = {}
			testTable[ "name" ] <- test.testName
			testTable[ "completed" ] <- test.completed
			testTable[ "passed" ] <- test.passed
			if ( !test.completed )
				testTable[ "error" ] <- test.error
			else if ( !test.passed )
			{
				testTable[ "expectedResult" ] <- test.expectedResult
				testTable[ "actualResult" ] <- test.actualResult
			}

			categoryResults.append( testTable )
		}
		out[ category ] <- categoryResults
	}

	NSSaveJSONFile( fileName, out )
}

void function RunAllTests()
{
	printt( "Running all tests!" )

	foreach ( category, categoryTests in file.tests )
	{
		foreach ( test in categoryTests )
		{
			RunTest( test )
		}
	}

	PrintAllTestResults()
}

void function RunTestsByCategory( string category )
{
	if ( !( category in file.tests ) )
	{
		printt( format( "Category '%s' has no tests registered", category ) )
		return
	}

	foreach ( categoryTest in file.tests[ category ] )
	{
		RunTest( categoryTest )
	}
}

void function RunTestByCategoryAndName( string category, string testName )
{
	// find test
	if ( !( category in file.tests ) )
	{
		printt( format( "Category '%s' has no tests registered", category ) )
		return
	}

	TestInfo ornull foundTest = null
	foreach ( categoryTest in file.tests[ category ] )
	{
		if ( categoryTest.testName == testName )
		{
			foundTest = categoryTest
			break
		}
	}

	if ( !foundTest )
	{
		printt( format( "Category '%s' does not contain a test with name '%s'", category, testName ) )
		return
	}

	expect TestInfo( foundTest )
	
	printt( "Running test!" )
	// run test
	RunTest( foundTest )
	// print result
	PrintTestResult( foundTest )
}

void function RunTest( TestInfo test )
{
	test.completed = false
	test.passed = false
	test.actualResult = null
	test.error = ""

	try
	{
		test.actualResult = test.callback()
		test.completed = true
		test.passed = test.actualResult == test.expectedResult
	}
	catch ( exception )
	{
		test.completed = false
		test.error = exception
	}
}

void function PrintAllTestResults()
{
	int totalSucceeded = 0
	int totalFailed = 0
	int totalErrored = 0

	foreach ( category, categoryTests in file.tests )
	{
		int categorySucceeded = 0
		int categoryFailed = 0
		int categoryErrored = 0

		printt( format( "Results for category: '%s'", category ) )
		foreach ( test in categoryTests )
		{
			if ( test.completed )
			{
				if ( test.passed )
				{
					printt( "\t", test.testName, "- Passed!" )
					categorySucceeded++
				}
				else
				{
					printt( "\t", test.testName, "- Failed!" )
					printt( "\t\tExpected:", test.expectedResult )
					printt( "\t\tActual:  ", test.actualResult )
					categoryFailed++
				}
			}
			else
			{
				printt( "\t", test.testName, "- Errored!" )
				printt( "\t\tError:", test.error )
				categoryErrored++
			}
		}

		printt( "Succeeded:", categorySucceeded, "Failed:", categoryFailed, "Errored:", categoryErrored )

		totalSucceeded += categorySucceeded
		totalFailed += categoryFailed
		totalErrored += categoryErrored
	}

	printt( "TOTAL SUCCEEDED:", totalSucceeded, "TOTAL FAILED:", totalFailed, "TOTAL ERRORED:", totalErrored )
}

void function PrintCategoryResults( string category )
{
	int categorySucceeded = 0
	int categoryFailed = 0
	int categoryErrored = 0

	printt( format( "Results for category: '%s'", category ) )
	foreach ( test in file.tests[ category ] )
	{
		if ( test.completed )
		{
			if ( test.passed )
			{
				printt( "\t", test.testName, "- Passed!" )
				categorySucceeded++
			}
			else
			{
				printt( "\t", test.testName, "- Failed!" )
				printt( "\t\tExpected:", test.expectedResult )
				printt( "\t\tActual:  ", test.actualResult )
				categoryFailed++
			}
		}
		else
		{
			printt( "\t", test.testName, "- Errored!" )
			printt( "\t\tError:", test.error )
			categoryErrored++
		}
	}

	printt( "Succeeded:", categorySucceeded, "Failed:", categoryFailed, "Errored:", categoryErrored )
}

void function PrintTestResult( TestInfo test )
{
	string resultString = test.testName

	if ( test.completed )
	{
		if ( test.passed )
			resultString += " - Passed!"
		else
		{
			resultString += " - Failed!"
			resultString += "\n\tExpected: " + test.expectedResult
			resultString += "\n\tActual:   " + test.actualResult
		}
	}
	else
	{
		resultString += " - Not completed!"
		resultString += "\n\tError: " + test.error
	}

	printt( resultString )
}

void function AddTest( string testCategory, string testName, var functionref() testFunc, var expectedResult )
{
	TestInfo newTest
	newTest.testName = testName
	newTest.callback = testFunc
	newTest.expectedResult = expectedResult

	// create the test category if it doesn't exist
	if ( !( testCategory in file.tests ) )
		file.tests[ testCategory ] <- [ newTest ]
	else
		file.tests[ testCategory ].append( newTest )
}
