// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IPostRule} from "../IPostRule.sol";
import {IGraph} from "../../graph/IGraph.sol";
import {IFeed} from "../../feed/IFeed.sol";

contract FollowersOnlyPostRule is IPostRule {
    struct Configuration {
        address graph;
        bool repliesRestricted;
        bool repostsRestricted;
        bool quotesRestricted;
    }

    mapping(address feed => mapping(uint256 postId => Configuration configuration)) internal _configuration;

    function configure(uint256 postId, bytes calldata data) external {
        Configuration memory configuration = abi.decode(data, (Configuration));
        _configuration[msg.sender][postId] = configuration;
    }

    function processQuote(uint256 rootPostId, uint256 quotedPostId, uint256 postId, bytes calldata data)
        external
        returns (bool)
    {
        return _processRestriction({
            isRestrictionEnabled: _configuration[msg.sender][rootPostId].quotesRestricted,
            feed: msg.sender,
            graph: _configuration[msg.sender][rootPostId].graph,
            rootPostId: rootPostId,
            newPostId: postId
        });
    }

    function processReply(uint256 rootPostId, uint256 repliedPostId, uint256 postId, bytes calldata data)
        external
        returns (bool)
    {
        return _processRestriction({
            isRestrictionEnabled: _configuration[msg.sender][rootPostId].repliesRestricted,
            feed: msg.sender,
            graph: _configuration[msg.sender][rootPostId].graph,
            rootPostId: rootPostId,
            newPostId: postId
        });
    }

    function processRepost(uint256 rootPostId, uint256 repostedPostId, uint256 postId, bytes calldata data)
        external
        returns (bool)
    {
        return _processRestriction({
            isRestrictionEnabled: _configuration[msg.sender][rootPostId].repostsRestricted,
            feed: msg.sender,
            graph: _configuration[msg.sender][rootPostId].graph,
            rootPostId: rootPostId,
            newPostId: postId
        });
    }

    function _processRestriction(
        bool isRestrictionEnabled,
        address feed,
        address graph,
        uint256 rootPostId,
        uint256 newPostId
    ) internal returns (bool) {
        if (isRestrictionEnabled) {
            address rootPostAuthor = IFeed(feed).getPostAuthor(rootPostId);
            address newPostAuthor = IFeed(feed).getPostAuthor(newPostId);
            require(IGraph(graph).isFollowing({followerAccount: newPostAuthor, targetAccount: rootPostAuthor}));
        }
        return isRestrictionEnabled;
    }
}
