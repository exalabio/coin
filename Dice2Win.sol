pragma solidity ^0.4.24;

contract Dice2Win {

    /**
        owner setting
     */
    address creator;
    address owner;
    bool activated_ = true;

    /**
        24h Total bet amounts/counts
     */
    uint256 totalAmount_;
    uint256 counts_;
    uint256 jackpotAmount_;
    uint256 jackpotAddress_;
    
    uint256 lockedInValues_;
    
    event Total (
        uint256 totalAmount,
        uint256 counts,
        uint256 jackpotAmount,
        address lastJackpotAddress
    );
    
    // Events that are issued to make statistic recovery easier.
    event FailedPayment(address indexed beneficiary, uint amount);
    event Payment(address indexed beneficiary, uint amount);
    // event JackpotPayment(address indexed beneficiary, uint amount);
    
    /**
        Constructor
     */
    constructor () 
        public
    {
        // 컨트랙트 등록 시 , owner에 세팅한다. 
        creator = msg.sender;

    }

    /**
        Modifier
     */
    modifier isActivated() {
        require(activated_ == true, "its not ready yet. check."); 
        _;
    }
    
    // Standard modifier on methods invokable only by contract owner.
    modifier onlyOwner {
        require (msg.sender == creator || msg.sender == owner, "OnlyOwner methods called by non-owner.");
        _;
    }
    
    /**
     * @dev prevents contracts from interacting with fomo3d 
     */
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        
        assembly {
            _codeLength := extcodesize(_addr)
        }
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    
    // Fallback function deliberately left empty. It's primary use case
    // is to top up the bank roll.
    // function () public payable {
    // }
    
    function setOwner(address _owner) external onlyOwner {
        owner = _owner;
    }
    
    // Contract may be destroyed only when there are no ongoing bets,
    // either settled or refunded. All funds are transferred to contract owner.
    function kill() external onlyOwner {
        require (lockedInValues_ == 0, "All bets should be processed (settled or refunded) before self-destruct.");
        selfdestruct(owner);
    }

    // Helper routine to process the payment.
    function sendFunds(address beneficiary, uint amount, uint successLogAmount) payable public {
        if (beneficiary.send(amount)) {
            emit Payment(beneficiary, successLogAmount);
        } else {
            emit FailedPayment(beneficiary, amount);
        }
    }
    
    // Helper routine to process the payment.
    function transferFunds(address beneficiary, uint amount, uint successLogAmount) private {
        bool succ = false;
        beneficiary.transfer(amount);
        
        if(succ){
            emit Payment(beneficiary, successLogAmount);
        } else {
            emit FailedPayment(beneficiary, amount);
        }
    }
    

    /**
        External functions
        외부에서만 호출가능
     */
    event External (uint256 a, uint256 b, string c);
    function externalfn(uint256 val) 
        external
        onlyOwner
        returns (uint256 a, uint256 b, string c)
    {
        require(val > 0, "upper 0.");
        require(val < 10, "possible min to 10.");
        
        // 0xb23bd17a66c252997b6bbceac6ee023b6ab1c3c8
        sendFunds(address(this), 10 ether, 10 ether);
        // transferFunds(address(this), 10 ether, 10 ether);
        
        emit External(address(this).balance,msg.sender.balance,"str3");
        return (address(this).balance,4,"str5");
    }

    /**
        Public functions
        내/외부를 포함, web3등 rpc도 호출가능
     */
    event Active (uint256 a, uint256 b, string c);
    function activate()
        public
    {
        // only team just can activate 
        require(
            msg.sender == 0xb5cafd2642494770f2a01d56b5942c89286e73a3 ||
            msg.sender == 0x77ec2baa4454d7b0db667299b6918e4520e16332,
            "only owner can activate"
        );

        // make sure that its been linked.
        // require(address(otherF3D_) != address(0), "must link to other FoMo3D first");
        
        // can only be ran once
        require(activated_ == false, "Dice2Win already activated");
        
        // activate the contract 
        activated_ = true;
        
    }

    /**
        Internal functions

     */
    event Internal (uint256 a);
    function internalfn() 
        internal 
    {
        emit Internal(3);
    }

    /**
        Private functions
     */
    event Private (uint256 a);
    function privatefn(uint256 a) 
        private 
    returns (uint256 d, uint256 e, string f)
    {
        emit Private(a);
        
        return (6, 7, "private8");
    }
}
