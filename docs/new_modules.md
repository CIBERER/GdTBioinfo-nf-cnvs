# Implementar un nuevo módulo

Para implementar un nuevo módulo, seguiremos el formato definido en nf-core. Para completar estos issues, lo primero será entrar en la web de [nf-core/modules](https://github.com/nf-core/modules) y comprobar si nuestro módulo está ya implementado.

## Módulo implementado en nf-core

Si entramos en el repositorio de nf-core y vemos que el módulo ya esta implementado, podemos añadirlo directamente usando [nf-core tools](https://github.com/nf-core/modules#using-existing-modules). Una vez importado al repositorio, haremos un PR y ya podemos cerrar el issue.

IMPORTANTE: Para incorporar el módulo de esta manera, hay que asegurarse que el módulo que importamos tiene la funcionalidad que necesitamos. Hay algunos programas, como por ejemplo gatk, que tienen diferente módulos para las diferentes funciones. 

## Módulo no implementado en nf-core

En este caso, tendremos que implementar el módulo nosotros. En nf-core tools, han desarrollado una [plantilla](https://github.com/nf-core/modules#nf-core-modules-create) que nos ayudará en el proceso. Cada módulo implementa o un programa completo o una funcionalidad de un programa. El primer paso será clonar el repositorio [modules de nf-core](https://github.com/nf-core/modules). Una vez dentro del repositorio modules, ejecturemos la herramienta.

IMPORTANTE: Hay que ejecutar la herramienta dentro del repositorio modules de nf-core. Si lo hacemos dentro de nuestro repositorio, no se generarán todos los archivos necesarios. Una vez la herramienta nos genere los archivos, copiaremos todos los archivos creados a nuestro repositorio. 

Si el programa que queremos implementar tiene una única función principal (p.e. fastqc) usaremos la siguiente sintaxis:

```
nf-core modules create . --tool cot
```

Si el programa que queremos implementar tiene varias funcionalidades (p.e. gatk), usaremos la siguiente sintaxis:

```
nf-core modules create . --tool cot/filter
```

En ambos casos, se ejecutará una herramienta que nos llevará paso a paso en la generación del módulo. Importante: el nombre del módulo será siempre en minúscula y sin signos de puntuación. En caso contrario, recibiremos un mensaje de advertencia y una nueva propuesta de nombre. 

El primer paso que hará la herramienta es comprobar si el programa que queremos implementar está en bioconda y/o Biocontainers. En caso afirmativo, añadirá la referencia correspondiente a los archivos. En caso contrario, nos pedirá que añadamos una referencia de Bioconda:

```
WARNING  Could not find Conda dependency using the Anaconda API: 'cot'                                                                                                                        create.py:144
Do you want to enter a different Bioconda package name? [y/n]:
```

Si el programa no está implementado aún en Bioconda, le daremos que no y solucionaremos este problema más adelante. 

El siguiente paso será que introduzcamos el nombre del autor del módulo. Aquí debemos poner nuestro usuario de github:

```
GitHub Username: (@author): @yocra3
```

A continuación, tenemos que introducir un tag para el proceso. El tag nos indicará las necesidades de recursos que tendrá el programa. Por defecto, tenemos 3 categorías que marcan los recursos de memoria y CPUs (process_low, process_medium y process_high) y una para procesos largos (process_long):

```
INFO     Provide an appropriate resource label for the process, taken from the nf-core pipeline template.                                                                                     create.py:187
         For example: process_low, process_medium, process_high, process_long                                                                                                                              
? Process resource label: process_low
```

Estas categorías nos sirven para agrupar los procesos según las necesidades que tengan. Cada usuario puede especificar al ejecutar la pipeline en qué consisten exactamente cada etiqueta (p.e. cuantos GB de RAM o CPUs usa un process_medium). 

El siguiente paso nos preguntará como queremos gestionar los inputs. La herramienta nos da la opción de generar una estructura de groovy para gestionar el input.  

```
INFO     Where applicable all sample-specific information e.g. 'id', 'single_end', 'read_group' MUST be provided as an input via a Groovy Map called 'meta'. This information may not be      create.py:201
         required in some instances, for example indexing reference genome files.                                                                                                                          
Will the module require a meta map of sample information? (yes/no) [y/n] (y): y
```

Esta estructura nos facilitará gestionar el id de la muestra y su archivo o archivos correspondientes. Por lo tanto, siempre marcaremos que sí, excepto si es un paso que nunca tendrá una muestra asociada (p.e. indexar un genoma).

A continuación nos saldrán los archivos que se han generado:

```
INFO     Created / edited following files:                                                                                                                                                    create.py:239
           ./software/cot/functions.nf                                                                                                                                                                     
           ./software/cot/main.nf                                                                                                                                                                          
           ./software/cot/meta.yml                                                                                                                                                                         
           ./tests/software/cot/main.nf                                                                                                                                                                    
           ./tests/software/cot/test.yml                                                                                                                                                                   
           ./tests/config/pytest_software.yml     
```          

IMPORTANTE: Si no se han generado 6 archivos y solo se ha generado 1, la herramienta no se ha ejecutado en el repositorio de nf-core modules. Hay que repetir todo el proceso desde el principio. 

A continuación, copiaremos todos los archivos manteniendo la estructura de carpeta, excepto `./tests/config/pytest_software.yml` al repositorio del CIBERER. Los archivos en la carpeta software, contienen el código y la documentación de nuestro módulo. Los archivos de la carpeta tests, tienen los tests para comprobar que los módulos funcionan.

De los 5 archivos que copiaremos, hay que editarlos todos menos `./software/cot/functions.nf`. Tenemos una descripción más detallada de cada archivos y como editarlo en [nf-core](https://github.com/nf-core/modules#nf-core-modules-create), paso 6. Los archivos tienen unas líneas marcados con `//TO DO` que indican los trozos que tenemos que editar. 

### Archivo softare/tool/main.nf

El archivo main.nf contiene la implementación del software que queremos ejecutar. A continuación describiremos los puntos que hay que editar.

#### Container

Si el programa que queremos implementar ya está en bioconda y Biocontainer, este trozo ya estará relleno y no tendremos que hacer nada. En caso contrario, tenemos que encapsular nosotros el software.

La recomendación es crear una imagen de docker que contenga el software necesario para ejecutar el código. En el repositorio con la [introducción a nextflow](https://github.com/yocra3/nextflow_introduction/) y en [este enlace](https://github.com/seqeralabs/nextflow-tutorial#Docker-hands-on), encontraréis ayuda sobre como generar esta imagen y subirla a dockerhub. Una vez hecho esto, hay que cambiar todo el trozo del container por:

```
container user/cot:1.0.0
```

Donde user es nuestro nombre de usuario de DockerHub y 1.0.0 es el tag de la imagen. A continuación, crearemos un issue nuevo en este repositorio (Issues -> New Issue) indicando que hace falta implementar el software en Bioconda y Biocontainers, para permitir resolver el problema en el futuro. 

#### Input

Contiene los datos de entrada del módulo. Todos los archivos que hagan referencia a la misma muestra (p.e. BAM, VCF, fastq...) deberán ir en la primera línea, como en el ejemplo de la plantilla. Otros archivos que sean necesarios para el proceso (p.e. fastas de referencia) los añadiremos en líneas sucesivas.

#### Output

Como mínimo, incluiremos los dos outputs que vienen en la referencia. Un primer output con una tupla con el archivo (o archivos) de salida y el id y otra con el texto de la versión del software. Si nuestro proceso genera más de un tipo de archivo, generaremos varios outputs. Podemos usar expresiones regulares para seleccionar los archivos con una extensión determinada. Este proceso omite los archivos de input.

En el apartado outputs NUNCA incluiremos archivos que estaban en el input. Por ejemplo, si implementaremos un módulo para indexar un bam, el input sería id, bam y el output id, bai. Para sincronizar los bam y el bai, lo haremos a nivel de canales en el workflow. 

#### Script

En este trozo meteremos el código que queremos ejecutar. Basándonos en el ejemplo, podemos ver como pasar otros argumentos o como aprovechar para nombrar los archivos. 

### Archivo softare/tool/meta.yml

Este archivo contiene la documentación del módulo. Es muy importante rellenarlo correctamente para que otros usuarios pueden utilizar el módulo en la pipeline. 

### Archivo tests/software/tool/main.nf 

En este archivo, añadiremos los tests para testear nuestro módulo. Cada test se implementa en un workflow de nextflow con un nombre diferente. Por defecto hay un solo workflow implementado pero podemos implementar cuántos sean necesarios. Se recomienda utilizar los archivos de prueba que vienen distribuidos por [nf-core](https://github.com/nf-core/test-datasets/tree/modules). En el README, podemos ver los archivos que hay disponibles y una pequeña descripción. Hay que tener en cuenta que estos archivos han sido incluídos como muestras mínimas para comprobar que el código se ejecuta sin fallos y no para obtener resultados significativos. 

Para acceder a los datos, se puede usar el diccionar `params.test_data` que está definido en el archivo `tests/config/test_data.config`. En caso que se necesitaran unos archivos preprocesados, se puede incluir algún paso previo adicional en el workflow. Por ejemplo, si estamos implementando un módulo para indexar un bam, pero solo tuviéramos fastqs, podríamos primero generar el bam y luego testear si se genera el índice.

### Archivo tests/software/tool/test.yml

Este archivo guarda los md5sums de los archivos generados en los tests para asegurar la consistencia de las ejecuciones. La mejor manera de generarlo, es usando el comando que viene en nf-core tools:

```
nf-core modules create-test-yml
```

Con esta herramiento, podremos elegir el módulo que queremos testear. Como la herramienta principal ya genera este archivo, es mejor que le pidamos que nos los sobreescriba. 

La función nos ejecutará el test (con el contenedor que elijamos) y registrará el md5sum de todos los archivos que se encuentren en la carpeta. En la herramienta, nos indicará la carpeta temporal donde guarda nextflow los archivos de la ejecución:

```
INFO     Running 'cot' test with command:                                                                                                                                           test_yml_builder.py:281
         nextflow run tests/software/cot -entry test_cot -c tests/config/nextflow.config --outdir /tmp/tmpulk78b6n                                                                                         
INFO     Repeating test ...                                                                                                                                                         test_yml_builder.py:284
INFO     Test workflow finished!                                                                                                                                                    test_yml_builder.py:297
INFO     Writing to 'tests/software/cot/test.yml'    
```
Podemos explorar los archivos de esta carpeta para asegurarnos que el programa se ha ejecutado como esperamos. Una vez hemos ejecutado esta herramienta, debemos ir al archivo tests/software/tool/test.yml (que ahora tendrá otros valores) y eliminar aquellas líneas que pudieran ser innecesarias, por describir algunos archivos que no necesitamos. 


## Finalizar módulo

Una vez cumplidos todos estos pasos, ya podremos hacer un PR con los nuevos archivos, como está explicado en el [README](https://github.com/yocra3/structural_variants_ciberer/blob/master/README.md) principal. Si el PR se acepta, ya podremos cerrar el issue correspondiente.