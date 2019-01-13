BlockChain project file name is SharedTaxiBusiness.sol

Information about functions which is not given with the project assignment paper initially.

I define GetCharge() function payable public. So, customers who use the taxi pays their ticket through this function. 
Charge is sent to contract. Ticket price depends according to callers msg.value. Static ticket value is not used.

Additionally, I didn't see anything about monthlyDriverPay of PaySalary(). I defined monthlyDriverPay as 2 ether.

I defined extra functions such as isParticipantExist(), getBalance(),getCarInfo(), setManager(), etc. for seeing what is going on at current stage. 
They can be usefull for you too.

Hope this helps, Sir. 
