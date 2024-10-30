pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {OwnerAdminOnlyAccessControl} from "../../contracts/primitives/access-control/OwnerAdminOnlyAccessControl.sol";

contract OwnerAdminOnlyAccessControlTest is Test {
    OwnerAdminOnlyAccessControl accessControl;

    function setUp() public {
        accessControl = new OwnerAdminOnlyAccessControl(address(this));
    }

    function testIt() public {}
}