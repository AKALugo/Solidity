//SPDX-License-Identifier: MIT
pragma solidity >0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20Loteria.sol";

contract Loteria {
    // Instancia contrato token.
    ERC20Basic private token;

    // Direcciones
    address public owner;
    address public contrato;

    constructor() public {
        token = new ERC20Basic(10000);
        owner = msg.sender;
        contrato = address(this);
    }

    //------------------------------------------------------- TOKEN -------------------------------------------------------
    
    // Modificador para funciones que solo pueda ejecutar el dueño del contrato.
    modifier Unicamente(address propietario) {
        require(propietario == owner, "No tienes permisos para ejecutar esta funcion");
        _;
    }

    event ComprarTokens(uint, address);

    // Precio de un token
    function PrecioTokens(uint _numTokens) internal pure returns(uint) {
        return _numTokens * (1 ether);
    }

    // Generar más tokens
    function GeneraTokens(uint _numTokens) public Unicamente(msg.sender) {
        token.increaseTotalSupply(_numTokens);
    }

    // Comprar tokens
    function CompraTokens(uint _numTokens) public payable {
        // Calculamos el precio de los tokens
        uint coste = PrecioTokens(_numTokens);
        // Comprobamos que hay suficientes ethers.
        require (msg.value >= coste, "Cantidad de ether insuficiente");
        // Comprobamos que hay suficientes tokens en el contrato.
        require (_numTokens <= token.balanceOf(contrato), "Cantidad de tokens insuficientes");

        // Calculamos los ethers que hay que devolver y los devolvemos.
        msg.sender.transfer(msg.value - coste);
        // Transferimos los tokens al comprador.
        token.transfer(msg.sender, _numTokens);

        // Emitimos el evento
        emit ComprarTokens(_numTokens, msg.sender);
    }

    // Tokens disponibles en el contrato.
    function TokensDisponibles() public view returns(uint) {
        return token.balanceOf(address(this));
    }

    // Obtener el balance tokens acumulados en el bote
    function Bote() public view returns(uint) {
        return token.balanceOf(owner);
    }

    // Tokens de una persona
    function MisTokens() public view returns (uint) {
        return token.balanceOf(msg.sender);
    }

    //------------------------------------------------------- Loteria -------------------------------------------------------

    // Precio del boleto en tokens
    uint public PrecioBoleto = 2;
    // Cantidad de boletos
    uint public BoletosTotales = 10;
    // Cantidad de boletos disponibles.
    uint public BoletosDisponibles = BoletosTotales;
    // Relacion entre la persona que compra el boleto y el numero de boletos
    mapping (address => uint[]) idPersona_boletos;
    // Relacion necesaria para identificar al ganador
    mapping(uint => address) ADN_boleto;
    // Numero aleatorio
    uint randNonce = 0;
    // Boletos generados
    uint [] boletos_comprados;
    // Evento
    event boleto_comprado(uint);
    event boleto_ganador(uint);
    event tokens_devueltos(uint, address);

    // Funcion para comprar boletos de loteria
    function ComprarBoleto(uint _boletos) public {
        // Precio total de los boletos que se quieren comprar;
        uint precio_total = _boletos * PrecioBoleto;
        // Comprobamos que el cliente tenga tokens suficientes.
        require (precio_total <= MisTokens(), "Cantidad de tokens insuficiente");
        // Comprobamos que hayan suficientes boletos para comprar.
        require (_boletos <= BoletosDisponibles, "No quedan tantos boletos disponibles");
        // Transferencia de tokens al owner -> bote/premio
        token.transferLoteria(msg.sender, owner, precio_total);
        // Bool para verificar que el boleto generado de forma aleatoria no lo tenga otra persona.
        bool unico = false;
        // Entero sin signo donde vamos a almacenar el numero aleatorio.
        uint random;

        // Generamos los boletos.
        for (uint i = 0; i < _boletos; i++) {
            while (!unico) {
                // Valor aleatorio entre 0 y 9999, lo generamos con la fecha actual (now), la dirección 
                // de la persona que compra los boletos y un randNonce que solo se puede utilizar una vez
                random = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % BoletosTotales;
                randNonce ++;
                // Comprobamos que no haya sido asignado a nadie ese numero
                if (ADN_boleto[random] == address(0x0)) {
                    // Guardamos los datos del boleto.
                    idPersona_boletos[msg.sender].push(random);
                    // Guardamos el numero del boleto para luego seleccionar a un ganador.
                    boletos_comprados.push(random);
                    // Asociamos el boleto a la persona
                    ADN_boleto[random] = msg.sender;

                    unico = true;
                }
            }
            unico = false;
            emit boleto_comprado(random);
        }
        // Restamos los boletos que se acaban de vender.
        BoletosDisponibles -= _boletos;
    }

    // Ver boletos comprados de la persona.
    function MisBoletos() public view returns(uint[] memory) {
        return idPersona_boletos[msg.sender];
    }

    // Funcion para generar un ganador e ingresarle los tokens
    function GenerarGanador() public Unicamente(msg.sender) {
        // Debe haber boletos comprados para generar un ganador
        require(boletos_comprados.length > 0, "No se ha vendido ningún boleto todavía");
        // Selecionamos un numero de forma aleatoria y escogemos el boleto ganador.
        uint ganador = boletos_comprados[uint(keccak256(abi.encodePacked(now))) % boletos_comprados.length];

        emit boleto_ganador(ganador);
        // Le enviamos al ganador todos los tokens.
        token.transferLoteria(owner, ADN_boleto[ganador], Bote());
    }

    // Devolucion de Tokens
    function DevolverTokens(uint _numTokens) public payable {
        // El cliente debe tener los tokens que quiere devolver
        require (_numTokens <= MisTokens(), "Tokens insuficientes");
        // Pasamos los tokens del cliente al contrato.
        token.transferLoteria(msg.sender, address(this), _numTokens);
        // Le damos sus ethers al cliente.
        msg.sender.transfer(PrecioTokens(_numTokens));

        emit tokens_devueltos(_numTokens, msg.sender);
    }
}