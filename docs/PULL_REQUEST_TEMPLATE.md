<!--
# structural_variants_ciberer pull request

¡Gracias por contribuir a la pipeline de variantes estructurales del CIBERER. 
Marcad las opciones completadas en las opciones de abajo, dependiendo de si se añade un módulo, un worflow. Si se corrige un bug, solo marcar
las opciones generales. 

Recordad que los PRs se deben hacer contra la rama devel.

Las instrucciones generales para las contribuciones están en [README.md](https://github.com/yocra3/structural_variants_ciberer/README.md)
-->

## Checklist general

Closes #XXX <!-- Añadir el issue relacionado con el PR -->

- [ ] Hay una descripción de los cambios hechos o del código añadido.
- [ ] El código está testeado.

## Checklist modulo
- [ ] Se han seguido las convenciones de [crear un módulo](https://github.com/yocra3/structural_variants_ciberer/blob/master/docs/new_modules.md)
- [ ] Se han borrado todos los TODO statements.
- [ ] Se emite un archivo `<SOFTWARE>.version.txt`.
- [ ] Se sigue la convención del nombre del módulo.
- [ ] Se siguen los requisitos para los parámetros.
- [ ] Se siguen las guías para nombre inputs y outputs.
- [ ] Hay un `label` que marca los recursos.

- [ ] Se incluyen tests ejecutables con datos de github.
- [ ] Si no se cumple la anterior, se ha abierto un issue (#XX <!-- Añadir el issue de los tests -->) para solucionar este problema en el futuro.

- [ ] Se usan contenedores de BioConda y BioContainers.
- [ ] Si no se cumple la anterior, se ha añadido un contenedor de docker y se ha abierto un issue (#XX <!-- Añadir el issue del contenedor -->) para solucionar este problema en el futuro.

## Checklist Subworkflow
- [ ] Se han seguido las convenciones de [crear un subworkflow](https://github.com/yocra3/structural_variants_ciberer/blob/master/docs/new_subworkflows.md)
- [ ] Se sigue la convención del nombre del subworkflow.
- [ ] Se siguen las guías para nombre inputs y outputs.

- [ ] Se incluyen tests ejecutables con datos de github.
- [ ] Si no se cumple la anterior, se ha abierto un issue (#XX <!-- Añadir el issue de los tests -->) para solucionar este problema en el futuro.
