//SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;

contract votacion {

    //Direccion del propietario del contrato
    address public owner;

    //Relacion entre el nombre del candidato y el hash de sus datos personales
    mapping (string => bytes32) Candidato;

    //Relacion entre el combre del candidato y el número de votos
    mapping (string => uint) VotosCandidato;

    //Lista para almacenar los nombres de los candidatos
    string[] candidatos;

    //Lista de los hashes de la identidad de los votantes
    bytes32[] votantes;

    constructor () public {
        owner = msg.sender;
    }

    // Cualquier persona puede presentarse a las elecciones 
    function Representar(string memory _nombre, uint _edad, string memory _ID) public {
        // Hash de los datos del candidato
        bytes32 hashCandidato = keccak256(abi.encodePacked(_nombre, _edad, _ID));

        // Almacenar el hash de los datos del candidato ligados a su nombre
        Candidato[_nombre] = hashCandidato;
        // Almacenamos el nombre del candidato.
        candidatos.push(_nombre);
    }

    // Permite visualizar a las personas que se hayan presentado como candidatos
    function VerCandidatos() public view returns(string[] memory) {
        return candidatos;
    }

    // Los votantes van a poder votar
    function Votar(string memory _candidato) public {

        // Hash del votante
        bytes32 hash_votante = keccak256(abi.encodePacked(msg.sender));

        // Verificamos si ya se ha votado
        for(uint iterator = 0; iterator < votantes.length; iterator++) {
            require(hash_votante != votantes[iterator], "Ya se ha votado previamente");
        }

        // Almacenamos al votante
        votantes.push(hash_votante);
        
        // Sumamos el voto
        VotosCandidato[_candidato]++;
    }

    // Votos de un candidato
    function VerVotosCandidatos(string memory _candidato) public view returns(uint) {
        return VotosCandidato[_candidato];
    }

    // Ver los votos de cada uno de los candidatos
    function VerResultados() public view returns (string memory) {
        
        // Resultado final
        string memory resultados;

        // Recorremos el array de candidatos
        for (uint iterator = 0; iterator < candidatos.length; iterator++) {
            // Actualizamos resultados y añadimos los candidatos y sus votos.
            resultados = string(abi.encodePacked(resultados, "| ", candidatos[iterator], " ", uint2str(VotosCandidato[candidatos[iterator]]), " |\n"));
        }

        return resultados;
    }

    // Propociona al ganador
    function Ganador() view public returns(string memory) {
        //Ganador 
        string memory ganador = candidatos[0];
        // En el caso de que haya empate
        bool flag;

        // Recorremos los candidatos buscando el de más votos.
        for (uint iterator = 1; iterator < candidatos.length; iterator++) {
            // Miramos la cantidad de votos
            if (VotosCandidato[ganador] < VotosCandidato[candidatos[iterator]]) {
                ganador = candidatos[iterator];
                flag = false;
            } else if (VotosCandidato[ganador] == VotosCandidato[candidatos[iterator]]){
                flag = true;
            }
        }

        if (flag) {
            ganador = "Hay un empate !!";
        }

        return ganador;
    }

    // Funcion que pasa de uint a string
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}