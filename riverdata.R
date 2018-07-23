library(httr)
library(jsonlite)
library(tidyverse)
library(lubridate)
source("helpers.R")

# Import Entrance Data by Entrance ID---------------------------------

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

# Import user permit data by entrance ID---------------------
#THis service has been deprecated in 2018. Need to figure out how to get past the 1000 record limit
# hist<-list()
# 
# for (i in ids) {
#   
#   call2<-paste0(pathEntID,"/",i,"/historicalreservations/","?apikey=",key)
#   
#   entHist<-GET(call2, authenticate(usr,pwd, type = "basic"))
#   
#   entHist_text<-content(entHist, "text")
#   
#   entHist_json<-fromJSON(entHist_text, flatten = TRUE)
#   
#   hist[[i]]<-entHist_json
#   
# }
# 
# rvrHist<-do.call(rbind,hist)
# rvrHist<-as.data.frame(rvrHist)


# Download reservation data and combine CSV files
# The REST API for these data is depreceated. ZIP files of CSV files were downloaded manually
# files<-list.files("./data",full.names = TRUE)
# rvrData<-data.frame()
# 
# for (i in files) {
#   
#   useData<-read.csv(i,stringsAsFactors = FALSE)
#   useData$EntityID<-as.character(useData$EntityID)
#   
#   dat<-useData %>% 
#     filter(EntityID %in% ids, EntityType=='Entrance') %>% 
#     select(Park,EntityID,FacilityID,CustomerState,StartDate)
#   
#   rvrData<-rbind(rvrData,dat)
#   
# }
# 
# 
# write.csv(rvrData,"./data/rvrData.csv", row.names = FALSE)

# Import hydrology time series data --------------------------------------------------

hcallMF<-"https://waterservices.usgs.gov/nwis/dv/?format=json&sites=13309220&startDT=2010-01-01&endDT=2018-07-23&statCd=00003&siteStatus=all"

hGet<-GET(hcallMF)

hGet_text<-content(hGet, "text")

hGet_json<-fromJSON(hGet_text, flatten = TRUE)

hGet_json<-hGet_json$value

hGet_json <- lapply(hGet_json, function(x) {
  x[sapply(x, is.null)] <- NA
  unlist(x)
})


mfData<-as.data.frame(t(do.call(rbind,hGet_json)))





#Analyze the data-----------------------------------------
rawData<-read.csv('./data/rvrData.csv',stringsAsFactors = FALSE)
rvrData<-rawData
#Clean dates
newdates<-strptime(rvrData$StartDate,format='%Y-%m-%d')
rvrData$StartDate<-as.POSIXct(newdates)

#Make variables
rvrData$Month<-month(rvrData$StartDate,label=TRUE,abbr=FALSE)
rvrData$Day<-wday(rvrData$StartDate, label = TRUE, abbr = FALSE)
rvrData$Year<-year(rvrData$StartDate)

#Plots
g<-ggplot(rvrData,aes(Month))+
  geom_bar()+
  facet_wrap(~Park,scales='free')
g

g<-ggplot(rvrData,aes(Day))+
  geom_bar()+
  facet_wrap(~Park,scales='free')
g

g<-ggplot(rvrData,aes(Day))+
  geom_bar()+
  facet_wrap(~Month)
g





