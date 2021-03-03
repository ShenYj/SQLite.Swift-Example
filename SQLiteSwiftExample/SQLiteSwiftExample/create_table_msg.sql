
-- 创建表 t_message --
CREATE TABLE IF NOT EXISTS "t_message" (
    "primary_key" INTEGER PRIMARY KEY,
    "message_code" TEXT UNIQUE,
    "message_title" TEXT,
    "message_detail" TEXT,
    "message_unread" Boolean,
    "system_time" TEXT DEFAULT (datetime('now','localtime'))
);
