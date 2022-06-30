// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {LibTerminus} from "../LibTerminus.sol";
import {LibTerminusController} from "../controller/LibTerminusController.sol";
import {LibDiamond} from "../../diamond/libraries/LibDiamond.sol";

library LibMumbaiDebugV1 {
    event LibMumbaiDebugV1Activity(string method, address indexed caller);

    uint256 private constant MUMBAI_CHAINID = 80001;
    uint256 private constant POLYGON_CHAINID = 137;
    uint256 private constant LOCAL_CHAINID = 1337;
    bytes32 private constant DEBUG_STORAGE_POSITION = keccak256("diamond.libMumbaiDebug.storage");

    /* solhint-disable var-name-mixedcase */
    struct LibMumbaiDebugStorage {
        bool debugEnabled;
        mapping(address => bool) admins;
        address[] allAdmins;
        mapping(address => bool) debuggers;
        address[] allDebuggers;
        mapping(address => bool) bans;
    } /* solhint-enable var-name-mixedcase */

    function libMumbaiDebugStorage() private pure returns (LibMumbaiDebugStorage storage lmds) {
        bytes32 position = DEBUG_STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            lmds.slot := position
        }
    }

    function enforceDebuggingEnabled() internal view {
        enforceTestnetOrLocal();
        require(libMumbaiDebugStorage().debugEnabled, "LibMumbaiDebugV1: Debugging is disabled");
    }

    function enforceTestnet() internal view {
        require(block.chainid == MUMBAI_CHAINID, "LibMumbaiDebugV1: This code CANNOT run be outside of Testnet!");
    }

    function enforceTestnetOrLocal() internal view {
        require(block.chainid == MUMBAI_CHAINID || block.chainid == LOCAL_CHAINID, "LibMumbaiDebugV1: This code CANNOT run be outside of Testnet or locally!");
    }

    function enforceDebuggerOrAdmin() internal view {
        LibMumbaiDebugStorage storage lmds = libMumbaiDebugStorage();
        require(!lmds.bans[msg.sender], "LibMumbaiDebugV1: Caller is banned");
        require(lmds.admins[msg.sender] || lmds.debuggers[msg.sender], "LibMumbaiDebugV1: Caller is not a recognized debugger");
    }

    function enforceAdmin() internal view {
        LibMumbaiDebugStorage storage lmds = libMumbaiDebugStorage();
        require(!lmds.bans[msg.sender], "LibMumbaiDebugV1: Caller is banned");
        require(lmds.admins[msg.sender], "LibMumbaiDebugV1: Caller is not a recognized admin");
    }

    function initialize() internal {
        enforceTestnetOrLocal();
        LibDiamond.enforceIsContractOwner();
        LibMumbaiDebugStorage storage lmds = libMumbaiDebugStorage();
        lmds.admins[msg.sender] = true;   //  owner is always an admin
        lmds.allAdmins.push(msg.sender);
        lmds.debuggers[msg.sender] = true;   //  owner is always an admin
        lmds.allDebuggers.push(msg.sender);
        debugEvent("initialize");
    }

    function debugEvent(string memory _s) internal {
        enforceTestnetOrLocal();
        emit LibMumbaiDebugV1Activity(_s, msg.sender);
    }

    function enableDebugging() internal {
        enforceTestnetOrLocal();
        LibDiamond.enforceIsContractOwner();
        libMumbaiDebugStorage().debugEnabled = true;
    }

    function disableDebugging() internal {
        enforceAdmin();
        libMumbaiDebugStorage().debugEnabled = false;
    }

    function registerAdmin(address _a) internal {
        enforceTestnet();
        enforceAdmin();
        LibMumbaiDebugStorage storage lmds = libMumbaiDebugStorage();
        lmds.admins[_a] = true;
        lmds.allAdmins.push(_a);
        debugEvent("libMumbaiDebugRegisterAdmin");
    }

    function registerDebugger(address _a) internal {
        enforceTestnet();
        enforceAdmin();
        LibMumbaiDebugStorage storage lmds = libMumbaiDebugStorage();
        lmds.debuggers[_a] = true;
        lmds.allDebuggers.push(_a);
        debugEvent("libMumbaiDebugRegisterDebugger");
    }

    function repairMissingRoles() internal {
        LibMumbaiDebugStorage storage lmds = libMumbaiDebugStorage();
        for(uint i = 0; i < lmds.allDebuggers.length; ++i) {
            lmds.debuggers[lmds.allDebuggers[i]] = true;
        }

        for(uint i = 0; i < lmds.allAdmins.length; ++i) {
            lmds.admins[lmds.allAdmins[i]] = true;
        }
    }

    function isAdmin(address _a) internal view returns (bool) {
        return libMumbaiDebugStorage().admins[_a];
    }

    function isDebugger(address _a) internal view returns (bool) {
        return libMumbaiDebugStorage().debuggers[_a];
    }

}
