using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration.Install;

namespace BCR.GARANTIAS.AplicaCalcAvaluo
{
    [RunInstaller(true)]
    public partial class InstalacionServicio : Installer
    {
        public InstalacionServicio()
        {
            InitializeComponent();
        }
    }
}