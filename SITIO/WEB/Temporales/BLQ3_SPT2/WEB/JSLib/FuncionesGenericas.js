/********************************************************************/
// Contenido    :  Funciones genércias que se utilizan en todas las
//				   páginas del proyecto web
/********************************************************************/


/************************************************************************
'Nombre:        Home
'Decripcion:    Funcion que retorna a la pagina principal
'Fecha:         02/JUN/04
************************************************************************/
function Home() {
	window.parent.location.href = "../Default.asp"
}

/************************************************************************
'Nombre:        Atras
'Decripcion:    Funcion que retorna a la pagina anterior
'Fecha:         02/JUN/04
************************************************************************/
function Atras() {
	history.back(1)
}

/************************************************************************
'Nombre:        Mano
'Decripcion:    Funcion que pone el cursor con el icono de la mano
'Fecha:         02/JUN/04
************************************************************************/
function Mano() {
	window.event.srcElement.style.cursor = "hand"
}

/************************************************************************
'Nombre:        SoloBlancos
'Decripcion:    Devuelve true si la hilera que le pasan por parámetro
'				solamente está compuesta de espacios en blanco.
'Fecha:         02/JUN/04
************************************************************************/
function SoloBlancos(str)
{
	var nCuantos = str.length;
	if(nCuantos == 0)
		return true;
	var blancos = /^[\s]+$/;
	return blancos.test(str);
}
	

/************************************************************************
'Nombre:        trim
'Decripcion:    trunca los espacios en blanco a la izquierda y a la 
'				derecha de la hilera que se le pasa por parámetro.
'				Devuelve la hilera modificada, por lo cual cuando se
'				invoca esta función se debe asignar a la variable con
'				que se quiere trabajar
'Fecha:         02/JUN/04
************************************************************************/
function trim(str)
{
	var n = str.length;
	if(n == 0) 
		return "";
	if(SoloBlancos(str))
		return "";
	
	while (str.substr(0,1) == " ")
	{
		str = str.substr(1);
	}
	n = str.length;
	
	while (str.substr(n -1,1) == " ") 
	{
		str = str.substr(0,n-1);
		n = str.length;
	}
	return str;
}

/************************************************************************
'Nombre:        EsDoble
'Decripcion:    Toma la hilera que recibe y examina si trae un dato 
'				numérico que sea de tipo entero o doble 
'Fecha:         02/JUN/04
************************************************************************/
function EsDoble(str) 
{ 
        var strDoble = /^[\d][\.]?[\d]+$/ 
        return strDoble.test(str) 
} 


/************************************************************************
'Nombre:        IsNum
'Decripcion:    Funcion en JScript con el fin de validar que un campo 
'				sea solo numerico.
'Fecha:         02/JUN/04
************************************************************************/
function IsNum(nNum) 
{   
	var str;
	var nCantPuntos;
	var nCantComas;
	
	nCantComas = 0;
	nCantPuntos = 0;
	
	if(nNum.value.length != 0)
	{
		//obtiene el valor absoluto
		nNum.value = nNum.value.replace("-","");
		str = nNum.value;
		
		
		for (var i=0; i < str.length; i++) 
		{
  			var ch=str.substring(i, i + 1);
  			if (ch < "0" || "9" < ch)
  			{
  				if (ch != "," && ch != ".")
  				{  		
					return false;
  				}  			
  				else
  				{
  					if(ch == ",")
  						//cuenta las comas en el numero
  						nCantComas++;
  					else
  						//cuenta los puntos en el numero
  						nCantPuntos++;
	  					
  					//si tiene mas de seis comas no es numerico
  					if(nCantComas >= 6)
  					{  			
						    return false;
  					}
	  				
  					//si tiene mas de dos puntos no es numerico
  					if(nCantPuntos >= 2)
  					{   
  						return false;
  					}
  				}	
  			}
		} //for
		
	}//if(nNum.value.length != 0)
	
	return true;
  
} //IsNum

/************************************************************************
'Nombre:        truncarDecimales
'Decripcion:    trunca los decimales a un numero determinado regido por
'				por el parametro nDecimales
'Fecha:         02/JUN/04
************************************************************************/
function truncarDecimales(nNum, nDecimales)
{
	var str = nNum;
	var strDecimales;
	var strEntero;
	
	if (str.indexOf(",") != -1)
	{
		strEntero = str.substring(0,str.indexOf(","));
		strDecimales = str.substring(str.indexOf(",") + 1, str.length);
		
		//Elimina comas y puntos de mas
		strDecimales = strDecimales.replace(",", "");
		strDecimales = strDecimales.replace(".", "");
						
		//si nDecimales > 0 se truncan los decimales
		//de lo contrario solo se retorna la parte 
		//entera del numero.
		if (nDecimales > 0)
		{
			//trunca decimales
			if (strDecimales.length > nDecimales)
			{
				strDecimales = strDecimales.substring(0,nDecimales);
			}
			str = strEntero + "," + strDecimales;
		}
		else
			//retorna parte entera
			str = strEntero;
				
	}	
	else
	{
		if (str.indexOf(".") != -1)
		{
			strEntero = str.substring(0,str.indexOf("."));
			strDecimales = str.substring(str.indexOf(".") + 1, str.length);
			
			//Elimina comas y puntos de mas
			strDecimales = strDecimales.replace(",", "");
			strDecimales = strDecimales.replace(".", "");
		
			//si nDecimales > 0 se truncan los decimales
			//de lo contrario solo se retorna la parte 
			//entera del numero.
			if (nDecimales > 0)
			{
				//trunca decimales
				if (strDecimales.length > nDecimales)
				{
					strDecimales = strDecimales.substring(0,nDecimales);
				}
				str = strEntero + "." + strDecimales;
			}
			else
				//retorna parte entera
				str = strEntero;
		}
	}
	
	nNum = str;
	return nNum;
	
}//truncarDecimales

/************************************************************************
'Nombre:        EliminarCerosIzquierda
'Decripcion:    elimina los ceros a la izquierda.
'Fecha:         02/JUN/04
************************************************************************/
function EliminarCerosIzquierda(nNum)
{
	var str = nNum;
	
	if(str.length != 0)
	{
		while (str.substring(0,1)== "0")
		{
			str = str.substring(1,str.length);
		}
	 	
 		//pone el cero al inicio si quedo ",21" ó ".21"
 		if (str.substring(0,1) == "," || str.substring(0,1) == ".")
 		{
 			str = "0" + str;
 		}
	}//if(str.length != 0)
 	
 	nNum = str;
 	
 	return nNum;
 	
}//EliminarCerosIzquierda 

/************************************************************************
'Nombre:        IsAlphabetic
'Decripcion:    Funcion en JScript con el fin de validar que un campo 
'				sea solo letras.
'Fecha:         02/JUN/04
************************************************************************/

function IsAlphabetic(strTexto) 
{   
	var str = strTexto.value;
	for (var i=0; i < str.length; i++) 
	{
  		var ch=str.substring(i, i + 1);
  		if (ch >= "0" && ch <= "9")
  		{
  			//el caracter es un número  			
			return false;
  		}
	} //for

	return true;
  
} //IsAlphabetic

/************************************************************************
'Nombre:        IsNumeric
'Decripcion:    Funcion en JScript con el fin de validar que un campo 
'				sea solo numeros.
'Fecha:         02/JUN/04
************************************************************************/

function IsNumeric(nNum) 
{   
	nNum.value = trim(nNum.value);
	var nNumero = nNum.value;
	for (var i=0; i < nNumero.length; i++) 
	{
  		var ch=nNumero.substring(i, i + 1);
  		if (ch < "0" || "9" < ch)
  		{
  			//el caracter es un NO número  			
			return false;
  		}
	} //for

	return true;
  
} //IsAlphabetic

/************************************************************************
'Nombre:        TieneCaracteresEspeciales
'Decripcion:    Funcion que valida si un string contiene caracteres 
'				especiales o numericos.
'Fecha:         02/JUN/04
************************************************************************/

function TieneCaracteresEspeciales(strTexto) 
{   
	var str = trim(strTexto.value);
	for (var i=0; i < str.length; i++) 
	{
  		var ch=str.substring(i, i + 1);
  		if ((ch < "A" || ch > "Z") && (ch < "a" || ch > "z") && ch != " ")
  		{
  			//el caracter es un número
  			//alert('El campo digitado debe ser alfabético.');
			strTexto.value = "";
			strTexto.focus();
			return false;
  		}
	} //for

	return true;
  
} //TieneCaracteresEspeciales

