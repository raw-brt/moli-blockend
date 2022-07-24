// SPDX-License-Identifier: UNLICENSED

/*
    Inspired in the almighty Tamagotchi and the works of dhof.eth and m1guelpf.eth
*/

pragma solidity ^0.8.7;

import "base64-sol/base64.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/metatx/ERC2771ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

contract Moli is
  OwnableUpgradeable,
  ERC721Upgradeable,
  ERC721EnumerableUpgradeable,
  ERC2771ContextUpgradeable
{
  // Events
  event MoliSummoned(address indexed summoner, string indexed name);

  // Constants
  using CountersUpgradeable for CountersUpgradeable.Counter;
  CountersUpgradeable.Counter private _tokenIds;

  uint256 public constant MAX_MOLI_POPULATION = 1000000;

  // Using blocks to track moli stats
  mapping(uint256 => uint256) internal _lastPlayBlock;
  mapping(uint256 => uint256) internal _lastWalkBlock;
  mapping(uint256 => uint256) internal _lastSyncedBlock;

  // Moli stats
  mapping(uint256 => string) internal _names;
  mapping(uint256 => uint[9]) internal _dnas;
  mapping(uint256 => uint8) internal _boredom;
  mapping(uint256 => uint8) internal _sadness;
  mapping(uint256 => uint8) internal _loneliness;

  // Methods
  function initialize(address trustedForwarder) public initializer {
    __Ownable_init();
    __ERC721_init("Moli", "MOL");
    __ERC2771Context_init(trustedForwarder);
  }

  function summon(string calldata name) public returns (uint256) {
    // Set tokenId
    _tokenIds.increment();
    uint256 newTokenId = _tokenIds.current();

    // Check if all Molis are summoned
    require(newTokenId <= MAX_MOLI_POPULATION, "Max. Moli population reached");

    // Set name
    _names[newTokenId] = name;

    // Set base stats
    _lastPlayBlock[newTokenId] = block.number;
    _lastSyncedBlock[newTokenId] = block.number;
    _lastWalkBlock[newTokenId] = block.number;
    _boredom[newTokenId] = 0;
    _sadness[newTokenId] = 0;
    _loneliness[newTokenId] = 0;

    // Initiate minting
    _mint(_msgSender(), newTokenId);

    return newTokenId;
  }

  function play(uint256 tokenId) public doesMoliExists isItYourMoli {
    // Check if wants to play
    // Check if it's with us
    // Check if it's so sad to play
    // Check if it's so alone to play
  }

  // Is this Moli alive?
  function isAlive(uint256 tokenId) 
    public 
    view 
    doesMoliExists 
    returns (bool) 
  {
    return
      getBoredom(tokenId) < 101 &&
      getSadness(tokenId) < 101 &&
      getLoneliness(tokenId) < 101;
  }

  // Get boredom stat for a given Moli
  function getBoredom(uint256 tokenId)
    public
    view
    doesMoliExists
    returns (uint256)
  {
    return
      _boredom[tokenId] + ((block.number - _lastPlayBlock[tokenId]) / 1000);
  }

  // Get sadness stat for a given Moli
  function getSadness(uint256 tokenId)
    public
    view
    doesMoliExists
    returns (uint256)
  {
    return
      _sadness[tokenId] + ((block.number - _lastWalkBlock[tokenId]) / 1000);
  }

  // Get loneliness stat for a given Moli
  function getLoneliness(uint256 tokenId)
    public
    view
    doesMoliExists
    returns (uint256)
  {
    return
      _loneliness[tokenId] +
      ((block.number - _lastSyncedBlock[tokenId]) / 1000);
  }

  // Get random available DNA
  function getRandomDNA() returns (uint[9]) {
    // Get random number between 0 and 255

    // Push to an array

    // Loop 9 times

    // Check if the DNA calculated is unique

    // If not, try again

    // If it is, return it
  }

  // Token URI

  // Modifiers
  modifier doesMoliExists() {
    require(_exists(tokenId), "Moli not found");
  }

  modifier isItYourMoli() {
    require(ownerOf(tokenId) == _msgSender(), "Not your Moli");
  }

  modifier doesItWantToPlay() {
    require(getSadness(tokenId) < 80, "I'm too sad to play");
    require(getLoneliness(tokenId) < 80, "I'm feeling too alone to play");
  }

  modifier doesItWantToTakeAWalk() {
    require(getBoredom(tokenId) < 80, "I'm too bored to take a walk");
    require(getLoneliness(tokenId) < 80, "I'm feeling too alone to walk");
  }

  modifier doesItWantToSync() {
    require(getBoredom(tokenId) < 80, "I'm too bored to sync with you");
    require(getSadness(tokenId) < 80, "I'm feeling too alone to sync");
  }
}
