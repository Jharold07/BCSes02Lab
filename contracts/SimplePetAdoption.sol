// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimplePetAdoption {

    struct Pet {
        string name;
        address adopter;
        uint timeAdopted;
    }

    Pet[] public pets; 

    event PetRegistered(string name, uint id);
    event PetAdopted(address adopter, uint id);
    event PetReturned(address adopter, uint id);

    address public owner;

    constructor() {
        owner = msg.sender; 
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el dueno puede ejecutar esta funcion");
        _;
    }

    modifier onlyNotOwner() {
        require(msg.sender != owner, "El dueno no puede ejecutar esta funcion");
        _;
    }

    function registerPet(string memory _name) public onlyOwner {
        pets.push(Pet(_name, address(0), 0));
        emit PetRegistered(_name, pets.length - 1);
    }

    function adoptPet(uint _id) public onlyNotOwner {
        require(_id < pets.length, "Mascota no existe");
        require(pets[_id].adopter == address(0), "Mascota ya adoptada");

        pets[_id].adopter = msg.sender;
        pets[_id].timeAdopted = block.timestamp;
        emit PetAdopted(msg.sender, _id);
    }

    function returnPet(uint _id) public onlyNotOwner {
        require(_id < pets.length, "Mascota no existe");
        Pet storage pet = pets[_id];
        require(pet.adopter == msg.sender, "No eres el adoptante");
        require(block.timestamp <= pet.timeAdopted + 2 minutes, "Tiempo de devolucion expirado");

        pet.adopter = address(0);
        pet.timeAdopted = 0;
        emit PetReturned(msg.sender, _id);
    }

    function countAdopted() public view returns (uint) {
        uint count = 0;
        for (uint i = 0; i < pets.length; i++) {
            if (pets[i].adopter != address(0)) {
                count++;
            }
        }
        return count;
    }
}
