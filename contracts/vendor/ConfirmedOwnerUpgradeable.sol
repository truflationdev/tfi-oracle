// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.0;

import "../interfaces/OwnableInterface.sol";

/** use internal initializer because to allow use with 0.7.0 solidity
 * change name s_owner -> owner, s_pendingOwner -> pendingOwner
 * make variables public
*/

/**
 * @title The ConfirmedOwnerUpgradeable contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwnerUpgradeable is OwnableInterface {
  bool public initialized;
  address public owner;
  address public pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  function initialize(address newOwner, address pendingOwner) public virtual {
    require(!initialized, "Contract has already initialized");
    require(newOwner != address(0), "Cannot set owner to zero");
    initialized = true;
    owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /**
   * @notice Allows an owner to begin transferring ownership to a new address,
   * pending.
   */
  function transferOwnership(address to) public override onlyOwner {
    _transferOwnership(to);
  }

  /**
   * @notice Allows an ownership transfer to be completed by the recipient.
   */
  function acceptOwnership() external override {
    require(msg.sender == pendingOwner, "Must be proposed owner");

    address oldOwner = owner;
    owner = msg.sender;
    pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /**
   * @notice Get the current owner
   */
  function owner() public view override returns (address) {
    return owner;
  }

  /**
   * @notice validate, transfer ownership, and emit relevant events
   */
  function _transferOwnership(address to) private {
    require(to != msg.sender, "Cannot transfer to self");

    pendingOwner = to;

    emit OwnershipTransferRequested(owner, to);
  }

  /**
   * @notice validate access
   */
  function _validateOwnership() internal view {
    require(msg.sender == owner, "Only callable by owner");
  }

  /**
   * @notice Reverts if called by anyone other than the contract owner.
   */
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}