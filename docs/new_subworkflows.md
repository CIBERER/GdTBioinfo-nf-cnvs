# Implementar un nuevo subworkflow

Para implementar un nuevo subworkflow, seguiremos el formato definido en el workflow de CNVNATOR. Podemos ver todos los archivos generados en el [Pull Request](https://github.com/yocra3/structural_variants_ciberer/pull/11) que cierra el [issue](https://github.com/yocra3/structural_variants_ciberer/issues/10). En este caso, no hay aún una herramiento de nf-core que nos genere los 3 archivos del subworkflow.

## Definición del subworkflow 

Seguiremos una estructura de carpeta similar a la usada para los módulos. Así, pondremos los subworkflows en la carpeta subworkflows dentro de software. Generaremos una carpeta para cada subworkflow que contendrá sólo un archivo main.nf con la definición del subworkflow (p.e. `./software/subworkflows/new_subworkflow/main.nf`). Esto nos facilitará el testeo del código, ya que podremos usar las mismas herramientas de los módulos. 

Los subworkflows deben contener un verbo que defina su función y que nos puede servir para diferenciarlos de los módulos.

El archivo main.nf debe contener tres partes: definición de los parámetros, inclusión de los módulos y definición del subworkflow. En este contexto, cuando nos refiramos a módulos también podemos hablar de otros subworkflows que incorporemos a un subworkflow mayor.

### Definición de los parámetros

Como mínimo, debemos definir una lista de parámetros para cada uno de los módulos que importemos. Estas listas se pueden generar vacias:

```
params.cnvnator_options = [:]
```

### Inclusión de los módulos

Cargaremos los módulos de los que se compondrá nuestro subworkflow usando include. En este paso, también debemos pasar los argumentos a los módulos:

```
include { CNVNATOR } from '../../cnvnator/main.nf' addParams( options: params.cnvnator_options )
```

### Definición del subworkflow

En este paso, ya definiremos el subworkflow como tal. El subworkflow empieza con la palabra `workflow` y el nombre que le querremos poner. En este caso, nombraremos siempre los subworflows en mayúscula y en snake_case.

```
workflow RUN_CNVNATOR {
```

A continuación, definiremos los inputs del subworkflow. Los inputs se definen usando la palabra clave `take:`. Es recomendable incluir una pequeña definición de cada canal de input para facilitar reusar el código en otros workflows.

```
  take:
  ch_input /// channel: [val(meta), path(bam), path(bai)]
```

El siguiente paso definirá los pasos como tal del subworkflow. Aquí incluiremos los módulos que se ejecutan y definiremos como se pasa la información de un módulo a otro. Podemos acceder a los outputs de los módulos usando `.out` y se usa la palabra clave `main:`:

```
  main:
  CNVNATOR(ch_input, fasta, genome, binSize)
  PYTHON_FORMATCNVNATOR(CNVNATOR.out.txt)
```

Finalmente, definiremos los outputs del subworkflow. Esto lo podemos hacer con la palabra clave `emit:`. En este caso, generaremos un canal por cada output que queremos que saque el subworkflow. Como mínimo, sacaremos un canal con la versión de cada módulo y el output del último módulo. También es importante incluir una pequeña definición de los canales de output para poder reaprovechar el subworkflow en otros subworkflows. 

```
  emit:
  cnvnator_orig        = CNVNATOR.out.txt                                 /// channel: [ val(meta), txt  ]
```

## Archivos de test

Generaremos dos archivos para los tests: `./test/software/subworkflows/new_subworkflow/main.nf` y `./test/software/subworkflows/new_subworkflow/test.yml`. Estos archivos son equivalentes a los archivos de los tests para módulos y se puede encontrar más información en la sección de tests de la ayuda de [añadir nuevos módulos](https://github.com/yocra3/structural_variants_ciberer/blob/master/docs/new_modules.md#archivo-testssoftwaretoolmainnf). 

## Finalizar subworkflow

Una vez cumplidos todos estos pasos, ya podremos hacer un PR con los nuevos archivos, como está explicado en el [README](https://github.com/yocra3/structural_variants_ciberer/blob/master/README.md) principal. Si el PR se acepta, se cerrará el issue correspondiente.
