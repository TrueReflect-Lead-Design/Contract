/**
 *SPDX-License-Identifier: None
*/

pragma solidity 0.8.7;

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

    mapping(address => uint256) internal _balances;
    mapping (address => bool) internal _isExcludedFromReflect;
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
                
        _totalSupply = _totalSupply.add(sValue);
        RFX = RFX.add(sValue);                 

        _balances[_owner] = sValue;
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
    
    function isExcludedfromReflect(address _address) external view returns (bool _bool) {
        _bool = _isExcludedFromReflect[_address];
    }
        
    function isExcludedfromFees(address _address) external view returns (bool _bool) {
        _bool = _isExcludedFromFees[_address];
    }
    
    function calculateFees(uint _amount) internal view returns (uint Fee){
        Fee = _amount.mul(_transferTaxRate).div(100000);
    }
    
    function excludeFromReflect(address _address, bool _bool) external onlyDev {
        require(_isExcludedFromReflect[_address] != _bool, 'ERROR: already set');
        _balances[_address] = _bool == true ? reflectValue(_balances[_address]) : valueReflected(_balances[_address]);
        _isExcludedFromReflect[_address] = _bool;    
    }
    
    function excludeFromFees(address _address, bool _bool) external onlyDev {
        _isExcludedFromFees[_address] = _bool;
    }

    function settleDeadAddress() internal { // scan dead address and spread its value to all holders.
        uint a = balanceOf(_deadAddress);
        uint b = _deadLedger;
        uint c = a-b;
        RFX -= c;
        _deadLedger += c;
    }

    function setTransferTaxRate(uint _amount) external onlyDev {
        require(_amount <= 15000 && _amount >= 1000); // Max 15%, Min 1%
        _transferTaxRate = _amount;
    }
    
    function reflectInBps() internal view returns (uint _int){ // find ratio of tokens to reflect value
        _int = totalSupply().mul(BPS).div(RFX);
    }
    
    function reflectValue(uint _int) internal view returns (uint rValue) { // find reflected value of tokens
        rValue =  reflectInBps().mul(_int).div(BPS);      
    }
    
    function valueReflected(uint _int) internal view returns (uint rValue) { // find the tokens that equal a reflected value
        rValue =  _int.mul(BPS).div(reflectInBps());
    }
                // owner always excluded                    
    function balanceOf(address account) public override view returns (uint256 rValue) { // return balance or reflected balance
        rValue = account == getOwner() ? _balances[account] : _isExcludedFromReflect[account] ? _balances[account] : reflectValue(_balances[account]);
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

    function _transfer(address sender, address recipient, uint256 amount) internal virtual { // one function reflect logic
        require(sender != address(0), 'ERC20: transfer from the zero address');
        require(recipient != address(0), 'ERC20: transfer to the zero address');
        
        uint rValue = valueReflected(amount);
        uint fee = 0;
        uint rFee = 0;
        
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
           
        }else if(_isExcludedFromReflect[sender]) 
        {
            _balances[sender] -= amount;
            _balances[recipient] += rFee > 0 ? rValue - rFee : rValue;
        }
        else if(_isExcludedFromReflect[recipient])
       {    _balances[sender] -= rValue;
            _balances[recipient] += fee > 0 ? amount - fee : amount;
       } else 
       {
            _balances[sender] -= rValue;
            _balances[recipient] += rFee > 0 ? rValue - rFee : rValue;
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
