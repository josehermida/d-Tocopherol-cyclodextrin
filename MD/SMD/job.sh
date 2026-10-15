#!/bin/bash
# USO: ./script.sh <valor_i>

# Validar argumento
if [ $# -ne 1 ]; then
    echo "Error: Debes pasar el valor de i como argumento. Ej: ./script.sh 5"
    exit 1
fi

i="$1"
conf=$((i*100+14000))
Amber_SCRDIR="/scratch-hermida"
Amber_SCRDIR="${Amber_SCRDIR}/MICELL/Complex/MetaMD/DrivenMD/New"

mkdir "$i" || { echo "Error al crear $i"; exit 1; }
mv "${conf}.rst"  "$i/" 2>/dev/null || echo "Advertencia: Algunos archivos no se encontraron."
cp  colvar.in mdin "Toco+Ciclo_Oct_23A.prmtop" "$i/" 2>/dev/null || echo "Advertencia: Algunos archivos no se encontraron."

cd "$i" || { echo "Error al entrar en $i"; exit 1; }
HomeDir=$PWD

cat <<EOF> Vai_Amber
#!/bin/bash
# JOB NAME
#SBATCH --job-name=DrivenMD_$conf
#
# NODE SPECIFIED
#SBATCH --nodelist=nodo04
#
#SBATCH --no-requeue
#SBATCH -e error_%j.err
#SBATCH -o output_%j.out
#SBATCH -p gpu
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 1
#SBATCH --mem=8G
#SBATCH -t 9999:00:00
#SBATCH -G 1
export HomeDir=$PWD
#activate_spack
source /usr/local/spack/share/spack/setup-env.sh
spack load amber@20


#   *  scratch directory
export Amber_SCRDIR="${Amber_SCRDIR}"

# Creation of scratch directory:
#mkdir -p "${Amber_SCRDIR}"


cd $HomeDir

pmemd.cuda -O -i mdin -o md.out -p Toco+Ciclo_Oct_23A.prmtop  -c $conf.rst -r ${Amber_SCRDIR}/md_driven_$conf.rst -ref $conf.rst -x ${Amber_SCRDIR}/md_driven_$conf.nc -l log  -AllowSmallBox

mv ${Amber_SCRDIR}/md_driven_$conf.rst  $HomeDir
EOF


sbatch Vai_Amber
cd  ..
