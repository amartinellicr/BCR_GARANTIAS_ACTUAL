using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration.Install;

namespace CargaArchivos
{
    [RunInstaller(true)]
    public partial class ServicesInstaller : Installer
    {
        public ServicesInstaller()
        {
            InitializeComponent();
        }
    }
}