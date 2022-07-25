// SPDX-License-Identifier: MIT

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
  mapping(uint256 => uint256) internal _lastFeedBlock;
  mapping(uint256 => uint256) internal _lastCleanBlock;

  // Moli stats
  mapping(uint256 => string) internal _names;
  mapping(uint256 => uint256[9]) internal _dnas;
  mapping(string => uint256) internal _dnasToTokenId;
  mapping(uint256 => uint8) internal _boredom;
  mapping(uint256 => uint8) internal _hunger;
  mapping(uint256 => uint8) internal _uncleanliness;

  // Initialize contract
  function initialize(address trustedForwarder) public initializer {
    __Ownable_init();
    __ERC721_init("Moli", "MOL");
    __ERC2771Context_init(trustedForwarder);
  }

  // Methods
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
    _lastFeedBlock[newTokenId] = block.number;
    _lastCleanBlock[newTokenId] = block.number;
    _boredom[newTokenId] = 0;
    _hunger[newTokenId] = 0;
    _uncleanliness[newTokenId] = 0;

    // Get DNA

    // Save DNA

    // Build tokenURI

    // Initiate minting
    _mint(_msgSender(), newTokenId);

    emit MoliSummoned(_msgSender(), name);

    return newTokenId;
  }

  // Play with your Moli
  function play(uint256 tokenId) 
    public 
    doesMoliExists 
    isItYourMoli 
    doesItWantToPlay
  {
    _lastPlayBlock[tokenId] = block.number;

    _boredom[tokenId] = 0;
    _hunger[tokenId] += 5;
    _uncleanliness[tokenId] += 5;
  }

  // Feed your Moli
  function feed(uint256 tokenId)
    public
    doesMoliExists
    isItYourMoli
    doesItWantToEat
  {
    _lastFeedBlock[tokenId] = block.number;

    _hunger[tokenId] = 0;
    _boredom[tokenId] += 5;
    _uncleanliness[tokenId] = += 5;
  }

  // Clean your Moli
  function clean(uint256 tokenId) 
    public
    doesMoliExists
    isItYourMoli
    doesItWantToGetClean
  {
    _lastCleanBlock[tokenId] = block.number;

    _uncleanliness[tokenId] = 0;
    _hunger[tokenId] += 5;
    _boredom[tokenId] += 5;
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
      getHunger(tokenId) < 101 &&
      getUncleanliness(tokenId) < 101;
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
  function getHunger(uint256 tokenId)
    public
    view
    doesMoliExists
    returns (uint256)
  {
    return
      _hunger[tokenId] + ((block.number - _lastWalkBlock[tokenId]) / 1000);
  }

  // Get loneliness stat for a given Moli
  function getUncleanliness(uint256 tokenId)
    public
    view
    doesMoliExists
    returns (uint256)
  {
    return
      _uncleanliness[tokenId] +
      ((block.number - _lastSyncedBlock[tokenId]) / 1000);
  }

  // Get random available DNA. TOD: CHANGE TO INTERNAL ONCE TESTED
  function getRandomDNA() public returns (uint[9]) {
    uint256[9] randomDNA;
    // Get random number between 0 and 255
    for (i = 0; i = 9; i++) {
      randomDNA.push(getPseudoRandomNumber());
    }

    // Check if the DNA calculated is unique
    if (_dnasToTokenId[keccak256(abi.encodePacked(randomDNA))]) {
      revert("Calculated DNA not unique");
    } else {
      return randomDNA;
    }
  }

// Get random number to calculate Moli's DNA
  function getPseudoRandomNumber() internal returns (uint256) {
    return uint(keccak256(abi.encodePacked(msg.sender, nonce))) % 256;
  }

// Get Moli status
function getMoliStatus(uint256 tokenId) 
  public 
  view 
  doesMoliExists 
  returns (string memory) 
{
  uint256 mostNeeded = 0;

  string[4] memory goodStatus = ["WAGMI", "Can't feel better!", "I'm great, thank you!", "I (L) you"];

  string memory status = goodStatus[block.number % 4];

  uint256 hunger = getHunger(tokenId);
  uint256 boredom = getBoredom(tokenId);
  uint256 uncleanliness = getUncleanliness(tokenId);

  if (isAlive(tokenId) === false) return "This Moli is no longer with us";

  if (hunger > 50 && hunger > mostNeeded) {
    mostNeeded = hunger;
    status = "I'm hungry. Feed me, please!"
  }

  if (uncleanliness > 50 && uncleanliness > mostNeeded) {
    mostNeeded = uncleanliness;
    status = "I'm feeling gross. Clean me, please!";
  }

  if (boredom > 50 && boredom > mostNeeded) {
    mostNeeded = boredom;
    status = "I'm extremely bored. Play with me, please!";
  }

  return status;
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
    require(getBoredom() > 0, "I don't need to play");
    require(getHunger(tokenId) < 80, "I'm too hungry to play");
    require(getUncleanliness(tokenId) < 80, "I'm feeling too gross to play");
  }

  modifier doesItWantToEat() {
    require(getBoredom(tokenId) < 80, "I'm too sad to eat");
    require(getUncleanliness(tokenId) < 80, "I'm feeling too gross to eat");
  }

  modifier doesItWantToGetClean() {
    require(getBoredom(tokenId) < 80, "I'm too bored to get clean");
    require(getHunger(tokenId) < 80, "I'm too hungry to get clean");
  }
}
