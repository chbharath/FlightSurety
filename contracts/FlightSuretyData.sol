pragma solidity >=0.4.25;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./FlightSuretyApp.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false
    
    uint256 private authorizedAirlineCount = 0;
    uint256 private changeOperatingStatusVote = 0;
    uint256 private insurancebalance = 0;
    address private insuranceAccount;
    uint256 private totalAmount = 0;
    struct Flight {
        uint8 statusCode;
        uint256 updatedTimestamp;
        Airline airline;
    }
    struct Airline {
        string name;
        address account;
        bool isRegistered;
        bool isAuthorized;
        bool operationalVote;
    }
    struct Insuree {
        address payable account;
        uint256 insuranceAmount;
        uint256 payoutBalance;
    }

    mapping(address => uint256) private funding;
    mapping(bytes32 => Flight) private flights;
    mapping(address => Airline) airlines;
    mapping(address => Insuree) private insurees;
    mapping(address => uint256) private creditBalance;

    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/
    
    event RegisteredAirline(address airline);
    event AuthorizedAirline(address airline);
    event BoughtInsurance(address caller, bytes32 key, uint256 amount);
    event CreditInsuree(address airline, address insuree, uint256 amount);
    event PayInsuree(address airline, address insuree, uint256 amount);

    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor
                                (
                                ) 
                                public 
    {
        contractOwner = msg.sender;
        airlines[contractOwner] = Airline({
            name: "Bharath",
            account: contractOwner,
            isRegistered: true,
            isAuthorized: true,
            operationalVote: true
        });

        authorizedAirlineCount = authorizedAirlineCount.add(1);
        emit RegisteredAirline(contractOwner);
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational() 
    {
        require(operational, "Contract is currently not operational");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }
    
    modifier requireIsAuthorized()
    {
        require(airlines[msg.sender].isAuthorized, "Airline should be authorized");
        _;
    }
    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */      
    function isOperational() 
                            external 
                            view 
                            returns(bool) 
    {
        return operational;
    }


    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */    
    function setOperatingStatus
                            (
                                bool mode
                            ) 
                            external
                            requireContractOwner 
    {
        address caller = msg.sender;

        if(authorizedAirlineCount < 4){
            operational = mode;
        } else {
            changeOperatingStatusVote = changeOperatingStatusVote.add(1);
            airlines[caller].operationalVote = mode;
            if(changeOperatingStatusVote >= (authorizedAirlineCount.div(2))){
                operational = mode;
                changeOperatingStatusVote = authorizedAirlineCount - changeOperatingStatusVote;
            }
        }
        
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

   /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *
    */   
    function registerAirline
                            (   string calldata name,
                                address airline
                            )
                            external
                            requireIsOperational
    {
         require(!airlines[airline].isRegistered,"airline is already registered");
         if(authorizedAirlineCount <=4){
             airlines[airline] = Airline({
                 name: name,
                 account: airline,
                 isRegistered: true,
                 isAuthorized: false,
                 operationalVote: true
             });
            authorizedAirlineCount = authorizedAirlineCount.add(1);
         }

         emit RegisteredAirline(airline);
          
    }


   /**
    * @dev Buy insurance for a flight
    *
    */   
    function buy
                            (      
                                address payable airline,
                                address insuree,
                                string calldata flight,
                                uint256 timeStamp,
                                uint256 amount                       
                            )
                            requireIsOperational
                            external
                            payable
    {
        require(insurees[insuree].account == insuree, "Provide insuree account address");
        require(msg.sender == insuree, "only insuree can call this function");
        require(amount == msg.value, "amount should be same as value sent");
        bytes32 key = getFlightKey(airline, flight, timeStamp);
        airline.transfer(amount);
        insurees[insuree].insuranceAmount += amount;
        insurancebalance += amount;

        emit BoughtInsurance(msg.sender, key, amount);
    }

    /**
     *  @dev Credits payouts to insurees
    */
    function creditInsurees
                                (
                                    address airline,
                                    address insuree,
                                    uint256 creditAmount
                                )
                                external
                                requireIsOperational
    {
        require(insurees[insuree].insuranceAmount >= creditAmount);

        insurees[insuree].payoutBalance = creditAmount;
        emit CreditInsuree(airline,insuree, creditAmount);
    }
    

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
    function pay
                            (
                                address payable airline,
                                address payable insuree,
                                uint256 payoutAmount
                            )
                            external
                            requireIsOperational
    {
        require(msg.sender == airline);
        insurees[insuree].account.transfer(payoutAmount);
        emit PayInsuree(airline, insuree, payoutAmount);
    }

   /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance payouts, the contract should be self-sustaining
    *
    */   
    function fund
                            (   
                                address payable airline
                            )
                            public
                            payable
                            requireIsOperational
    {
        require(msg.value >= 10 ether, "Minimum 10 ether should be funded");
        require(airlines[airline].isRegistered, "Account must be registered before funding");

        totalAmount = totalAmount.add(msg.value);
        airline.transfer(msg.value);

        if(!airlines[airline].isAuthorized){
            airlines[airline].isAuthorized = true;
            authorizedAirlineCount = authorizedAirlineCount.add(1);
            emit AuthorizedAirline(airline);
        }
    }

    function getFlightKey
                        (
                            address airline,
                            string memory flight,
                            uint256 timestamp
                        )
                        pure
                        internal
                        returns(bytes32) 
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    function() 
                            external 
                            payable 
    {
        fund(msg.sender);
    }


}

