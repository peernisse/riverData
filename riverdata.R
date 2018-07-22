library(httr)
library(jsonlite)
library(tidyverse)
source("helpers.R")

# Import Data by Entrance ID---------------------------------

myList<-list()

for (i in ids) {
  
  call1<-paste0(pathEntID,"/",i,"?apikey=",key)
  
  entIDs<-GET(call1, authenticate(usr,pwd, type = "basic"))
  
  entIDs_text<-content(entIDs, "text")
  
  entIDs_json<-fromJSON(entIDs_text, flatten = TRUE)
  
  myList[[i]]<-entIDs_json
  
}

entLocs<-do.call(rbind,myList)
entLocs<-as.data.frame(entLocs) %>% 
  select(12,7,13,8,14,3,2,6)







