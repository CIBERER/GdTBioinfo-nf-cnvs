---
name: Nuevo modulo
about: Generar template para nuevo modulo
title: "[MODULO]"
labels: modulo
assignees: ''

---

## Descripción del programa

Especificar qué programa se quiere implementar en el módulo, la versión y el comando en caso que sea específico (p.e. en programas como gatk que tienen varias opciones). 

## Parámetros

Especificar los parámetros que son necesarios para la ejecución del software. Los opcionales se pasarán a través de nextflow. 

## Inputs y outputs

Especificar que inputs necesita el módulo y qué outputs se tienen que capturar.

## Checklist
[ ] El módulo funciona en local
[ ] Los tests se pueden ejecutar con datos accesibles públicamente (en caso contrario, crear un issue para generar tests para el módulo)
[ ] El módulo usa un contenedor de Bioconda y biocontainer (en caso contrario, crear un issue para crear el contenedor).
