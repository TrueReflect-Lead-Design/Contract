/**
 *SPDX-License-Identifier: None
*/

pragma solidity 0.8.7;
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transfermofi `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
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
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract MasterChef is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;         // How many LP tokens the user has provided.
        uint256 rewardDebt;     // Reward debt. See explanation below.
        uint256 rewardLockedUp;  // Reward locked up.
        uint256 nextHarvestUntil; // When can the user harvest again.
        //
        // We do some fancy math here. Basically, any point in time, the amount of reflect
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accTokenPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accTokenPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. Reflect to distribute per block.
        uint256 lastRewardBlock; // Last block number that reflect distribution occurs.
        uint256 accTokenPerShare; // Accumulated reflect per share, times 1e12. See below.
        uint16 depositFeeBP; // Deposit fee in basis points
        uint256 harvestInterval;  // Harvest interval in seconds
        uint totalLP; // track how many total deposits held by chef
    }

    // The REFLECT TOKEN!
    TrueReflect public token;
    // reflect tokens created per second.
    uint256 public tokenPerSecond;
    // Max harvest interval: 12 hours.
    uint256 public constant MAXIMUM_HARVEST_INTERVAL = 12 hours;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block timestamp when Reflect mining starts.
    uint256 public startBlock;
    // block timestamp farming ended.
    uint public endTime = 0;
    
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event UpdateEmissionRate(address indexed user, uint256 tokenPerSecond);
    event RewardLockedUp(address indexed user, uint256 indexed pid, uint256 amountLockedUp);

    constructor(
        TrueReflect _token,
        uint256 _tokenPerSecond,
        uint256 _startBlock
    )  {
        token = _token;
        tokenPerSecond = _tokenPerSecond;
        startBlock = block.timestamp.add(_startBlock * 1 days);
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    mapping(IERC20 => bool) public poolExistence;
    modifier nonDuplicated(IERC20 _lpToken) {
        require(poolExistence[_lpToken] == false, "nonDuplicated: duplicated");
        _;
    }    
    
    function blockTimestamp() public view returns (uint time) { // to assist with countdowns on site
        time = block.timestamp;
    }

    function userPoolLockup(uint _pid, address _user) public view returns (int lock) {
        UserInfo storage user = userInfo[_pid][_user];
        lock = int(user.nextHarvestUntil) - int(block.timestamp);
        if(lock < 0) lock = 0;
        
    }

    function add(uint256 _allocPoint, IERC20 _lpToken, uint16 _depositFeeBP, uint256 _harvestInterval, bool _withUpdate) public onlyOwner {
        require(_depositFeeBP <= 400, "add: invalid deposit fee basis points");
        require(_harvestInterval <= MAXIMUM_HARVEST_INTERVAL, "add: invalid harvest interval");
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.timestamp > startBlock ? block.timestamp : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accTokenPerShare: 0,
            depositFeeBP: _depositFeeBP,
            harvestInterval: _harvestInterval * 1 hours,
            totalLP: 0
        }));
    }

    function set(uint256 _pid, uint256 _allocPoint, uint16 _depositFeeBP, uint256 _harvestInterval, bool _withUpdate) public onlyOwner {
        require(_depositFeeBP <= 400, "set: invalid deposit fee basis points");
        require(_harvestInterval <= MAXIMUM_HARVEST_INTERVAL, "set: invalid harvest interval");
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
        poolInfo[_pid].harvestInterval = _harvestInterval * 1 hours;
    }
    
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        return endTime > 0 ? _from > endTime ?  0 :  endTime.sub(_from) : _to.sub(_from);
    }

    function pendingToken(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTokenPerShare = pool.accTokenPerShare;
        uint256 lpSupply = pool.totalLP;
        if (block.timestamp > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.timestamp);
            uint256 tokenReward = multiplier.mul(tokenPerSecond).mul(pool.allocPoint).div(totalAllocPoint);
            accTokenPerShare = accTokenPerShare.add(tokenReward.mul(1e12).div(lpSupply));
        }
        uint256 pending = user.amount.mul(accTokenPerShare).div(1e12).sub(user.rewardDebt);
        return pending.add(user.rewardLockedUp);
    }
        
    function requestOwnership() external {
        require(endTime > 0, "ERROR: farming not finished");
        Ownable(address(token)).transferOwnership(getDev());
    }
    function canHarvest(uint256 _pid, address _user) public view returns (bool) {
        UserInfo storage user = userInfo[_pid][_user];
        return block.timestamp >= user.nextHarvestUntil;
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.timestamp <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.totalLP;
        if (lpSupply == 0 || pool.allocPoint == 0 || endTime > 0) {
            pool.lastRewardBlock = block.timestamp;
            return;
        }

        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.timestamp);
        uint256 tokenReward = multiplier.mul(tokenPerSecond).mul(pool.allocPoint).div(totalAllocPoint);
        token.mint(getDev(), tokenReward.div(10));
        token.mint(address(this), tokenReward);
        pool.accTokenPerShare = pool.accTokenPerShare.add(tokenReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.timestamp;
                if(token.totalSupply() > 5000000*10**6) endTime = block.timestamp; // not strictly enforced to 5M, to allow all promised tokens.
    }

    function deposit(uint256 _pid, uint256 _amount) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        payOrLockupPending(_pid);
        
        if (_amount > 0) {
            
            uint balanceBefore =  pool.lpToken.balanceOf(address(this));
            pool.lpToken.transferFrom(address(msg.sender), address(this), _amount);
            uint balanceAfter =  pool.lpToken.balanceOf(address(this));
            _amount = balanceAfter.sub(balanceBefore);
            
            if (pool.depositFeeBP > 0) {
                uint256 depositFee = _amount.mul(pool.depositFeeBP).div(10000);
                _amount -= depositFee;
                pool.lpToken.safeTransfer(getDev(), depositFee);
                user.amount = user.amount.add(_amount);
                pool.totalLP += _amount;
            } else {
                user.amount = user.amount.add(_amount);
                pool.totalLP += _amount;
            }
        }
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        payOrLockupPending(_pid);
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            pool.totalLP -= _amount;
        }
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        user.rewardLockedUp = 0;
        user.nextHarvestUntil = 0;
        pool.totalLP -= amount;
        pool.lpToken.safeTransfer(address(msg.sender), amount);

        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }
    
    function payOrLockupPending(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        if (user.nextHarvestUntil == 0) {
            user.nextHarvestUntil = block.timestamp.add(pool.harvestInterval);
        }

        uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(user.rewardDebt);
        if (canHarvest(_pid, msg.sender)) {
            if (pending > 0 || user.rewardLockedUp > 0) {
                uint256 totalRewards = pending.add(user.rewardLockedUp);

                user.rewardLockedUp = 0;
                user.nextHarvestUntil = block.timestamp.add(pool.harvestInterval);
                
                safeTokenTranfer(msg.sender, totalRewards);
            }
        } else if (pending > 0) {
            user.rewardLockedUp = user.rewardLockedUp.add(pending);
            emit RewardLockedUp(msg.sender, _pid, pending);
        }
    }

    function safeTokenTranfer(address _to, uint256 _amount) internal {
        uint256 tokenBal = token.balanceOf(address(this));
        bool transferSuccess = false;
        if (_amount > tokenBal) {
            transferSuccess = token.transfer(_to, tokenBal);
        } else {
            transferSuccess = token.transfer(_to, _amount);
        }
        require(transferSuccess, "safeTokenTranfer: transfer failed");
    }

    function updateEmissionRate(uint256 _tokenPerSecond) public onlyDev {
        require(_tokenPerSecond <= 50 ether, "can't be more than 50 ether"); // just be reasonable!
        massUpdatePools();
        tokenPerSecond = _tokenPerSecond;
        emit UpdateEmissionRate(msg.sender, _tokenPerSecond);
    }

}
