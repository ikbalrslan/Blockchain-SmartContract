pragma solidity ^0.4.18;

contract SharedAccount{
    // Contract Owner takes all the money.
    // Contract Owner can close account and share the balance with all accounts.
    // Contract Owner can change contract owner
    
    struct AccountBalance{
        address addr;
        uint balance;
        bool isActive;
    }
    
    //without iteration on array, mapping helps for matching account adresses with their balances
    mapping(address => AccountBalance) accounts;
    
    uint maxAccountCount;
    uint public numberOfAccount;
    
    function SharedAccount(uint _maxAccountCount){
        if(_maxAccountCount !=0 ){
            maxAccountCount = _maxAccountCount;
            
        }else{
            maxAccountCount = 128;
        }
    }
    
    //payable keyword for money depositable account
    function openAccount() payable public {
        require(!isAccountExists(msg.sender));
        require(numberOfAccount < maxAccountCount);
        
        accounts[msg.sender] = AccountBalance(msg.sender, msg.value, true);
        numberOfAccount++;
    }
    
    function withDrawMoney(uint amount) public {
        require(isAccountExists(msg.sender));// modifier ile yapilabilir mi?
        require(accounts[msg.sender].balance >= amount);// modifier ile yapilabilir mi?
        
        msg.sender.transfer(amount);
        accounts[msg.sender].balance -= amount;
    }
    
    function depositMoney() payable public {
        require(isAccountExists(msg.sender)); // modifier ile yapilabilir mi?
        accounts[msg.sender].balance += msg.value; 
    }
    
    function isAccountExists(address accountOwner) private return (bool){
        return accounts[accountOwner].addr != address(0) && accounts[accountOwner].isActive;
    }
}
