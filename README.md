## Introducción

El objetivo de este repositorio es implementar una pipeline en nextflow para detectar variantes estructurales a partir de datos de alineamientos (.bam) y de genotipos (.vcf). Esta pipeline contendrá las diferentes aproximaciones que se han desarrollado por los grupos de trabajo de Bioinformática de CIBERER. Este trabajo se está desarrollando como colaboración entre el WP6 (variantes estructurales) y el WP13 (Diseño de Flujos de trabajo). 

## ¿Cómo participar?

En primer lugar, es necesario entrar en nuestros canales de [slack](https://join.slack.com/t/bioinfo2021wp2/shared_invite/zt-r3pt4pgg-dDiXcO4ZiJbFbIls73uBVg) y contactar con los coordinadores de los WPs: Carlos Ruiz ([cruizarenas@unav.es](mailto:cruizarenas@unav.es)), Pablo Mínguez ([pablo.minguez@quironsalud.es](mailto:pablo.minguez@quironsalud.es)) y Daniel López ([daniel.lopez.lopez@juntadeandalucia.es](mailto:daniel.lopez.lopez@juntadeandalucia.es)). Para colaborar, será necesario solicitar una invitación para poder  subir cambios al repositorio. 

La metodología de trabajo consiste en realizar diferentes tares que se encuentran en el apartado [issues](https://github.com/yocra3/structural_variants_ciberer/issues). Los issues están clasificados en tres categorías principales.

- Módulos: los módulos incorporan un nuevo software o comando al entorno de nextflow. Definen una tarea concreta que se ejecutará en nextflow. 
- Subworkflows: los subworkflows son un conjunto de módulos que desempeñan una tarea concreta. Cada herramienta para detectar variantes estructurales tendrá un subworkflow que contendrá 3 módulos:
1. Ejecución de la herramienta
2. Filtrado de los CNVs
3. Conversión de los CNVs a un formato común.
- Nuevo tool: Conjunto de subworkflows que llevan a cabo un análisis completo. 

Una vez hemos decidido en qué issue queremos trabajar, debemos [asignarnos al issue](https://docs.github.com/en/issues/tracking-your-work-with-issues/managing-issues/assigning-issues-and-pull-requests-to-other-github-users#assigning-an-individual-issue-or-pull-request). La asignación de los issues sirve para que el resto de colaboradores sepamos en qué issues se están trabajando y evitar duplicar trabajo. 

A continuación, ya podemos trabajar en resolver el issue en cuestión. En la wiki, encontraréis más información sobre como implementar [módulos](https://github.com/yocra3/structural_variants_ciberer/blob/master/docs/new_modules.md) y [subworkflows](https://github.com/yocra3/structural_variants_ciberer/blob/master/docs/new_subworkflows.md). El repositorio incluye algunos issues resueltos que también sirven de ejemplo. Así, tenemos un [issue de ejemplo](https://github.com/yocra3/structural_variants_ciberer/issues/1) sobre como hacer un módulo con su correspondiente [pull request](https://github.com/yocra3/structural_variants_ciberer/pull/6), donde podemos ver los archivos generados. Lo mismo tenemos para los subworklows: [issue](https://github.com/yocra3/structural_variants_ciberer/issues/10) y [pull request](https://github.com/yocra3/structural_variants_ciberer/pull/11). Añadir una nueva pipeline requerirá editar el archivo principal. Este procedimiento está en proceso de definición, por lo que aún no hay ni ejemplos ni guías.


Para poder mantener la estabilidad del repositorio, es muy importante que las aportaciones se hagan en un repositorio personal desde el que podemos hacer un pull request (PR) a este repositorio. Para ello, hay que seguir los siguientes pasos, explicados con detalle en el siguiente [enlace](https://www.freecodecamp.org/espanol/news/como-hacer-tu-primer-pull-request-en-github/):

1. Hacer un fork del repositorio
2. Crear una rama con un nombre que identifique al issue
3. Solucionar el issue
4. Hacer un pull request (PR) a este repositorio. 

Es importante que el PR lo hagamos a la rama devel. Así, podremos ir añadiendo poco a poco nuevas funcionalidades sin riesgo de afectar al funcionamento de la pipeline. El PR lo revisaremos los coordinadores del proyecto para asegurarnos que todo es correcto. Una vez el PR está aceptado, se cerrará el issue. Preferiblemente, cada issue debe tener su PR, para así facilitar la revisión e integración de nuevo código.

## ¿Por dónde empiezo?

Hemos preparado una pequeña introducción a Nextflow que os servirá para poder empezar a trabajar. En el [repositorio](https://github.com/yocra3/nextflow_introduction/) encontraréis una presentación powerpoint y unos cuántos ejemplos de scripts en nextflow. Estos scripts se pueden ejecutar y servirán para profundizar en el aprendizaje. En la presentación se incluyen diferentes enlaces con otros recursos para seguir aprendiendo.

Si ya tenemos conocimiento de nextflow, el siguiente paso es empezar a implementar un [módulo](https://github.com/yocra3/structural_variants_ciberer/blob/master/docs/new_modules.md). Los módulos implican principalmente la definición de un proceso y la implementación de los tests. La implementación de los tests comporta definir canales y ejecutar procesos. Por lo tanto, aprenderemos a trabajar con las dos partes principales de nextflow, en un escenario simple.

Finalmente, ya podremos pasar a definir [subworkflows](https://github.com/yocra3/structural_variants_ciberer/blob/master/docs/new_subworkflows.md). Los subworkflows implican diferentes procesos y habitualmente requirirán el manejo y transformación de canales, tareas de mayor complejidad.
