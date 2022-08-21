//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

contract OMS_COVID {
    
    // Dueño del contrato
    address public OMS;
    // Centros autorizados.
    mapping(address => bool) public ValidacionCentroSalud;
    // Mapping para relacionar un centro con su contrato.
    mapping(address => address) public CentroSalud_Contrato;
    // Array que contiene los contratos de los centros validados.
    address[] public contratoCentro;
    // Array que contiene las solicitudes de los centros que quieren el acceso al sistema
    address[] solicitudes;

    constructor() {
        OMS = msg.sender;
    }

    // Eventos
    event NuevoContrato(address, address);
    event NuevoCentroValidado(address);
    event SoliciudAcceso(address);

    // SOlo la OMS puede realizar ciertas funciones.
    modifier UnicamenteOMS(address _direccion) {
        require(OMS == _direccion, "Solo la OMS puede realizar esta funcion");
        _;
    }

    // Funcion para solicitar acceso al sistema medico.
    function SolicitarAcceso() public {
        // Almacenamos la solicitud
        solicitudes.push(msg.sender);

        emit SoliciudAcceso(msg.sender);
    }

    // Funcion para que la OMS visualize las solicitudes
    function VisualizarSolicitudes() public view UnicamenteOMS(msg.sender) returns(address[] memory) {
        return solicitudes;
    }

    // Funcion que autoriza a un centro de salud a autogestionarse.
    function CentrosSalud(address _centroSalud)  public UnicamenteOMS(msg.sender) {
        // Le damos permisos al centro de salud para crear sus contratos
        ValidacionCentroSalud[_centroSalud] = true;

        emit NuevoCentroValidado(_centroSalud);
    }

    // FUncion que permita crear un contrato inteligente de un centro de salud
    function FactoryCentroSalud() public {
        // Miramos que el centro esté autorizado
        require (ValidacionCentroSalud[msg.sender] == true, "No tienes permiso para realizar esta accion");
        // Generamos un smart Contract y lo almacenamos
        contratoCentro.push(address (new CentroSalud(msg.sender)));
        // Relacionamos el centro de salud con el contrato
        CentroSalud_Contrato[msg.sender] = contratoCentro[contratoCentro.length - 1];

        emit NuevoContrato(msg.sender, contratoCentro[contratoCentro.length - 1]);
    }
}

contract CentroSalud {

    // Direccion del centro que crea el contrato
    address public Centro;
    // Mapping que relaciona el hash de una prueba con el codigo IPFS
    mapping(bytes32 => DatosPruebas) ResultadoPruebaCOVID;

    // Estructura de lops resultados.
    struct DatosPruebas {
        uint numPrueba;
        string IPFS;
        bool resultado;
    }

    // Eventos
    event NuevoResultado (string, bool);

    constructor (address _direccion) {
        Centro = _direccion;
    }

    // Solo el centro de salud puede ejecutar.
    modifier UnicamenteCentroSalud (address _direccion) {
        require (Centro == _direccion, "Solo el centro de salud puede acceder a esta funcion");
        _;
    }

    // Funcion para emitir un resultado de una prueba de COVID.
    function AlmacenarResultadosPruebaCOVID(string memory _idPersona, bool _resultado, string memory _codigoIPFS, uint _numPrueba) public UnicamenteCentroSalud(msg.sender) {
        // Calculamos el hash de la persona, creamos una estructura con los datos y guardamos la relacion en el mapping.
        ResultadoPruebaCOVID[keccak256(abi.encodePacked(_idPersona))] = DatosPruebas(_numPrueba, _codigoIPFS, _resultado);

        emit NuevoResultado (_codigoIPFS, _resultado);
    }

    // Funcion que permite a un paciente revisar los resultados de su prueba
    function VisualizarResultadosPruebaCOVID(string memory _idPersona) public view returns(string memory, string memory) {
        // calculamos el hash de la persona.
        bytes32 hashPersona = keccak256(abi.encodePacked(_idPersona));

        // Miramos los resultados.
        if (ResultadoPruebaCOVID[hashPersona].resultado) {
            return ("Positivo", ResultadoPruebaCOVID[hashPersona].IPFS);
        }
        return ("Negativo", ResultadoPruebaCOVID[hashPersona].IPFS);
    }
}