// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimplePetAdoption {

    // ---- Variables ----
    address public owner; // dueño del contrato

    struct Pet {
        string name;
        address adopter;
        uint timeAdopted;
    }

    Pet[] public pets; // arreglo público

    // ---- Eventos ----
    event PetRegistered(string name, uint id);
    event PetAdopted(address adopter, uint id);
    event PetReturned(address adopter, uint id);

    // ---- Constructor ----
    constructor() {
        owner = msg.sender; // el que despliega es el refugio
    }

    // ---- Modificadores ----
    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el dueno puede ejecutar esta funcion");
        _;
    }

    modifier onlyNotOwner() {
        require(msg.sender != owner, "El dueno no puede ejecutar esta funcion");
        _;
    }

    // ---- Funciones ----

    // 1️⃣ Registrar mascota (solo el refugio)
    function registerPet(string memory _name) public onlyOwner {
        pets.push(Pet(_name, address(0), 0));
        emit PetRegistered(_name, pets.length - 1);
    }

    // 2️⃣ Adoptar mascota (solo no dueños)
    function adoptPet(uint _id) public onlyNotOwner {
        require(_id < pets.length, "Mascota no existe");
        require(pets[_id].adopter == address(0), "Mascota ya adoptada");

        pets[_id].adopter = msg.sender;
        pets[_id].timeAdopted = block.timestamp;
        emit PetAdopted(msg.sender, _id);
    }

    // 3️⃣ Devolver mascota dentro de 2 minutos
    function returnPet(uint _id) public onlyNotOwner {
        require(_id < pets.length, "Mascota no existe");
        Pet storage pet = pets[_id];
        require(pet.adopter == msg.sender, "No eres el adoptante");
        require(block.timestamp <= pet.timeAdopted + 2 minutes, "Tiempo de devolucion expirado");

        pet.adopter = address(0);
        pet.timeAdopted = 0;
        emit PetReturned(msg.sender, _id);
    }

    // 4️⃣ Contar mascotas adoptadas
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
