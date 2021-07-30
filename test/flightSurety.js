
var Test = require('../config/testConfig.js');
var BigNumber = require('bignumber.js');



contract('Flight Surety Tests', async (accounts) => {

  var config;
  before('setup contract', async () => {
    config = await Test.Config(accounts);
    //await config.FlightSuretyData.authorizeCaller(config.FlightSuretyApp.address);
  });
  
  let contractOwner = accounts[0];
  /****************************************************************************************/
  /* Operations and Settings                                                              */
  /****************************************************************************************/

  it(`(multiparty) has correct initial isOperational() value`, async function () {

    // Get operating status
    let status = await config.flightSuretyData.isOperational.call();
    assert.equal(status, true, "Incorrect initial operating status value");

  });

  it(`(multiparty) can block access to setOperatingStatus() for non-Contract Owner account`, async function () {

      // Ensure that access is denied for non-Contract Owner account
      let accessDenied = false;
      try 
      {
          await config.flightSuretyData.setOperatingStatus(false, { from: config.testAddresses[2] });
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, true, "Access not restricted to Contract Owner");
            
  });

  it(`(multiparty) can allow access to setOperatingStatus() for Contract Owner account`, async function () {

      // Ensure that access is allowed for Contract Owner account
      let accessDenied = false;
      try 
      {
          await config.flightSuretyData.setOperatingStatus(false, { from: contractOwner });
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, false, "Access not restricted to Contract Owner");
      
  });

  it(`(multiparty) can block access to functions using requireIsOperational when operating status is false`, async function () {

      await config.flightSuretyData.setOperatingStatus(false);

      let reverted = false;
      try 
      {
          await config.flightSurety.setTestingMode(true);
      }
      catch(e) {
          reverted = true;
      }
      assert.equal(reverted, true, "Access not blocked for requireIsOperational");      

      // Set it back for other tests to work
      await config.flightSuretyData.setOperatingStatus(true);

  });

  it('(airline) cannot register an Airline using registerAirline() if it is not funded', async () => {
    
    // ARRANGE
    let newAirline1 = accounts[1];
    let newAirline2 = accounts[2];
    let newAirline3 = accounts[3];
    let newAirline4 = accounts[4];
    let newAirline5 = accounts[5];
    //let newAirline2 = accounts[2];
    // ACT
    try {
        await config.flightSuretyData.registerAirline("New Airline1", newAirline1, {from: config.firstAirline});
    }
    catch(e) {
        console.log(e)
    }

    //try {
    //    await config.flightSuretyData.fund(newAirline1, {from: config.newAirline1});
    //}
    //catch(e) {
    //    console.log(e)
    //}

    try {
        await config.flightSuretyData.registerAirline("New Airline2", newAirline2, {from: newAirline1});
    }
    catch(e) {
        console.log(e)
    }


    let result = await config.flightSuretyData.isAirline.call(newAirline1); 
    let result1 = await config.flightSuretyData.isAuthorized.call(newAirline1);
    // ASSERT
    assert.equal(result && result1, false, "Airline should not be able to register another airline if it hasn't provided funding");

  });
 

  it('(multiparty) can register an Airline using registerAirline() if it is funded', async () => {
    
    // ARRANGE
    let newAirline1 = accounts[1];
    let newAirline2 = accounts[2];
    let newAirline3 = accounts[3];
    let newAirline8 = accounts[8];
    let newAirline9 = accounts[9];
    // ACT
    try {
        await config.flightSuretyData.registerAirline("New Airline8", newAirline8, {from: config.firstAirline});
    }
    catch(e) {
        console.log(e)
    }

    try {
        await config.flightSuretyData.fund(newAirline8, {from: newAirline8, value: 10000000000000000000});
    }
    catch(e) {
        console.log(e)
    }

    try {
        await config.flightSuretyData.registerAirline("New Airline9", newAirline9, {from: newAirline8});
    }
    catch(e) {
        console.log(e)
    }


    let result = await config.flightSuretyData.isAirline.call(newAirline8);
    console.log(result);
    let result1 = await config.flightSuretyData.isAuthorized.call(newAirline8);
    console.log(result1);
    // ASSERT
    assert.equal(result && result1, true, "Airline should be able to register another airline if it has provided funding");

  });

  it('(multiparty) fifth airline can be registered with multiparty concensus', async () => {
    
    // ARRANGE
    let newAirline1 = accounts[1];
    let newAirline2 = accounts[2];
    let newAirline3 = accounts[3];
    let newAirline4 = accounts[4];
    let newAirline5 = accounts[5];
    let newAirline6 = accounts[6];
    let newAirline7 = accounts[7];
    let newAirline8 = accounts[8];
    let newAirline9 = accounts[9];
    let newAirline10 = accounts[10];
    // ACT
    await config.flightSuretyData.registerAirline("New Airline4", newAirline4, {from: config.firstAirline});
    await config.flightSuretyData.fund(newAirline4, {from: newAirline4, value: 10000000000000000000});
    
    await config.flightSuretyData.registerAirline("New Airline5", newAirline5, {from: newAirline4});
    await config.flightSuretyData.fund(newAirline5, {from: newAirline5, value: 10000000000000000000});

    // await config.flightSuretyData.fund(newAirline3, {from: newAirline3, value: 10000000000000000000});
    // await config.flightSuretyData.registerAirline("New Airline3", newAirline3, {from: newAirline2});

    // await config.flightSuretyData.fund(newAirline4, {from: newAirline4, value: 10000000000000000000});
    // await config.flightSuretyData.registerAirline("New Airline4", newAirline4, {from: newAirline3});

    // await config.flightSuretyData.fund(newAirline5, {from: newAirline5, value: 10000000000000000000});
    // await config.flightSuretyData.registerAirline("New Airline5", newAirline5, {from: newAirline4});

    //await config.flightSuretyData.registerAirline("New Airline3", newAirline3, {from: newAirline2});

    let result = await config.flightSuretyData.isAirline.call(newAirline5);
    console.log(result);
    let result1 = await config.flightSuretyData.isAuthorized.call(newAirline5);
    console.log(result1);
    // ASSERT
    assert.equal(result && result1, true, "Fifth airline and later should be registered only with majority concensus");

  });


});
