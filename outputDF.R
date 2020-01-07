library(tidyverse)
library(stringr)
library(magrittr)

setwd("C:/Users/Tomoya/Documents/R/mongodbTest")

#RDSファイル読み込み

#ファイル一覧読み込み(media)
mediafilesList <- list.files("./TweetDF/", pattern = "^media.*$", full.names = TRUE)

mediatweetDF <- data.frame()
for (i in 1:length(mediafilesList)) {
  tempmediaDF <- readRDS(mediafilesList[i])
  mediatweetDF <- rbind.data.frame(mediatweetDF, tempmediaDF)
}

#ファイル一覧読み込み(reply)
replyfilesList <- list.files("./TweetDF/", pattern = "^reply.*$", full.names = TRUE)

replytweetDF <- data.frame()
for (i in 1:length(replyfilesList)) {
  tempreplyDF <- readRDS(replyfilesList[i])
  replytweetDF <- rbind.data.frame(replytweetDF, tempreplyDF)
}

#　重複行の削除
replytweetDF %<>% distinct(screen_name, status_id, .keep_all=TRUE)

print("readRDS Ended.")

#created_timeが標準時のため、日本時間から9時間ズレているため修正
mediatweetDF %<>% mutate(created_at = created_at + 60*60*9)
replytweetDF %<>% mutate(created_at = created_at + 60*60*9)

#mediaDFを整理 -> MediaTweetDF

mediatweetDF %>% select(created_at,
                        screen_name,
                        text,
                        status_id,
                        favorite_count,
                        retweet_count,
                        urls_expanded_url,
                        following = friends_count,
                        followers_count) -> mediatweetCleanedDF
mediatweetCleanedDF %<>% mutate(date = as.Date(created_at))

#ReplyDFを整理 ->ReplyTweetDF

replytweetDF %>% select(created_at,
                        target = reply_to_screen_name,
                        reply_to_status_id,
                        fromuser = screen_name,
                        text,
                        favorite_count,
                        retweet_count,
                        urls_expanded_url,
                        status_id) -> replytweetCleanedDF
replytweetCleanedDF %<>% mutate(date = as.Date(created_at))

print("Cleansing DataFrame Ended.")

#リプライ数をMediaTweetDFに付与する
replytweetCleanedDF %>% 
  group_by(target, reply_to_status_id) %>%
  summarise(replyAmount = n()) -> ReplyAmountDF
mediatweetCleanedDF %<>% 
  left_join(ReplyAmountDF, by = c("screen_name" = "target", "status_id" = "reply_to_status_id"))
mediatweetCleanedDF %<>% mutate(replyAmount = replace_na(replyAmount, FALSE))

print("ReplyAmount Connected.")

#TweetDF出力
DFtime <- Sys.Date() -5
saveRDS(mediatweetCleanedDF, file = paste0("./outputDF/MediaTweetDF.rds"))
saveRDS(replytweetCleanedDF, file = paste0("./outputDF/ReplyTweetDF.rds"))

print("saveRDS Ended.")
