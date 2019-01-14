BlockChain project file name is SharedTaxiBusiness.sol

Information about functions which is not given with the project assignment paper initially.

I define GetCharge() function payable public. So, customers who use the taxi pays their ticket through this function. 
Charge is sent to contract. Ticket price depends according to callers msg.value. Static ticket value is not used.

Additionally, about set manager, transfer and time processes:

-> I didn't see anything about monthlyDriverPay of PaySalary(). I defined monthlyDriverPay as 2 ether.
-> I defined setManager() for changing or setting the manager initially or afterwards.
-> I used contractBalance variable for keeping contract balance. But there is no problem about transfering money.
	-> The deployed address (namely contract adress) has a balance but taking money from any account is performed by payable functions.
	Function caller pays money as entered value and this money is sended to the another account with the transfer function. There is no dubt about that.
	But, again, keeping contract balance in the contractBalance variable does not prevent me from transferring the profit share to the participants, decreasing the expense and other payments. Except for adding money to the contract balance, all transactions are made with the transfer function.

-> In summary, I looked contractBalance for the balance value. There is a simple way to sending balance value to the contract adress(transfer function) but this needs extra gas for each operation, needs extra function defining as payable and needs extra operations. No need for that. If there is a function like getContractBalance in the sheet(like getSalary), I could understand this.

-> Time period of paySalary(), carExpenses() and payDividend() functions starts when function calling for the first time.
	-> For example, driverPaidTime is initially zero. But, if paySalary() is called for the first time, 'now' of time is assigned to the driverPaidTime.

I defined extra functions such as isParticipantExist(), getBalance(),getCarInfo(), etc. for seeing what is going on at current stage. 
They can be usefull for you too.

Hope this helps, Sir. 
