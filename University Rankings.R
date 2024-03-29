## We will be installing the following packages
install.packages("mice")
install.packages("VIM")
install.packages("corrgram")
install.packages("corrplot")
install.packages("ggplot2")
install.packages("outliers")
install.packages("car")

## Below are the libraries which are loaded
library("mice")
library("VIM")
library("corrgram")
library("corrplot")
library("outliers")
library("car")
library("ggplot2")

## Uploading the data
getwd()
setwd("C:/Users/gidda/Desktop/Stats Final Project")
ur = read.csv("Rankings_New.csv", header=T)

## Change Columns to nymeric
ur$income = sub('-',' ',ur$income)
ur$income = as.numeric(as.character(ur$income))
ur$num_students = gsub(',','',ur$num_students)
ur$num_students = as.numeric(as.character(ur$num_students))
ur$international_students = as.numeric(as.character(gsub('%','',ur$international_students)))
colnames(ur)[colnames(ur)=="X._Female_Students"] <- "Female_Students"
colnames(ur)[colnames(ur)=="�..world_rank"] <- "World_rank"

##Missing Data Analysis
pMiss <- function(x){sum(is.na(x))/length(x)*100}
apply(ur,1,pMiss)
apply(ur,2,pMiss)

## Below gives a clear image of missing data
md.pattern(ur)

## Checking missing values again
sapply(ur, function(x) sum(is.na(x)))

aggr_plot <- aggr(ur, col=c('navyblue','red'), numbers=TRUE, sortVars=TRUE, labels=names(ur), cex.axis=.7, gap=3, ylab=c("Histogram of missing data","Pattern"))

## Data imputation
tempData <- mice(ur,m=5,meth='cart')
sapply(training_set, function(x) sum(is.na(x)))
modelFit2 <- with(tempData, lm(total_score~research+citations+international+income))
summary(modelFit2)
train_complete <- complete(tempData,"long")
training_set = train_complete[(1:150),]
test_set = train_complete[(150:200),]

## Outlier Detection
outlier(rank_model[,4:13])

## Correlation plot of newly imputed data
q = as.matrix(training_set[,c(3,6:15)])
corrplot(cor(q), method = "number", number.cex=0.75, is.corr = FALSE)

par(mfrow=c(2,2))
plot(training_set, col="blue", main="Matrix Scatterplot of all the independent variables")
ggpairs(training_set[,c(3,6:15)])

## Building different models
rank_model = lm(World_rank~research+citations+international+teaching+total_score+Female_Students+student_staff_ratio+international_students+num_students+income, data=training_set)
summary(rank_model)
rank_model = lm(World_rank~research+citations+international+income, data=training_set)
summary(rank_model)
rank_model = lm(total_score~research+international+Female_Students+student_staff_ratio, data=training_set)
summary(rank_model)
rank_model = lm(total_score~research+citations+international+income, data=training_set)
summary(rank_model)
rank_model = lm(total_score~research+citations+international+income+Female_students+student_staff_ratio, data=training_set)
summary(rank_model)
par(mfrow=c(2,2))
plot(rank_model)

## Predictions for data
predict (rank_model, test_set)

## Assumptions for Multiple Linear Regression

## Linearity
plot(fitted(rank_model), residuals(rank_model))
abline(0,1, col="blue", lwd=2)

## Equality
plot(fitted(rank_model), residuals(rank_model))
abline(0,1, col="blue", lwd=2)

## Independence 
durbinWatsonTest(rank_model)

##Normality
hist(rank_model$residuals, main ="Histogram of residuals")
qqPlot(rank_model, main="QQ Plot")

## Multi Collinearity
vif(rank_model)

## Residuals
layout(matrix(c(1,2,3,4), 2, 2, byrow = TRUE))
qqnorm(rank_model$residuals)
plot(rank_model$fitted.values,rank_model$residuals,main="Fitted Value vs Residuals",xlab="Fitted Values",ylab="Residuals",col="red")
hist(rank_model$residuals,col="orange",main = "Histogram of Residuals")
plot(training_set$total_score,rank_model$residuals,main="Observations vs Residuals",xlab="Observations",ylab="Residuals",col="blue")

## Ordinal Regression
library("ordinal")
library("MASS")
str(ur)
training_set = train_complete[(1:30),]
training_set = training_set[,c(3,6:15)]
training_set$World_rank = as.factor (training_set$World_rank)
training_set$World_rank <- ordered (training_set$World_rank, levels = c(30:1))

model <- polr(World_rank~research+citations+income,training_set, Hess = TRUE)
summary(model)

## Getting Co-efficients
(ctable = coef(summary(model)))
p <- pnorm(abs(ctable[, "t value"]), lower.tail = FALSE) * 2
(ctable <- cbind(ctable, "p value" = p))

## Confidence Intervals
(ci <- confint(model))

(exp(coef(model)))
exp(cbind(OR = coef(model), ci))
pred <- predict(model, training_set)
print(pred, digits = 3)


