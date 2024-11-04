// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IGroupRule} from "../IGroupRule.sol";
import {SimplePaymentRule} from "../../base/SimplePaymentRule.sol";

contract SimplePaymentGroupRule is SimplePaymentRule, IGroupRule {
    mapping(address group => PaymentConfiguration configuration) internal _configuration;

    function configure(bytes calldata data) external {
        PaymentConfiguration memory configuration = abi.decode(data, (PaymentConfiguration));
        _validatePaymentConfiguration(configuration);
        _configuration[msg.sender] = configuration;
    }

    function processJoining(address account, uint256, /* membershipId */ bytes calldata data) external returns (bool) {
        _processPayment(_configuration[msg.sender], abi.decode(data, (PaymentConfiguration)), account);
        return true;
    }

    function processRemoval(address, /* account */ uint256, /* membershipId */ bytes calldata /*data*/ )
        external
        pure
        returns (bool)
    {
        return false;
    }

    function processLeaving(address, /* account */ uint256, /* membershipId */ bytes calldata /*data*/ )
        external
        pure
        returns (bool)
    {
        return false;
    }
}
