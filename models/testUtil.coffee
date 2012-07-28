class TestUtil

  @printTestResult: (testName, errors, verbose = true) -> 
    if errors.length > 0
      console.log "#{testName} Failed"
      console.dir errors
    else
      console.log "#{testName} OK" if verbose

exports.TestUtil = TestUtil
