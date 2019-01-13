pragma solidity >=0.4.22 <0.6.0;

contract SharedTaxiBusiness{
    
    modifier onlyOwner(){
        require(contractOwner == msg.sender);
        _;
    }
    
    modifier notOwner(){
        require(contractOwner != msg.sender);
        _;
    }
    
    modifier notCarDealer(){
        require(carDealer != msg.sender);
        _;
    }
    
    modifier notManager(){
        require(manager != msg.sender);
        _;
    }
    
    modifier notTaxiDriver(){
        require(taxiDriver != msg.sender);
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
    modifier canVote(){
        require(participants[msg.sender].vote != true);
        _;
    }
    
    modifier canPurchase(){
        require(now - carProposed.proposeTime <= carProposed.offerValidTime);
        require(contractBalance >= carProposed.price);
        _;
    }
    
    modifier canSell(){
        require(now - carPurchasedProposed.proposeTime <= carPurchasedProposed.offerValidTime);
        require(msg.value == carPurchasedProposed.price);
        require(carPurchasedProposed.approvalState > (numberOfParticipant / 2), "total votes must be greater than the half of the community");
        _;
    }
    
    modifier hasBalance(){
        require(balances[msg.sender] > 0);
        _;
    }
    
    
    
    
    //without iteration on array, mapping helps for matching participant adresses with their balances
    mapping(address => ParticipantBalance) participants;
    ParticipantBalance[] public participantArray; //for reverting the votes of participants to false;
    mapping(address => uint) private balances;
    //mapping(address => bool) private participantVotes;
    
    
    uint maxParticipantCount;
    uint public numberOfParticipant;
    uint public contractBalance;
    uint public participationFee; //fixed 100 ether
    uint public monthlyDriverPay; //fixed 2 ether
    uint public _fixedExpenses; // fixed per 6 months
    uint public totalExpenses; //all expenses
    
    
    address public contractOwner;
    address public manager;
    address payable public taxiDriver;
    address payable public carDealer;
    
    
    struct ParticipantBalance{
        address addr;
        uint balance;
        bool vote; //for voting the car
    }
    
    struct OwnedCar{
        uint32 carID;
    }
    
    struct ProposedCar{
        uint carID;
        uint price;
        uint offerValidTime;
        uint proposeTime;
    }
    
    //mapping(uint => ProposedCar) public proposedCars;
    ProposedCar public carProposed;
    
    struct ProposedPurchase{
        uint carID;
        uint price;
        uint offerValidTime;
        uint approvalState;
        uint proposeTime;
    }
    
    //mapping(uint => ProposedPurchase) public purchasedCars;
    ProposedPurchase public carPurchasedProposed;
    
    uint public driverPaidTime;
    uint public dealerExpenseTime;
    uint public payDividendTime;
    
    
    
    
    constructor() public {
        contractOwner = msg.sender;
        maxParticipantCount = 100; //fixed 100 participant
        participationFee = 100 ether; //fixed 100 ether
        monthlyDriverPay = 2 ether;
        _fixedExpenses = 10 ether;
        driverPaidTime = 0;
        dealerExpenseTime = 0;
        payDividendTime = 0;
    }
    
    //payable keyword for money depositable account
    function Join() notOwner notCarDealer notManager notTaxiDriver canJoin payable public {
        balances[contractOwner] += participationFee; //keep all contract money here
        contractBalance += participationFee;//keep all contract money here
        participants[msg.sender] = ParticipantBalance(msg.sender, msg.value, false);
        //array keeps the participants for extra conditions
        participantArray.push(ParticipantBalance(msg.sender, msg.value, false));
        numberOfParticipant++;
    }
    
    function SetManager(address _manager) onlyOwner public{ //set manager to a specific adress
        manager = _manager;
    }
    
    function SetCarDealer(address payable _carDealer) onlyManager public{ //set CarDealer to a specific adress
        carDealer = _carDealer;
    }
     
    function CarPropose(uint _carID,uint _price, uint _offerValidTime) onlyCarDealer public{
        //proposedCars[_carID] = ProposedCar(_carID,_price,_offerValidTime);
        carProposed.carID = _carID;
        carProposed.price = _price * 1 ether;
        carProposed.offerValidTime = _offerValidTime * 1 days;
        carProposed.proposeTime = now;
        
    }
    
    function getCarInfo() onlyCarDealer public view returns (uint, uint, uint, uint) {
        //return (proposedCars[_carID].carID, proposedCars[_carID].price, proposedCars[_carID].offerValidTime);
        return(carProposed.carID, carProposed.price, carProposed.offerValidTime, carProposed.proposeTime);
    }
    
    function PurchaseCar() onlyManager canPurchase public{
        contractBalance -= carProposed.price;
        //balances[carDealer] += carProposed.price; //tranfer fonksiyonuna bak
        carDealer.transfer(carProposed.price);
    }
    
    
    function PurchasePropose(uint _price, uint _offerValidTime) onlyCarDealer public{
        //purchasedCars[carProposed.carID] = ProposedPurchase(carProposed.carID,_price,_offerValidTime, 0);
        carPurchasedProposed.carID = carProposed.carID;
        carPurchasedProposed.price = _price * 1 ether;
        carPurchasedProposed.offerValidTime = _offerValidTime * 1 days;
        carPurchasedProposed.approvalState = 0;
        carPurchasedProposed.proposeTime = now;
    }
    
    function SetDriver(address payable _taxiDriver) onlyManager public{
        taxiDriver = _taxiDriver;
    }
    
    function ApproveSellProposal() onlyParticipant canVote public{
        participants[msg.sender].vote = true;
        carPurchasedProposed.approvalState += 1;
    }
    
    /*buraya vote sayısına göre karar eklenecek*/
    function SellCar() onlyCarDealer canSell payable public{
        contractBalance += carPurchasedProposed.price;
        for (uint i=0; i<numberOfParticipant; i++) {
            participants[participantArray[i].addr].vote = false;
        }
        
        
    }
    
    function GetCharge() payable public{
        contractBalance += msg.value;
    }
        
    function PaySalary() onlyManager public{
        if(driverPaidTime != 0){
            require(now - 30 days >= driverPaidTime , "driverPaidTime must take 30 days period.");
        }
        driverPaidTime = now;
        contractBalance -= monthlyDriverPay;
        balances[taxiDriver] += monthlyDriverPay;
    }
    
    function GetSalary() onlyDriver hasBalance() public{
        taxiDriver.transfer(balances[taxiDriver]);
        balances[taxiDriver] = 0;
    }
    
    function CarExpenses() onlyManager public{
        if(dealerExpenseTime != 0){
            require(now - 30 * 6 days >= dealerExpenseTime , "expenses must be sended 6 months period.");
        }
        dealerExpenseTime = now;
        contractBalance -= _fixedExpenses;
        carDealer.transfer(_fixedExpenses);
    }
    
    function PayDividend() onlyManager public{
        if(payDividendTime != 0){
            require(now - 30 * 6 days >= payDividendTime , "pay dividend must be sended 6 months period.");
        }
        payDividendTime = now;
        totalExpenses = monthlyDriverPay + _fixedExpenses;
        contractBalance -= totalExpenses; //all expenses
        uint payOfParticipantTemp = (contractBalance / numberOfParticipant); 
        if(contractBalance > 0){
            for (uint i=0; i<numberOfParticipant; i++) {
                balances[participantArray[i].addr] += payOfParticipantTemp;
                contractBalance -= payOfParticipantTemp;
            }
        }
    }
    
    //Only participant can call this function and can see his/her balance
    function GetDividend() onlyParticipant hasBalance() public{
        msg.sender.transfer(balances[msg.sender]);
        balances[msg.sender] = 0;
    }
    
    function isParticipantExist(address accountOwner) private view returns (bool){
        return participants[accountOwner].addr != address(0);
    }
    
    //for looking the balance of specific account
    function getBalance() public view returns(int){ //int is used for negative participant balance
        return int(balances[msg.sender]);
    }
    
    //Fallback function
    function() external{
        revert();
    }
}