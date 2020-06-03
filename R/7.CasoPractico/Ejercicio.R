# install.packages("MASS")
# install.packages("missForest")

library(plyr)
library(dplyr)
library(ggplot2)
library(missForest)

createDF<- function(file)
  {
  datos<-read.csv(file,header=FALSE,dec=",")
  summary(datos)
  str(datos)
  datos$binAproved<-mapvalues(datos$V16,from=c('+',"-"), to=c(1,0))
  datos$V16<-NULL
  #Transform numeric "char" variables to float
  datos$V2<-as.double(datos$V2)
  datos$V3<-as.double(datos$V3)
  datos$V8<-as.double(datos$V8)
  datos$V14<-as.integer(datos$V14)
  str(datos)
  
  caracteres<- names(datos[, sapply(datos, class) == 'character'])
  objetivo<-tail(caracteres,1)
  carac<- caracteres[!caracteres %in% objetivo]
  
  continuo<-names(datos[, sapply(datos, class) == 'numeric'])
  integ<-names(datos[, sapply(datos, class) == 'integer'])
  numeros<-append(continuo,integ)
  
   for (columna in colnames(datos)){
     if (class(datos[,columna])=="character"){
       datos[,columna]<-factor(datos[,columna])
     }
   }
      
  
  for (var in carac)
  { plot<-ggplot(data=datos ) +
    geom_bar(aes_string(x=toString(var),fill=objetivo),position = "dodge")
    print(plot)
  }
  for (num in numeros){
    plot<-ggplot(data=datos ) +
    geom_density(aes_string(x=toString(num),fill=objetivo),alpha=0.5)
    geom_histogram(aes_string(x=toString(num),fill=objetivo),alpha=0.5)
   print(plot)
  }
  print(ggplot(data=datos ) +
    geom_histogram(aes(x=V15,fill=binAproved),position = "dodge",bins=30))
  print(ggplot(data=datos ) +
    geom_histogram(aes(x=V11,fill=binAproved),position = "dodge",bins=30))
  return(datos)
}

#####      
# input missing values
help(missForest)

datos<-createDF("CASO_FINAL_crx.data")
datos[datos=="?"]<-NA
#replacement of NaN
datosFilled<-(missForest(xmis = datos,replace=FALSE))

#rough train_test_split
train<-as.data.frame(datosFilled[1])[1:590,]
test<-as.data.frame(datosFilled[1])[-(590:1),]

############## 
#Model generation
library(MASS)
# install.packages(c("e1071", "caret", "e1071"))
library(caret)
library(ggplot2)
library(lattice)
library(e1071)
X_train<- data.matrix(subset(train, select= - ximp.binAproved))
y_train<- train$ximp.binAproved

X_test<- data.matrix(subset(test, select= - ximp.binAproved))
y_test<- test$ximp.binAproved

library(pROC)
library(glmnet)
set.seed(555)



#######
#Ridge
cv.ridge <- cv.glmnet(X_train, y_train, family='binomial', alpha=0, parallel=TRUE, standardize=TRUE, type.measure='mse')
# Resultados
plot(cv.ridge)
#este es el mejor valor de lambda
cv.ridge$lambda.min
#este es el valor del error que se estima para ese valor lambda mínimo dado en MSE
min(cv.ridge$cvm)
coefs.Ridge<-coef(cv.ridge, s=cv.ridge$lambda.min)

y_pred_Ridge <- as.numeric(predict.glmnet(cv.ridge$glmnet.fit, newx=X_test, s=cv.ridge$lambda.min)>.5)

RidgeConfundido<-confusionMatrix(as.factor(y_test), as.factor(y_pred_Ridge), mode="everything")

RidgeAuc<-auc(y_test, y_pred_Ridge)

logs_odds_ratio_R<-exp(coef(cv.ridge))
print(logs_odds_ratio_R)

######
###Lasso
cv.lasso <- cv.glmnet(X_train, y_train, family='binomial', alpha=1, parallel=TRUE, standardize=TRUE, type.measure='mse')
# Resultados
plot(cv.lasso)
#este es el mejor valor de lambda
cv.lasso$lambda.min
#este es el valor del error que se estima para ese valor lambda mínimo dado en MSE
min(cv.lasso$cvm)
coefs.lasso<-coef(cv.lasso, s=cv.ridge$lambda.min)
print(coefs.lasso )
y_pred_lasso <- as.numeric(predict.glmnet(cv.lasso$glmnet.fit, newx=X_test, s=cv.ridge$lambda.min)>.5)


# print(LassoConfundido)
LassoAuc<-auc(y_test, y_pred_lasso)
print(LassoAuc)
logs_odds_ratio_L<-exp(coef(cv.lasso))
print(logs_odds_ratio_L)


#mejor metrica con lasso (auc=)0,77) vs Ridge(auc=0.71)
#6 TP=+100 FP=-20----Using ConfusionMatrix
LassoConfundido<-confusionMatrix(as.factor(y_test), as.factor(y_pred_lasso), mode="everything")
print(LassoConfundido)

TP<-LassoConfundido$table[4]
FP<-LassoConfundido$table[2]



Earnings<-TP*100-FP*20

#segun este modelo ( que no ha sido muestreado de forma estadisticamente representativo,)
#habrian 8 aprobados reales(800e) y 6 aprobados falsos(-120e), por lo tanto tendriamos 680e de beneficio
#por cada 100 personas




#Comments on variables based on the difference in aproved/not
# V15 doesn't affect much the output..except when it goes far from 0||Outliers
# V14  almost doesn't have an impact
# v13 v12  almost almost doesn't affect
# V11 has  couple outliers and as it increases affects the output
# v10 has an relative impact
# V9 has a strong impact
# V8 has a strong impact
# V7 & v6 almost does not have an impact
# v5 & v4 & v1 almost not significant and have empty values "?"
# V3 has an impact but not too strong
# V2 almost almost doesn't affect

