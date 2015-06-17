using System;
using System.Collections;
using System.Text;
using System.Configuration;
using System.Xml;
using System.Globalization;

namespace BCRGARANTIAS.Utilidades
{
    public class CalendarioServicio : IConfigurationSectionHandler
    {

        #region [ Variables ]

        Hashtable config;
        string seccion;
        #endregion

        #region IConfigurationSectionHandler Members

        object IConfigurationSectionHandler.Create(
          object parent, object configContext, XmlNode section)
        {
            // Creates the configuration object that this method will return.
            // This can be a custom configuration class.
            // In this example, we use a System.Collections.Hashtable.
            Hashtable myConfigObject = new Hashtable();

            // Gets any attributes for this section element.
            Hashtable mainAttribs = new Hashtable();

            foreach (XmlAttribute attrib in section.Attributes)
            {
                if (XmlNodeType.Attribute == attrib.NodeType)
                    mainAttribs.Add(attrib.Name, attrib.Value);
            }

            // Puts the section name and attributes as the first config object item.
            myConfigObject.Add(section.Name, mainAttribs);

            // Gets the child element names and attributes.
            foreach (XmlNode child in section.ChildNodes)
            {
                if (XmlNodeType.Element == child.NodeType)
                {
                    Hashtable myChildAttribs = new Hashtable();

                    foreach (XmlAttribute childAttrib in child.Attributes)
                    {
                        if (XmlNodeType.Attribute == childAttrib.NodeType)
                            myChildAttribs.Add(childAttrib.Name, childAttrib.Value);
                    }
                    myConfigObject.Add(child.Name, myChildAttribs);
                }

                foreach (XmlNode child2 in child.ChildNodes)
                {
                    if (XmlNodeType.Element == child2.NodeType)
                    {
                        Hashtable myChildAttribs = new Hashtable();

                        foreach (XmlAttribute childAttrib in child2.Attributes)
                        {
                            if (XmlNodeType.Attribute == childAttrib.NodeType)
                                myChildAttribs.Add(childAttrib.Name, childAttrib.Value);
                        }
                        myConfigObject.Add(child2.Name, myChildAttribs);
                    }
                }


            }
            return (myConfigObject);
        }
        #endregion

        #region [ Constructores ]

        public CalendarioServicio()
        {

        }

        public CalendarioServicio(string tseccion)
        {
            seccion = tseccion;
        }
        #endregion

        #region [ Propiedades ]

        public string Seccion
        {
            get
            {
                return seccion;
            }
        }

        public string PeriodicidadEjecucion
        {
            get
            {
                string periodicidadEjecucion;

                periodicidadEjecucion = "";

                periodicidadEjecucion = obtenerAtributo("EsquemaEjecucion", "PeriodicidadEjecucion");
                return periodicidadEjecucion;
            }
        }

        public string HoraEjecucion
        {
            get
            {
                string horaEjecucion;

                horaEjecucion = "";
                switch (PeriodicidadEjecucion)
                {
                    case "Diaria":
                        horaEjecucion = obtenerAtributo("Diaria", "HoraEjecucion");
                        break;
                    case "Semanal":

                        horaEjecucion = obtenerAtributo(diadelaSemana, "HoraEjecucion");
                        break;
                    case "Mensual":

                        horaEjecucion = obtenerAtributo("Mensual", "HoraEjecucion");
                        break;
                }
                return horaEjecucion;
            }
        }

        public bool DebeCorrerAhora
        {

            get
            {
                string horaEjecucionstr;
                DateTime horaEjecucion;
                horaEjecucionstr = HoraEjecucion;

                if (horaEjecucionstr == "-1")
                {
                    return false;
                }

                horaEjecucion = DateTime.Parse(horaEjecucionstr);

                return DateTime.Now >= horaEjecucion;
            }
        }

        public bool DebeCorrerHoy
        {

            get
            {
                bool debeCorrerHoy;
                string ejecutarHoystr;
                string dia;

                debeCorrerHoy = false;
                switch (PeriodicidadEjecucion)
                {
                    case "Diaria":
                        debeCorrerHoy = true;
                        break;
                    case "Semanal":

                        ejecutarHoystr = obtenerAtributo(diadelaSemana, "EjecutarHoy");
                        debeCorrerHoy = bool.Parse(ejecutarHoystr);
                        break;
                    case "Mensual":
                        dia = obtenerAtributo("Mensual", "Dia");

                        if (int.Parse(dia) == DateTime.Today.Day)
                        {
                            debeCorrerHoy = true;
                        }
                        break;
                }

                return debeCorrerHoy;
            }
        }


        private string diadelaSemana
        {
            get
            {
                string diadelaSemana = "";

                switch (DateTime.Today.DayOfWeek)
                {
                    case DayOfWeek.Friday:
                        diadelaSemana = "Viernes";
                        break;
                    case DayOfWeek.Monday:
                        diadelaSemana = "Lunes";
                        break;
                    case DayOfWeek.Saturday:
                        diadelaSemana = "Sabado";
                        break;
                    case DayOfWeek.Sunday:
                        diadelaSemana = "Domingo";
                        break;
                    case DayOfWeek.Thursday:
                        diadelaSemana = "Jueves";
                        break;
                    case DayOfWeek.Tuesday:
                        diadelaSemana = "Martes";
                        break;
                    case DayOfWeek.Wednesday:
                        diadelaSemana = "Miercoles";
                        break;
                    default:
                        break;
                }

                return diadelaSemana;
            }

        }


        #endregion

        #region [ Métodos privados ]
        private string obtenerAtributo(string seccion, string atributo)
        {
            string valor;
            Hashtable attribs = (Hashtable)config[seccion];
            valor = "";
            foreach (DictionaryEntry deAttrib in attribs)
            {
                if (deAttrib.Key.ToString() == atributo)
                {
                    valor = deAttrib.Value.ToString();
                }
            }

            return valor;
        }
        #endregion

        #region [ Métodos ]
        public void Leer()
        {
            config = (Hashtable)ConfigurationManager.GetSection(seccion);
        }
        #endregion

    }
}
