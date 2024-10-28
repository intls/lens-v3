// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Events} from "./../../types/Events.sol";
import {RoleBasedAccessControl} from "./RoleBasedAccessControl.sol";

contract OwnerAdminOnlyAccessControl is RoleBasedAccessControl {
    uint256 constant ADMIN_ROLE_ID = uint256(keccak256("ADMIN"));

    constructor(address owner) RoleBasedAccessControl(owner) {
        _setAccess(ADMIN_ROLE_ID, ANY_CONTRACT_ADDRESS, ANY_PERMISSION_ID, Access.GRANTED);
    }

    function _beforeGrantingRole(address account, uint256 roleId) internal virtual override {
        require(roleId == ADMIN_ROLE_ID, "You cannot grant other roles than ADMIN");
        super._beforeGrantingRole(account, roleId);
    }

    function _beforeSettingAccess(
        uint256, /*roleId*/
        address, /*contractAddress*/
        uint256, /*permissionId*/
        Access /*access*/
    ) internal virtual override {
        revert();
    }

    function _emitLensContractDeployedEvent() internal virtual override {
        emit Events.Lens_Contract_Deployed(
            "access-control",
            "lens.access-control.owner-admin-only",
            "access-control",
            "lens.access-control.owner-admin-only"
        );
    }
}
