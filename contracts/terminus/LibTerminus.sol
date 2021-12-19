// SPDX-License-Identifier: Apache-2.0

/**
 * Authors: Moonstream Engineering (engineering@moonstream.to)
 * GitHub: https://github.com/bugout-dev/dao
 *
 * Common storage structure and internal methods for Moonstream DAO Terminus contracts.
 * As Terminus is an extension of ERC1155, this library can also be used to implement bare ERC1155 contracts
 * using the common storage pattern (e.g. for use in diamond proxies).
 */

// TODO(zomglings): Should we support EIP1761 in addition to ERC1155 or roll our own scopes and feature flags?
// https://eips.ethereum.org/EIPS/eip-1761

pragma solidity ^0.8.9;

library LibTerminus {
    bytes32 constant TERMINUS_STORAGE_POSITION =
        keccak256("moonstreamdao.eth.storage.terminus");

    struct TerminusStorage {
        // Terminus administration
        address controller;
        bool isTerminusActive;
        uint256 currentPoolID;
        address paymentToken;
        uint256 poolBasePrice;
        // Terminus pools
        mapping(uint256 => address) poolController;
        mapping(uint256 => bool) poolActive;
        mapping(uint256 => string) poolURI;
        mapping(uint256 => uint256) poolSupply;
        mapping(uint256 => mapping(address => uint256)) poolBalances;
        mapping(address => mapping(address => bool)) globalOperatorApprovals;
        // TODO(zomglings): Add mappings for pool properties. E.g. poolTransferable, poolMintable, etc.
    }

    function terminusStorage()
        internal
        pure
        returns (TerminusStorage storage es)
    {
        bytes32 position = TERMINUS_STORAGE_POSITION;
        assembly {
            es.slot := position
        }
    }

    event ControlTransferred(
        address indexed previousController,
        address indexed newController
    );

    event PoolControlTransferred(
        uint256 indexed poolID,
        address indexed previousController,
        address indexed newController
    );

    function setController(address newController) internal {
        TerminusStorage storage ts = terminusStorage();
        address previousController = ts.controller;
        ts.controller = newController;
        emit ControlTransferred(previousController, newController);
    }

    function enforceIsController() internal view {
        TerminusStorage storage ts = terminusStorage();
        require(msg.sender == ts.controller, "LibTerminus: Must be controller");
    }

    function setTerminusActive(bool active) internal {
        TerminusStorage storage ts = terminusStorage();
        ts.isTerminusActive = active;
    }

    function setPoolController(uint256 poolID, address newController) internal {
        TerminusStorage storage ts = terminusStorage();
        address previousController = ts.poolController[poolID];
        ts.poolController[poolID] = newController;
        emit PoolControlTransferred(poolID, previousController, newController);
    }

    function createSimplePool() internal returns (uint256) {
        TerminusStorage storage ts = terminusStorage();
        uint256 poolID = ts.currentPoolID + 1;
        setPoolController(poolID, msg.sender);
        ts.currentPoolID++;
        return poolID;
    }

    function enforceIsActive() internal view {
        TerminusStorage storage ts = terminusStorage();
        require(
            ts.isTerminusActive,
            "LibTerminus: Terminus contract must be active"
        );
    }

    function enforcePoolIsActive(uint256 poolID) internal view {
        TerminusStorage storage ts = terminusStorage();
        require(
            ts.poolActive[poolID],
            "LibTerminus: Terminus pool must be active"
        );
    }

    function enforcePoolIsController(uint256 poolID, address maybeController)
        internal
        view
    {
        TerminusStorage storage ts = terminusStorage();
        require(
            ts.poolController[poolID] == maybeController,
            "LibTerminus: Must be pool controller"
        );
    }
}
