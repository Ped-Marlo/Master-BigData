# Ejercicio A --------------------------------------------------------------
X <- c(1,2,3,1,4,5,2)
Y <- c(0,3,2,0,5,9,3)
df<- data.frame(X,Y)
df<-unique(df)
row.names(df)<-c("CA", "SE", "MA", "BA", "VA")

df$Z<-(df$X+df$Y)/df$X
df$costa<-factor(c('s','s','n','s','n'))
sapply(df,class)

yy_new<-df[df$Y<4]

# Ejercicio B --------------------------------------------------------------

url <- "http://archive.ics.uci.edu/ml/machine-learning-databases/autos/imports-85.data"
datos<- read.csv(url,na.strings = '?')
summary(datos)
Shape<-dim(datos)
tipos<-sapply(datos, class)
tipos
factor<-datos[sapply(datos,class)=='factor']

# nans<-sapply(datos,)

min(datos[,1])
max(datos[,1])
datos[,1]<-datos[,1]-min(datos[,1])
datos[,1]
names(datos)[names(datos) == "alfa.romero"] <- "brand"
