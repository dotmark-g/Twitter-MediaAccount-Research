library(tidyverse)
library(rtweet)

targetlist <- read.csv("medialist.csv")
targetlist <- as.vector(targetlist$V1)

tempfrom <- Sys.Date()-5
tempto <- Sys.Date()-4

TweetDF <- data.frame()

for (i in 1:length(targetlist)) {
  q <- paste0("from:", targetlist[i], ", since:", tempfrom,
              ", until:", tempto, " -filter:replies")
  temptweetDF <- search_tweets(q, n = 300, include_rts = FALSE, retryonratelimit = TRUE)
  TweetDF <- rbind.data.frame(TweetDF, temptweetDF)
  print(paste0(i, "/", length(targetlist), " ", targetlist[i], " Ended!"))
  if(i %% 10 == 0){print(paste0("Now ", nrow(TweetDF), " Tweets Collected!"))}
}

filetitle <- paste0("./TweetDF/media-", tempfrom, ".rds")
saveRDS(TweetDF, file = filetitle)

print("Mediatweet Collected.")

#getreply start

TweetDF <- data.frame()

for (i in 1:length(targetlist)) {
  q <- paste0("to:", targetlist[i], ", since:", tempfrom,
              ", until:", tempto)
  temptweetDF <- search_tweets(q, n = 5000, include_rts = FALSE, retryonratelimit = TRUE)
  TweetDF <- rbind.data.frame(TweetDF, temptweetDF)
  print(paste0(nrow(temptweetDF)," Tweets Collected. " ,i, "/", length(targetlist), " ", targetlist[i], " Ended!"))
  if(i %% 10 == 0){print(paste0("Now ", nrow(TweetDF), " Tweets Collected!"))}
}

filetitle <- paste0("./TweetDF/reply-", tempfrom, ".rds")
saveRDS(TweetDF, file = filetitle)

print("Scraping Ended!")
