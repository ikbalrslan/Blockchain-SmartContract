pragma solidity ^0.4.20;

contract SharedTaxiBusiness{
    
    modifier onlyOwner(){
        require(contractOwner == msg.sender);
        _;
    }
    
    modifier notOwner(){
        require(contractOwner != msg.sender);
        _;
    }
    
    modifier onlyParticipant(){
        require(participants[msg.sender].addr == msg.sender);
        _;
    }
    
    modifier onlyManager(){
        require(manager == msg.sender);
        _;
    }
    
    modifier onlyCarDealer(){
        require(carDealer == msg.sender);
        _;
    }
    
    modifier onlyDriver(){
        require(taxiDriver == msg.sender);
        _;
    }
    
    modifier canJoin(){
        require(!isParticipantExist(msg.sender)); //if participation doesn't exist already
        require(numberOfParticipant < maxParticipantCount);
        require(msg.value == participationFee);
        _;
    }
    
    
    
    
    //without iteration on array, mapping helps for matching participant adresses with their balances
    mapping(address => ParticipantBalance) participants;
    mapping(address => uint) private balances;
    
    uint maxParticipantCount;
    uint public numberOfParticipant;
    uint public contractBalance;
    uint public participationFee; //fixed 100 ether
    
    address contractOwner;
    address manager;
    address taxiDriver;
    address carDealer;
    uint public _fixedExpenses;
    
    struct ParticipantBalance{
        address addr;
        uint balance;
    }
    
    struct OwnedCar{
        uint32 carID;
    }
    
    struct ProposedCar{
        uint carID;
        uint price;
        uint offerValidTime;
    }
    
    mapping(uint => ProposedCar) public cars;
    ProposedCar public car1;
    
    struct ProposedPurchase{
        uint32 carID;
        uint price;
        uint offerValidTime;
        uint approvalState;
    }
    
    uint timeHadle;
    
    
    
    function SharedTaxiBusiness() public {
        contractOwner = msg.sender;
        maxParticipantCount = 5; //fixed 100 participant
        participationFee = 50 ether; //fixed 100 ether
    }
    
    //payable keyword for money depositable account
    function Join() notOwner canJoin payable public {
        //balances[msg.sender] -= participationFee;
        balances[contractOwner] += participationFee; //keep all contract money here
        //contractBalance += participationFee;//keep all contract money here
        participants[msg.sender] = ParticipantBalance(msg.sender, msg.value);
        numberOfParticipant++;
    }
    
    function SetManager(address _manager) onlyOwner public{ //set manager to a specific adress
        manager = _manager;
    }
    
    function SetCarDealer(address _carDealer) onlyManager public{ //set CarDealer to a specific adress
        carDealer = _carDealer;
    }
     
    function CarPropose(uint32 _carID,uint _price, uint _offerValidTime) onlyCarDealer public{
        cars[_carID] = ProposedCar(_carID,_price,_offerValidTime);
        car1.carID = _carID;
        car1.price = _price;
        car1.offerValidTime = _offerValidTime;
        
    }
    
    function getCarInfo(uint _carID) onlyCarDealer public constant returns (uint, uint, uint) {
        return (cars[_carID].carID, cars[_carID].price, cars[_carID].offerValidTime);
    }
    
    
    /*
    function PurchaseCar() onlyManager public{}
    
    function PurchasePropose() onlyCarDealer public{}
    
    function ApproveSellProposal() onlyParticipant public{}
    
    function SellCar() onlyCarDealer public{}
    
    function SetDriver() onlyManager public{}
    
    function GetCharge() public{}
    
    function PaySalary() onlyManager{}
    
    function GetSalary() onlyDriver{}
    
    function CarExpenses() onlyManager{}
    
    function PayDividend() onlyManager{}
    */
    
    //Only participant can call this function and can see his/her balance
    function GetDividend() onlyParticipant public constant returns (uint) {
        //require(balances[msg.sender] != 0);
        //msg.sender.transfer(balances[msg.sender]);
        //return msg.value;
        return msg.sender.balance;
    }
    
    function isParticipantExist(address accountOwner) private constant returns (bool){
        return participants[accountOwner].addr != address(0);
    }
    
    //for looking the balance of specific account
    function getBalance() public constant returns(int){ //int is used for negative participant balance
        return int(balances[msg.sender]);
    }
    
    
    /*
    //Fallback function
    function(){
        throw;
    }
    */
}