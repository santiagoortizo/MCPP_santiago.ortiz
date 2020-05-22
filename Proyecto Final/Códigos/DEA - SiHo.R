rm(list = ls())
# Paquetes ----------------------------------------------------------------
install.packages("stringr")
install.packages("tidyverse")
install.packages("ggplot2")
install.packages("lpSolve") 
install.packages("rDEA")
install.packages("GGally")
install.packages("openxlsx")
install.packages("kableExtra")
install.packages("fBasics")
library(kableExtra)
library(fBasics)
library(stats)
library(readxl)
library(MASS)
library(dplyr)
library(stringr)
library(dynlm)
library(quantmod)
library(tidyverse)
library(ggplot2)
library(data.table)
library(lpSolve)
library(rDEA)
library(GGally)
library(xlsx)
library(writexl)
library(openxlsx)
library(GGally)


# Base de datos original -----------------------------------------------------------
capacidad_instalada <- read_excel("C:/Users/tatoo/Desktop/MCPP/MCPP_santiago.ortiz/Proyecto Final/Datos/Capacidad_instalada.xlsx")
distribucion_rec_hum <- read_excel("C:/Users/tatoo/Desktop/MCPP/MCPP_santiago.ortiz/Proyecto Final/Datos/Distribucion_rec_hum.xlsx")
produccion_servicios <- read_excel("C:/Users/tatoo/Desktop/MCPP/MCPP_santiago.ortiz/Proyecto Final/Datos/Produccion_servicios.xlsx")
gastos_comprometidos <- read_excel("C:/Users/tatoo/Desktop/MCPP/MCPP_santiago.ortiz/Proyecto Final/Datos/Gastos_comprometidos.xlsx")


# Base de datos agrupada --------------------------------------------------
sis_hos <- rbind(capacidad_instalada, distribucion_rec_hum, produccion_servicios, gastos_comprometidos)

# - Corrección de algunos nombres
sis_hos$Departamento <- ifelse(sis_hos$Departamento=="Bogotá, DC", "Bogotá, D.C.", sis_hos$Departamento) 
sis_hos$Concepto <- ifelse(sis_hos$Concepto=="ADMINISTRATIVO", "APOYO", sis_hos$Concepto) 
sis_hos$Concepto <- ifelse(sis_hos$Concepto=="ASISTENCIAL", "OPERATIVO", sis_hos$Concepto) 


# Descripción de base de datos --------------------------------------------
table(sis_hos$Año) # Hay 17 años
table(sis_hos$Departamento) # Contamos con 32 departamentos y el DC
table(sis_hos$Departamento, sis_hos$Nivel) # No todos los departamentos tienen tres niveles.
table(sis_hos$Clase) # Hay cuatro tipos de clases de datos:
                        # - Capacidad Instalada
                        # - Distribución Recurso Humano
                        # - Gastos Comprometidos      
                        # - Producción de Servicios
table(sis_hos$Concepto[sis_hos$Clase=="Capacidad Instalada"]) # Siete tipos de capacidad instalada
                                                             # - Camas de hospitalización
                                                             # - Consultorios de consulta externa
                                                             # - Consultorios en el servicio de urgencias
                                                             # - Camas de observación
                                                             # - Mesas de partos (X)
                                                             # - Salas de quirófanos (X) 
                                                             # - Número de unidades de odontología
table(sis_hos$Concepto[sis_hos$Clase=="Gastos Comprometidos"]) # Hay muchos, pero estos son los más importantes:
                                                              #...GASTOS DE PERSONAL (X)
                                                              #.........Servicios personales asociados a la nómina
                                                              #...............Sueldos personal de nómina
                                                              #......Gastos de Personal de Planta
table(sis_hos$Concepto[sis_hos$Clase=="Producción de Servicios"])
# Consultas de medicina general electivas realizadas
# Consultas de medicina general urgentes realizadas
# Consultas de medicina especializada urgentes realizadas
# Consultas de medicina especializada electivas realizadas
# Partos vaginales (X)
# Partos por cesárea (X)
# Total de cirugías realizadas (Sin incluir partos y cesáreas) (X)
# Pacientes en Observación 
# Pacientes Unidad Cuidados Intensivos
# ...Días estancia de los egresos obstétricos (Partos, cesáreas y otros obstétricos)
# Total de días cama disponibles
# Total de días cama ocupados 

table(sis_hos$Concepto[sis_hos$Clase=="Distribución Recurso Humano"])
# OPERATIVO (X)
# APOYO (X)


# Base de datos reducida --------------------------------------------------


sis_hos_reduc <- subset.data.frame(sis_hos, subset = sis_hos$Concepto=="OPERATIVO"|
                               # sis_hos$Concepto=="APOYO"|       
                               sis_hos$Concepto=="Partos vaginales"|
                               sis_hos$Concepto=="Partos por cesárea"|
                               sis_hos$Concepto=="Total de cirugías realizadas (Sin incluir partos y cesáreas)"|   
                               # sis_hos$Concepto=="...GASTOS DE PERSONAL"|
                               sis_hos$Concepto=="Mesas de partos"|
                               sis_hos$Concepto=="Salas de quirófanos")

sis_hos_reduc$Cantidad <- as.numeric(sis_hos_reduc$Cantidad)
sis_hos_reduc$Nivel <- as.numeric(sis_hos_reduc$Nivel)
sis_hos_reduc$Año <- as.numeric(sis_hos_reduc$Año)

# Prueba LOOP para sub bases de datos -------------------------------------

i=2017
j=3

exp1= noquote(paste("sis_hos",i,j, sep="_")) 
exp2= paste(exp1,'<- subset.data.frame(sis_hos_reduc, subset = sis_hos_reduc$A?o== i & sis_hos_reduc$Nivel==j)')
eval(parse(text= exp2))


for (i in 2017:2018){
  for (j in 1:3){
    noquote(paste("sis_hos",i,j, sep="_")) <- subset.data.frame(sis_hos_reduc, subset = sis_hos_reduc$A?o== i &
                                                         sis_hos_reduc$Nivel==j)
    noquote(paste("sis_hos",i,j, sep="_")) <- noquote(paste("sis_hos",i,j, sep="_"))[-c(2,3)]
    noquote(paste("sis_hos",i,j, sep="_")) <- noquote(paste("sis_hos",i,j, sep="_")) %>%
      spread(key = Concepto, value = Cantidad)
    noquote(paste("sis_hos",i,j, sep="_"))$prop_sueldos <- (noquote(paste("sis_hos",i,j, sep="_"))$`.........Servicios personales asociados a la nómina`/ noquote(paste("sis_hos",i,j, sep="_"))$`...GASTOS DE PERSONAL`)*100
    names(noquotes(paste("sis_hos",i,j, sep="_")))[c(5,10)] <- c("Personal Operativo", "Proporción sueldos")
    }
}

for (i in 2017:2018){
  for (j in 1:3){
    assign(paste("sis_hos",i,j, sep="_"), (subset.data.frame(sis_hos_reduc, subset = sis_hos_reduc$Año== i &
                                                               sis_hos_reduc$Nivel==j)))
    assign(paste("sis_hos",i,j, sep="_"), (as.data.frame(noquote(paste("sis_hos",i,j, sep="_"))[-c(2,3)])))
    assign(paste("sis_hos",i,j, sep="_"), (as.data.frame(noquote(paste("sis_hos",i,j, sep="_"))) %>%
                                             spread(key = Concepto, value = Cantidad)))
    assign(paste("sis_hos",i,j, sep="_")$prop_sueldos,
           ((as.data.frame(noquote(paste("sis_hos",i,j, sep="_")))$`.........Servicios personales asociados a la nÃ³mina`/ as.data.frame(noquote(paste("sis_hos",i,j, sep="_")))$`...GASTOS DE PERSONAL`)*100))
    names(paste("sis_hos",i,j, sep="_"))[c(5,10)] <- c("Personal Operativo", "ProporciÃ³n sueldos")
  }
}


assign(paste("A","B", sep=""), (15))


# Año: 2017  --------------------------------------------------------------

# Nivel 1 -----------------------------------------------------------------
sis_hos_2017_1 <- subset.data.frame(sis_hos_reduc, subset = sis_hos_reduc$Año== 2017 &
                                      sis_hos_reduc$Nivel== 2)
# Borramos clase las categorías redundantes
sis_hos_2017_1 <- subset(sis_hos_2017_1, select=-c(Nivel,Año, Clase))
sis_hos_2017_1 <- sis_hos_2017_1 %>% distinct()
sis_hos_2017_1 <- sis_hos_2017_1[-c(78, 79), ]# Ponemos las observaciones como columnas
sis_hos_2017_1 <- sis_hos_2017_1 %>%
  spread(key = Concepto, value = Cantidad)
# Podría ser un análisis interesante.
#sis_hos_2017_1$Gasto__empleado <- (sis_hos_2017_1$`...GASTOS DE PERSONAL`/(sis_hos_2017_1$APOYO + sis_hos_2017_1$OPERATIVO))
names(sis_hos_2017_1)[3] <- "Personal Operativo"
est_desc_2017_1 <- basicStats(sis_hos_2017_1[seq(2,7,1)])[c("Median", "Mean", "Stdev", "Minimum", "Maximum"),]
kable(est_desc_2017_1, "latex", booktabs = T )%>%
   kable_styling(latex_options = "striped", font_size = 10)
# ggpairs(sis_hos_2017_1[seq(2,7,1)])
# names(sis_hos_2017_1)
inp_var <- sis_hos_2017_1[c("Salas de quirófanos",
                            "Mesas de partos",
                            "Personal Operativo")]
out_var <- sis_hos_2017_1[c("Partos vaginales",
                            "Partos por cesárea",
                            "Total de cirugías realizadas (Sin incluir partos y cesáreas)")]
modelo <- dea(XREF = inp_var, YREF = out_var, 
               X=inp_var[,], Y=out_var[,],
               model = "output", RTS = "variable")
resultados <- cbind(round(modelo$thetaOpt,4), round(modelo$lambda,4))
rownames(resultados) <- sis_hos_2017_1[[1]]
colnames(resultados) <- c("Eficiencia", rownames(resultados))
resultados <- as.data.frame(resultados)
setwd("C:/Users/tatoo/OneDrive - Universidad del rosario/Trabajo PR/DEA/Resultados/MCPP")
write_xlsx(resultados, path = "resultados6.xlsx")


# Gráficos ----------------------------------------------------------------
library(ggplot2)
theme_set(theme_bw())

sis_hos_2017_1$prop_partos <- (sis_hos_2017_1$`Partos por cesárea`/(sis_hos_2017_1$`Partos vaginales` + sis_hos_2017_1$`Partos por cesárea`))*100


# Draw plot
ggplot(sis_hos_2017_1, aes(x=Departamento, y=prop_partos)) + 
  geom_bar(stat="identity", width=.5, fill="tomato3") + 
  theme(axis.text.x = element_text(angle=65, vjust=0.6))



# Nivel 2 -----------------------------------------------------------------

sis_hos_2017_2 <- subset.data.frame(sis_hos_reduc, subset = sis_hos_reduc$Año== 2017 &
                                      sis_hos_reduc$Nivel==2)
sis_hos_2017_2 <- sis_hos_2017_2[-c(2,3)]

sis_hos_2017_2 <- sis_hos_2017_2 %>%
  spread(key = Concepto, value = Cantidad)

sis_hos_2017_2$prop_sueldos <- (sis_hos_2017_2$`.........Servicios personales asociados a la nómina`/sis_hos_2017_2$`...GASTOS DE PERSONAL`)*100

names(sis_hos_2017_2)[c(5,10)] <- c("Personal Operativo", "Proporción sueldos")

est_desc_2018_2 <- basicStats(sis_hos_2017_2[seq(4,10,1)])[c("Mean", "Stdev", "Median", "Minimum", "Maximum"),]
kable(est_desc_2018_2, "latex", booktabs = T )%>%
  kable_styling(latex_options = "striped", font_size = 10)

ggpairs(sis_hos_2017_2[seq(4,10,1)])

names(sis_hos_2017_2)

inp_var <- sis_hos_2017_2[c("Proporción sueldos", "Mesas de partos", 
                            "Salas de quirófanos","Personal Operativo")]

out_var <- sis_hos_2017_2[c("Partos por cesárea", "Partos vaginales",
                            "Total de cirugías realizadas (Sin incluir partos y cesáreas)")]

modelo1 <- dea(XREF = inp_var, YREF = out_var, 
               X=inp_var[,], Y=out_var[,],
               model = "input", RTS = "constant")

resultados2 <- cbind(round(modelo1$thetaOpt,4), round(modelo1$lambda,4))
rownames(resultados2) <- sis_hos_2017_2[[1]]
colnames(resultados2) <- c("Eficiencia", rownames(resultados2))

resultados2 <- as.data.frame(resultados2)


# Nivel 3 -----------------------------------------------------------------

sis_hos_2017_3 <- subset.data.frame(sis_hos_reduc, subset = sis_hos_reduc$Año== 2017 &
                                      sis_hos_reduc$Nivel==3)
sis_hos_2017_3 <- sis_hos_2017_3[-c(2,3)]

sis_hos_2017_3 <- sis_hos_2017_3 %>%
  spread(key = Concepto, value = Cantidad)

sis_hos_2017_3$prop_sueldos <- (sis_hos_2017_3$`.........Servicios personales asociados a la nómina`/sis_hos_2017_3$`...GASTOS DE PERSONAL`)*100

names(sis_hos_2017_3)[c(5,10)] <- c("Personal Operativo", "Proporción sueldos")

est_desc_2018_3 <- basicStats(sis_hos_2017_3[seq(4,10,1)])[c("Mean", "Stdev", "Median", "Minimum", "Maximum"),]
kable(est_desc_2018_3, "latex", booktabs = T )%>%
  kable_styling(latex_options = "striped", font_size = 10)

ggpairs(sis_hos_2017_3[seq(4,10,1)])

names(sis_hos_2017_3)

inp_var <- sis_hos_2017_3[c("Proporción sueldos", "Mesas de partos", 
                            "Salas de quirófanos","Personal Operativo")]

out_var <- sis_hos_2017_3[c("Partos por cesárea", "Partos vaginales",
                            "Total de cirugías realizadas (Sin incluir partos y cesáreas)")]

modelo1 <- dea(XREF = inp_var, YREF = out_var, 
               X=inp_var[,], Y=out_var[,],
               model = "input", RTS = "constant")

resultados3 <- cbind(round(modelo1$thetaOpt,4), round(modelo1$lambda,4))
rownames(resultados3) <- sis_hos_2017_3[[1]]
colnames(resultados3) <- c("Eficiencia", rownames(resultados3))

resultados3 <- as.data.frame(resultados3)

# Año: 2018  --------------------------------------------------------------

# Nivel 1 -----------------------------------------------------------------
sis_hos_2018_1 <- subset.data.frame(sis_hos_reduc, subset = sis_hos_reduc$Año== 2018 &
                                      sis_hos_reduc$Nivel==1)
sis_hos_2018_1 <- sis_hos_2018_1[-c(2,3)]

sis_hos_2018_1 <- sis_hos_2018_1 %>%
  spread(key = Concepto, value = Cantidad)

sis_hos_2018_1$prop_sueldos <- (sis_hos_2018_1$`.........Servicios personales asociados a la nómina`/sis_hos_2018_1$`...GASTOS DE PERSONAL`)*100

names(sis_hos_2018_1)[c(5,10)] <- c("Personal Operativo", "Proporción sueldos")

est_desc_2018_1 <- basicStats(sis_hos_2018_1[seq(4,10,1)])[c("Mean", "Stdev", "Median", "Minimum", "Maximum"),]
kable(est_desc_2018_1, "latex", booktabs = T )%>%
  kable_styling(latex_options = "striped", font_size = 10)

ggpairs(sis_hos_2018_1[seq(4,10,1)])

names(sis_hos_2018_1)

inp_var <- sis_hos_2018_1[c("Proporción sueldos", "Mesas de partos", 
                            "Salas de quirófanos","Personal Operativo")]

out_var <- sis_hos_2018_1[c("Partos por cesárea", "Partos vaginales",
                            "Total de cirugías realizadas (Sin incluir partos y cesáreas)")]

modelo1 <- dea(XREF = inp_var, YREF = out_var, 
               X=inp_var[,], Y=out_var[,],
               model = "input", RTS = "constant")

resultados4 <- cbind(round(modelo1$thetaOpt,4), round(modelo1$lambda,4))
rownames(resultados4) <- sis_hos_2018_1[[1]]
colnames(resultados4) <- c("Eficiencia", rownames(resultados4))

resultados4 <- as.data.frame(resultados4)


# Nivel 2 -----------------------------------------------------------------

sis_hos_2018_2 <- subset.data.frame(sis_hos_reduc, subset = sis_hos_reduc$Año== 2018 &
                                      sis_hos_reduc$Nivel==2)
sis_hos_2018_2 <- sis_hos_2018_2[-c(2,3)]

sis_hos_2018_2 <- sis_hos_2018_2 %>%
  spread(key = Concepto, value = Cantidad)

sis_hos_2018_2$prop_sueldos <- (sis_hos_2018_2$`.........Servicios personales asociados a la nómina`/sis_hos_2018_2$`...GASTOS DE PERSONAL`)*100

names(sis_hos_2018_2)[c(5,10)] <- c("Personal Operativo", "Proporción sueldos")

est_desc_2018_2 <- basicStats(sis_hos_2018_2[seq(4,10,1)])[c("Mean", "Stdev", "Median", "Minimum", "Maximum"),]
kable(est_desc_2018_2, "latex", booktabs = T )%>%
  kable_styling(latex_options = "striped", font_size = 10)

ggpairs(sis_hos_2018_2[seq(4,10,1)])

names(sis_hos_2018_2)

inp_var <- sis_hos_2018_2[c("Proporción sueldos", "Mesas de partos", 
                            "Salas de quirófanos","Personal Operativo")]

out_var <- sis_hos_2018_2[c("Partos por cesárea", "Partos vaginales",
                            "Total de cirugías realizadas (Sin incluir partos y cesáreas)")]

modelo1 <- dea(XREF = inp_var, YREF = out_var, 
               X=inp_var[,], Y=out_var[,],
               model = "input", RTS = "constant")

resultados5 <- cbind(round(modelo1$thetaOpt,4), round(modelo1$lambda,4))
rownames(resultados5) <- sis_hos_2018_2[[1]]
colnames(resultados5) <- c("Eficiencia", rownames(resultados5))

resultados5 <- as.data.frame(resultados5)


# Nivel 3 -----------------------------------------------------------------

sis_hos_2018_3 <- subset.data.frame(sis_hos_reduc, subset = sis_hos_reduc$Año== 2018 &
                                      sis_hos_reduc$Nivel==3)
sis_hos_2018_3 <- sis_hos_2018_3[-c(2,3)]

sis_hos_2018_3 <- sis_hos_2018_3 %>%
  spread(key = Concepto, value = Cantidad)

sis_hos_2018_3$prop_sueldos <- (sis_hos_2018_3$`.........Servicios personales asociados a la nómina`/sis_hos_2018_3$`...GASTOS DE PERSONAL`)*100

names(sis_hos_2018_3)[c(5,10)] <- c("Personal Operativo", "Proporción sueldos")

est_desc_2018_3 <- basicStats(sis_hos_2018_3[seq(4,10,1)])[c("Mean", "Stdev", "Median", "Minimum", "Maximum"),]
kable(est_desc_2018_3, "latex", booktabs = T )%>%
  kable_styling(latex_options = "striped", font_size = 10)

ggpairs(sis_hos_2018_3[seq(4,10,1)])

names(sis_hos_2018_3)

inp_var <- sis_hos_2018_3[c("Proporción sueldos", "Mesas de partos", 
                            "Salas de quirófanos","Personal Operativo")]

out_var <- sis_hos_2018_3[c("Partos por cesárea", "Partos vaginales",
                            "Total de cirugías realizadas (Sin incluir partos y cesáreas)")]

modelo1 <- dea(XREF = inp_var, YREF = out_var, 
               X=inp_var[,], Y=out_var[,],
               model = "input", RTS = "constant")

resultados6 <- cbind(round(modelo1$thetaOpt,4), round(modelo1$lambda,4))
rownames(resultados6) <- sis_hos_2018_3[[1]]
colnames(resultados6) <- c("Eficiencia", rownames(resultados6))

resultados6 <- as.data.frame(resultados6)


# Resultados --------------------------------------------------------------
setwd("C:/Users/santiago.ortizo/OneDrive - Universidad del rosario/Trabajo PR/DEA/Resultados")

write_xlsx(resultados1, path = "resultados1.xlsx")
write_xlsx(resultados2, path = "resultados2.xlsx")
write_xlsx(resultados3, path = "resultados3.xlsx")
write_xlsx(resultados4, path = "resultados4.xlsx")
write_xlsx(resultados5, path = "resultados5.xlsx")
write_xlsx(resultados6, path = "resultados6.xlsx")
