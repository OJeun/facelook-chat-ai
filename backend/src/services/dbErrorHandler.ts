export const errorHandler = (error: any, reply: any) => {
  console.error("error:", error);

  if (error.backendMessage) {
    error.message = error.backendMessage;
  }

  reply
    .code(error?.response?.status || 500)
    .send(error?.response?.data || error.message);
};
