/**
 *SPDX-License-Identifier: None
*/

pragma solidity 0.8.7;

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
abstract contract Ownable {
    address internal _owner;
    address internal _dev;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event DevAddressTransferred(address indexed previousDev, address indexed newDev);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        _dev = msgSender;
        emit OwnershipTransferred(address(this), msgSender);
        emit DevAddressTransferred(address(this), msgSender);
    }
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    /**
     * @dev Returns the address of the current owner.
     */
    function getOwner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the current dev.
     */
    function getDev() public view returns (address) {
        return _dev;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Throws if called by any account other than the dev.
     */
    modifier onlyDev() {
        require(_dev == _msgSender(), 'Ownable: caller is not the dev');
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferDevAddress(address newOwner) external onlyDev {
        _transferDevAddress(newOwner);
    }

    /**
     * @dev Transfers the dev address of the contract to a new account (`newDev`).
     */
    function _transferDevAddress(address newDev) internal {
        require(newDev != address(0), 'Ownable: new dev is the zero address');
        emit DevAddressTransferred(_dev, newDev);
        _dev = newDev;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

}

// Truely mintable reflect token. nough said.
contract TrueReflect is IERC20, Ownable {
    using SafeMath for uint256;

    uint256 internal _totalSupply;
    string internal _name;
    string internal _symbol;
    uint8 internal immutable _decimals;
    uint internal constant BPS = 1e12; // factor resolution
    uint internal RFX;
    address internal constant _deadAddress = 0x000000000000000000000000000000000000dEaD;
    uint internal _deadLedger = 0; // counter for dead wallet adjustments
    uint internal _transferTaxRate = 5000; // 5%
    address internal _lpAddress;
    bool public EMERGENCY_MODE = false; // in the event that the reflect math is broken in an unresolvable way or a bug presents itself
                                        // transfer of the token may become impossible without a bypass
                                        // also useful for deployment and LP setup

    mapping(address => uint256) internal _balances;
    mapping (address => bool) internal _isExcludedFromReflect;
    mapping (address => bool) internal _isExcludedFromAntiWhale;
    mapping (address => bool) internal _isExcludedFromFees;
    mapping(address => mapping(address => uint256)) internal _allowances;

    constructor() {
        _name = 'True Reflect';
        _symbol = 'TRT';
        _decimals = 6;
        uint sValue = 100000*10**6;
        
        _isExcludedFromReflect[_deadAddress] = true;
        _isExcludedFromReflect[_owner] = true;
        _isExcludedFromFees[_owner] = true;
        _isExcludedFromAntiWhale[_owner] = true;
        _totalSupply = _totalSupply.add(sValue);
        RFX = RFX.add(sValue);                 

        _balances[_owner] = sValue;

    }

    function setLpAddress(address _address) external onlyOwner { // to be set prior to transfer to MasterChef
        _lpAddress = _address;
    }

    function name() public override view returns (string memory) {
        return _name;
    }

    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }
    
    function taxRate() public view returns (uint256) {
        return _transferTaxRate.mul(100).div(100000);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), 'ERC20: approve from the zero address');
        require(spender != address(0), 'ERC20: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    modifier AntiWhale (address sender, uint amount) {
        require(
            EMERGENCY_MODE == true ||
            _lpAddress == address(0) ||
            _isExcludedFromAntiWhale[sender] ||
            _isExcludedFromAntiWhale[tx.origin] ||
            amount <= balanceOf(_lpAddress).mul(5).div(100)
            );
        _;
    }
    
    function isExcludedfromReflect(address _address) external view returns (bool _bool) {
        _bool = _isExcludedFromReflect[_address];
    }
          
    function isExcludedfromAntiWhale(address _address) external view returns (bool _bool) {
        _bool = _isExcludedFromAntiWhale[_address];
    }
        
    function isExcludedfromFees(address _address) external view returns (bool _bool) {
        _bool = _isExcludedFromFees[_address];
    }
            
    function isEmergencyModeOn() external view returns (bool _bool) {
        _bool = EMERGENCY_MODE;
    }
    
    function calculateFees(uint _amount) internal view returns (uint Fee){
        Fee = _amount.mul(_transferTaxRate).div(100000);
    }
    
    function excludeFromReflect(address _address, bool _bool) external onlyDev {
        require(_isExcludedFromReflect[_address] != _bool, 'ERROR: already set');
        _balances[_address] = _bool == true ? reflectValue(_balances[_address]) : valueReflected(_balances[_address]);  // adjust user balance to conform to new ruleset and maintain value
        _isExcludedFromReflect[_address] = _bool;    
    }
    
    function excludeFromFees(address _address, bool _bool) external onlyDev {
        _isExcludedFromFees[_address] = _bool;
    }    
    
    function excludeFromAntiWhale(address _address, bool _bool) external onlyDev {
        _isExcludedFromAntiWhale[_address] = _bool;
    }
    
    function setEmergencyMode(bool _bool) external onlyDev {
        EMERGENCY_MODE = _bool;
    }

    function settleDeadAddress() public { // scan dead address and spread its value to all holders.
        uint a = balanceOf(_deadAddress);
        uint b = _deadLedger;
        uint c = a-b;
        RFX -= c;
        _deadLedger += c;
    }

    function setTransferTaxRate(uint _amount) external onlyDev {
        require(_amount <= 7000 && _amount >= 1000); // Max 15%, Min 1%
        _transferTaxRate = _amount;
    }
    
    function reflectInBps() internal view returns (uint _int){ // find ratio of tokens to reflect value
        _int = totalSupply().mul(BPS).div(RFX);
    }
    
    function reflectValue(uint _int) internal view returns (uint rValue) { // find reflected value of tokens
        rValue =  reflectInBps().mul(_int).div(BPS);      
    }
    
    function valueReflected(uint _int) internal view returns (uint rValue) { // find the tokens that reflected a value
        rValue =  _int.mul(BPS).div(reflectInBps());
    }
   
    function balanceOf(address account) public override view returns (uint256 rValue) { // return balance or reflected balance
        rValue = EMERGENCY_MODE == true ? _balances[account] : _isExcludedFromReflect[account] ? _balances[account] : reflectValue(_balances[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        settleDeadAddress(); // added here so it calls less often but automatically
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _approve(sender,_msgSender(), _allowances[sender][_msgSender()].sub(amount, 'ERC20: transfer amount exceeds allowance'));
        _transfer(sender, recipient, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual AntiWhale(sender, amount) { // one function reflect logic
        require(sender != address(0), 'ERC20: transfer from the zero address');
        require(recipient != address(0), 'ERC20: transfer to the zero address');
        
        uint rValue = valueReflected(amount);
        uint fee = 0;
        uint rFee = 0;
        
        if(EMERGENCY_MODE == true) {
            _balances[sender] -= amount;
            _balances[recipient] +=  amount;    
            emit Transfer(sender, recipient, amount);  
            return;
        }
        
        if(!_isExcludedFromFees[tx.origin]) {
            fee = calculateFees(amount);
            rFee = calculateFees(rValue);
            RFX -= fee;
            emit Transfer(sender, recipient, amount-fee);
        } else {
           emit Transfer(sender, recipient, amount);  
        }
        
        if(_isExcludedFromReflect[recipient] && _isExcludedFromReflect[sender])
       {    _balances[sender] -= amount;
            _balances[recipient] += fee > 0 ? amount - fee : amount;
            return;
           
        }else if(_isExcludedFromReflect[sender]) 
        {
            _balances[sender] -= amount;
            _balances[recipient] += rFee > 0 ? rValue - rFee : rValue;
            return;
        }
        else if(_isExcludedFromReflect[recipient])
       {    _balances[sender] -= rValue;
            _balances[recipient] += fee > 0 ? amount - fee : amount;
            return;
       } else 
       {
            _balances[sender] -= rValue;
            _balances[recipient] += rFee > 0 ? rValue - rFee : rValue;
            return;
       }

    }

    function mint(address account, uint256 amount) public onlyOwner {  // must be invoked on an account that is excluded from reflect to avoid unresolvable math errors
        require(account != address(0), 'ERC20: mint to the zero address');
        uint preTotal = totalSupply();
        _totalSupply = _totalSupply.add(amount); // increase total
        uint addedRatio = _totalSupply.mul(BPS).div(preTotal); // find increase to totalSupply
        
        RFX = RFX.mul(addedRatio).div(BPS); // maintain reflect pool
                                                                    
        _balances[account] += amount;

        emit Transfer(address(this), account, amount);
    }
    
}


contract MasterChef is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    // Info of each user.
    struct UserInfo {
        uint256 amount;         // How many LP tokens the user has provided.
        uint256 rewardDebt;     // Reward debt. See explanation below.
        uint rewardLockup;      // total reward in lockup for user
        uint unlockupTime;        // timestamp reward unlocks

    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. TOKENs to distribute per block.
        uint256 lastRewardTime;  // Last block number that TOKENs distribution occurs.
        uint256 accTokenPerShare;   // Accumulated TOKENs per share, times 1e12. See below.
        uint16 depositFeeBP;      // Deposit fee in basis points
    }

    // The TOKEN TOKEN!
    TrueReflect public token;
    // TOKEN tokens created per block.
    uint256 public reflectPerSecond;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when TOKEN mining starts.
    uint256 public startTime;
    uint public endTime = 0;
    uint internal constant BPS = 1e12; // factor resolution
    
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        TrueReflect _token,
        uint256 _reflectPerSecond,
        uint256 farmingDelay
    )  {
        token = _token;
        reflectPerSecond = _reflectPerSecond;
        startTime = block.timestamp + (farmingDelay * 1 days);
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }
    
    function blockTimestamp() public view returns (uint time) { // to assist wioth countdowns on site
        time = block.timestamp;
    }

    function userPoolLockup(uint _pid, address _user) public view returns (int lock) {
        UserInfo storage user = userInfo[_pid][_user];
        lock = int(user.unlockupTime) - int(block.timestamp);
        if(lock < 0) lock = 0;
        
    }
    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, IERC20 _lpToken, uint16 _depositFeeBP, bool _withUpdate) public onlyOwner {
        require(_depositFeeBP <= 400, "add: invalid deposit fee basis points");
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.timestamp > startTime ? block.timestamp : startTime;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardTime: lastRewardBlock,
            accTokenPerShare: 0,
            depositFeeBP: _depositFeeBP
        }));
    }

    // Update the given pool's TOKEN allocation point and deposit fee. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, uint16 _depositFeeBP, bool _withUpdate) public onlyOwner {
        require(_depositFeeBP <= 400, "set: invalid deposit fee basis points");
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
         return endTime > 0 ? _from > endTime ?  0 :  endTime.sub(_from) : _to.sub(_from);
       
    }

    // View function to see pending REFLECTs on frontend.
    function pendingReflect(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accReflectPerShare = pool.accTokenPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.timestamp > pool.lastRewardTime && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardTime, block.timestamp);
            uint256 reflectReward = multiplier.mul(reflectPerSecond).mul(pool.allocPoint).div(totalAllocPoint);
            accReflectPerShare = accReflectPerShare.add(reflectReward.mul(BPS).div(lpSupply));
        }
        return user.amount.mul(accReflectPerShare).div(BPS).sub(user.rewardDebt).add(user.rewardLockup);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.timestamp <= pool.lastRewardTime || endTime > 0) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0 || pool.allocPoint == 0) {
            pool.lastRewardTime = block.timestamp;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardTime, block.timestamp);
        uint256 tokenReward = multiplier.mul(reflectPerSecond).mul(pool.allocPoint).div(totalAllocPoint);
      if(token.totalSupply().add(tokenReward.add(tokenReward.mul(15).div(100))) >= 5000000*10**6 ) {
        endTime = block.timestamp; // go ahead and mint all promised tokens not strictly capped to 5M, but cut off minting and return contract to the developers to continue the project.
        reflectPerSecond = 1; // set minimum emmission, to aid UI in displaying change immediatly 
      } 
        token.mint(getDev(), tokenReward.mul(15).div(100));
        token.mint(address(this), tokenReward);
        pool.accTokenPerShare = pool.accTokenPerShare.add(tokenReward.mul(BPS).div(lpSupply));
        pool.lastRewardTime = block.timestamp;
    }
        
   function readUserLock(uint256 _pid, address _user) internal view returns (bool) {  // check if user can harvest
        UserInfo storage user = userInfo[_pid][_user];
        return block.timestamp >= user.unlockupTime;
    }
    
    function processHarvest(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        if (user.unlockupTime == 0) {
            user.unlockupTime = block.timestamp.add(1 minutes);
        }

        uint256 pending = user.amount.mul(pool.accTokenPerShare).div(BPS);
        if (readUserLock(_pid, msg.sender)) {
            if (pending > 0 || user.rewardLockup > 0) {
                uint256 totalRewards = pending.add(user.rewardLockup);
                
                user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(BPS);
                user.rewardLockup = 0;
                user.unlockupTime = block.timestamp.add(1 minutes);

                safeTokenTransfer(msg.sender, totalRewards);
            }
        } else if (pending > 0) {
            user.rewardLockup = user.rewardLockup.add(pending);
        }
    }

    // Deposit LP tokens to MasterChef for TOKEN allocation.
    function deposit(uint256 _pid, uint256 _amount) public nonReentrant{
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        processHarvest(_pid);
    
        if(_amount > 0) {
            uint balanceBefore =  pool.lpToken.balanceOf(address(this));
            pool.lpToken.transferFrom(address(msg.sender), address(this), _amount);
            uint balanceAfter =  pool.lpToken.balanceOf(address(this));
            _amount = balanceAfter.sub(balanceBefore);
            if(pool.depositFeeBP > 0){
                uint256 depositFee = _amount.mul(pool.depositFeeBP).div(10000);
                user.amount = user.amount.add(_amount - depositFee);
                pool.lpToken.transfer(getDev(), depositFee);
            }else{
                user.amount = user.amount.add(_amount);
            }
        }

        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(BPS);
        emit Deposit(msg.sender, _pid, _amount);
    }
    
    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeTokenTransfer(msg.sender, pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.transfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public nonReentrant{
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.transfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    // Safe token transfer function, just in case if rounding error causes pool to not have enough TOKENs.
    function safeTokenTransfer(address _to, uint256 _amount) internal {
        uint256 tokenBal = token.balanceOf(address(this));
        if (_amount > tokenBal) {
            token.transfer(_to, tokenBal);
        } else {
            token.transfer(_to, _amount);
        }
    }

    //Pancake has to add hidden dummy pools inorder to alter the emission, here we make it simple and transparent to all.
    function updateEmissionRate(uint256 _reflectPerSecond) external onlyDev {
        massUpdatePools();
        reflectPerSecond = _reflectPerSecond;
    }
    
    function returnOwnership() external {
        require(endTime > 0, "ERROR: Yield Farm still active.");
        Ownable(address(token)).transferOwnership(getDev());
    }
}
