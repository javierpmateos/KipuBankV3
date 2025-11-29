// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// Uniswap V2 interfaces
interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
    
    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
    
    function WETH() external pure returns (address);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

/**
 * @title KipuBankV3
 * @author javierpmateos
 * @notice Advanced DeFi bank with Uniswap V2 integration - auto-swaps any token to USDC
 * @dev Extends KipuBankV2 with automatic token swapping via Uniswap V2
 * @custom:educational This contract is for educational purposes only
 * @custom:security-contact sec***@gmail.com
 */
contract KipuBankV3 is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /*///////////////////////////////////
          Type declarations
    ///////////////////////////////////*/

    /// @notice Token swap configuration
    struct SwapConfig {
        bool requiresSwap;      // True if token needs swap to USDC
        bool isSupported;       // True if token is supported
        address[] swapPath;     // Path for Uniswap swap
    }

    /*///////////////////////////////////
           State variables
    ///////////////////////////////////*/

    // Roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    // Constants
    uint8 private constant USDC_DECIMALS = 6;
    address private constant NATIVE_TOKEN = address(0);
    uint256 private constant SLIPPAGE_TOLERANCE = 98; // 2% slippage
    uint256 private constant SLIPPAGE_DENOMINATOR = 100;

    /// @notice Uniswap V2 Router
    IUniswapV2Router02 public immutable i_uniswapRouter;
    
    /// @notice Uniswap V2 Factory
    IUniswapV2Factory public immutable i_uniswapFactory;
    
    /// @notice USDC token address
    address public immutable i_usdc;
    
    /// @notice WETH address
    address public immutable i_weth;
    
    /// @notice Max withdrawal per transaction in USDC (6 decimals)
    uint256 public immutable i_withdrawalLimitUSDC;
    
    /// @notice Max total bank capacity in USDC (6 decimals)
    uint256 public immutable i_bankCapUSDC;
    
    /// @notice Total deposits tracked in USDC (6 decimals)
    uint256 public s_totalDepositsUSDC;
    
    /// @notice Total deposit count
    uint256 public s_depositCount;
    
    /// @notice Total withdrawal count
    uint256 public s_withdrawalCount;
    
    /// @notice User balances in USDC (6 decimals)
    mapping(address => uint256) public s_balances;
    
    /// @notice Token swap configurations
    mapping(address => SwapConfig) public s_swapConfigs;
    
    /// @notice Supported token list
    address[] public s_supportedTokens;

    /*///////////////////////////////////
               Events
    ///////////////////////////////////*/
    
    event Deposit(
        address indexed user,
        address indexed tokenIn,
        uint256 amountIn,
        uint256 usdcReceived,
        uint256 newBalance
    );
    
    event Withdrawal(
        address indexed user,
        uint256 amount,
        uint256 newBalance
    );
    
    event TokenSwapped(
        address indexed user,
        address indexed tokenIn,
        uint256 amountIn,
        uint256 usdcOut
    );
    
    event TokenAdded(address indexed token, bool requiresSwap);
    event TokenRemoved(address indexed token);
    event EmergencyWithdrawal(address indexed token, address indexed to, uint256 amount);

    /*///////////////////////////////////
               Errors
    ///////////////////////////////////*/
    
    error ZeroAmountNotAllowed();
    error BankCapacityExceeded();
    error InsufficientBalance();
    error WithdrawalLimitExceeded();
    error TransferFailed();
    error TokenNotSupported();
    error TokenAlreadySupported();
    error SwapFailed();
    error InvalidSwapPath();
    error NoPairExists();
    error ZeroAddress();
    error SlippageTooHigh();

    /*///////////////////////////////////
            Modifiers
    ///////////////////////////////////*/
    
    modifier validAmount(uint256 _amount) {
        if (_amount == 0) revert ZeroAmountNotAllowed();
        _;
    }
    
    modifier supportedToken(address _token) {
        if (!s_swapConfigs[_token].isSupported) revert TokenNotSupported();
        _;
    }

    /*///////////////////////////////////
            Functions
    ///////////////////////////////////*/

    /*/////////////////////////
        constructor
    /////////////////////////*/
    
    /**
     * @notice Initialize KipuBankV3 with Uniswap V2 integration
     * @param _withdrawalLimitUSDC Max withdrawal per tx in USDC (6 decimals)
     * @param _bankCapUSDC Max total capacity in USDC (6 decimals)
     * @param _uniswapRouter Uniswap V2 Router address
     * @param _uniswapFactory Uniswap V2 Factory address
     * @param _usdc USDC token address
     * @dev SEPOLIA VERSION: Only USDC is pre-configured. ETH support must be added via addTokenETH()
     */
    constructor(
        uint256 _withdrawalLimitUSDC,
        uint256 _bankCapUSDC,
        address _uniswapRouter,
        address _uniswapFactory,
        address _usdc
    ) {
        if (_uniswapRouter == address(0)) revert ZeroAddress();
        if (_uniswapFactory == address(0)) revert ZeroAddress();
        if (_usdc == address(0)) revert ZeroAddress();
        
        i_withdrawalLimitUSDC = _withdrawalLimitUSDC;
        i_bankCapUSDC = _bankCapUSDC;
        i_uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        i_uniswapFactory = IUniswapV2Factory(_uniswapFactory);
        i_usdc = _usdc;
        i_weth = i_uniswapRouter.WETH();
        
        // Setup roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
        
        // ⚠️ DIFERENCIA SEPOLIA: Solo USDC pre-configurado
        // Add USDC support (no swap needed)
        s_swapConfigs[i_usdc] = SwapConfig({
            requiresSwap: false,
            isSupported: true,
            swapPath: new address[](0)
        });
        s_supportedTokens.push(i_usdc);
        
        // ⚠️ ETH NO está pre-configurado en Sepolia
        // Se debe agregar manualmente con addTokenETH() después del deployment
        // Razón: Evitar revert si el par WETH/USDC no tiene liquidez suficiente
    }

    /*/////////////////////////
     Receive & Fallback
    /////////////////////////*/
    
    /**
     * @notice Receive ETH and deposit (swaps to USDC)
     * @dev Only works if ETH support has been enabled by admin
     */
    receive() external payable {
        if (msg.value == 0) revert ZeroAmountNotAllowed();
        if (!s_swapConfigs[NATIVE_TOKEN].isSupported) revert TokenNotSupported();
        _depositWithSwap(NATIVE_TOKEN, msg.value);
    }
    
    /**
     * @notice Reject other calls
     */
    fallback() external payable {
        revert();
    }

    /*/////////////////////////
        external
    /////////////////////////*/
    
    /**
     * @notice Deposit native ETH (swaps to USDC)
     * @dev Only works if ETH support has been enabled by admin via addTokenETH()
     */
    function depositETH() external payable validAmount(msg.value) nonReentrant {
        if (!s_swapConfigs[NATIVE_TOKEN].isSupported) revert TokenNotSupported();
        _depositWithSwap(NATIVE_TOKEN, msg.value);
    }
    
    /**
     * @notice Deposit ERC20 tokens (swaps to USDC if needed)
     * @param _token Token address
     * @param _amount Amount in token decimals
     */
    function depositToken(address _token, uint256 _amount) 
        external 
        validAmount(_amount) 
        supportedToken(_token) 
        nonReentrant 
    {
        if (_token == NATIVE_TOKEN) revert TokenNotSupported();
        
        // Transfer tokens first
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        
        _depositWithSwap(_token, _amount);
    }
    
    /**
     * @notice Withdraw USDC
     * @param _amount Amount in USDC (6 decimals)
     */
    function withdraw(uint256 _amount) 
        external 
        validAmount(_amount) 
        nonReentrant 
    {
        // Checks
        if (_amount > s_balances[msg.sender]) {
            revert InsufficientBalance();
        }
        
        if (_amount > i_withdrawalLimitUSDC) {
            revert WithdrawalLimitExceeded();
        }
        
        // Effects
        s_balances[msg.sender] -= _amount;
        s_totalDepositsUSDC -= _amount;
        s_withdrawalCount++;
        
        emit Withdrawal(msg.sender, _amount, s_balances[msg.sender]);
        
        // Interactions
        IERC20(i_usdc).safeTransfer(msg.sender, _amount);
    }
    
    /**
     * @notice Add native ETH support (admin only)
     * @dev Validates WETH/USDC pair exists before enabling
     */
    function addTokenETH() external onlyRole(ADMIN_ROLE) {
        if (s_swapConfigs[NATIVE_TOKEN].isSupported) revert TokenAlreadySupported();
        
        // Check if WETH/USDC pair exists
        address pair = i_uniswapFactory.getPair(i_weth, i_usdc);
        if (pair == address(0)) revert NoPairExists();
        
        // Create swap path: WETH -> USDC
        address[] memory ethPath = new address[](2);
        ethPath[0] = i_weth;
        ethPath[1] = i_usdc;
        
        s_swapConfigs[NATIVE_TOKEN] = SwapConfig({
            requiresSwap: true,
            isSupported: true,
            swapPath: ethPath
        });
        
        s_supportedTokens.push(NATIVE_TOKEN);
        
        emit TokenAdded(NATIVE_TOKEN, true);
    }
    
    /**
     * @notice Add new token support (admin only)
     * @param _token Token address
     * @dev Automatically detects if direct pair with USDC exists
     */
    function addToken(address _token) external onlyRole(ADMIN_ROLE) {
        if (s_swapConfigs[_token].isSupported) revert TokenAlreadySupported();
        if (_token == i_usdc) revert TokenAlreadySupported();
        if (_token == NATIVE_TOKEN) revert TokenNotSupported(); // Use addTokenETH() for ETH
        
        // Check if pair exists
        address pair = i_uniswapFactory.getPair(_token, i_usdc);
        if (pair == address(0)) revert NoPairExists();
        
        // Create swap path: token -> USDC
        address[] memory path = new address[](2);
        path[0] = _token;
        path[1] = i_usdc;
        
        s_swapConfigs[_token] = SwapConfig({
            requiresSwap: true,
            isSupported: true,
            swapPath: path
        });
        
        s_supportedTokens.push(_token);
        
        emit TokenAdded(_token, true);
    }
    
    /**
     * @notice Remove token support (admin only)
     * @param _token Token to remove
     */
    function removeToken(address _token) external onlyRole(ADMIN_ROLE) {
        if (!s_swapConfigs[_token].isSupported) revert TokenNotSupported();
        if (_token == i_usdc) revert TokenNotSupported();
        
        s_swapConfigs[_token].isSupported = false;
        
        // Remove from array
        for (uint256 i = 0; i < s_supportedTokens.length; i++) {
            if (s_supportedTokens[i] == _token) {
                s_supportedTokens[i] = s_supportedTokens[s_supportedTokens.length - 1];
                s_supportedTokens.pop();
                break;
            }
        }
        
        emit TokenRemoved(_token);
    }
    
    /**
     * @notice Emergency withdrawal (admin only)
     * @param _token Token to withdraw
     * @param _to Recipient
     * @param _amount Amount to withdraw
     */
    function emergencyWithdraw(address _token, address _to, uint256 _amount) 
        external 
        onlyRole(ADMIN_ROLE) 
    {
        if (_to == address(0)) revert ZeroAddress();
        
        if (_token == NATIVE_TOKEN) {
            (bool success, ) = payable(_to).call{value: _amount}("");
            if (!success) revert TransferFailed();
        } else {
            IERC20(_token).safeTransfer(_to, _amount);
        }
        
        emit EmergencyWithdrawal(_token, _to, _amount);
    }

    /*/////////////////////////
        internal
    /////////////////////////*/
    
    /**
     * @notice Internal deposit with automatic swap to USDC
     * @param _token Token address
     * @param _amount Amount in token decimals
     * @dev CORRECTED: Atomic bankCap verification with pre-calculated total
     */
    function _depositWithSwap(address _token, uint256 _amount) internal supportedToken(_token) {
        SwapConfig memory config = s_swapConfigs[_token];
        uint256 usdcReceived;
        
        if (!config.requiresSwap) {
            // Direct USDC deposit
            usdcReceived = _amount;
        } else {
            // Swap to USDC
            usdcReceived = _swapToUSDC(_token, _amount, config.swapPath);
            
            // CORRECTION 1: Explicit validation that swap was successful
            if (usdcReceived == 0) revert SwapFailed();
        }
        
        // CORRECTION 2: Atomic calculation before verification
        // This ensures the same value is used for both check and state update
        uint256 newTotalDeposits = s_totalDepositsUSDC + usdcReceived;
        
        // CORRECTION 3: Verify bank capacity with pre-calculated value
        if (newTotalDeposits > i_bankCapUSDC) {
            revert BankCapacityExceeded();
        }
        
        // CORRECTION 4: Update state using pre-calculated value
        // This guarantees atomicity and prevents any edge case where
        // the calculation could give different results
        s_balances[msg.sender] += usdcReceived;
        s_totalDepositsUSDC = newTotalDeposits;
        s_depositCount++;
        
        emit Deposit(msg.sender, _token, _amount, usdcReceived, s_balances[msg.sender]);
    }
    
    /**
     * @notice Execute swap to USDC via Uniswap V2
     * @param _tokenIn Input token
     * @param _amountIn Input amount
     * @param _path Swap path
     * @return usdcOut Amount of USDC received
     */
    function _swapToUSDC(
        address _tokenIn,
        uint256 _amountIn,
        address[] memory _path
    ) internal returns (uint256 usdcOut) {
        if (_path.length < 2) revert InvalidSwapPath();
        
        // Calculate minimum output with slippage
        uint256[] memory amountsOut = i_uniswapRouter.getAmountsOut(_amountIn, _path);
        uint256 minAmountOut = (amountsOut[amountsOut.length - 1] * SLIPPAGE_TOLERANCE) / SLIPPAGE_DENOMINATOR;
        
        uint256[] memory amounts;
        
        if (_tokenIn == NATIVE_TOKEN) {
            // Swap ETH for USDC
            amounts = i_uniswapRouter.swapExactETHForTokens{value: _amountIn}(
                minAmountOut,
                _path,
                address(this),
                block.timestamp + 300 // 5 min deadline
            );
        } else {
            // Approve router
            IERC20(_tokenIn).forceApprove(address(i_uniswapRouter), _amountIn);
            
            // Swap ERC20 for USDC
            amounts = i_uniswapRouter.swapExactTokensForTokens(
                _amountIn,
                minAmountOut,
                _path,
                address(this),
                block.timestamp + 300
            );
            
            // Reset approval
            IERC20(_tokenIn).forceApprove(address(i_uniswapRouter), 0);
        }
        
        usdcOut = amounts[amounts.length - 1];
        
        if (usdcOut == 0) revert SwapFailed();
        
        emit TokenSwapped(msg.sender, _tokenIn, _amountIn, usdcOut);
        
        return usdcOut;
    }

    /*/////////////////////////
      View & Pure
    /////////////////////////*/
    
    /**
     * @notice Get user balance in USDC
     * @param _user User address
     * @return Balance in USDC (6 decimals)
     */
    function getBalance(address _user) external view returns (uint256) {
        return s_balances[_user];
    }
    
    /**
     * @notice Get estimated USDC output for a token amount
     * @param _token Token address
     * @param _amount Token amount
     * @return Estimated USDC output
     */
    function getEstimatedUSDC(address _token, uint256 _amount) 
        external 
        view 
        supportedToken(_token) 
        returns (uint256) 
    {
        SwapConfig memory config = s_swapConfigs[_token];
        
        if (!config.requiresSwap) {
            return _amount;
        }
        
        uint256[] memory amounts = i_uniswapRouter.getAmountsOut(_amount, config.swapPath);
        return amounts[amounts.length - 1];
    }
    
    /**
     * @notice Get bank info
     */
    function getBankInfo() 
        external 
        view 
        returns (
            uint256 totalDepositsUSDC,
            uint256 bankCapUSDC,
            uint256 withdrawalLimitUSDC,
            uint256 depositCount,
            uint256 withdrawalCount,
            uint256 supportedTokenCount,
            uint256 availableCapacity
        ) 
    {
        return (
            s_totalDepositsUSDC,
            i_bankCapUSDC,
            i_withdrawalLimitUSDC,
            s_depositCount,
            s_withdrawalCount,
            s_supportedTokens.length,
            i_bankCapUSDC - s_totalDepositsUSDC
        );
    }
    
    /**
     * @notice Get all supported tokens
     */
    function getSupportedTokens() external view returns (address[] memory) {
        return s_supportedTokens;
    }
    
    /**
     * @notice Get token swap configuration
     */
    function getSwapConfig(address _token) external view returns (SwapConfig memory) {
        return s_swapConfigs[_token];
    }
    
    /**
     * @notice Check if bank has capacity for deposit
     */
    function hasCapacityFor(uint256 _usdcAmount) external view returns (bool) {
        return s_totalDepositsUSDC + _usdcAmount <= i_bankCapUSDC;
    }
}
