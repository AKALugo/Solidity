//SPDX-License-Identifier: MIT
pragma solidity >0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20Disney.sol";

contract Disney {

    // <------------------------------------------- DECLARACIONES ------------------------------------------->
    // Instancia contrato Token ERC20
    ERC20Basic private token;

    // Direccion de Disney (owner)
    address payable public owner;

    // Informacion de un cliente.
    struct cliente {
        uint token_comprado;
        string[] atracciones_visitadas;
    }

    // Estructura de datos clientes.
    mapping (address => cliente) public Clientes;

    constructor() public {
        token = new ERC20Basic(1000);
        owner = msg.sender;
    }


    // <------------------------------------------- GESTION TOKEN ------------------------------------------->

    // Funcion para calcular la conversión del token a ether.
    function PrecioTokens(uint _numTokens) internal pure returns (uint) {
        // Relacion 1:1
        return _numTokens * (1 ether);
    }

    // FUncion para comprar Tokens en Disney
    function CompraTokens(uint _numTokens) public payable {
        // Calculamos cuantos ether tiene que pagar.
        uint coste = PrecioTokens(_numTokens);
        // Se mira que el cliente tenga ether para pagar.
        require (msg.value >= coste, "Cantidad de ether insuficiente");

        // Comprobamos que hayan tantos tokens como se quiere comprar.
        require (BalanceOf() >= _numTokens, "Cantidad de tokens insuficientes");

        // Retornamos el dinero restante al cliente.
        msg.sender.transfer(msg.value - coste);
        // Le damos al cliente sus tokens.
        token.transfer(msg.sender, _numTokens);
        // Guardamos la compra en nuestra estructura de datos
        Clientes[msg.sender].token_comprado += _numTokens;
    }

    // Tokens que quedan en el contrato.
    function BalanceOf() public view returns (uint) {
        return token.balanceOf(address(this));
    }

    // Tokens restantes de un cliente
    function MisTokens() public view returns(uint) {

        return token.balanceOf(msg.sender);
    }

    // Aumentamos el número de tokens, solo Disney puede
    function GenerarTokens (uint _numTokens) public Unicamente(msg.sender) {
        token.increaseTotalSupply(_numTokens);
    }

    // Solo disney puede realizar la acción.
    modifier Unicamente(address _direccion) {
        require( _direccion == owner, "No tienes permiso para ejecutar esta acción");
        _;
    }

    // <------------------------------------------- GESTION PARQUE ------------------------------------------->

    // Eventos
    event disfruta_atraccion(string);
    event nueva_atraccion(string, uint);
    event baja_atraccion(string);
    event subir_atraccion(string);

    // Estructura datos atraccion
    struct atraccion {
        string nombre;
        uint precio;
        bool estado;
    }

    // Relacion nombre atraccion:datos atraccion
    mapping (string => atraccion) public MappingAtracciones;
    // Nombre de todas las atracciones.
    string[] Atracciones;
    // Relación cliente:historial
    mapping (address => string[]) HistorialCliente;

    // Crear nuevas atracciones
    function NuevaAtraccion(string memory _nombreAtraccion, uint _precio) public Unicamente(msg.sender) {
        // Creacion de una atraccion
        MappingAtracciones[_nombreAtraccion] = atraccion(_nombreAtraccion, _precio, true);
        // Guardamos el nombre
        Atracciones.push(_nombreAtraccion);

        // Emitimos el evento de nueva atracción.
        emit nueva_atraccion(_nombreAtraccion, _precio);
    }

    // Dar de baja una atraccion
    function BajarAtraccion (string memory _nombreAtraccion) public Unicamente(msg.sender) {
        bool alta = false;
        // Comprobamos que la atracción exista previamente.
        for (uint i = 0; i < Atracciones.length; i++) {
            if (keccak256(abi.encodePacked(Atracciones[i])) == keccak256(abi.encodePacked(_nombreAtraccion))) {
                alta = true;
                if (MappingAtracciones[_nombreAtraccion].estado) {
                    // Cambiamos el estado de la atraccion,
                    MappingAtracciones[_nombreAtraccion].estado = false;
                } else {
                    require(MappingAtracciones[_nombreAtraccion].estado, "No se puede dar de baja a una atraccion que ya esta de baja");
                }
                break;
            }
        }
        require(alta, "No se puede dar de baja a una atraccion que no exista");

        // Emitimos un evento
        emit baja_atraccion(_nombreAtraccion);
    }

    // Poner operativa una atraccion
    function SubirAtraccion (string memory _nombreAtraccion) public Unicamente(msg.sender) {
        bool alta = false;
        // Comprobamos que la atracción exista previamente.
        for (uint i = 0; i < Atracciones.length; i++) {
            if (keccak256(abi.encodePacked(Atracciones[i])) == keccak256(abi.encodePacked(_nombreAtraccion))) {
                alta = true;
                if (!MappingAtracciones[_nombreAtraccion].estado) {
                    // Cambiamos el estado de la atraccion,
                    MappingAtracciones[_nombreAtraccion].estado = true;
                } else {
                    require(!MappingAtracciones[_nombreAtraccion].estado, "No se puede dar de alta a una atraccion que ya esta dada de alta");
                }
                break;
            }
        }
        require(alta, "No se puede dar de alta a una atraccion que no exista");
        
        // Emitimos un evento
        emit subir_atraccion(_nombreAtraccion);
    }

    // Visualizar las atracciones de Disney
    function AtraccionesDisponibles() public view returns (string memory) {
        string memory disponibles;
        for (uint i = 0; i < Atracciones.length; i++) {
            if (MappingAtracciones[Atracciones[i]].estado) {
                disponibles = string(abi.encodePacked(disponibles, " | ", Atracciones[i]));
            }
        }

        return disponibles;
    }

    // Funcion para subirse en una atraccion y pagar
    function SubirseAtraccion(string memory _nombreAtraccion) public {
        // Bools para conocer el estado de la atraccion
        bool atraccionExiste = false;
        bool atraccionDisponible = false;

        // Recorremos las atracciones
        for (uint i = 0; i < Atracciones.length; i++) {
            // Encontramos la atraccion
            if (keccak256(abi.encodePacked(Atracciones[i])) == keccak256(abi.encodePacked(_nombreAtraccion))) {
                atraccionExiste = true;
                // Si la atraccion está disponible
                if (MappingAtracciones[Atracciones[i]].estado) {
                    atraccionDisponible = true;

                    // Miramos que el cliente tenga los tokens suficientes
                    require (MappingAtracciones[Atracciones[i]].precio <= MisTokens(), "Tokens insuficientes");

                    // El cliente procede a hacer el pago.
                    token.transfer_Disney(msg.sender, address(this), MappingAtracciones[Atracciones[i]].precio);

                    // Actualizamos el historial
                    HistorialCliente[msg.sender].push(Atracciones[i]);

                    // Lanzamos evento.
                    emit disfruta_atraccion(Atracciones[i]);
                } else {
                    // Si no encontramos la atraccion
                    require(atraccionDisponible, "La atraccion en cuestion no se encuentra disponible");
                }
                break;
            }
        }
        // Si no encontramos la atraccion
        require(atraccionExiste, "La atraccion en cuestión no existe");
    }

    // Historial de las atracciones del cliente.
    function Historial () public view returns (string[] memory) {
        return HistorialCliente[msg.sender];
    }

    // Devolvemos los tokens.
    function DevolverTokens(uint _numTokens) public payable {
        // Miramos que el usuario tenga los tokens
        require(MisTokens() >= _numTokens, "Tokens insuficientes");
        
        // Hacemos la transferencia del cliente a Disney.
        token.transfer_Disney(msg.sender, address(this),  _numTokens);

        // Devolvemos los ethers al cliente.
        msg.sender.transfer(PrecioTokens(_numTokens));
    }
}