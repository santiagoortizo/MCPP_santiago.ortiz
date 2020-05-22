# Análisis envolvente de datos a las Empresas Sociales del Estado (E.S.E). Estudio preliminar
## Santiago Ortiz Ortiz

Este proyecto explica de manera superficial el uso del modelo de programación lineal DEA para encontrar ratios de eficiencia relativa en las IPS de los distintos departamentos de Colombia. Así mismo, en el repositorio podrá encontrar información valiosa para obtener bases de datos que no se encuentran en un formato adecuado para su uso (ej. tablas HTML). Para descargar la información se utilizó Web Scraping.

## Modelo DEA
El Análisis Envolvente de Datos (Data Envelopment Analysis - DEA) ha sido ampliamente utilizado en investigaciones sobre el sector salud, analizando principalmente como los cambios en distintas regulaciones han afectado la eficiencia de estos sistemas y como esto ha impactado el gasto público en salud. Bajo la lógica de medición de eficiencia existen distintos métodos clasificados en dos grupos: paramétricos y no paramétricos. Los primeros son aquellos que tienen una forma funcional de producción definida a priori; mientras que los segundos no asumen la existencia de dicha forma funcional. El DEA es un método de programación lineal (simplex) que mide la eficiencia económica relativa de una firma a una frontera de eficiencia construida con las firmas más eficientes. Esta metodología permite identificar oportunidades de ahorro de recursos o mejora en la productividad de cada una de las firmas que se encuentran por debajo de la frontera productiva eficiente.
No obstante, estos modelos deben usarse con precaución, en la medida que determinar la eficiencia de los sistemas de salud es un proceso complejo, debido a la existencia de problemas metodológicos. En principio, el estado de la salud de la ciudad puede influye en los niveles de productividad, así como el nivel de bienestar y situación socio-económica que presenten sus ciudadanos.

## Técnicas empleadas
- La base de datos empleada proviene del Sistema de Gestión Hospitalaria. Apesar de que esta base esta abierta al público, su manipulación no es tan sencilla. Para poder acceder a los datos hay que hacer un proceso de Copy & Paste constante. Si uno quisiera extraer los datos desde el 2002 hasta el 2018 para todos los departamentos del país incluyendo Bogotá, tendría que disponer de aproximadamente 34 horas  de fluido Ctrl + C y Ctrl + V (y de muchos clickeos). Es por esto, que se desarrollo un código de Web Scraping el cual recorriera la página web en donde se encuentran los datos y los extrayera. Simulando así un acto de Copy & Paste. (Nota: hacer el código no llevo más de 34 horas. Sin embargo, si así hubiese sido, habrián sido 34 horas de reto constante y de aprendizaje)
- Para este propósito, se utilizaron librerias como "requests", "BeautifulSoup", "Pandas", "Selenium", entre otras (Python).
- Así mismo, una libreria bastante útil fue "rDEA" de RStudio, con la cual pude estimar el modelo y los parámetros de eficiencia. 

## Resultados
- Las IPS (E.S.E) Nivel II de los distintos departamentos de Colombia aumentaron la eﬁciencia relativa con la que proveían servicios como cirugías y atención en partos, tanto vaginales como cesáreas. 
- Algunos departamentos que son considerados pobres pueden tener altas tasas de eﬁciencia debido a que con muy pocos recursos y capacidades atienden un gran número de pacientes. 
- Los modelos DEA son útiles para estimar el número de servicios promedio que debe aumentar una ﬁrma para ser más eﬁciente.

![Ratio eficiencia de un modelo Output orientado con retornos variables a escala. Nivel II-2017](https://github.com/santiagoortizo/MCPP_santiago.ortiz/blob/master/Proyecto%20Final/Resultados/Im%C3%A1genes/Nivel%20II%20-%202017.png)
