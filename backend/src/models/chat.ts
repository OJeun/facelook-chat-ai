// Define the structure for individual messages
interface Message {
  groupId: string;
  senderId: string;
  message: string;
}

interface MessageWithTimestamp extends Message {
  createdAt: string;
}

interface UserSentimentScore {
  score: number; // 1-10
  userId: string;
}

// Define the structure for the entire chat, this chat model is target for sentiment analysis which has all data ai needs
interface Chat {
  id: number;
  messages: Message[];
  sentimentScores: UserSentimentScore[];
}

interface AnalysisResult {
  chatId: string;
  addAchievementScores: AddAchievementScore[];
  sentimentScores: UserSentimentScore[];
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

export {
    Chat,
    Message,
    AnalysisResult,
    AddAchievementScore,
    EmojiGenerationResult,
    FullAnalysisResult,
    MessageWithTimestamp,
};
