// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IGroupRule} from "./IGroupRule.sol";
import {RulesStorage, RulesLib} from "./../base/RulesLib.sol";
import {RuleConfiguration, RuleExecutionData} from "./../../types/Types.sol";

contract RuleBasedGroup {
    using RulesLib for RulesStorage;

    struct RuleBasedStorage {
        RulesStorage groupRulesStorage;
    }

    // keccak256('lens.rule.based.group.storage')
    bytes32 constant RULE_BASED_GROUP_STORAGE_SLOT = 0x6b4f86fd68b78c2e5c3c4bc3b3dbb99669a3da3f0bb2db367c4d64acdb2fd3d9;

    function $ruleBasedStorage() private pure returns (RuleBasedStorage storage _storage) {
        assembly {
            _storage.slot := RULE_BASED_GROUP_STORAGE_SLOT
        }
    }

    function $groupRulesStorage() private view returns (RulesStorage storage _storage) {
        return $ruleBasedStorage().groupRulesStorage;
    }

    // Internal

    function _addGroupRule(RuleConfiguration calldata rule) internal {
        $groupRulesStorage().addRule(rule, abi.encodeWithSelector(IGroupRule.configure.selector, rule.configData));
    }

    function _updateGroupRule(RuleConfiguration calldata rule) internal {
        $groupRulesStorage().updateRule(rule, abi.encodeWithSelector(IGroupRule.configure.selector, rule.configData));
    }

    function _removeGroupRule(address rule) internal {
        $groupRulesStorage().removeRule(rule);
    }

    function _processJoining(address account, uint256 membershipId, RuleExecutionData calldata data) internal {
        _processGroupRule(IGroupRule.processJoining.selector, account, membershipId, data);
    }

    function _processRemoval(address account, uint256 membershipId, RuleExecutionData calldata data) internal {
        _processGroupRule(IGroupRule.processRemoval.selector, account, membershipId, data);
    }

    function _processLeaving(address account, uint256 membershipId, RuleExecutionData calldata data) internal {
        _processGroupRule(IGroupRule.processLeaving.selector, account, membershipId, data);
    }

    function _processGroupRule(bytes4 selector, address account, uint256 membershipId, RuleExecutionData calldata data)
        private
    {
        // Check required rules (AND-combined rules)
        for (uint256 i = 0; i < $groupRulesStorage().requiredRules.length; i++) {
            (bool callNotReverted,) = $groupRulesStorage().requiredRules[i].call(
                abi.encodeWithSelector(selector, account, membershipId, data.dataForRequiredRules[i])
            );
            require(callNotReverted, "Some required rule failed");
        }
        // Check any-of rules (OR-combined rules)
        if ($groupRulesStorage().anyOfRules.length == 0) {
            return; // If there are no OR-combined rules, we can return
        }
        for (uint256 i = 0; i < $groupRulesStorage().anyOfRules.length; i++) {
            (bool callNotReverted, bytes memory returnData) = $groupRulesStorage().anyOfRules[i].call(
                abi.encodeWithSelector(selector, account, membershipId, data.dataForAnyOfRules[i])
            );
            if (callNotReverted && abi.decode(returnData, (bool))) {
                // Note: abi.decode would fail if call reverted, so don't put this out of the brackets!
                return; // If any of the OR-combined rules passed, it means they succeed and we can return
            }
        }
        revert("All of the any-of rules failed");
    }

    function _getGroupRules(bool isRequired) internal view returns (address[] memory) {
        return $groupRulesStorage().getRulesArray(isRequired);
    }
}
