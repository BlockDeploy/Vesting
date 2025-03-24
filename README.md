
### Instructions for Using Vesting

**Description:**  `Vesting`  is a Solidity 0.8.7 contract for gradually releasing  
tokens (ETH or ERC-20) according to a set schedule. It allows "locking" funds for a beneficiary and releasing them  
in parts or fully over time — perfect for employee payments, investor allocations, or DAO participants as of March 2025.  
**How it works:**  The contract owner creates a vesting schedule, specifying the amount, token, beneficiary,  
and duration (e.g., 1 year). The beneficiary can withdraw the available amount via  `claim`  as time progresses,  
proportional to the elapsed duration.  
**Advantages:**  Flexibility (supports ETH and tokens, customizable duration), security (only the owner can  
create vesting), transparency (all data on the blockchain).  
**What it offers:**  Controlled asset distribution with protection against immediate withdrawal.

**Compilation:**  Go to the "Deploy Contracts" page in BlockDeploy,  
paste the code into the "Contract Code" field (it uses the IERC20 interface for tokens),  
select Solidity version 0.8.7 from the dropdown menu,  
click "Compile" — the "ABI" and "Bytecode" fields will populate automatically.

**Deployment:**  In the "Deploy Contract" section:  
- Select the network (Ethereum Mainnet, BNB Chain),  
- Enter the private key of a wallet with ETH/BNB for gas in the "Private Key" field,  
- The constructor requires no parameters, click "Deploy",  
- Review the network and fee in the modal window and confirm.  
After deployment, you’ll get the contract address (e.g.,  `0xYourVestingAddress`) in the BlockDeploy logs.

**How to Use Vesting:**  

-   **Create a Vesting:**  The owner calls  `vest`,  
    specifying: the beneficiary address (e.g.,  `0xEmployee`), amount (e.g., 1000000000000000000 for 1 ETH),  
    token address (`0x0`  for ETH or, e.g.,  `0x6B175474E89094C44Da98b954EedeAC495271d0F`  for DAI),  
    and duration in seconds (e.g., 31536000 for 1 year). For ETH, send the amount with the transaction;  
    for tokens, pre-approve the contract via  `approve`.
-   **Check Available Amount:**  The beneficiary calls  `getVestingInfo`,  
    to view the total amount, claimed amount, and currently available amount.
-   **Withdraw Tokens:**  The beneficiary calls  `claim`,  
    to withdraw the amount available at that moment (released proportionally to elapsed time).

**Example Workflow:**  
- The owner creates a vesting for  `0xEmployee`  with 10 ETH and a 1-year duration (31536000 seconds).  
- After 6 months (`block.timestamp`  + 15768000 seconds), the employee calls  `claim`  and receives 5 ETH  
(half the amount, as half the time has passed).  
- After a year, they call  `claim`  again and withdraw the remaining 5 ETH.  
If it were a token like DAI, the process would be identical but with ERC-20 mechanics.
