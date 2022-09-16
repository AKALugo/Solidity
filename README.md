# Solidity
* En este repositorio se encuentran diferentes proyectos escritos en ___Solidity___. Los proyectos son:
    1. Sistema de votaciones.
    2. Token ERC20.
    3. Gestion de un parque de atracciones utilizando un token ERC20, en este caso se ha puesto como ejemplo un parque de Disney, se pueden desplegar atraciones, establecer su precio, dar de baja ...
    4. Sistema de loteria, se comprarán tokens ERC20 para posteriormente comprar los boletos, los boletos se generan de forma aleatoria y única por lo tanto solo puede haber un ganador, además estos son limitados. El owner del contrato será el encargado de almacenar los tokens con los cuales se hayan comprado los boletos y luego se encargará de generar aleatoriamente un ganador entre los boletos comprados y de enviarle el bote acumulado.
    5. Sistema médico gestionado por la OMS, los diferentes Centros de Salud pueden solicitar acceso pero solo la OMS concederlo. Cuando un centro obtenga el acceso este podrá desplegar un contrato utilizando una `Factory` y posteriormente con el contrato desplegado podrá publicar de forma confidencial los resultados de las pruebas COVID de los pacientes, después ellos con su identificador único y secreto podrán consultar los resultados.
    6. NFT.