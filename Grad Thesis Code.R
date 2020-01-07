library(tidyverse)
library(rtweet)
library(xlsx)

#保存してあるツイートデータの読み込み
MediaTweetReply <- readRDS("./outputDF/MediaTweetDF.rds")

#RT・“いいね!”・リプライ数の標準化
MediaTweetReply %<>% mutate(St.RT = scale(retweet_count / followers_count),
                            St.Fav = scale(favorite_count / followers_count),
                            St.Reply  = scale(replyAmount / followers_count))

#各種カテゴリー因子との結合
MediaNamesList <- read.xlsx("./MediaNamesList.xlsx", 1)
MediaTweetReply %<>% left_join(MediaNamesList, by = "screen_name")

#重回帰分析
lmDF<- lm(St.Reply ~ (St.RT + maincategory)^2 + paid + dependent + include_delivery + domicile  , data = MediaTweetReply)
summary(lmDF)


#以下リプライの感情分析

#形態素解析・感情値代入済みのデータを読み込む
maResultDF <- readRDS("./outputDF/maResultDF.rds")
maResultDF %<>% left_join(MediaNamesList, by = c("target" = "screen_name"))
maResultDF %<>% ungroup()

maResultDF %>% mutate(Std.Emotion = scale(Emotion_Value), Std.Term = scale(Term_Count)) -> Std.maResult

#感情値について、重回帰分析をおこなう
summary(lm(formula = Emotion_Value ~ Term_Count * (maincategory + paid + dependent + include_delivery + domicile), data = Std.maResult))


#形態素数と感情値の密度分布を描画する
maResultDF %>% ggplot() +
  geom_density2d(aes(x = Term_Count, y = Emotion_Value))


#形態素数の密度曲線を描画する
maResultDF %>%
  mutate(hard = ifelse(maincategory %in% c("economy", "general", "local"),
                       "hard", "other")) %>% 
  ggplot() +
  geom_density(aes(x = Term_Count, fill = hard, alpha = 0.5))


