#!/bin/bash
echo "Actualizando schema de desarrollo..."
cp data/xyz.arell.ongaku.gschema.xml ~/.local/share/glib-2.0/schemas/
glib-compile-schemas ~/.local/share/glib-2.0/schemas/
echo "Schema actualizado. Keys disponibles:"
gsettings list-keys xyz.arell.ongaku
