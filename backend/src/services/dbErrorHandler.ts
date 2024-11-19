export const errorHandler = (error: any, reply: any) => {
  console.error("error:", error);
  reply
    .code(error?.response?.status || 500)
    .send(error?.response?.data || error.message);
};
