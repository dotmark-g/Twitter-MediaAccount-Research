
tst <- readRDS("./TweetDF/media-2019-11-20.rds")

MediaTweets <- data.frame()

for (i in 20:27) {
  q <- paste0("./TweetDF/media-2019-11-", i, ".rds")
  tempTw <- readRDS(file = q)
  MediaTweets <- rbind.data.frame(MediaTweets, tempTw)
}

MediaReplies <- data.frame()
for (i in 20:27) {
  q <- paste0("./TweetDF/reply-2019-11-", i, ".rds")
  tempTw <- readRDS(file = q)
  MediaReplies <- rbind.data.frame(MediaReplies, tempTw)
}

mutate(MediaDateDF, tweetAmount = )

MediaDateDF <- select(MediaTweets,
                      screen_name,
                      created_at,
                      text,
                      fav = favorite_count,
                      RTs = retweet_count,
                      URL = urls_expanded_url)
MediaDateDF <- mutate(MediaDateDF, created_at = as.Date(created_at))

mediainfo %>% mutate(tweetsAmount = )

tempCountsList <- vector()


for (i in 1:6) {
  MediaDateDF %>% filter(created_at == queryDate, .keep_all = TRUE)
  
}

MediaDateList <- select(medialist, Name = V1)
tempCountsList <- vector()
queryDate <-  as.Date(c("2019-11-20"))


for (t in 1:7) {
  for (i in 1:150) {
    tempCountsVec <- sum(MediaDateDF$screen_name == medialist$V1[i] &
                           MediaDateDF$created_at == queryDate)
    tempCountsList <- c(tempCountsList, tempCountsVec) }
  
  tempColName <- strftime(queryDate, format="%Y%m%d")
  tempCountsDF <- data.frame(tempCountsList)
  colnames(tempCountsDF) <- tempColName
  
  MediaDateList <- cbind.data.frame(MediaDateList, tempCountsDF)
  
  queryDate <- queryDate + 1
  tempCountsList <- vector()
}












