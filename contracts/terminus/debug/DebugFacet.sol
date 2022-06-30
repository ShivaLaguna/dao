// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {LibMumbaiDebugV1} from "./LibMumbaiDebugV1.sol";
import {LibTerminus} from "../LibTerminus.sol";
import {LibTerminusController} from "../controller/LibTerminusController.sol";
import {LibDiamond} from "../../diamond/libraries/LibDiamond.sol";


contract DebugFacet {

    event DebugDummyEvent(
        string message,
        uint256 bigNumber,
        uint8 smallNumber,
        address indexed caller
    );

    function initializeLMDV1Library() external {
        LibDiamond.enforceIsContractOwner();
        LibMumbaiDebugV1.enforceTestnetOrLocal();
        LibMumbaiDebugV1.initialize();
    }

    function enableLMDV1Debugging() external {
        LibDiamond.enforceIsContractOwner();
        LibMumbaiDebugV1.enforceTestnetOrLocal();
        LibMumbaiDebugV1.enableDebugging();
    }

    function disableLMDV1Debugging() public {
        LibMumbaiDebugV1.disableDebugging();
    }

    function disableDebugging() external {
        disableLMDV1Debugging();
    }

    function debugPing() external view returns (string memory) {
        LibMumbaiDebugV1.enforceTestnet();
        return "pong";
    }

    function debugEcho(string memory s) external view returns (string memory) {
        LibMumbaiDebugV1.enforceTestnet();
        return s;
    }

    function debugEchoUint(uint256 i) external view returns (uint256) {
        LibMumbaiDebugV1.enforceTestnet();
        return i;
    }

    function debugExpectedFailure() public view {
        LibMumbaiDebugV1.enforceTestnet();
        require(false, "DebugFacet: This method is expected to fail");
    }

    function debugExpectedRevertOnDataWrite() external view{
        LibMumbaiDebugV1.enforceTestnet();
        require(false, "DebugFacet: This transaction is expected to fail");
    }

    function debugEmitTestEvent() external {
        LibMumbaiDebugV1.enforceTestnet();
        emit DebugDummyEvent("Debug event message", 109123494361698739045525162863955305292285610587294481426878721, 255, msg.sender);
    }

    function debugBatchRegisterAdmin(address[] memory _a) public {
        for(uint256 i = 0; i < _a.length; ++i) {
            debugRegisterAdmin(_a[i]);
        }
    }

    function debugRegisterAdmin(address _a) public {
        LibMumbaiDebugV1.enforceTestnet();
        LibMumbaiDebugV1.enforceAdmin();
        LibMumbaiDebugV1.registerAdmin(_a);
    }

    function debugBatchRegisterDebugger(address[] memory _a) internal {
        for(uint256 i = 0; i < _a.length; ++i) {
            debugRegisterDebugger(_a[i]);
        }
    }

    function debugRegisterDebugger(address _a) public {
        LibMumbaiDebugV1.enforceTestnet();
        LibMumbaiDebugV1.enforceAdmin();
        LibMumbaiDebugV1.registerDebugger(_a);
    }

    function debugGetRole(address _address) external view returns (bool isAdmin, bool isDebugger){
        LibMumbaiDebugV1.enforceTestnet();
        isAdmin = LibMumbaiDebugV1.isAdmin(_address);
        isDebugger = LibMumbaiDebugV1.isDebugger(_address);
    }

    function debugRepairMissingRoles() external {
        LibMumbaiDebugV1.enforceTestnet();
        LibMumbaiDebugV1.enforceAdmin();
        LibMumbaiDebugV1.repairMissingRoles();
    }
    
}
