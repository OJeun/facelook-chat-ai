// Define the structure for individual messages
interface redisMessage {
  id: string;
  groupId: string;
  senderId: string;
  senderName: string;
  content: string;
}

interface redisMessageWithTimeStamp extends redisMessage {
  createdAt: string;
}

interface messagesFromDB {
  chatId: string;
  groupId: number;
  senderId: string;
  senderName: string;
  message: string;
  createdAt: Date;
}

interface Message {
  message: string;
  userId: string;
  messageId: string;
}

interface UserSentimentScore {
  score: number; // 1-10
  userId: string;
}

interface UserSentimentScoreWithAchievementScore extends UserSentimentScore {
  score: number; // 1-10
  userId: string;
  achievementScore: number;
}

// Define the structure for the entire chat, this chat model is target for sentiment analysis which has all data ai needs
interface Chat {
  id: number;
  messages: Message[];
  sentimentScores: UserSentimentScore[];
}

interface AiResult {
  chatId: string;
  sentimentScores: UserSentimentScore[];
}

interface AnalysisResult {
  chatId: string;
  sentimentScores: UserSentimentScoreWithAchievementScore[];
}

interface FullAnalysisResult extends AnalysisResult {
  emojis: EmojiGenerationResult[];
}

interface AddAchievementScore {
  userId: string;
  score: number;
}

interface EmojiGenerationResult {
  emoji: string;
  userId: string;
}

interface EmojiWithMessageId extends EmojiGenerationResult {
  messageId: string;
}

export {
  Chat,
  redisMessage,
  AnalysisResult,
  AddAchievementScore,
  EmojiGenerationResult,
  FullAnalysisResult,
  EmojiWithMessageId,
  UserSentimentScoreWithAchievementScore,
  UserSentimentScore,
  AiResult,
  redisMessageWithTimeStamp,
  messagesFromDB,
};
