// Define the structure for individual messages
interface redisMessage {
  chatId: string;
  groupId: string;
  senderId: string;
  senderName: string;
  message: string;
}

interface redisMessageWithTimeStamp extends redisMessage {
  createdAt: string;
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
  emojis: EmojiWithMessageId[];
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

interface AiAnalysisResult {
  chatId: string;
  analysisResult: FullAnalysisResult;
  timestamp: string; // Timestamp when the analysis was performed
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
  AiAnalysisResult,
};
