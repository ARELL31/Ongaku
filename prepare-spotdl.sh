#!/bin/bash
# prepare-spotdl.sh

echo "Preparing SpotDL custom environment..."

# Verificar que el directorio del entorno virtual existe
SPOTDL_SOURCE="/home/arell/Documentos/sptdl"
if [ ! -d "$SPOTDL_SOURCE" ]; then
    echo "Error: SpotDL environment not found at $SPOTDL_SOURCE"
    exit 1
fi

# Crear directorio limpio
rm -rf spotdl-custom
mkdir -p spotdl-custom

echo "Copying SpotDL environment from $SPOTDL_SOURCE..."
# Copiar entorno virtual
cp -r "$SPOTDL_SOURCE"/* spotdl-custom/

echo "Cleaning unnecessary files..."
# Limpiar archivos innecesarios
find spotdl-custom -name "*.pyc" -delete
find spotdl-custom -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
find spotdl-custom -name "*.pyo" -delete

# Hacer ejecutables solo archivos regulares (no enlaces simbólicos)
find spotdl-custom/bin -type f -exec chmod +x {} \; 2>/dev/null || true

# Verificar que SpotDL está presente
if [ -f "spotdl-custom/bin/spotdl" ]; then
    echo "✓ SpotDL found in environment"
else
    echo "⚠ Warning: spotdl binary not found in bin/"
fi

echo "SpotDL custom environment prepared in spotdl-custom/"
echo "Size: $(du -sh spotdl-custom | cut -f1)"
